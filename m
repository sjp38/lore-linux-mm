Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 53C4A6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 09:30:01 -0400 (EDT)
Date: Thu, 2 Jun 2011 15:29:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110602132954.GC19505@random.random>
References: <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110601005747.GC7019@csn.ul.ie>
 <20110601175809.GB7306@suse.de>
 <20110601191529.GY19505@random.random>
 <20110601214018.GC7306@suse.de>
 <20110601233036.GZ19505@random.random>
 <20110602010352.GD7306@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602010352.GD7306@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Thu, Jun 02, 2011 at 02:03:52AM +0100, Mel Gorman wrote:
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 2d29c9a..65fa251 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -631,12 +631,14 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>  		entry = mk_pmd(page, vma->vm_page_prot);
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
>  		entry = pmd_mkhuge(entry);
> +
>  		/*
> -		 * The spinlocking to take the lru_lock inside
> -		 * page_add_new_anon_rmap() acts as a full memory
> -		 * barrier to be sure clear_huge_page writes become
> -		 * visible after the set_pmd_at() write.
> +		 * Need a write barrier to ensure the writes from
> +		 * clear_huge_page become visible before the
> +		 * set_pmd_at
>  		 */
> +		smp_wmb();
> +

On x86 at least this is noop because of the
spin_lock(&page_table_lock) after clear_huge_page. But I'm not against
adding this in case other archs supports THP later.

But smp_wmb() is optimized away at build time by cpp so this can't
possibly help if you're reproducing !SMP.

>  		page_add_new_anon_rmap(page, vma, haddr);
>  		set_pmd_at(mm, haddr, pmd, entry);
>  		prepare_pmd_huge_pte(pgtable, mm);
> @@ -753,6 +755,13 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  
>  	pmdp_set_wrprotect(src_mm, addr, src_pmd);
>  	pmd = pmd_mkold(pmd_wrprotect(pmd));
> +
> +	/*
> +	 * Write barrier to make sure the setup for the PMD is fully visible
> +	 * before the set_pmd_at
> +	 */
> +	smp_wmb();
> +
>  	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
>  	prepare_pmd_huge_pte(pgtable, dst_mm);

This part seems superfluous to me, it's also noop for !SMP. Only wmb()
would stay. the pmd is perfectly fine to stay in a register, not even
a compiler barrier is needed, even less a smp serialization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
