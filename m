Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2E36B025E
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:28:16 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d134so219920484pfd.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:28:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b27si4583007pgn.86.2017.01.23.15.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 15:28:15 -0800 (PST)
Date: Mon, 23 Jan 2017 15:28:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: write protect MADV_FREE pages
Message-Id: <20170123152814.2a55c4110df3bd0d67de5fc3@linux-foundation.org>
In-Reply-To: <791151284cd6941296f08488b8cb7f1968175a0a.1485212872.git.shli@fb.com>
References: <791151284cd6941296f08488b8cb7f1968175a0a.1485212872.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, Kernel-team@fb.com, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@surriel.com>, stable@kernel.org

On Mon, 23 Jan 2017 15:15:52 -0800 Shaohua Li <shli@fb.com> wrote:

> The page reclaim has an assumption writting to a page with clean pte
> should trigger a page fault, because there is a window between pte zero
> and tlb flush where a new write could come. If the new write doesn't
> trigger page fault, page reclaim will not notice it and think the page
> is clean and reclaim it. The MADV_FREE pages don't comply with the rule
> and the pte is just cleaned without writeprotect, so there will be no
> pagefault for new write. This will cause data corruption.

I'd like to see here a complete description of the bug's effects: waht
sort of workload will trigger it, what the end-user visible effects
are, etc.

> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1381,6 +1381,7 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  			tlb->fullmm);
>  		orig_pmd = pmd_mkold(orig_pmd);
>  		orig_pmd = pmd_mkclean(orig_pmd);
> +		orig_pmd = pmd_wrprotect(orig_pmd);

Is this the right way round?  There's still a window where we won't get
that write fault on the cleaned pte.  Should the pmd_wrprotect() happen
before the pmd_mkclean()?


>  		set_pmd_at(mm, addr, pmd, orig_pmd);
>  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 0e3828e..bfb6800 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -373,6 +373,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  
>  			ptent = pte_mkold(ptent);
>  			ptent = pte_mkclean(ptent);
> +			ptent = pte_wrprotect(ptent);
>  			set_pte_at(mm, addr, pte, ptent);
>  			if (PageActive(page))
>  				deactivate_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
