Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 43DD46B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 21:50:59 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so97424883pac.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 18:50:59 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id i6si9805574pdr.64.2015.04.07.18.50.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Apr 2015 18:50:58 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH v3 1/2] memory-failure: export page_type and action
 result
Date: Wed, 8 Apr 2015 01:45:25 +0000
Message-ID: <20150408014524.GB24617@hori1.linux.bs1.fc.nec.co.jp>
References: <1428404731-21565-1-git-send-email-xiexiuqi@huawei.com>
 <1428404731-21565-2-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1428404731-21565-2-git-send-email-xiexiuqi@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <5704EC8DF95A204A82D0096B2AE6E648@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>
Cc: "rostedt@goodmis.org" <rostedt@goodmis.org>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "hpa@linux.intel.com" <hpa@linux.intel.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "luto@amacapital.net" <luto@amacapital.net>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "bp@suse.de" <bp@suse.de>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Apr 07, 2015 at 07:05:30PM +0800, Xie XiuQi wrote:
> Export 'outcome' and 'page_type' to mm.h, so we could use this emnus
> outside.
>=20
> This patch is preparation for adding trace events for memory-failure
> recovery action.
>=20
> Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>

I made some update on mm/memory-failure.c, so some more rebasing is needed.
Please see mm-memory-failurec-define-page-types-for-action_result-in-one-pl=
ace-v3
in latest linux-mmotm.

Other than that, this patch looks good to me.

Thanks,
Naoya Horiguchi

> ---
>  include/linux/mm.h  |  34 +++++++++++
>  mm/memory-failure.c | 163 +++++++++++++++++++++-------------------------=
------
>  2 files changed, 99 insertions(+), 98 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4a3a385..5d812b0 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2114,6 +2114,40 @@ extern void shake_page(struct page *p, int access)=
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
> +enum mf_page_type {
> +	MF_KERNEL,
> +	MF_KERNEL_HIGH_ORDER,
> +	MF_SLAB,
> +	MF_DIFFERENT_COMPOUND,
> +	MF_POISONED_HUGE,
> +	MF_HUGE,
> +	MF_FREE_HUGE,
> +	MF_UNMAP_FAILED,
> +	MF_DIRTY_SWAPCACHE,
> +	MF_CLEAN_SWAPCACHE,
> +	MF_DIRTY_MLOCKED_LRU,
> +	MF_CLEAN_MLOCKED_LRU,
> +	MF_DIRTY_UNEVICTABLE_LRU,
> +	MF_CLEAN_UNEVICTABLE_LRU,
> +	MF_DIRTY_LRU,
> +	MF_CLEAN_LRU,
> +	MF_TRUNCATED_LRU,
> +	MF_BUDDY,
> +	MF_BUDDY_2ND,
> +	MF_UNKNOWN,
> +};
> +
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
>  extern void clear_huge_page(struct page *page,
>  			    unsigned long addr,
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 5074998..34e9c65 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -56,6 +56,7 @@
>  #include <linux/mm_inline.h>
>  #include <linux/kfifo.h>
>  #include "internal.h"
> +#include "ras/ras_event.h"
> =20
>  int sysctl_memory_failure_early_kill __read_mostly =3D 0;
> =20
> @@ -503,68 +504,34 @@ static void collect_procs(struct page *page, struct=
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
> -enum page_type {
> -	KERNEL,
> -	KERNEL_HIGH_ORDER,
> -	SLAB,
> -	DIFFERENT_COMPOUND,
> -	POISONED_HUGE,
> -	HUGE,
> -	FREE_HUGE,
> -	UNMAP_FAILED,
> -	DIRTY_SWAPCACHE,
> -	CLEAN_SWAPCACHE,
> -	DIRTY_MLOCKED_LRU,
> -	CLEAN_MLOCKED_LRU,
> -	DIRTY_UNEVICTABLE_LRU,
> -	CLEAN_UNEVICTABLE_LRU,
> -	DIRTY_LRU,
> -	CLEAN_LRU,
> -	TRUNCATED_LRU,
> -	BUDDY,
> -	BUDDY_2ND,
> -	UNKNOWN,
> +	[MF_IGNORED] =3D "Ignored",
> +	[MF_FAILED] =3D "Failed",
> +	[MF_DELAYED] =3D "Delayed",
> +	[MF_RECOVERED] =3D "Recovered",
>  };
> =20
>  static const char *action_page_type[] =3D {
> -	[KERNEL]		=3D "reserved kernel page",
> -	[KERNEL_HIGH_ORDER]	=3D "high-order kernel page",
> -	[SLAB]			=3D "kernel slab page",
> -	[DIFFERENT_COMPOUND]	=3D "different compound page after locking",
> -	[POISONED_HUGE]		=3D "huge page already hardware poisoned",
> -	[HUGE]			=3D "huge page",
> -	[FREE_HUGE]		=3D "free huge page",
> -	[UNMAP_FAILED]		=3D "unmapping failed page",
> -	[DIRTY_SWAPCACHE]	=3D "dirty swapcache page",
> -	[CLEAN_SWAPCACHE]	=3D "clean swapcache page",
> -	[DIRTY_MLOCKED_LRU]	=3D "dirty mlocked LRU page",
> -	[CLEAN_MLOCKED_LRU]	=3D "clean mlocked LRU page",
> -	[DIRTY_UNEVICTABLE_LRU]	=3D "dirty unevictable LRU page",
> -	[CLEAN_UNEVICTABLE_LRU]	=3D "clean unevictable LRU page",
> -	[DIRTY_LRU]		=3D "dirty LRU page",
> -	[CLEAN_LRU]		=3D "clean LRU page",
> -	[TRUNCATED_LRU]		=3D "already truncated LRU page",
> -	[BUDDY]			=3D "free buddy page",
> -	[BUDDY_2ND]		=3D "free buddy page (2nd try)",
> -	[UNKNOWN]		=3D "unknown page",
> +	[MF_KERNEL]			=3D "reserved kernel page",
> +	[MF_KERNEL_HIGH_ORDER]		=3D "high-order kernel page",
> +	[MF_SLAB]			=3D "kernel slab page",
> +	[MF_DIFFERENT_COMPOUND]		=3D "different compound page after locking",
> +	[MF_POISONED_HUGE]		=3D "huge page already hardware poisoned",
> +	[MF_HUGE]			=3D "huge page",
> +	[MF_FREE_HUGE]			=3D "free huge page",
> +	[MF_UNMAP_FAILED]		=3D "unmapping failed page",
> +	[MF_DIRTY_SWAPCACHE]		=3D "dirty swapcache page",
> +	[MF_CLEAN_SWAPCACHE]		=3D "clean swapcache page",
> +	[MF_DIRTY_MLOCKED_LRU]		=3D "dirty mlocked LRU page",
> +	[MF_CLEAN_MLOCKED_LRU]		=3D "clean mlocked LRU page",
> +	[MF_DIRTY_UNEVICTABLE_LRU]	=3D "dirty unevictable LRU page",
> +	[MF_CLEAN_UNEVICTABLE_LRU]	=3D "clean unevictable LRU page",
> +	[MF_DIRTY_LRU]			=3D "dirty LRU page",
> +	[MF_CLEAN_LRU]			=3D "clean LRU page",
> +	[MF_TRUNCATED_LRU]		=3D "already truncated LRU page",
> +	[MF_BUDDY]			=3D "free buddy page",
> +	[MF_BUDDY_2ND]			=3D "free buddy page (2nd try)",
> +	[MF_UNKNOWN]			=3D "unknown page",
>  };
> =20
>  /*
> @@ -598,7 +565,7 @@ static int delete_from_lru_cache(struct page *p)
>   */
>  static int me_kernel(struct page *p, unsigned long pfn)
>  {
> -	return IGNORED;
> +	return MF_IGNORED;
>  }
> =20
>  /*
> @@ -607,7 +574,7 @@ static int me_kernel(struct page *p, unsigned long pf=
n)
>  static int me_unknown(struct page *p, unsigned long pfn)
>  {
>  	printk(KERN_ERR "MCE %#lx: Unknown page state\n", pfn);
> -	return FAILED;
> +	return MF_FAILED;
>  }
> =20
>  /*
> @@ -616,7 +583,7 @@ static int me_unknown(struct page *p, unsigned long p=
fn)
>  static int me_pagecache_clean(struct page *p, unsigned long pfn)
>  {
>  	int err;
> -	int ret =3D FAILED;
> +	int ret =3D MF_FAILED;
>  	struct address_space *mapping;
> =20
>  	delete_from_lru_cache(p);
> @@ -626,7 +593,7 @@ static int me_pagecache_clean(struct page *p, unsigne=
d long pfn)
>  	 * should be the one m_f() holds.
>  	 */
>  	if (PageAnon(p))
> -		return RECOVERED;
> +		return MF_RECOVERED;
> =20
>  	/*
>  	 * Now truncate the page in the page cache. This is really
> @@ -640,7 +607,7 @@ static int me_pagecache_clean(struct page *p, unsigne=
d long pfn)
>  		/*
>  		 * Page has been teared down in the meanwhile
>  		 */
> -		return FAILED;
> +		return MF_FAILED;
>  	}
> =20
>  	/*
> @@ -657,7 +624,7 @@ static int me_pagecache_clean(struct page *p, unsigne=
d long pfn)
>  				!try_to_release_page(p, GFP_NOIO)) {
>  			pr_info("MCE %#lx: failed to release buffers\n", pfn);
>  		} else {
> -			ret =3D RECOVERED;
> +			ret =3D MF_RECOVERED;
>  		}
>  	} else {
>  		/*
> @@ -665,7 +632,7 @@ static int me_pagecache_clean(struct page *p, unsigne=
d long pfn)
>  		 * This fails on dirty or anything with private pages
>  		 */
>  		if (invalidate_inode_page(p))
> -			ret =3D RECOVERED;
> +			ret =3D MF_RECOVERED;
>  		else
>  			printk(KERN_INFO "MCE %#lx: Failed to invalidate\n",
>  				pfn);
> @@ -751,9 +718,9 @@ static int me_swapcache_dirty(struct page *p, unsigne=
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
> @@ -761,9 +728,9 @@ static int me_swapcache_clean(struct page *p, unsigne=
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
> @@ -789,9 +756,9 @@ static int me_huge_page(struct page *p, unsigned long=
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
> @@ -826,7 +793,7 @@ static struct page_state {
>  	int type;
>  	int (*action)(struct page *p, unsigned long pfn);
>  } error_states[] =3D {
> -	{ reserved,	reserved,	KERNEL,	me_kernel },
> +	{ reserved,	reserved,	MF_KERNEL,	me_kernel },
>  	/*
>  	 * free pages are specially detected outside this table:
>  	 * PG_buddy pages only make a small fraction of all free pages.
> @@ -837,31 +804,31 @@ static struct page_state {
>  	 * currently unused objects without touching them. But just
>  	 * treat it as standard kernel for now.
>  	 */
> -	{ slab,		slab,		SLAB,	me_kernel },
> +	{ slab,		slab,		MF_SLAB,	me_kernel },
> =20
>  #ifdef CONFIG_PAGEFLAGS_EXTENDED
> -	{ head,		head,		HUGE,		me_huge_page },
> -	{ tail,		tail,		HUGE,		me_huge_page },
> +	{ head,		head,		MF_HUGE,		me_huge_page },
> +	{ tail,		tail,		MF_HUGE,		me_huge_page },
>  #else
> -	{ compound,	compound,	HUGE,		me_huge_page },
> +	{ compound,	compound,	MF_HUGE,		me_huge_page },
>  #endif
> =20
> -	{ sc|dirty,	sc|dirty,	DIRTY_SWAPCACHE,	me_swapcache_dirty },
> -	{ sc|dirty,	sc,		CLEAN_SWAPCACHE,	me_swapcache_clean },
> +	{ sc|dirty,	sc|dirty,	MF_DIRTY_SWAPCACHE,	me_swapcache_dirty },
> +	{ sc|dirty,	sc,		MF_CLEAN_SWAPCACHE,	me_swapcache_clean },
> =20
> -	{ mlock|dirty,	mlock|dirty,	DIRTY_MLOCKED_LRU,	me_pagecache_dirty },
> -	{ mlock|dirty,	mlock,		CLEAN_MLOCKED_LRU,	me_pagecache_clean },
> +	{ mlock|dirty,	mlock|dirty,	MF_DIRTY_MLOCKED_LRU,	me_pagecache_dirty },
> +	{ mlock|dirty,	mlock,		MF_CLEAN_MLOCKED_LRU,	me_pagecache_clean },
> =20
> -	{ unevict|dirty, unevict|dirty,	DIRTY_UNEVICTABLE_LRU,	me_pagecache_dir=
ty },
> -	{ unevict|dirty, unevict,	CLEAN_UNEVICTABLE_LRU,	me_pagecache_clean },
> +	{ unevict|dirty, unevict|dirty,	MF_DIRTY_UNEVICTABLE_LRU,	me_pagecache_=
dirty },
> +	{ unevict|dirty, unevict,	MF_CLEAN_UNEVICTABLE_LRU,	me_pagecache_clean =
},
> =20
> -	{ lru|dirty,	lru|dirty,	DIRTY_LRU,	me_pagecache_dirty },
> -	{ lru|dirty,	lru,		CLEAN_LRU,	me_pagecache_clean },
> +	{ lru|dirty,	lru|dirty,	MF_DIRTY_LRU,	me_pagecache_dirty },
> +	{ lru|dirty,	lru,		MF_CLEAN_LRU,	me_pagecache_clean },
> =20
>  	/*
>  	 * Catchall entry: must be at end.
>  	 */
> -	{ 0,		0,		UNKNOWN,	me_unknown },
> +	{ 0,		0,		MF_UNKNOWN,	me_unknown },
>  };
> =20
>  #undef dirty
> @@ -896,13 +863,13 @@ static int page_action(struct page_state *ps, struc=
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
>  		       pfn, action_page_type[ps->type], count);
> -		result =3D FAILED;
> +		result =3D MF_FAILED;
>  	}
>  	action_result(pfn, ps->type, result);
> =20
> @@ -911,7 +878,7 @@ static int page_action(struct page_state *ps, struct =
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
> @@ -1152,7 +1119,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	if (!(flags & MF_COUNT_INCREASED) &&
>  		!get_page_unless_zero(hpage)) {
>  		if (is_free_buddy_page(p)) {
> -			action_result(pfn, BUDDY, DELAYED);
> +			action_result(pfn, MF_BUDDY, MF_DELAYED);
>  			return 0;
>  		} else if (PageHuge(hpage)) {
>  			/*
> @@ -1169,12 +1136,12 @@ int memory_failure(unsigned long pfn, int trapno,=
 int flags)
>  			}
>  			set_page_hwpoison_huge_page(hpage);
>  			res =3D dequeue_hwpoisoned_huge_page(hpage);
> -			action_result(pfn, FREE_HUGE,
> -				      res ? IGNORED : DELAYED);
> +			action_result(pfn, MF_FREE_HUGE,
> +				      res ? MF_IGNORED : MF_DELAYED);
>  			unlock_page(hpage);
>  			return res;
>  		} else {
> -			action_result(pfn, KERNEL_HIGH_ORDER, IGNORED);
> +			action_result(pfn, MF_KERNEL_HIGH_ORDER, MF_IGNORED);
>  			return -EBUSY;
>  		}
>  	}
> @@ -1196,9 +1163,9 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  			 */
>  			if (is_free_buddy_page(p)) {
>  				if (flags & MF_COUNT_INCREASED)
> -					action_result(pfn, BUDDY, DELAYED);
> +					action_result(pfn, MF_BUDDY, MF_DELAYED);
>  				else
> -					action_result(pfn, BUDDY_2ND, DELAYED);
> +					action_result(pfn, MF_BUDDY_2ND, MF_DELAYED);
>  				return 0;
>  			}
>  		}
> @@ -1211,7 +1178,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	 * If this happens just bail out.
>  	 */
>  	if (compound_head(p) !=3D hpage) {
> -		action_result(pfn, DIFFERENT_COMPOUND, IGNORED);
> +		action_result(pfn, MF_DIFFERENT_COMPOUND, MF_IGNORED);
>  		res =3D -EBUSY;
>  		goto out;
>  	}
> @@ -1251,7 +1218,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	 * on the head page to show that the hugepage is hwpoisoned
>  	 */
>  	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
> -		action_result(pfn, POISONED_HUGE, IGNORED);
> +		action_result(pfn, MF_POISONED_HUGE, MF_IGNORED);
>  		unlock_page(hpage);
>  		put_page(hpage);
>  		return 0;
> @@ -1280,7 +1247,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	 */
>  	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
>  	    !=3D SWAP_SUCCESS) {
> -		action_result(pfn, UNMAP_FAILED, IGNORED);
> +		action_result(pfn, MF_UNMAP_FAILED, MF_IGNORED);
>  		res =3D -EBUSY;
>  		goto out;
>  	}
> @@ -1289,7 +1256,7 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
>  	 * Torn down by someone else?
>  	 */
>  	if (PageLRU(p) && !PageSwapCache(p) && p->mapping =3D=3D NULL) {
> -		action_result(pfn, TRUNCATED_LRU, IGNORED);
> +		action_result(pfn, MF_TRUNCATED_LRU, MF_IGNORED);
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
