Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 707B26B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 00:52:31 -0500 (EST)
Date: Mon, 29 Nov 2010 14:38:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 53 of 66] add numa awareness to hugepage allocations
Message-Id: <20101129143801.abef5228.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <223ee926614158fc1353.1288798108@v2.random>
References: <patchbomb.1288798055@v2.random>
	<223ee926614158fc1353.1288798108@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> @@ -1655,7 +1672,11 @@ static void collapse_huge_page(struct mm
>  	unsigned long hstart, hend;
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +#ifndef CONFIG_NUMA
>  	VM_BUG_ON(!*hpage);
> +#else
> +	VM_BUG_ON(*hpage);
> +#endif
>  
>  	/*
>  	 * Prevent all access to pagetables with the exception of
> @@ -1693,7 +1714,15 @@ static void collapse_huge_page(struct mm
>  	if (!pmd_present(*pmd) || pmd_trans_huge(*pmd))
>  		goto out;
>  
> +#ifndef CONFIG_NUMA
>  	new_page = *hpage;
> +#else
> +	new_page = alloc_hugepage_vma(khugepaged_defrag(), vma, address);
> +	if (unlikely(!new_page)) {
> +		*hpage = ERR_PTR(-ENOMEM);
> +		goto out;
> +	}
> +#endif
>  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL)))
>  		goto out;
>  
I think this should be:

	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
#ifdef CONFIG_NUMA
		put_page(new_page);
#endif
		goto out;
	}

Thanks,
Daisuke Nishimura.

> @@ -1724,6 +1753,9 @@ static void collapse_huge_page(struct mm
>  		spin_unlock(&mm->page_table_lock);
>  		anon_vma_unlock(vma->anon_vma);
>  		mem_cgroup_uncharge_page(new_page);
> +#ifdef CONFIG_NUMA
> +		put_page(new_page);
> +#endif
>  		goto out;
>  	}
>  
> @@ -1759,7 +1791,9 @@ static void collapse_huge_page(struct mm
>  	mm->nr_ptes--;
>  	spin_unlock(&mm->page_table_lock);
>  
> +#ifndef CONFIG_NUMA
>  	*hpage = NULL;
> +#endif
>  	khugepaged_pages_collapsed++;
>  out:
>  	up_write(&mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
