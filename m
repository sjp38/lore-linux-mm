Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC5D6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 15:09:54 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so185042094pac.3
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 12:09:53 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id qy7si29992646pab.169.2015.11.16.12.09.53
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 12:09:53 -0800 (PST)
Date: Mon, 16 Nov 2015 13:09:50 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 03/11] pmem: enable REQ_FUA/REQ_FLUSH handling
Message-ID: <20151116200950.GB9737@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-4-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4j4arHE+iAALn1WPDzSb_QSCDy8udtXU1FV=kYSZDfv8A@mail.gmail.com>
 <22E0F870-C1FB-431E-BF6C-B395A09A2B0D@dilger.ca>
 <CAPcyv4jwx3VzyRugcpH7KCOKM64kJ4Bq4wgY=iNJMvLTHrBv-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jwx3VzyRugcpH7KCOKM64kJ4Bq4wgY=iNJMvLTHrBv-Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andreas Dilger <adilger@dilger.ca>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, Nov 13, 2015 at 06:32:40PM -0800, Dan Williams wrote:
> On Fri, Nov 13, 2015 at 4:43 PM, Andreas Dilger <adilger@dilger.ca> wrote:
> > On Nov 13, 2015, at 5:20 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> >>
> >> On Fri, Nov 13, 2015 at 4:06 PM, Ross Zwisler
> >> <ross.zwisler@linux.intel.com> wrote:
> >>> Currently the PMEM driver doesn't accept REQ_FLUSH or REQ_FUA bios.  These
> >>> are sent down via blkdev_issue_flush() in response to a fsync() or msync()
> >>> and are used by filesystems to order their metadata, among other things.
> >>>
> >>> When we get an msync() or fsync() it is the responsibility of the DAX code
> >>> to flush all dirty pages to media.  The PMEM driver then just has issue a
> >>> wmb_pmem() in response to the REQ_FLUSH to ensure that before we return all
> >>> the flushed data has been durably stored on the media.
> >>>
> >>> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> >>
> >> Hmm, I'm not seeing why we need this patch.  If the actual flushing of
> >> the cache is done by the core why does the driver need support
> >> REQ_FLUSH?  Especially since it's just a couple instructions.  REQ_FUA
> >> only makes sense if individual writes can bypass the "drive" cache,
> >> but no I/O submitted to the driver proper is ever cached we always
> >> flush it through to media.
> >
> > If the upper level filesystem gets an error when submitting a flush
> > request, then it assumes the underlying hardware is broken and cannot
> > be as aggressive in IO submission, but instead has to wait for in-flight
> > IO to complete.
> 
> Upper level filesystems won't get errors when the driver does not
> support flush.  Those requests are ended cleanly in
> generic_make_request_checks().  Yes, the fs still needs to wait for
> outstanding I/O to complete but in the case of pmem all I/O is
> synchronous.  There's never anything to await when flushing at the
> pmem driver level.
> 
> > Since FUA/FLUSH is basically a no-op for pmem devices,
> > it doesn't make sense _not_ to support this functionality.
> 
> Seems to be a nop either way.  Given that DAX may lead to dirty data
> pending to the device in the cpu cache that a REQ_FLUSH request will
> not touch, its better to leave it all to the mm core to handle.  I.e.
> it doesn't make sense to call the driver just for two instructions
> (sfence + pcommit) when the mm core is taking on the cache flushing.
> Either handle it all in the mm or the driver, not a mixture.

Does anyone know if ext4 and/or XFS alter their algorithms based on whether
the driver supports REQ_FLUSH/REQ_FUA?  Will the filesystem behave more
efficiently with respect to their internal I/O ordering, etc., if PMEM
advertises REQ_FLUSH/REQ_FUA support, even though we could do the same thing
at the DAX layer?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
