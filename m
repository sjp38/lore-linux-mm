Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 16BA06B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:06:15 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id q3so81946118pav.3
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:06:15 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id v80si11172753pfa.245.2015.12.21.09.06.13
        for <linux-mm@kvack.org>;
        Mon, 21 Dec 2015 09:06:14 -0800 (PST)
Date: Mon, 21 Dec 2015 10:05:45 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v5 4/7] dax: add support for fsync/sync
Message-ID: <20151221170545.GA13494@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450502540-8744-5-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4irspQEPVdYfLK+QfW4t-1_y1gFFVuBm00=i03PFQwEYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4irspQEPVdYfLK+QfW4t-1_y1gFFVuBm00=i03PFQwEYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Sat, Dec 19, 2015 at 10:37:46AM -0800, Dan Williams wrote:
> On Fri, Dec 18, 2015 at 9:22 PM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > To properly handle fsync/msync in an efficient way DAX needs to track dirty
> > pages so it is able to flush them durably to media on demand.
> >
> > The tracking of dirty pages is done via the radix tree in struct
> > address_space.  This radix tree is already used by the page writeback
> > infrastructure for tracking dirty pages associated with an open file, and
> > it already has support for exceptional (non struct page*) entries.  We
> > build upon these features to add exceptional entries to the radix tree for
> > DAX dirty PMD or PTE pages at fault time.
> >
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> [..]
> > +static void dax_writeback_one(struct address_space *mapping, pgoff_t index,
> > +               void *entry)
> > +{
> > +       struct radix_tree_root *page_tree = &mapping->page_tree;
> > +       int type = RADIX_DAX_TYPE(entry);
> > +       struct radix_tree_node *node;
> > +       void **slot;
> > +
> > +       if (type != RADIX_DAX_PTE && type != RADIX_DAX_PMD) {
> > +               WARN_ON_ONCE(1);
> > +               return;
> > +       }
> > +
> > +       spin_lock_irq(&mapping->tree_lock);
> > +       /*
> > +        * Regular page slots are stabilized by the page lock even
> > +        * without the tree itself locked.  These unlocked entries
> > +        * need verification under the tree lock.
> > +        */
> > +       if (!__radix_tree_lookup(page_tree, index, &node, &slot))
> > +               goto unlock;
> > +       if (*slot != entry)
> > +               goto unlock;
> > +
> > +       /* another fsync thread may have already written back this entry */
> > +       if (!radix_tree_tag_get(page_tree, index, PAGECACHE_TAG_TOWRITE))
> > +               goto unlock;
> > +
> > +       radix_tree_tag_clear(page_tree, index, PAGECACHE_TAG_TOWRITE);
> > +
> > +       if (type == RADIX_DAX_PMD)
> > +               wb_cache_pmem(RADIX_DAX_ADDR(entry), PMD_SIZE);
> > +       else
> > +               wb_cache_pmem(RADIX_DAX_ADDR(entry), PAGE_SIZE);
> 
> Hi Ross, I should have realized this sooner, but what guarantees that
> the address returned by RADIX_DAX_ADDR(entry) is still valid at this
> point?  I think we need to store the sector in the radix tree and then
> perform a new dax_map_atomic() operation to either lookup a valid
> address or fail the sync request.  Otherwise, if the device is gone
> we'll crash, or write into some other random vmalloc address space.

Ah, good point, thank you.  v4 of this series is based on a version of
DAX where we aren't properly dealing with PMEM device removal.  I've got an
updated version that merges with your dax_map_atomic() changes, and I'll add
this change into v5 which I will send out today.  Thank you for the
suggestion.

One clarification, with the code as it is in v4 we are only doing
clflush/clflushopt/clwb instructions on the kaddr we've stored in the radix
tree, so I don't think that there is actually a risk of us doing a "write into
some other random vmalloc address space"?  I think at worse we will end up
clflushing an address that either isn't mapped or has been remapped by someone
else.  Or are you worried that the clflush would trigger a cache writeback to
a memory address where writes have side effects, thus triggering the side
effect?

I definitely think it needs to be fixed, I'm just trying to make sure I
understood your comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
