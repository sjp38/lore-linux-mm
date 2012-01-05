Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 343CF6B004D
	for <linux-mm@kvack.org>; Thu,  5 Jan 2012 11:29:11 -0500 (EST)
Message-ID: <4F05CFAF.9020502@ah.jp.nec.com>
Date: Thu, 05 Jan 2012 11:28:31 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] pagemap: avoid splitting thp when reading /proc/pid/pagemap
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324506228-18327-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20120104155042.c24e529b.akpm@linux-foundation.org>
In-Reply-To: <20120104155042.c24e529b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Wed, Jan 04, 2012 at 03:50:42PM -0800, Andrew Morton wrote:
> On Wed, 21 Dec 2011 17:23:45 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > Thp split is not necessary if we explicitly check whether pmds are
> > mapping thps or not. This patch introduces the check and the code
> > to generate pagemap entries for pmds mapping thps, which results in
> > less performance impact of pagemap on thp.
> > 
> >
> > ...
> 
> The type choices seem odd:
> 
> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +static u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
> > +{
> > +	u64 pme = 0;
> 
> Why are these u64?

I guess (I just copied this type choice from other *pte_to_pagemap_entry()
type functions) it's because each entry in /proc/pid/pagemap is in fixed
sized (64 bit) format as described in the comment above pagemap_read().

> Should we have a pme_t, matching pte_t, pmd_t, etc?

Yes, it makes code's meaning clearer.

> 
> > +	if (pte_present(pte))
> > +		pme = PM_PFRAME(pte_pfn(pte) + offset)
> > +			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
> > +	return pme;
> > +}
> > +#else
> > +static inline u64 thp_pte_to_pagemap_entry(pte_t pte, int offset)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >  			     struct mm_walk *walk)
> >  {
> > @@ -665,14 +684,34 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >  	struct pagemapread *pm = walk->private;
> >  	pte_t *pte;
> >  	int err = 0;
> > -
> > -	split_huge_page_pmd(walk->mm, pmd);
> > +	u64 pfn = PM_NOT_PRESENT;
> 
> Again, why a u64?  pfn's are usually unsigned long.

I think variable's name 'pfn' is wrong rather than type choice
because this variable stores pagemap entry which is not a pure pfn.
There's room for improvement, so I'll try it in the next turn.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
