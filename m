Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0978C6B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 10:14:36 -0500 (EST)
Date: Mon, 7 Jan 2013 15:14:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 22/49] mm: mempolicy: Add MPOL_MF_LAZY
Message-ID: <20130107151430.GL3885@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <1354875832-9700-23-git-send-email-mgorman@suse.de>
 <1357363097.5273.12.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1357363097.5273.12.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 04, 2013 at 11:18:17PM -0600, Simon Jeons wrote:
> > +static int
> > +change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
> > +			unsigned long address)
> > +{
> > +	pgd_t *pgd;
> > +	pud_t *pud;
> > +	pmd_t *pmd;
> > +	pte_t *pte, *_pte;
> > +	struct page *page;
> > +	unsigned long _address, end;
> > +	spinlock_t *ptl;
> > +	int ret = 0;
> > +
> > +	VM_BUG_ON(address & ~PAGE_MASK);
> > +
> > +	pgd = pgd_offset(mm, address);
> > +	if (!pgd_present(*pgd))
> > +		goto out;
> > +
> > +	pud = pud_offset(pgd, address);
> > +	if (!pud_present(*pud))
> > +		goto out;
> > +
> > +	pmd = pmd_offset(pud, address);
> > +	if (pmd_none(*pmd))
> > +		goto out;
> > +
> > +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> > +		int page_nid;
> > +		ret = HPAGE_PMD_NR;
> > +
> > +		VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> > +
> > +		if (pmd_numa(*pmd)) {
> > +			spin_unlock(&mm->page_table_lock);
> > +			goto out;
> > +		}
> > +
> > +		page = pmd_page(*pmd);
> > +
> > +		/* only check non-shared pages */
> > +		if (page_mapcount(page) != 1) {
> > +			spin_unlock(&mm->page_table_lock);
> > +			goto out;
> > +		}
> > +
> > +		page_nid = page_to_nid(page);
> > +
> > +		if (pmd_numa(*pmd)) {
> > +			spin_unlock(&mm->page_table_lock);
> > +			goto out;
> > +		}
> > +
> 
> Hi Gorman,
> 
> Since pmd_trans_huge_lock has already held &mm->page_table_lock, then
> why check pmd_numa(*pmd) again?
> 

It looks like oversight. I've added a TODO item to clean it up when I
revisit NUMA balancing some time soon.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
