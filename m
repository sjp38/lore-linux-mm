Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BCDA2600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 01:25:19 -0500 (EST)
Date: Mon, 4 Jan 2010 15:16:49 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 25 of 28] transparent hugepage core
Message-Id: <20100104151649.34f6c469.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <4d96699c8fb89a4a22eb.1261076428@v2.random>
References: <patchbomb.1261076403@v2.random>
	<4d96699c8fb89a4a22eb.1261076428@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

> +static int __do_huge_anonymous_page(struct mm_struct *mm,
> +				    struct vm_area_struct *vma,
> +				    unsigned long address, pmd_t *pmd,
> +				    struct page *page,
> +				    unsigned long haddr)
> +{
> +	int ret = 0;
> +	pgtable_t pgtable;
> +
> +	VM_BUG_ON(!PageCompound(page));
> +	pgtable = pte_alloc_one(mm, address);
> +	if (unlikely(!pgtable)) {
> +		put_page(page);
> +		return VM_FAULT_OOM;
> +	}
> +
> +	clear_huge_page(page, haddr, HPAGE_NR);
> +
> +	__SetPageUptodate(page);
> +	smp_wmb();
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (unlikely(!pmd_none(*pmd))) {
> +		put_page(page);
> +		pte_free(mm, pgtable);
> +	} else {
> +		pmd_t entry;
> +		entry = mk_pmd(page, vma->vm_page_prot);
> +		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +		entry = pmd_mkhuge(entry);
> +		page_add_new_anon_rmap(page, vma, haddr);
> +		set_pmd_at(mm, haddr, pmd, entry);
> +		prepare_pmd_huge_pte(pgtable, mm);
> +	}
> +	spin_unlock(&mm->page_table_lock);
> +	
> +	return ret;
> +}
> +
IIUC, page_add_new_anon_rmap()(and add_page_to_lru_list(), which will be called
by the call path) will update zone state of NR_ANON_PAGES and NR_ACTIVE_ANON.
Shouldn't we also modify zone state codes to support transparent hugepage support ?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
