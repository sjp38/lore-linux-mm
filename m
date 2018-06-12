Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC3B66B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 09:53:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v12-v6so7667520wmc.1
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 06:53:18 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g27-v6si480561edb.317.2018.06.12.06.53.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 06:53:17 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5CDoTlq115971
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 09:53:15 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jjeanm26a-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 09:53:14 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 12 Jun 2018 09:53:13 -0400
Subject: Re: [RFC PATCH 1/3] Revert "mm: always flush VMA ranges affected by
 zap_page_range"
References: <20180612071621.26775-1-npiggin@gmail.com>
 <20180612071621.26775-2-npiggin@gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Tue, 12 Jun 2018 19:23:04 +0530
MIME-Version: 1.0
In-Reply-To: <20180612071621.26775-2-npiggin@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <87943ec8-49f8-7956-f88f-d3b5ff91bbde@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 06/12/2018 12:46 PM, Nicholas Piggin wrote:
> This reverts commit 4647706ebeee6e50f7b9f922b095f4ec94d581c3.
> 
> Patch 99baac21e4585 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss
> problem") provides a superset of the TLB flush coverage of this
> commit, and even includes in the changelog "this patch supersedes
> 'mm: Always flush VMA ranges affected by zap_page_range v2'".
> 
> Reverting this avoids double flushing the TLB range, and the less
> efficient flush_tlb_range() call (the mmu_gather API is more precise
> about what ranges it invalidates).
> 
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
>   mm/memory.c | 14 +-------------
>   1 file changed, 1 insertion(+), 13 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 7206a634270b..9d472e00fc2d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1603,20 +1603,8 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long start,
>   	tlb_gather_mmu(&tlb, mm, start, end);
>   	update_hiwater_rss(mm);
>   	mmu_notifier_invalidate_range_start(mm, start, end);
> -	for ( ; vma && vma->vm_start < end; vma = vma->vm_next) {
> +	for ( ; vma && vma->vm_start < end; vma = vma->vm_next)
>   		unmap_single_vma(&tlb, vma, start, end, NULL);
> -
> -		/*
> -		 * zap_page_range does not specify whether mmap_sem should be
> -		 * held for read or write. That allows parallel zap_page_range
> -		 * operations to unmap a PTE and defer a flush meaning that
> -		 * this call observes pte_none and fails to flush the TLB.
> -		 * Rather than adding a complex API, ensure that no stale
> -		 * TLB entries exist when this call returns.
> -		 */
> -		flush_tlb_range(vma, start, end);
> -	}
> -
>   	mmu_notifier_invalidate_range_end(mm, start, end);
>   	tlb_finish_mmu(&tlb, start, end);
>   }
> 

No really related to this patch, but does 99baac21e4585 do the right 
thing if the range start - end covers pages with multiple page sizes?

-aneesh
