Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8BB6B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 21:28:57 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so12442727pac.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 18:28:56 -0800 (PST)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id vt6si46685579pab.166.2015.11.03.18.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 18:28:56 -0800 (PST)
Received: by pacrf6 with SMTP id rf6so4434005pac.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 18:28:56 -0800 (PST)
Date: Wed, 4 Nov 2015 11:29:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Message-ID: <20151104022951.GA3744@swordfish>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446600367-7976-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (11/04/15 10:25), Minchan Kim wrote:
[..]
> +static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
> +
> +{
> +	struct mmu_gather *tlb = walk->private;
> +	struct mm_struct *mm = tlb->mm;
> +	struct vm_area_struct *vma = walk->vma;
> +	spinlock_t *ptl;
> +	pte_t *pte, ptent;
> +	struct page *page;


I'll just ask (probably I'm missing something)

	+ pmd_trans_huge_lock() ?

> +	split_huge_page_pmd(vma, addr, pmd);
> +	if (pmd_trans_unstable(pmd))
> +		return 0;
> +
> +	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	arch_enter_lazy_mmu_mode();
> +	for (; addr != end; pte++, addr += PAGE_SIZE) {
> +		ptent = *pte;
> +
> +		if (!pte_present(ptent))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, ptent);
> +		if (!page)
> +			continue;
> +

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
