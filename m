Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 381AC6B004D
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 18:50:44 -0500 (EST)
Date: Wed, 4 Jan 2012 15:50:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] pagemap: avoid splitting thp when reading
 /proc/pid/pagemap
Message-Id: <20120104155042.c24e529b.akpm@linux-foundation.org>
In-Reply-To: <1324506228-18327-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1324506228-18327-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed, 21 Dec 2011 17:23:45 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Thp split is not necessary if we explicitly check whether pmds are
> mapping thps or not. This patch introduces the check and the code
> to generate pagemap entries for pmds mapping thps, which results in
> less performance impact of pagemap on thp.
> 
>
> ...

The type choices seem odd:

> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
> +{
> +	u64 pme = 0;

Why are these u64?

Should we have a pme_t, matching pte_t, pmd_t, etc?

> +	if (pte_present(pte))
> +		pme = PM_PFRAME(pte_pfn(pte) + offset)
> +			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
> +	return pme;
> +}
> +#else
> +static inline u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
> +{
> +	return 0;
> +}
> +#endif
> +
>  static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  			     struct mm_walk *walk)
>  {
> @@ -665,14 +684,34 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	struct pagemapread *pm = walk->private;
>  	pte_t *pte;
>  	int err = 0;
> -
> -	split_huge_page_pmd(walk->mm, pmd);
> +	u64 pfn = PM_NOT_PRESENT;

Again, why a u64?  pfn's are usually unsigned long.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
