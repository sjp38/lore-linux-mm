Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 69D536B0062
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 14:17:03 -0500 (EST)
Message-ID: <4EEF8D81.4080301@ah.jp.nec.com>
Date: Mon, 19 Dec 2011 14:16:17 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] pagemap: avoid splitting thp when reading /proc/pid/pagemap
References: <1324319919-31720-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324319919-31720-2-git-send-email-n-horiguchi@ah.jp.nec.com> <alpine.DEB.2.00.1112191044300.19949@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1112191044300.19949@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Dec 19, 2011 at 10:48:17AM -0800, David Rientjes wrote:
> On Mon, 19 Dec 2011, Naoya Horiguchi wrote:
...
> > @@ -666,10 +685,33 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >  	pte_t *pte;
> >  	int err = 0;
> >  
> > -	split_huge_page_pmd(walk->mm, pmd);
> > -
> >  	/* find the first VMA at or above 'addr' */
> >  	vma = find_vma(walk->mm, addr);
> > +
> > +	spin_lock(&walk->mm->page_table_lock);
> 
> pagemap_pte_range() could potentially be called a _lot_, so I'd recommend 
> optimizing this by checking for pmd_trans_huge() prior to taking 
> page_table_lock and then rechecking after grabbing it with likely().

OK, I'll try it.
Similar logic is used on smaps_pte_range() and gather_pte_stats(),
so I think it's better to write a separate patch for this optimization.

> > +	if (pmd_trans_huge(*pmd)) {
> > +		if (pmd_trans_splitting(*pmd)) {
> > +			spin_unlock(&walk->mm->page_table_lock);
> > +			wait_split_huge_page(vma->anon_vma, pmd);
> > +		} else {
> > +			u64 pfn = PM_NOT_PRESENT;
> 
> This doesn't need to be initialized and it would probably be better to 
> declare "pfn" at the top-level of this function since it's later used for 
> the non-thp case.

Agreed.
I unify two declarations of "pfn" at the beginning of the function.

Thank you for nice feedback.
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
