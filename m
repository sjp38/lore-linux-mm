Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id AFED06B006C
	for <linux-mm@kvack.org>; Wed,  6 May 2015 21:13:30 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so24861667pac.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 18:13:30 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id m12si605408pdn.67.2015.05.06.18.13.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 06 May 2015 18:13:29 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v4 1/3] memory-failure: export page_type and action
 result
Date: Thu, 7 May 2015 00:48:07 +0000
Message-ID: <20150507004806.GA7745@hori1.linux.bs1.fc.nec.co.jp>
References: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>
 <1429519480-11687-2-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1429519480-11687-2-git-send-email-xiexiuqi@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B9D88BC480DBC64FB71779A8A54C4C08@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: "rostedt@goodmis.org" <rostedt@goodmis.org>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "luto@amacapital.net" <luto@amacapital.net>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

On Mon, Apr 20, 2015 at 04:44:38PM +0800, Xie XiuQi wrote:
> Export 'outcome' and 'action_page_type' to mm.h, so we could use
> this enums outside.
>=20
> This patch is preparation for adding trace events for memory-failure
> recovery action.
>=20
> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  include/linux/mm.h  |  34 +++++++++++
>  mm/memory-failure.c | 168 +++++++++++++++++++++-------------------------=
------
>  2 files changed, 101 insertions(+), 101 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8b08607..8413615 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2152,6 +2152,40 @@ extern void shake_page(struct page *p, int access)=
;
>  extern atomic_long_t num_poisoned_pages;
>  extern int soft_offline_page(struct page *page, int flags);
> =20
> +
> +/*
> + * Error handlers for various types of pages.
> + */
> +enum mf_outcome {
> +	MF_IGNORED,	/* Error: cannot be handled */
> +	MF_FAILED,	/* Error: handling failed */
> +	MF_DELAYED,	/* Will be handled later */
> +	MF_RECOVERED,	/* Successfully recovered */
> +};
> +
> +enum mf_action_page_type {
> +	MF_MSG_KERNEL,
> +	MF_MSG_KERNEL_HIGH_ORDER,
> +	MF_MSG_SLAB,
> +	MF_MSG_DIFFERENT_COMPOUND,
> +	MF_MSG_POISONED_HUGE,
> +	MF_MSG_HUGE,
> +	MF_MSG_FREE_HUGE,
> +	MF_MSG_UNMAP_FAILED,
> +	MF_MSG_DIRTY_SWAPCACHE,
> +	MF_MSG_CLEAN_SWAPCACHE,
> +	MF_MSG_DIRTY_MLOCKED_LRU,
> +	MF_MSG_CLEAN_MLOCKED_LRU,
> +	MF_MSG_DIRTY_UNEVICTABLE_LRU,
> +	MF_MSG_CLEAN_UNEVICTABLE_LRU,
> +	MF_MSG_DIRTY_LRU,
> +	MF_MSG_CLEAN_LRU,
> +	MF_MSG_TRUNCATED_LRU,
> +	MF_MSG_BUDDY,
> +	MF_MSG_BUDDY_2ND,
> +	MF_MSG_UNKNOWN,
> +};
> +
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
>  extern void clear_huge_page(struct page *page,
>  			    unsigned long addr,
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d9359b7..6f5748d 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -503,68 +503,34 @@ static void collect_procs(struct page *page, struct=
 list_head *tokill,
>  	kfree(tk);
>  }
> =20
> -/*
> - * Error handlers for various types of pages.
> - */
> -
> -enum outcome {
> -	IGNORED,	/* Error: cannot be handled */
> -	FAILED,		/* Error: handling failed */
> -	DELAYED,	/* Will be handled later */
> -	RECOVERED,	/* Successfully recovered */
> -};
> -
>  static const char *action_name[] =3D {
> -	[IGNORED] =3D "Ignored",
> -	[FAILED] =3D "Failed",
> -	[DELAYED] =3D "Delayed",
> -	[RECOVERED] =3D "Recovered",
> -};
> -
> -enum action_page_type {
> -	MSG_KERNEL,
> -	MSG_KERNEL_HIGH_ORDER,
> -	MSG_SLAB,
> -	MSG_DIFFERENT_COMPOUND,
> -	MSG_POISONED_HUGE,
> -	MSG_HUGE,
> -	MSG_FREE_HUGE,
> -	MSG_UNMAP_FAILED,
> -	MSG_DIRTY_SWAPCACHE,
> -	MSG_CLEAN_SWAPCACHE,
> -	MSG_DIRTY_MLOCKED_LRU,
> -	MSG_CLEAN_MLOCKED_LRU,
> -	MSG_DIRTY_UNEVICTABLE_LRU,
> -	MSG_CLEAN_UNEVICTABLE_LRU,
> -	MSG_DIRTY_LRU,
> -	MSG_CLEAN_LRU,
> -	MSG_TRUNCATED_LRU,
> -	MSG_BUDDY,
> -	MSG_BUDDY_2ND,
> -	MSG_UNKNOWN,
> +	[MF_IGNORED] =3D "Ignored",
> +	[MF_FAILED] =3D "Failed",
> +	[MF_DELAYED] =3D "Delayed",
> +	[MF_RECOVERED] =3D "Recovered",
>  };
> =20
>  static const char * const action_page_types[] =3D {
> -	[MSG_KERNEL]			=3D "reserved kernel page",
> -	[MSG_KERNEL_HIGH_ORDER]		=3D "high-order kernel page",
> -	[MSG_SLAB]			=3D "kernel slab page",
> -	[MSG_DIFFERENT_COMPOUND]	=3D "different compound page after locking",
> -	[MSG_POISONED_HUGE]		=3D "huge page already hardware poisoned",
> -	[MSG_HUGE]			=3D "huge page",
> -	[MSG_FREE_HUGE]			=3D "free huge page",
> -	[MSG_UNMAP_FAILED]		=3D "unmapping failed page",
> -	[MSG_DIRTY_SWAPCACHE]		=3D "dirty swapcache page",
> -	[MSG_CLEAN_SWAPCACHE]		=3D "clean swapcache page",
> -	[MSG_DIRTY_MLOCKED_LRU]		=3D "dirty mlocked LRU page",
> -	[MSG_CLEAN_MLOCKED_LRU]		=3D "clean mlocked LRU page",
> -	[MSG_DIRTY_UNEVICTABLE_LRU]	=3D "dirty unevictable LRU page",
> -	[MSG_CLEAN_UNEVICTABLE_LRU]	=3D "clean unevictable LRU page",
> -	[MSG_DIRTY_LRU]			=3D "dirty LRU page",
> -	[MSG_CLEAN_LRU]			=3D "clean LRU page",
> -	[MSG_TRUNCATED_LRU]		=3D "already truncated LRU page",
> -	[MSG_BUDDY]			=3D "free buddy page",
> -	[MSG_BUDDY_2ND]			=3D "free buddy page (2nd try)",
> -	[MSG_UNKNOWN]			=3D "unknown page",
> +	[MF_MSG_KERNEL]			=3D "reserved kernel page",
> +	[MF_MSG_KERNEL_HIGH_ORDER]	=3D "high-order kernel page",
> +	[MF_MSG_SLAB]			=3D "kernel slab page",
> +	[MF_MSG_DIFFERENT_COMPOUND]	=3D "different compound page after locking"=
,
> +	[MF_MSG_POISONED_HUGE]		=3D "huge page already hardware poisoned",
> +	[MF_MSG_HUGE]			=3D "huge page",
> +	[MF_MSG_FREE_HUGE]		=3D "free huge page",
> +	[MF_MSG_UNMAP_FAILED]		=3D "unmapping failed page",
> +	[MF_MSG_DIRTY_SWAPCACHE]	=3D "dirty swapcache page",
> +	[MF_MSG_CLEAN_SWAPCACHE]	=3D "clean swapcache page",
> +	[MF_MSG_DIRTY_MLOCKED_LRU]	=3D "dirty mlocked LRU page",
> +	[MF_MSG_CLEAN_MLOCKED_LRU]	=3D "clean mlocked LRU page",
> +	[MF_MSG_DIRTY_UNEVICTABLE_LRU]	=3D "dirty unevictable LRU page",
> +	[MF_MSG_CLEAN_UNEVICTABLE_LRU]	=3D "clean unevictable LRU page",
> +	[MF_MSG_DIRTY_LRU]		=3D "dirty LRU page",
> +	[MF_MSG_CLEAN_LRU]		=3D "clean LRU page",
> +	[MF_MSG_TRUNCATED_LRU]		=3D "already truncated LRU page",
> +	[MF_MSG_BUDDY]			=3D "free buddy page",
> +	[MF_MSG_BUDDY_2ND]		=3D "free buddy page (2nd try)",
> +	[MF_MSG_UNKNOWN]		=3D "unknown page",
>  };
> =20
>  /*
> @@ -598,7 +564,7 @@ static int delete_from_lru_cache(struct page *p)
>   */
>  static int me_kernel(struct page *p, unsigned long pfn)
>  {
> -	return IGNORED;
> +	return MF_IGNORED;
>  }
> =20
>  /*
> @@ -607,7 +573,7 @@ static int me_kernel(struct page *p, unsigned long pf=
n)
>  static int me_unknown(struct page *p, unsigned long pfn)
>  {
>  	printk(KERN_ERR "MCE %#lx: Unknown page state\n", pfn);
> -	return FAILED;
> +	return MF_FAILED;
>  }
> =20
>  /*
> @@ -616,7 +582,7 @@ static int me_unknown(struct page *p, unsigned long p=
fn)
>  static int me_pagecache_clean(struct page *p, unsigned long pfn)
>  {
>  	int err;
> -	int ret =3D FAILED;
> +	int ret =3D MF_FAILED;
>  	struct address_space *mapping;
> =20
>  	delete_from_lru_cache(p);
> @@ -626,7 +592,7 @@ static int me_pagecache_clean(struct page *p, unsigne=
d long pfn)
>  	 * should be the one m_f() holds.
>  	 */
>  	if (PageAnon(p))
> -		return RECOVERED;
> +		return MF_RECOVERED;
> =20
>  	/*
>  	 * Now truncate the page in the page cache. This is really
> @@ -640,7 +606,7 @@ static int me_pagecache_clean(struct page *p, unsigne=
d long pfn)
>  		/*
>  		 * Page has been teared down in the meanwhile
>  		 */
> -		return FAILED;
> +		return MF_FAILED;
>  	}
> =20
>  	/*
> @@ -657,7 +623,7 @@ static int me_pagecache_clean(struct page *p, unsigne=
d long pfn)
>  				!try_to_release_page(p, GFP_NOIO)) {
>  			pr_info("MCE %#lx: failed to release buffers\n", pfn);
>  		} else {
> -			ret =3D RECOVERED;
> +			ret =3D MF_RECOVERED;
>  		}
>  	} else {
>  		/*
> @@ -665,7 +631,7 @@ static int me_pagecache_clean(struct page *p, unsigne=
d long pfn)
>  		 * This fails on dirty or anything with private pages
>  		 */
>  		if (invalidate_inode_page(p))
> -			ret =3D RECOVERED;
> +			ret =3D MF_RECOVERED;
>  		else
>  			printk(KERN_INFO "MCE %#lx: Failed to invalidate\n",
>  				pfn);
> @@ -751,9 +717,9 @@ static int me_swapcache_dirty(struct page *p, unsigne=
d long pfn)
>  	ClearPageUptodate(p);
> =20
>  	if (!delete_from_lru_cache(p))
> -		return DELAYED;
> +		return MF_DELAYED;
>  	else
> -		return FAILED;
> +		return MF_FAILED;
>  }
> =20
>  static int me_swapcache_clean(struct page *p, unsigned long pfn)
> @@ -761,9 +727,9 @@ static int me_swapcache_clean(struct page *p, unsigne=
d long pfn)
>  	delete_from_swap_cache(p);
> =20
>  	if (!delete_from_lru_cache(p))
> -		return RECOVERED;
> +		return MF_RECOVERED;
>  	else
> -		return FAILED;
> +		return MF_FAILED;
>  }
> =20
>  /*
> @@ -789,9 +755,9 @@ static int me_huge_page(struct page *p, unsigned long=
 pfn)
>  	if (!(page_mapping(hpage) || PageAnon(hpage))) {
>  		res =3D dequeue_hwpoisoned_huge_page(hpage);
>  		if (!res)
> -			return RECOVERED;
> +			return MF_RECOVERED;
>  	}
> -	return DELAYED;
> +	return MF_DELAYED;
>  }
> =20
>  /*
> @@ -823,10 +789,10 @@ static int me_huge_page(struct page *p, unsigned lo=
ng pfn)
>  static struct page_state {
>  	unsigned long mask;
>  	unsigned long res;
> -	enum action_page_type type;
> +	enum mf_action_page_type type;
>  	int (*action)(struct page *p, unsigned long pfn);
>  } error_states[] =3D {
> -	{ reserved,	reserved,	MSG_KERNEL,	me_kernel },
> +	{ reserved,	reserved,	MF_MSG_KERNEL,	me_kernel },
>  	/*
>  	 * free pages are specially detected outside this table:
>  	 * PG_buddy pages only make a small fraction of all free pages.
> @@ -837,31 +803,31 @@ static struct page_state {
>  	 * currently unused objects without touching them. But just
>  	 * treat it as standard kernel for now.
>  	 */
> -	{ slab,		slab,		MSG_SLAB,	me_kernel },
> +	{ slab,		slab,		MF_MSG_SLAB,	me_kernel },
> =20
>  #ifdef CONFIG_PAGEFLAGS_EXTENDED
> -	{ head,		head,		MSG_HUGE,		me_huge_page },
> -	{ tail,		tail,		MSG_HUGE,		me_huge_page },
> +	{ head,		head,		MF_MSG_HUGE,		me_huge_page },
> +	{ tail,		tail,		MF_MSG_HUGE,		me_huge_page },
>  #else
> -	{ compound,	compound,	MSG_HUGE,		me_huge_page },
> +	{ compound,	compound,	MF_MSG_HUGE,		me_huge_page },
>  #endif
> =20
> -	{ sc|dirty,	sc|dirty,	MSG_DIRTY_SWAPCACHE,	me_swapcache_dirty },
> -	{ sc|dirty,	sc,		MSG_CLEAN_SWAPCACHE,	me_swapcache_clean },
> +	{ sc|dirty,	sc|dirty,	MF_MSG_DIRTY_SWAPCACHE,	me_swapcache_dirty },
> +	{ sc|dirty,	sc,		MF_MSG_CLEAN_SWAPCACHE,	me_swapcache_clean },
> =20
> -	{ mlock|dirty,	mlock|dirty,	MSG_DIRTY_MLOCKED_LRU,	me_pagecache_dirty }=
,
> -	{ mlock|dirty,	mlock,		MSG_CLEAN_MLOCKED_LRU,	me_pagecache_clean },
> +	{ mlock|dirty,	mlock|dirty,	MF_MSG_DIRTY_MLOCKED_LRU,	me_pagecache_dirt=
y },
> +	{ mlock|dirty,	mlock,		MF_MSG_CLEAN_MLOCKED_LRU,	me_pagecache_clean },
> =20
> -	{ unevict|dirty, unevict|dirty,	MSG_DIRTY_UNEVICTABLE_LRU,	me_pagecache=
_dirty },
> -	{ unevict|dirty, unevict,	MSG_CLEAN_UNEVICTABLE_LRU,	me_pagecache_clean=
 },
> +	{ unevict|dirty, unevict|dirty,	MF_MSG_DIRTY_UNEVICTABLE_LRU,	me_pageca=
che_dirty },
> +	{ unevict|dirty, unevict,	MF_MSG_CLEAN_UNEVICTABLE_LRU,	me_pagecache_cl=
ean },
> =20
> -	{ lru|dirty,	lru|dirty,	MSG_DIRTY_LRU,	me_pagecache_dirty },
> -	{ lru|dirty,	lru,		MSG_CLEAN_LRU,	me_pagecache_clean },
> +	{ lru|dirty,	lru|dirty,	MF_MSG_DIRTY_LRU,	me_pagecache_dirty },
> +	{ lru|dirty,	lru,		MF_MSG_CLEAN_LRU,	me_pagecache_clean },
> =20
>  	/*
>  	 * Catchall entry: must be at end.
>  	 */
> -	{ 0,		0,		MSG_UNKNOWN,	me_unknown },
> +	{ 0,		0,		MF_MSG_UNKNOWN,	me_unknown },
>  };
> =20
>  #undef dirty
> @@ -881,7 +847,7 @@ static struct page_state {
>   * "Dirty/Clean" indication is not 100% accurate due to the possibility =
of
>   * setting PG_dirty outside page lock. See also comment above set_page_d=
irty().
>   */
> -static void action_result(unsigned long pfn, enum action_page_type type,=
 int result)
> +static void action_result(unsigned long pfn, enum mf_action_page_type ty=
pe, int result)
>  {
>  	pr_err("MCE %#lx: recovery action for %s: %s\n",
>  		pfn, action_page_types[type], action_name[result]);
> @@ -896,13 +862,13 @@ static int page_action(struct page_state *ps, struc=
t page *p,
>  	result =3D ps->action(p, pfn);
> =20
>  	count =3D page_count(p) - 1;
> -	if (ps->action =3D=3D me_swapcache_dirty && result =3D=3D DELAYED)
> +	if (ps->action =3D=3D me_swapcache_dirty && result =3D=3D MF_DELAYED)
>  		count--;
>  	if (count !=3D 0) {
>  		printk(KERN_ERR
>  		       "MCE %#lx: %s still referenced by %d users\n",
>  		       pfn, action_page_types[ps->type], count);
> -		result =3D FAILED;
> +		result =3D MF_FAILED;
>  	}
>  	action_result(pfn, ps->type, result);
> =20
> @@ -911,7 +877,7 @@ static int page_action(struct page_state *ps, struct =
page *p,
>  	 * Could adjust zone counters here to correct for the missing page.
>  	 */
> =20
> -	return (result =3D=3D RECOVERED || result =3D=3D DELAYED) ? 0 : -EBUSY;
> +	return (result =3D=3D MF_RECOVERED || result =3D=3D MF_DELAYED) ? 0 : -=
EBUSY;
>  }
> =20
>  /*
> @@ -1152,7 +1118,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	if (!(flags & MF_COUNT_INCREASED) &&
>  		!get_page_unless_zero(hpage)) {
>  		if (is_free_buddy_page(p)) {
> -			action_result(pfn, MSG_BUDDY, DELAYED);
> +			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
>  			return 0;
>  		} else if (PageHuge(hpage)) {
>  			/*
> @@ -1169,12 +1135,12 @@ int memory_failure(unsigned long pfn, int trapno,=
 int flags)
>  			}
>  			set_page_hwpoison_huge_page(hpage);
>  			res =3D dequeue_hwpoisoned_huge_page(hpage);
> -			action_result(pfn, MSG_FREE_HUGE,
> -				      res ? IGNORED : DELAYED);
> +			action_result(pfn, MF_MSG_FREE_HUGE,
> +				      res ? MF_IGNORED : MF_DELAYED);
>  			unlock_page(hpage);
>  			return res;
>  		} else {
> -			action_result(pfn, MSG_KERNEL_HIGH_ORDER, IGNORED);
> +			action_result(pfn, MF_MSG_KERNEL_HIGH_ORDER, MF_IGNORED);
>  			return -EBUSY;
>  		}
>  	}
> @@ -1196,10 +1162,10 @@ int memory_failure(unsigned long pfn, int trapno,=
 int flags)
>  			 */
>  			if (is_free_buddy_page(p)) {
>  				if (flags & MF_COUNT_INCREASED)
> -					action_result(pfn, MSG_BUDDY, DELAYED);
> +					action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
>  				else
> -					action_result(pfn, MSG_BUDDY_2ND,
> -						      DELAYED);
> +					action_result(pfn, MF_MSG_BUDDY_2ND,
> +						      MF_DELAYED);
>  				return 0;
>  			}
>  		}
> @@ -1212,7 +1178,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	 * If this happens just bail out.
>  	 */
>  	if (compound_head(p) !=3D hpage) {
> -		action_result(pfn, MSG_DIFFERENT_COMPOUND, IGNORED);
> +		action_result(pfn, MF_MSG_DIFFERENT_COMPOUND, MF_IGNORED);
>  		res =3D -EBUSY;
>  		goto out;
>  	}
> @@ -1252,7 +1218,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	 * on the head page to show that the hugepage is hwpoisoned
>  	 */
>  	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
> -		action_result(pfn, MSG_POISONED_HUGE, IGNORED);
> +		action_result(pfn, MF_MSG_POISONED_HUGE, MF_IGNORED);
>  		unlock_page(hpage);
>  		put_page(hpage);
>  		return 0;
> @@ -1281,7 +1247,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	 */
>  	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
>  	    !=3D SWAP_SUCCESS) {
> -		action_result(pfn, MSG_UNMAP_FAILED, IGNORED);
> +		action_result(pfn, MF_MSG_UNMAP_FAILED, MF_IGNORED);
>  		res =3D -EBUSY;
>  		goto out;
>  	}
> @@ -1290,7 +1256,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	 * Torn down by someone else?
>  	 */
>  	if (PageLRU(p) && !PageSwapCache(p) && p->mapping =3D=3D NULL) {
> -		action_result(pfn, MSG_TRUNCATED_LRU, IGNORED);
> +		action_result(pfn, MF_MSG_TRUNCATED_LRU, MF_IGNORED);
>  		res =3D -EBUSY;
>  		goto out;
>  	}
> --=20
> 1.8.3.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
