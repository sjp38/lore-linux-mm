Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 14D316B0055
	for <linux-mm@kvack.org>; Fri, 29 May 2009 01:10:03 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4T5AAoB027171
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 May 2009 14:10:10 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DCEBE45DD7B
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:10:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 947E345DD78
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:10:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C3071DB803F
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:10:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D8E111DB8037
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:10:05 +0900 (JST)
Date: Fri, 29 May 2009 14:08:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] add swap cache interface for swap reference
Message-Id: <20090529140832.1f4b288b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090529132153.3a72f2c3.nishimura@mxp.nes.nec.co.jp>
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090528141049.cc45a116.kamezawa.hiroyu@jp.fujitsu.com>
	<20090529132153.3a72f2c3.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 May 2009 13:21:53 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 28 May 2009 14:10:49 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > In following patch, usage of swap cache will be recorded into swap_map.
> > This patch is for necessary interface changes to do that.
> > 
> > 2 interfaces:
> >   - swapcache_prepare()
> >   - swapcache_free()
> > is added for allocating/freeing refcnt from swap-cache to existing
> > swap entries. But implementation itself is not changed under this patch.
> > At adding swapcache_free(), memcg's hook code is moved under swapcache_free().
> > This is better than using scattered hooks.
> > 
> IIUC, swap_free() at the end of shmem_writepage() should also be changed to swapcache_free().
> 
Hmm!. Oh, yes. shmem_writepage()'s error path. Thank you. It will be fixed.

Thanks,
-Kame

> Thanks,
> Daisuke Nishimura.
> 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/swap.h |    7 +++++++
> >  mm/swap_state.c      |   11 +++++------
> >  mm/swapfile.c        |   19 +++++++++++++++++++
> >  mm/vmscan.c          |    3 +--
> >  4 files changed, 32 insertions(+), 8 deletions(-)
> > 
> > Index: new-trial-swapcount2/include/linux/swap.h
> > ===================================================================
> > --- new-trial-swapcount2.orig/include/linux/swap.h
> > +++ new-trial-swapcount2/include/linux/swap.h
> > @@ -301,8 +301,10 @@ extern void si_swapinfo(struct sysinfo *
> >  extern swp_entry_t get_swap_page(void);
> >  extern swp_entry_t get_swap_page_of_type(int);
> >  extern int swap_duplicate(swp_entry_t);
> > +extern int swapcache_prepare(swp_entry_t);
> >  extern int valid_swaphandles(swp_entry_t, unsigned long *);
> >  extern void swap_free(swp_entry_t);
> > +extern void swapcache_free(swp_entry_t, struct page *page);
> >  extern int free_swap_and_cache(swp_entry_t);
> >  extern int swap_type_of(dev_t, sector_t, struct block_device **);
> >  extern unsigned int count_swap_pages(int, int);
> > @@ -371,11 +373,16 @@ static inline void show_swap_cache_info(
> >  
> >  #define free_swap_and_cache(swp)	is_migration_entry(swp)
> >  #define swap_duplicate(swp)		is_migration_entry(swp)
> > +#define swapcache_prepare(swp)		is_migration_entry(swp)
> >  
> >  static inline void swap_free(swp_entry_t swp)
> >  {
> >  }
> >  
> > +static inline void swapcache_free(swp_entry_t swp, struct page *page)
> > +{
> > +}
> > +
> >  static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
> >  			struct vm_area_struct *vma, unsigned long addr)
> >  {
> > Index: new-trial-swapcount2/mm/swap_state.c
> > ===================================================================
> > --- new-trial-swapcount2.orig/mm/swap_state.c
> > +++ new-trial-swapcount2/mm/swap_state.c
> > @@ -162,11 +162,11 @@ int add_to_swap(struct page *page)
> >  			return 1;
> >  		case -EEXIST:
> >  			/* Raced with "speculative" read_swap_cache_async */
> > -			swap_free(entry);
> > +			swapcache_free(entry, NULL);
> >  			continue;
> >  		default:
> >  			/* -ENOMEM radix-tree allocation failure */
> > -			swap_free(entry);
> > +			swapcache_free(entry, NULL);
> >  			return 0;
> >  		}
> >  	}
> > @@ -188,8 +188,7 @@ void delete_from_swap_cache(struct page 
> >  	__delete_from_swap_cache(page);
> >  	spin_unlock_irq(&swapper_space.tree_lock);
> >  
> > -	mem_cgroup_uncharge_swapcache(page, entry);
> > -	swap_free(entry);
> > +	swapcache_free(entry, page);
> >  	page_cache_release(page);
> >  }
> >  
> > @@ -293,7 +292,7 @@ struct page *read_swap_cache_async(swp_e
> >  		/*
> >  		 * Swap entry may have been freed since our caller observed it.
> >  		 */
> > -		if (!swap_duplicate(entry))
> > +		if (!swapcache_prepare(entry))
> >  			break;
> >  
> >  		/*
> > @@ -317,7 +316,7 @@ struct page *read_swap_cache_async(swp_e
> >  		}
> >  		ClearPageSwapBacked(new_page);
> >  		__clear_page_locked(new_page);
> > -		swap_free(entry);
> > +		swapcache_free(entry, NULL);
> >  	} while (err != -ENOMEM);
> >  
> >  	if (new_page)
> > Index: new-trial-swapcount2/mm/swapfile.c
> > ===================================================================
> > --- new-trial-swapcount2.orig/mm/swapfile.c
> > +++ new-trial-swapcount2/mm/swapfile.c
> > @@ -510,6 +510,16 @@ void swap_free(swp_entry_t entry)
> >  }
> >  
> >  /*
> > + * Called after dropping swapcache to decrease refcnt to swap entries.
> > + */
> > +void swapcache_free(swp_entry_t entry, struct page *page)
> > +{
> > +	if (page)
> > +		mem_cgroup_uncharge_swapcache(page, entry);
> > +	return swap_free(entry);
> > +}
> > +
> > +/*
> >   * How many references to page are currently swapped out?
> >   */
> >  static inline int page_swapcount(struct page *page)
> > @@ -1979,6 +1989,15 @@ bad_file:
> >  	goto out;
> >  }
> >  
> > +/*
> > + * Called when allocating swap cache for exising swap entry,
> > + */
> > +int swapcache_prepare(swp_entry_t entry)
> > +{
> > +	return swap_duplicate(entry);
> > +}
> > +
> > +
> >  struct swap_info_struct *
> >  get_swap_info_struct(unsigned type)
> >  {
> > Index: new-trial-swapcount2/mm/vmscan.c
> > ===================================================================
> > --- new-trial-swapcount2.orig/mm/vmscan.c
> > +++ new-trial-swapcount2/mm/vmscan.c
> > @@ -477,8 +477,7 @@ static int __remove_mapping(struct addre
> >  		swp_entry_t swap = { .val = page_private(page) };
> >  		__delete_from_swap_cache(page);
> >  		spin_unlock_irq(&mapping->tree_lock);
> > -		mem_cgroup_uncharge_swapcache(page, swap);
> > -		swap_free(swap);
> > +		swapcache_free(swap, page);
> >  	} else {
> >  		__remove_from_page_cache(page);
> >  		spin_unlock_irq(&mapping->tree_lock);
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
