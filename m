Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9F8536B005D
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 16:31:33 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] HWPOISON: report sticky EIO for poisoned file
Date: Thu, 23 Aug 2012 16:31:27 -0400
Message-Id: <1345753887-31225-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120823092211.GB12745@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 23, 2012 at 05:22:11PM +0800, Fengguang Wu wrote:
> On Wed, Aug 22, 2012 at 11:17:34AM -0400, Naoya Horiguchi wrote:
> > From: Wu Fengguang <fengguang.wu@intel.com>
> > 
> > This makes the EIO reports on write(), fsync(), or the NFS close()
> > sticky enough. The only way to get rid of it may be
> > 
> > 	echo 3 > /proc/sys/vm/drop_caches
> 
> That's no longer valid with your next patch. If I understand it right,
> the EIO will only go away after truncate.

yes, that's right.

> So it may also need to
> update comments in memory-failure.c and Documentation/vm/hwpoison.txt

OK. I'll add it in the next version.

> > Note that the impacted process will only be killed if it mapped the page.
> > XXX
> > via read()/write()/fsync() instead of memory mapped reads/writes, simply
> > because it's very hard to find them.
>  
> Please remove the above scratched texts.

Yes.

Thanks,
Naoya

> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  include/linux/pagemap.h | 13 +++++++++++++
> >  mm/filemap.c            | 11 +++++++++++
> >  mm/memory-failure.c     |  2 +-
> >  3 files changed, 25 insertions(+), 1 deletion(-)
> > 
> > diff --git v3.6-rc1.orig/include/linux/pagemap.h v3.6-rc1/include/linux/pagemap.h
> > index e42c762..4d8d821 100644
> > --- v3.6-rc1.orig/include/linux/pagemap.h
> > +++ v3.6-rc1/include/linux/pagemap.h
> > @@ -24,6 +24,7 @@ enum mapping_flags {
> >  	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
> >  	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
> >  	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
> > +	AS_HWPOISON	= __GFP_BITS_SHIFT + 4,	/* hardware memory corruption */
> >  };
> >  
> >  static inline void mapping_set_error(struct address_space *mapping, int error)
> > @@ -53,6 +54,18 @@ static inline int mapping_unevictable(struct address_space *mapping)
> >  	return !!mapping;
> >  }
> >  
> > +#ifdef CONFIG_MEMORY_FAILURE
> > +static inline int mapping_hwpoison(struct address_space *mapping)
> > +{
> > +	return test_bit(AS_HWPOISON, &mapping->flags);
> > +}
> > +#else
> > +static inline int mapping_hwpoison(struct address_space *mapping)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
> >  {
> >  	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
> > diff --git v3.6-rc1.orig/mm/filemap.c v3.6-rc1/mm/filemap.c
> > index fa5ca30..8bdaf57 100644
> > --- v3.6-rc1.orig/mm/filemap.c
> > +++ v3.6-rc1/mm/filemap.c
> > @@ -297,6 +297,8 @@ int filemap_fdatawait_range(struct address_space *mapping, loff_t start_byte,
> >  		ret = -ENOSPC;
> >  	if (test_and_clear_bit(AS_EIO, &mapping->flags))
> >  		ret = -EIO;
> > +	if (mapping_hwpoison(mapping))
> > +		ret = -EIO;
> >  
> >  	return ret;
> >  }
> > @@ -447,6 +449,15 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
> >  	VM_BUG_ON(!PageLocked(page));
> >  	VM_BUG_ON(PageSwapBacked(page));
> >  
> > +	/*
> > +	 * Hardware corrupted page will be removed from mapping,
> > +	 * so we want to deny (possibly) reloading the old data.
> > +	 */
> > +	if (unlikely(mapping_hwpoison(mapping))) {
> > +		error = -EIO;
> > +		goto out;
> > +	}
> > +
> >  	error = mem_cgroup_cache_charge(page, current->mm,
> >  					gfp_mask & GFP_RECLAIM_MASK);
> >  	if (error)
> > diff --git v3.6-rc1.orig/mm/memory-failure.c v3.6-rc1/mm/memory-failure.c
> > index 79dfb2f..a1e7e00 100644
> > --- v3.6-rc1.orig/mm/memory-failure.c
> > +++ v3.6-rc1/mm/memory-failure.c
> > @@ -652,7 +652,7 @@ static int me_pagecache_dirty(struct page *p, unsigned long pfn)
> >  		 * the first EIO, but we're not worse than other parts
> >  		 * of the kernel.
> >  		 */
> > -		mapping_set_error(mapping, EIO);
> > +		set_bit(AS_HWPOISON, &mapping->flags);
> >  	}
> >  
> >  	return me_pagecache_clean(p, pfn);
> > -- 
> > 1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
