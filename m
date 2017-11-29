Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 247D26B0069
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 10:21:27 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y2so2319188pgv.8
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 07:21:27 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b184si1380404pgc.787.2017.11.29.07.21.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 07:21:25 -0800 (PST)
Subject: Re: [PATCH] x86/mm/kaiser: Flush the correct ASID in
 __native_flush_tlb_single()
References: <20171128095531.F32E1BC7@viggo.jf.intel.com>
 <20171129143526.GP3326@worktop>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <27729551-ecd6-e4e9-d214-4ab03d8008da@linux.intel.com>
Date: Wed, 29 Nov 2017 07:21:23 -0800
MIME-Version: 1.0
In-Reply-To: <20171129143526.GP3326@worktop>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, bp@alien8.de, x86@kernel.org

On 11/29/2017 06:35 AM, Peter Zijlstra wrote:
>> @@ -451,6 +474,9 @@ static inline void __native_flush_tlb_si
>>  	if (kern_asid(loaded_mm_asid) != user_asid(loaded_mm_asid))
>>  		invpcid_flush_one(user_asid(loaded_mm_asid), addr);
>>  	invpcid_flush_one(kern_asid(loaded_mm_asid), addr);
>> +
>> +	/* Check that we are flushing the active ASID: */
>> +	VM_WARN_ON_ONCE(kern_asid(loaded_mm_asid) != cr3_asid());
>>  }
> 
> Can't we do this differently (after my recent patches)? It appears to me
> we can unconditionally do INVLPG to shoot down the kernel mapping, and
> then, depending on INVPCID support we can either use that to shoot down
> a single page or simply invalidate the entire user mapping.

Yes, that works.  Also, as I think about it, INVLPG is a safer
(bug-resistant) instruction to use too.  INVPCID _can_ get the current
(kernel) ASID wrong, as we saw.  But INVLPG always uses the current one
and can't be wrong about flushing the *current* ASID.

I think Andy measured it to be faster than INVPCID too.

So, maybe we should just remove INVPCID's use entirely.

>  arch/x86/include/asm/tlbflush.h | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
> 
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 481d5094559e..9587722162ee 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -438,29 +438,20 @@ static inline void __native_flush_tlb_single(unsigned long addr)
>  {
>  	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
>  
> +	asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
> +
> +	if (!kaiser_enabled)
> +		return;
> +
>  	/*
>  	 * Some platforms #GP if we call invpcid(type=1/2) before
>  	 * CR4.PCIDE=1.  Just call invpcid in the case we are called
>  	 * early.
>  	 */
> -	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE)) {
> +	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE))
>  		flush_user_asid(loaded_mm_asid);
> -		asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
> -		return;
> -	}
> -	/* Flush the address out of both PCIDs. */
> -	/*
> -	 * An optimization here might be to determine addresses
> -	 * that are only kernel-mapped and only flush the kernel
> -	 * ASID.  But, userspace flushes are probably much more
> -	 * important performance-wise.
> -	 *
> -	 * Make sure to do only a single invpcid when KAISER is
> -	 * disabled and we have only a single ASID.
> -	 */
> -	if (kern_asid(loaded_mm_asid) != user_asid(loaded_mm_asid))
> +	else
>  		invpcid_flush_one(user_asid(loaded_mm_asid), addr);
> -	invpcid_flush_one(kern_asid(loaded_mm_asid), addr);
>  }
>  
>  static inline void __flush_tlb_all(void)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
