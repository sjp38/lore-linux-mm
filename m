Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 10C8F6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 20:25:25 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAJ1PN9w028313
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Nov 2010 10:25:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 05A4545DE52
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:25:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D318045DE53
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:25:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AA62C1DB8015
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:25:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C1451DB8014
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 10:25:22 +0900 (JST)
Date: Fri, 19 Nov 2010 10:19:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 39 of 66] memcg huge memory
Message-Id: <20101119101938.2edf889f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <877d2f205026b0463450.1288798094@v2.random>
References: <patchbomb.1288798055@v2.random>
	<877d2f205026b0463450.1288798094@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, 03 Nov 2010 16:28:14 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Add memcg charge/uncharge to hugepage faults in huge_memory.c.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -233,6 +233,7 @@ static int __do_huge_pmd_anonymous_page(
>  	VM_BUG_ON(!PageCompound(page));
>  	pgtable = pte_alloc_one(mm, haddr);
>  	if (unlikely(!pgtable)) {
> +		mem_cgroup_uncharge_page(page);
>  		put_page(page);
>  		return VM_FAULT_OOM;
>  	}
> @@ -243,6 +244,7 @@ static int __do_huge_pmd_anonymous_page(
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_none(*pmd))) {
>  		spin_unlock(&mm->page_table_lock);
> +		mem_cgroup_uncharge_page(page);
>  		put_page(page);
>  		pte_free(mm, pgtable);
>  	} else {
> @@ -286,6 +288,10 @@ int do_huge_pmd_anonymous_page(struct mm
>  		page = alloc_hugepage(transparent_hugepage_defrag(vma));
>  		if (unlikely(!page))
>  			goto out;
> +		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
> +			put_page(page);
> +			goto out;
> +		}
>  
>  		return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
>  	}
> @@ -402,9 +408,15 @@ static int do_huge_pmd_wp_page_fallback(
>  	for (i = 0; i < HPAGE_PMD_NR; i++) {
>  		pages[i] = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
>  					  vma, address);
> -		if (unlikely(!pages[i])) {
> -			while (--i >= 0)
> +		if (unlikely(!pages[i] ||
> +			     mem_cgroup_newpage_charge(pages[i], mm,
> +						       GFP_KERNEL))) {
> +			if (pages[i])
>  				put_page(pages[i]);
> +			while (--i >= 0) {
> +				mem_cgroup_uncharge_page(pages[i]);
> +				put_page(pages[i]);
> +			}

Maybe you can use batched-uncharge here.
==
mem_cgroup_uncharge_start()
{
	do loop;
}
mem_cgroup_uncharge_end();
==
Then, many atomic ops can be reduced.


>  			kfree(pages);
>  			ret |= VM_FAULT_OOM;
>  			goto out;
> @@ -455,8 +467,10 @@ out:
>  
>  out_free_pages:
>  	spin_unlock(&mm->page_table_lock);
> -	for (i = 0; i < HPAGE_PMD_NR; i++)
> +	for (i = 0; i < HPAGE_PMD_NR; i++) {
> +		mem_cgroup_uncharge_page(pages[i]);
>  		put_page(pages[i]);
> +	}

here, too.

>  	kfree(pages);
>  	goto out;
>  }
> @@ -501,14 +515,22 @@ int do_huge_pmd_wp_page(struct mm_struct
>  		goto out;
>  	}
>  
> +	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> +		put_page(new_page);
> +		put_page(page);
> +		ret |= VM_FAULT_OOM;
> +		goto out;
> +	}
> +
>  	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
>  	__SetPageUptodate(new_page);
>  
>  	spin_lock(&mm->page_table_lock);
>  	put_page(page);
> -	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> +	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
> +		mem_cgroup_uncharge_page(new_page);
>  		put_page(new_page);
> -	else {
> +	} else {
>  		pmd_t entry;
>  		VM_BUG_ON(!PageHead(page));
>  		entry = mk_pmd(new_page, vma->vm_page_prot);


Hmm...it seems there are no codes for move_account() hugepage in series.
I think it needs some complicated work to walk page table.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
