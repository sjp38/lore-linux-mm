Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B84506B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 16:38:27 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id n5so145496393pfn.2
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 13:38:27 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xw2si749220pac.192.2016.03.28.13.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 13:38:26 -0700 (PDT)
Date: Mon, 28 Mar 2016 13:38:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] x86/mm: TLB_REMOTE_SEND_IPI should count pages
Message-Id: <20160328133825.210d00fd4af7c7b7039a44c7@linux-foundation.org>
In-Reply-To: <1458980705-121507-2-git-send-email-namit@vmware.com>
References: <1458980705-121507-1-git-send-email-namit@vmware.com>
	<1458980705-121507-2-git-send-email-namit@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, mgorman@suse.de, sasha.levin@oracle.com, riel@redhat.com, dave.hansen@linux.intel.com, luto@kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, jmarchan@redhat.com, hughd@google.com, vdavydov@virtuozzo.com, minchan@kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Sat, 26 Mar 2016 01:25:04 -0700 Nadav Amit <namit@vmware.com> wrote:

> TLB_REMOTE_SEND_IPI was recently introduced, but it counts bytes instead
> of pages. In addition, it does not report correctly the case in which
> flush_tlb_page flushes a page. Fix it to be consistent with other TLB
> counters.
> 
> Fixes: 4595f9620cda8a1e973588e743cf5f8436dd20c6

I think you mean 5b74283ab251b9 ("x86, mm: trace when an IPI is about
to be sent")?

> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -106,8 +106,6 @@ static void flush_tlb_func(void *info)
>  
>  	if (f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
>  		return;
> -	if (!f->flush_end)
> -		f->flush_end = f->flush_start + PAGE_SIZE;
>  
>  	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
>  	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
> @@ -135,12 +133,20 @@ void native_flush_tlb_others(const struct cpumask *cpumask,
>  				 unsigned long end)
>  {
>  	struct flush_tlb_info info;
> +
> +	if (end == 0)
> +		end = start + PAGE_SIZE;
>  	info.flush_mm = mm;
>  	info.flush_start = start;
>  	info.flush_end = end;
>  
>  	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH);
> -	trace_tlb_flush(TLB_REMOTE_SEND_IPI, end - start);
> +	if (end == TLB_FLUSH_ALL)
> +		trace_tlb_flush(TLB_REMOTE_SEND_IPI, TLB_FLUSH_ALL);
> +	else
> +		trace_tlb_flush(TLB_REMOTE_SEND_IPI,
> +				(end - start) >> PAGE_SHIFT);
> +
>  	if (is_uv_system()) {
>  		unsigned int cpu;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
