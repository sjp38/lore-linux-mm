Date: Wed, 9 Jan 2008 13:41:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-Id: <20080109134132.ba7bb33c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080108210002.638347207@redhat.com>
References: <20080108205939.323955454@redhat.com>
	<20080108210002.638347207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

I like this patch set thank you.

On Tue, 08 Jan 2008 15:59:44 -0500
Rik van Riel <riel@redhat.com> wrote:
> Index: linux-2.6.24-rc6-mm1/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.24-rc6-mm1.orig/mm/memcontrol.c	2008-01-07 11:55:09.000000000 -0500
> +++ linux-2.6.24-rc6-mm1/mm/memcontrol.c	2008-01-07 17:32:53.000000000 -0500
<snip>

> -enum mem_cgroup_zstat_index {
> -	MEM_CGROUP_ZSTAT_ACTIVE,
> -	MEM_CGROUP_ZSTAT_INACTIVE,
> -
> -	NR_MEM_CGROUP_ZSTAT,
> -};
> -
>  struct mem_cgroup_per_zone {
>  	/*
>  	 * spin_lock to protect the per cgroup LRU
>  	 */
>  	spinlock_t		lru_lock;
> -	struct list_head	active_list;
> -	struct list_head	inactive_list;
> -	unsigned long count[NR_MEM_CGROUP_ZSTAT];
> +	struct list_head	lists[NR_LRU_LISTS];
> +	unsigned long		count[NR_LRU_LISTS];
>  };
>  /* Macro for accessing counter */
>  #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
> @@ -160,6 +152,7 @@ struct page_cgroup {
>  };
>  #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
>  #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
> +#define PAGE_CGROUP_FLAG_FILE	(0x4)	/* page is file system backed */
> 

Now, we don't have control_type and a feature for accounting only CACHE.
Balbir-san, do you have some new plan ?

BTW, is it better to use PageSwapBacked(pc->page) rather than adding a new flag
PAGE_CGROUP_FLAG_FILE ?


PAGE_CGROUP_FLAG_ACTIVE is used because global reclaim can change
ACTIVE/INACTIVE attribute without accessing memory cgroup.
(Then, we cannot trust PageActive(pc->page))

ANON <-> FILE attribute can be changed dinamically (after added to LRU) ?

If no, using page_file_cache(pc->page) will be easy.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
