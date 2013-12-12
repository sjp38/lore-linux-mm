Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7D46B0037
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:59:39 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so553743pde.20
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:59:39 -0800 (PST)
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
        by mx.google.com with ESMTPS id ek3si16632604pbd.175.2013.12.12.05.59.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 05:59:38 -0800 (PST)
Received: by mail-pb0-f43.google.com with SMTP id rq2so564695pbb.2
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:59:37 -0800 (PST)
Message-ID: <52A9C145.9050706@linaro.org>
Date: Thu, 12 Dec 2013 21:59:33 +0800
From: Alex Shi <alex.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] x86: mm: Clean up inconsistencies when flushing TLB
 ranges
References: <1386849309-22584-1-git-send-email-mgorman@suse.de> <1386849309-22584-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1386849309-22584-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/12/2013 07:55 PM, Mel Gorman wrote:
> NR_TLB_LOCAL_FLUSH_ALL is not always accounted for correctly and the
> comparison with total_vm is done before taking tlb_flushall_shift into
> account. Clean it up.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Alex Shi
> ---
>  arch/x86/mm/tlb.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index ae699b3..09b8cb8 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -189,6 +189,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  {
>  	unsigned long addr;
>  	unsigned act_entries, tlb_entries = 0;
> +	unsigned long nr_base_pages;
>  
>  	preempt_disable();
>  	if (current->active_mm != mm)
> @@ -210,18 +211,17 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  		tlb_entries = tlb_lli_4k[ENTRIES];
>  	else
>  		tlb_entries = tlb_lld_4k[ENTRIES];
> +
>  	/* Assume all of TLB entries was occupied by this task */

the benchmark break this assumption?
> -	act_entries = mm->total_vm > tlb_entries ? tlb_entries : mm->total_vm;
> +	act_entries = tlb_entries >> tlb_flushall_shift;
> +	act_entries = mm->total_vm > act_entries ? act_entries : mm->total_vm;
> +	nr_base_pages = (end - start) >> PAGE_SHIFT;
>  
>  	/* tlb_flushall_shift is on balance point, details in commit log */
> -	if ((end - start) >> PAGE_SHIFT > act_entries >> tlb_flushall_shift) {
> +	if (nr_base_pages > act_entries || has_large_page(mm, start, end)) {
>  		count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
>  		local_flush_tlb();
>  	} else {
> -		if (has_large_page(mm, start, end)) {
> -			local_flush_tlb();
> -			goto flush_all;
> -		}
>  		/* flush range by one by one 'invlpg' */
>  		for (addr = start; addr < end;	addr += PAGE_SIZE) {
>  			count_vm_event(NR_TLB_LOCAL_FLUSH_ONE);
> 


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
