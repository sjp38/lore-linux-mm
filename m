Date: Mon, 25 Feb 2008 16:47:45 +0900 (JST)
Message-Id: <20080225.164745.47821156.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [1/7] definitions
 for page_cgroup
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080225121034.bd74be07.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
	<20080225121034.bd74be07.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, hugh@veritas.com, yamamoto@valinux.co.jp, ak@suse.de, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> (This is one of a series of patch for "lookup page_cgroup" patches..)
> 
>  * Exporting page_cgroup definition.
>  * Remove page_cgroup member from sturct page.
>  * As result, PAGE_CGROUP_LOCK_BIT and assign/access functions are removed.
> 
> Other chages will appear in following patches.
> There is a change in the structure itself, spin_lock is added.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
     (snip)
> +#ifdef CONFIG_CGROUP_MEM_CONT
> +/*
> + * page_cgroup is yet another mem_map structure for accounting  usage.
> + * but, unlike mem_map, allocated on demand for accounted pages.
> + * see also memcontrol.h
> + * In nature, this cosumes much amount of memory.
> + */
> +
> +struct mem_cgroup;
> +
> +struct page_cgroup {
> +	struct page 		*page;       /* the page this accounts for*/
> +	struct mem_cgroup 	*mem_cgroup; /* current cgroup subsys */
> +	int    			flags;	     /* See below */
> +	int    			refcnt;      /* reference count */
> +	spinlock_t		lock;        /* lock for all above members */
> +	struct list_head 	lru;         /* for per cgroup LRU */
> +};

You can possible reduce the size of page_cgroup structure not to consume
a lot of memory. I think this is important.

I have some ideas:
(1) I don't think every struct page_cgroup needs to have a "lock" member.
    I think one "lock" variable for several page_cgroup will be also enough
    from a performance viewpoint. In addition, it will become low-impact for
    cache memory. I guess it may be okay if each array of page_cgroup --
    which you just introduced now -- has one lock variable.
(2) The "flags" member and the "refcnt" member can be encoded into
    one member.
(3) The page member can be replaced with the page frame number and it will be
    also possible to use some kind of ID instead of the mem_cgroup member.
    This means these members can be encoded to one members with other members
    such as "flags" and "refcnt"

You don't need to hurry to implement this but will you put these on the
ToDo list.

> +
> +/* flags */
> +#define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache. */
> +#define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* is on active list */

I've been also wondering the preallocation of page_croup approach,
with which the page member of page_cgroup can be completely removed.


Thank you,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
