Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA6A6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 10:50:43 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id 78so224724013pfw.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 07:50:43 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id fk10si48971808pab.187.2016.01.05.07.50.42
        for <linux-mm@kvack.org>;
        Tue, 05 Jan 2016 07:50:42 -0800 (PST)
Date: Tue, 5 Jan 2016 08:50:39 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v6 4/7] dax: add support for fsync/msync
Message-ID: <20160105155039.GA6462@linux.intel.com>
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450899560-26708-5-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4jVJGPO8Yhz8WgSJTFw+o8=5n6yx17zchXA6C+wEKcajg@mail.gmail.com>
 <20160105111346.GC2724@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160105111346.GC2724@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Tue, Jan 05, 2016 at 12:13:46PM +0100, Jan Kara wrote:
> On Sun 03-01-16 10:13:06, Dan Williams wrote:
> > On Wed, Dec 23, 2015 at 11:39 AM, Ross Zwisler
> > <ross.zwisler@linux.intel.com> wrote:
> > > To properly handle fsync/msync in an efficient way DAX needs to track dirty
> > > pages so it is able to flush them durably to media on demand.
> > >
> > > The tracking of dirty pages is done via the radix tree in struct
> > > address_space.  This radix tree is already used by the page writeback
> > > infrastructure for tracking dirty pages associated with an open file, and
> > > it already has support for exceptional (non struct page*) entries.  We
> > > build upon these features to add exceptional entries to the radix tree for
> > > DAX dirty PMD or PTE pages at fault time.
> > >
> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > 
> > I'm hitting the following report with the ndctl dax test [1] on
> > next-20151231.  I bisected it to
> >  commit 3cb108f941de "dax-add-support-for-fsync-sync-v6".  I'll take a
> > closer look tomorrow, but in case someone can beat me to it, here's
> > the back-trace:
> > 
> > ------------[ cut here ]------------
> > kernel BUG at fs/inode.c:497!
> 
> I suppose this is the check that mapping->nr_exceptional is zero, isn't it?
> Hum, I don't see how that could happen given we call
> truncate_inode_pages_final() just before the clear_inode() call which
> removes all the exceptional entries from the radix tree.  And there's not
> much room for a race during umount... Does the radix tree really contain
> any entry or is it an accounting bug?
> 
> 								Honza

I think this is a bug with the existing way that we handle PMD faults.  The
issue is that the PMD path doesn't properly remove radix tree entries for zero
pages covering holes.  The PMD path calls unmap_mapping_range() to unmap the
range out of the struct address_space, but it is missing a call to
truncate_inode_pages_range() or similar to clear out those entries in the
radix tree.  Up until now we didn't notice, we just had an orphaned entry in
the radix tree, but with my code we then find the page entry in the radix
tree when handling a PMD fault, we remove it and add in a PMD entry.  This
causes us to be off on both our mapping->nrpages and mapping->nrexceptional
counts.	

In the PTE path we properly remove the pages from the radix tree when
upgrading from a hole to a real DAX entry via the delete_from_page_cache()
call, which eventually calls page_cache_tree_delete().

I'm working on a fix now (and making sure all the above is correct).

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
