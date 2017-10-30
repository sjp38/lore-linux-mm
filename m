Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6A726B0253
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 04:47:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q196so5745751wmg.15
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 01:47:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y204si2618558wme.125.2017.10.30.01.47.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Oct 2017 01:47:43 -0700 (PDT)
Date: Mon, 30 Oct 2017 09:38:07 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 00/13] dax: fix dma vs truncate and remove 'page-less'
 support
Message-ID: <20171030083807.GA23278@quack2.suse.cz>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020074750.GA13568@lst.de>
 <20171020093148.GA20304@lst.de>
 <20171026105850.GA31161@quack2.suse.cz>
 <CAA9_cmeiT2CU8Nue-HMCv+AyuDmSzXoCVxD1bebt2+cBDRTWog@mail.gmail.com>
 <20171030020023.GG3666@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171030020023.GG3666@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@gmail.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "J. Bruce Fields" <bfields@fieldses.org>, linux-mm <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Sean Hefty <sean.hefty@intel.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Doug Ledford <dledford@redhat.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi,

On Mon 30-10-17 13:00:23, Dave Chinner wrote:
> On Sun, Oct 29, 2017 at 04:46:44PM -0700, Dan Williams wrote:
> > Coming back to this since Dave has made clear that new locking to
> > coordinate get_user_pages() is a no-go.
> > 
> > We can unmap to force new get_user_pages() attempts to block on the
> > per-fs mmap lock, but if punch-hole finds any elevated pages it needs
> > to drop the mmap lock and wait. We need this lock dropped to get
> > around the problem that the driver will not start to drop page
> > references until it has elevated the page references on all the pages
> > in the I/O. If we need to drop the mmap lock that makes it impossible
> > to coordinate this unlock/retry loop within truncate_inode_pages_range
> > which would otherwise be the natural place to land this code.
> > 
> > Would it be palatable to unmap and drain dma in any path that needs to
> > detach blocks from an inode? Something like the following that builds
> > on dax_wait_dma() tried to achieve, but does not introduce a new lock
> > for the fs to manage:
> > 
> > retry:
> >     per_fs_mmap_lock(inode);
> >     unmap_mapping_range(mapping, start, end); /* new page references
> > cannot be established */
> >     if ((dax_page = dax_dma_busy_page(mapping, start, end)) != NULL) {
> >         per_fs_mmap_unlock(inode); /* new page references can happen,
> > so we need to start over */
> >         wait_for_page_idle(dax_page);
> >         goto retry;
> >     }
> >     truncate_inode_pages_range(mapping, start, end);
> >     per_fs_mmap_unlock(inode);
> 
> These retry loops you keep proposing are just bloody horrible.  They
> are basically just a method for blocking an operation until whatever
> condition is preventing the invalidation goes away. IMO, that's an
> ugly solution no matter how much lipstick you dress it up with.
> 
> i.e. the blocking loops mean the user process is going to be blocked
> for arbitrary lengths of time. That's not a solution, it's just
> passing the buck - now the userspace developers need to work around
> truncate/hole punch being randomly blocked for arbitrary lengths of
> time.

So I see substantial difference between how you and Christoph think this
should be handled. Christoph writes in [1]:

The point is that we need to prohibit long term elevated page counts
with DAX anyway - we can't just let people grab allocated blocks forever
while ignoring file system operations.  For stage 1 we'll just need to
fail those, and in the long run they will have to use a mechanism
similar to FL_LAYOUT locks to deal with file system allocation changes.

So Christoph wants to block truncate until references are released, forbid
long term references until userspace acquiring them supports some kind of
lease-breaking. OTOH you suggest truncate should just proceed leaving
blocks allocated until references are released. We cannot have both... I'm
leaning more towards the approach Christoph suggests as it puts the burned
to the place which is causing it - the application having long term
references - and applications needing this should be sufficiently rare that
we don't have to devise a general mechanism in the kernel for this.

If the solution Christoph suggests is acceptable to you, I think we should
first write a patch to forbid acquiring long term references to DAX blocks.
On top of that we can implement mechanism to block truncate while there are
short term references pending (and for that retry loops would be IMHO
acceptable). And then we can work on a mechanism to notify userspace that
it needs to drop references to blocks that are going to be truncated so
that we can re-enable taking of long term references.

								Honza

[1]
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1522887.html

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
