Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87A4C6B0280
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:35:42 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id a72so3031922ioe.13
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:35:42 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h10si1299576ioa.106.2017.11.29.06.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 06:35:41 -0800 (PST)
Date: Wed, 29 Nov 2017 15:35:26 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86/mm/kaiser: Flush the correct ASID in
 __native_flush_tlb_single()
Message-ID: <20171129143526.GP3326@worktop>
References: <20171128095531.F32E1BC7@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128095531.F32E1BC7@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, bp@alien8.de, x86@kernel.org

On Tue, Nov 28, 2017 at 01:55:31AM -0800, Dave Hansen wrote:
>  static inline void __native_flush_tlb_single(unsigned long addr)
>  {
> +	u16 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
>  
>  	/*
> +	 * Handle systems that do not support PCIDs.  This will also
> +	 * get used in cases where this is called before PCID detection
> +	 * is done.
>  	 */
>  	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE)) {
> +		__invlpg(addr);
>  		return;
>  	}
> +
> +	/*
> +	 * An "invalid" loaded_mm_asid means that we have not
> +	 * initialized 'cpu_tlbstate' and are not using PCIDs.
> +	 * Just flush the TLB as if PCIDs were not present.
> +	 */
> +	if (loaded_mm_asid == INVALID_HW_ASID) {
> +		__invlpg(addr);
> +		return;
> +	}
> +
>  	/* Flush the address out of both PCIDs. */
>  	/*
>  	 * An optimization here might be to determine addresses
> @@ -451,6 +474,9 @@ static inline void __native_flush_tlb_si
>  	if (kern_asid(loaded_mm_asid) != user_asid(loaded_mm_asid))
>  		invpcid_flush_one(user_asid(loaded_mm_asid), addr);
>  	invpcid_flush_one(kern_asid(loaded_mm_asid), addr);
> +
> +	/* Check that we are flushing the active ASID: */
> +	VM_WARN_ON_ONCE(kern_asid(loaded_mm_asid) != cr3_asid());
>  }

Can't we do this differently (after my recent patches)? It appears to me
we can unconditionally do INVLPG to shoot down the kernel mapping, and
then, depending on INVPCID support we can either use that to shoot down
a single page or simply invalidate the entire user mapping.

---
 arch/x86/include/asm/tlbflush.h | 23 +++++++----------------
 1 file changed, 7 insertions(+), 16 deletions(-)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 481d5094559e..9587722162ee 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -438,29 +438,20 @@ static inline void __native_flush_tlb_single(unsigned long addr)
 {
 	u32 loaded_mm_asid = this_cpu_read(cpu_tlbstate.loaded_mm_asid);
 
+	asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
+
+	if (!kaiser_enabled)
+		return;
+
 	/*
 	 * Some platforms #GP if we call invpcid(type=1/2) before
 	 * CR4.PCIDE=1.  Just call invpcid in the case we are called
 	 * early.
 	 */
-	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE)) {
+	if (!this_cpu_has(X86_FEATURE_INVPCID_SINGLE))
 		flush_user_asid(loaded_mm_asid);
-		asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
-		return;
-	}
-	/* Flush the address out of both PCIDs. */
-	/*
-	 * An optimization here might be to determine addresses
-	 * that are only kernel-mapped and only flush the kernel
-	 * ASID.  But, userspace flushes are probably much more
-	 * important performance-wise.
-	 *
-	 * Make sure to do only a single invpcid when KAISER is
-	 * disabled and we have only a single ASID.
-	 */
-	if (kern_asid(loaded_mm_asid) != user_asid(loaded_mm_asid))
+	else
 		invpcid_flush_one(user_asid(loaded_mm_asid), addr);
-	invpcid_flush_one(kern_asid(loaded_mm_asid), addr);
 }
 
 static inline void __flush_tlb_all(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
