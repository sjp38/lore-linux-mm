Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7F3946B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 16:31:56 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep AS_HWPOISON sticky
Date: Thu, 23 Aug 2012 16:31:43 -0400
Message-Id: <1345753903-31389-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120823091125.GA12745@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 23, 2012 at 05:11:25PM +0800, Fengguang Wu wrote:
> On Wed, Aug 22, 2012 at 11:17:35AM -0400, Naoya Horiguchi wrote:
> > "HWPOISON: report sticky EIO for poisoned file" still has a corner case
> > where we have possibilities of data lost. This is because in this fix
> > AS_HWPOISON is cleared when the inode cache is dropped.
> > 
> > For example, consider an application in which a process periodically
> > (every 10 minutes) writes some logs on a file (and closes it after
> > each writes,) and at the end of each day some batch programs run using
> > the log file. If a memory error hits on dirty pagecache of this log file
> > just after periodic write/close and the inode cache is cleared before the
> > next write, then this application is not aware of the error and the batch
> > programs will work wrongly.
> > 
> > To avoid this, this patch makes us pin the hwpoisoned inode on memory
> > until we remove or completely truncate the hwpoisoned file.
> 
> Good point!
>  
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  fs/inode.c              | 12 ++++++++++++
> >  include/linux/pagemap.h | 11 +++++++++++
> >  mm/memory-failure.c     |  2 +-
> >  mm/truncate.c           |  2 ++
> >  4 files changed, 26 insertions(+), 1 deletion(-)
> > 
> > diff --git v3.6-rc1.orig/fs/inode.c v3.6-rc1/fs/inode.c
> > index ac8d904..8742397 100644
> > --- v3.6-rc1.orig/fs/inode.c
> > +++ v3.6-rc1/fs/inode.c
> > @@ -717,6 +717,15 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
> >  		}
> >  
> >  		/*
> > +		 * Keep inode caches on memory for user processes to certainly
> > +		 * be aware of memory errors.
> > +		 */
> > +		if (unlikely(mapping_hwpoison(inode->i_mapping))) {
> > +			spin_unlock(&inode->i_lock);
> > +			continue;
> > +		}
> 
> That chunk prevents reclaiming all the cached pages. However the intention
> is only to keep the struct inode together with the hwpoison bit?

Yes, we can not reclaim pagecaches from shrink_slab(), but we can do from
shrink_zone(). So it shouldn't happen that cached pages on hwpoisoned file
remain for long under high memory pressure.

> > +		/*
> >  		 * Referenced or dirty inodes are still in use. Give them
> >  		 * another pass through the LRU as we canot reclaim them now.
> >  		 */
> > @@ -1405,6 +1414,9 @@ static void iput_final(struct inode *inode)
> >  		inode->i_state &= ~I_WILL_FREE;
> >  	}
> >  
> > +	if (unlikely(mapping_hwpoison(inode->i_mapping) && drop))
> > +		mapping_clear_hwpoison(inode->i_mapping);
> 
> Is that clear necessary? Because the bit will be gone with the inode
> struct: it's going to be de-allocated anyway.

With the chunk in prune_icache_sb() we keep the inode struct with
AS_HWPOISON set on memory, so in order to remove it, we need explicitly
clear the bit.
Without this clear, the inode remains until system reboot.

> >  	inode->i_state |= I_FREEING;
> >  	if (!list_empty(&inode->i_lru))
> >  		inode_lru_list_del(inode);
> > diff --git v3.6-rc1.orig/include/linux/pagemap.h v3.6-rc1/include/linux/pagemap.h
> > index 4d8d821..9fce4e4 100644
> > --- v3.6-rc1.orig/include/linux/pagemap.h
> > +++ v3.6-rc1/include/linux/pagemap.h
> > @@ -59,11 +59,22 @@ static inline int mapping_hwpoison(struct address_space *mapping)
> >  {
> >  	return test_bit(AS_HWPOISON, &mapping->flags);
> >  }
> > +static inline void mapping_set_hwpoison(struct address_space *mapping)
> > +{
> > +	set_bit(AS_HWPOISON, &mapping->flags);
> > +}
> > +static inline void mapping_clear_hwpoison(struct address_space *mapping)
> > +{
> > +	clear_bit(AS_HWPOISON, &mapping->flags);
> > +}
> >  #else
> >  static inline int mapping_hwpoison(struct address_space *mapping)
> >  {
> >  	return 0;
> >  }
> > +static inline void mapping_clear_hwpoison(struct address_space *mapping)
> > +{
> > +}
> >  #endif
> >  
> >  static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
> > diff --git v3.6-rc1.orig/mm/memory-failure.c v3.6-rc1/mm/memory-failure.c
> > index a1e7e00..ca064c6 100644
> > --- v3.6-rc1.orig/mm/memory-failure.c
> > +++ v3.6-rc1/mm/memory-failure.c
> > @@ -652,7 +652,7 @@ static int me_pagecache_dirty(struct page *p, unsigned long pfn)
> >  		 * the first EIO, but we're not worse than other parts
> >  		 * of the kernel.
> >  		 */
> > -		set_bit(AS_HWPOISON, &mapping->flags);
> > +		mapping_set_hwpoison(mapping);
> >  	}
> >  
> >  	return me_pagecache_clean(p, pfn);
> > diff --git v3.6-rc1.orig/mm/truncate.c v3.6-rc1/mm/truncate.c
> > index 75801ac..82a994f 100644
> > --- v3.6-rc1.orig/mm/truncate.c
> > +++ v3.6-rc1/mm/truncate.c
> > @@ -574,6 +574,8 @@ void truncate_setsize(struct inode *inode, loff_t newsize)
> >  
> >  	oldsize = inode->i_size;
> >  	i_size_write(inode, newsize);
> > +	if (unlikely(mapping_hwpoison(inode->i_mapping) && !newsize))
> 
> It might be a bit better to test !newsize first.

Ah, OK.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
