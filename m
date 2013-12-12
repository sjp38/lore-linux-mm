Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2564D6B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 08:42:03 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so518199pdj.8
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:42:02 -0800 (PST)
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
        by mx.google.com with ESMTPS id 2si14865011pax.167.2013.12.12.05.41.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 05:42:00 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id y10so525884pdj.9
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:41:59 -0800 (PST)
Message-ID: <52A9BD23.9010902@linaro.org>
Date: Thu, 12 Dec 2013 21:41:55 +0800
From: Alex Shi <alex.shi@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] x86: mm: Account for the of CPUs that must be flushed
 during a TLB range flush
References: <1386849309-22584-1-git-send-email-mgorman@suse.de> <1386849309-22584-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1386849309-22584-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/12/2013 07:55 PM, Mel Gorman wrote:
> X86 TLB range flushing uses a balance point to decide if a single global TLB
> flush or multiple single page flushes would perform best.  This patch takes into
> account how many CPUs must be flushed.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  arch/x86/mm/tlb.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
> index 09b8cb8..0cababa 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -217,6 +217,9 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
>  	act_entries = mm->total_vm > act_entries ? act_entries : mm->total_vm;
>  	nr_base_pages = (end - start) >> PAGE_SHIFT;
>  
> +	/* Take the number of CPUs to range flush into account */
> +	nr_base_pages *= cpumask_weight(mm_cpumask(mm));
> +

flush range calculation base on per cpu, since no matter how many cpus
in the process, tlb flush and refill time won't change.
>  	/* tlb_flushall_shift is on balance point, details in commit log */
>  	if (nr_base_pages > act_entries || has_large_page(mm, start, end)) {
>  		count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
> 


-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
