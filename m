Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71BC0280422
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 14:56:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t193so68115492pgc.0
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:56:32 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j62si7362525pgd.608.2017.08.21.11.56.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 11:56:30 -0700 (PDT)
From: "Liang, Kan" <kan.liang@intel.com>
Subject: RE: [PATCH 1/2] sched/wait: Break up long wake list walk
Date: Mon, 21 Aug 2017 18:56:20 +0000
Message-ID: <37D7C6CF3E00A74B8858931C1DB2F07753788B58@SHSMSX103.ccr.corp.intel.com>
References: <CA+55aFwzTMrZwh7TE_VeZt8gx5Syoop-kA=Xqs56=FkyakrM6g@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F0775378761B@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFy_RNx5TQ8esjPPOKuW-o+fXbZgWapau2MHyexcAZtqsw@mail.gmail.com>
 <20170818122339.24grcbzyhnzmr4qw@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F077537879BB@SHSMSX103.ccr.corp.intel.com>
 <20170818144622.oabozle26hasg5yo@techsingularity.net>
 <37D7C6CF3E00A74B8858931C1DB2F07753787AE4@SHSMSX103.ccr.corp.intel.com>
 <CA+55aFxZjjqUM4kPvNEeZahPovBHFATiwADj-iPTDN0-jnU67Q@mail.gmail.com>
 <20170818185455.qol3st2nynfa47yc@techsingularity.net>
 <CA+55aFwX0yrUPULrDxTWVCg5c6DKh-yCG84NXVxaptXNQ4O_kA@mail.gmail.com>
 <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
In-Reply-To: <20170821183234.kzennaaw2zt2rbwz@techsingularity.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andi
 Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

> > Because that code sequence doesn't actually depend on
> > "wait_on_page_lock()" for _correctness_ anyway, afaik. Anybody who
> > does "migration_entry_wait()" _has_ to retry anyway, since the page
> > table contents may have changed by waiting.
> >
> > So I'm not proud of the attached patch, and I don't think it's really
> > acceptable as-is, but maybe it's worth testing? And maybe it's
> > arguably no worse than what we have now?
> >
> > Comments?
> >
>=20
> The transhuge migration path for numa balancing doesn't go through the
> migration_entry_wait patch despite similarly named functions that suggest
> it does so this may only has the most effect when THP is disabled. It's
> worth trying anyway.

I just finished the test of yield patch (only functionality not performance=
).=20
Yes, it works well with THP disabled.
With THP enabled, I observed one LOCKUP caused by long queue wait.

Here is the call stack with THP enabled.=20
#
   100.00%  (ffffffff9e1aefca)
            |
            ---wait_on_page_bit
               do_huge_pmd_numa_page
               __handle_mm_fault
               handle_mm_fault
               __do_page_fault
               do_page_fault
               page_fault
               |
               |--60.39%--0x2b7b7
               |          |
               |          |--34.26%--0x127d8
               |          |          start_thread
               |          |
               |           --25.95%--0x127a2
               |                     start_thread
               |
                --39.25%--0x2b788
                          |
                           --38.81%--0x127a2
                                     start_thread


>=20
> Covering both paths would be something like the patch below which spins
> until the page is unlocked or it should reschedule. It's not even boot
> tested as I spent what time I had on the test case that I hoped would be
> able to prove it really works.

I will give it a try.

Thanks,
Kan

>=20
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 79b36f57c3ba..31cda1288176 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -517,6 +517,13 @@ static inline void wait_on_page_locked(struct page
> *page)
>  		wait_on_page_bit(compound_head(page), PG_locked);
>  }
>=20
> +void __spinwait_on_page_locked(struct page *page);
> +static inline void spinwait_on_page_locked(struct page *page)
> +{
> +	if (PageLocked(page))
> +		__spinwait_on_page_locked(page);
> +}
> +
>  static inline int wait_on_page_locked_killable(struct page *page)
>  {
>  	if (!PageLocked(page))
> diff --git a/mm/filemap.c b/mm/filemap.c
> index a49702445ce0..c9d6f49614bc 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1210,6 +1210,15 @@ int __lock_page_or_retry(struct page *page,
> struct mm_struct *mm,
>  	}
>  }
>=20
> +void __spinwait_on_page_locked(struct page *page)
> +{
> +	do {
> +		cpu_relax();
> +	} while (PageLocked(page) && !cond_resched());
> +
> +	wait_on_page_locked(page);
> +}
> +
>  /**
>   * page_cache_next_hole - find the next hole (not-present entry)
>   * @mapping: mapping
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 90731e3b7e58..c7025c806420 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1443,7 +1443,7 @@ int do_huge_pmd_numa_page(struct vm_fault
> *vmf, pmd_t pmd)
>  		if (!get_page_unless_zero(page))
>  			goto out_unlock;
>  		spin_unlock(vmf->ptl);
> -		wait_on_page_locked(page);
> +		spinwait_on_page_locked(page);
>  		put_page(page);
>  		goto out;
>  	}
> @@ -1480,7 +1480,7 @@ int do_huge_pmd_numa_page(struct vm_fault
> *vmf, pmd_t pmd)
>  		if (!get_page_unless_zero(page))
>  			goto out_unlock;
>  		spin_unlock(vmf->ptl);
> -		wait_on_page_locked(page);
> +		spinwait_on_page_locked(page);
>  		put_page(page);
>  		goto out;
>  	}
> diff --git a/mm/migrate.c b/mm/migrate.c
> index e84eeb4e4356..9b6c3fc5beac 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -308,7 +308,7 @@ void __migration_entry_wait(struct mm_struct *mm,
> pte_t *ptep,
>  	if (!get_page_unless_zero(page))
>  		goto out;
>  	pte_unmap_unlock(ptep, ptl);
> -	wait_on_page_locked(page);
> +	spinwait_on_page_locked(page);
>  	put_page(page);
>  	return;
>  out:
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
