Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34CC46B03CB
	for <linux-mm@kvack.org>; Mon,  8 May 2017 11:35:00 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a66so66149773pfl.6
        for <linux-mm@kvack.org>; Mon, 08 May 2017 08:35:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s72si13440081pfa.114.2017.05.08.08.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 May 2017 08:34:59 -0700 (PDT)
Subject: Re: [RFC 03/10] x86/mm: Make the batched unmap TLB flush API more
 generic
References: <cover.1494160201.git.luto@kernel.org>
 <983c5ee661d8fe8a70c596c4e77076d11ce3f80a.1494160201.git.luto@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d36207ef-a4b3-24ef-40e4-9e6a22b092cb@intel.com>
Date: Mon, 8 May 2017 08:34:58 -0700
MIME-Version: 1.0
In-Reply-To: <983c5ee661d8fe8a70c596c4e77076d11ce3f80a.1494160201.git.luto@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Sasha Levin <sasha.levin@oracle.com>

On 05/07/2017 05:38 AM, Andy Lutomirski wrote:
> diff --git a/mm/rmap.c b/mm/rmap.c
> index f6838015810f..2e568c82f477 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -579,25 +579,12 @@ void page_unlock_anon_vma_read(struct anon_vma *anon_vma)
>  void try_to_unmap_flush(void)
>  {
>  	struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
> -	int cpu;
>  
>  	if (!tlb_ubc->flush_required)
>  		return;
>  
> -	cpu = get_cpu();
> -
> -	if (cpumask_test_cpu(cpu, &tlb_ubc->cpumask)) {
> -		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> -		local_flush_tlb();
> -		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
> -	}
> -
> -	if (cpumask_any_but(&tlb_ubc->cpumask, cpu) < nr_cpu_ids)
> -		flush_tlb_others(&tlb_ubc->cpumask, NULL, 0, TLB_FLUSH_ALL);
> -	cpumask_clear(&tlb_ubc->cpumask);
>  	tlb_ubc->flush_required = false;
>  	tlb_ubc->writable = false;
> -	put_cpu();
>  }
>  
>  /* Flush iff there are potentially writable TLB entries that can race with IO */
> @@ -613,7 +600,7 @@ static void set_tlb_ubc_flush_pending(struct mm_struct *mm, bool writable)
>  {
>  	struct tlbflush_unmap_batch *tlb_ubc = &current->tlb_ubc;
>  
> -	cpumask_or(&tlb_ubc->cpumask, &tlb_ubc->cpumask, mm_cpumask(mm));
> +	arch_tlbbatch_add_mm(&tlb_ubc->arch, mm);
>  	tlb_ubc->flush_required = true;
>  
>  	/*

Looking at this patch in isolation, how can this be safe?  It removes
TLB flushes from the generic code.  Do other patches in the series fix
this up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
