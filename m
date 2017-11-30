Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 136696B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 07:43:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u16so4861175pfh.7
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 04:43:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v5si2959270pgc.309.2017.11.30.04.43.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 04:43:33 -0800 (PST)
Date: Thu, 30 Nov 2017 13:43:19 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/6] x86/mm/kaiser: Optimize __native_flush_tlb
Message-ID: <20171130124319.ovyierac7ywxzhjy@hirez.programming.kicks-ass.net>
References: <20171129103301.131535445@infradead.org>
 <20171129103512.918991807@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171129103512.918991807@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at

On Wed, Nov 29, 2017 at 11:33:07AM +0100, Peter Zijlstra wrote:

>  static inline void __native_flush_tlb(void)
>  {
> +	flush_user_asid(this_cpu_read(cpu_tlbstate.loaded_mm_asid));
>  
>  	/*
> +	 * If current->mm == NULL then we borrow a mm
> +	 * which may change during a task switch and
> +	 * therefore we must not be preempted while we
> +	 * write CR3 back:
>  	 */
> +	preempt_disable();
> +	native_write_cr3(__native_read_cr3());
> +	preempt_enable();



> +	/*
> +	 * Does not need tlb_flush_shared_nonglobals()
> +	 * since the CR3 write without PCIDs flushes all
> +	 * non-globals.
> +	 */
> +	return;

OK, so seeing that comment today made me realize I had so far failed to
audit the whole flush user vs flush kernel thing.

In short the above comment is complete crap.

>  }


The longer story is that:

  flush_tlb_all()
  flush_tlb_kernel_range()

need to flush kernel pages and thus flush _all_ the (kernel) ASIDs.

Whereas:

  flush_tlb_mm()
  flush_tlb_range()
  flush_tlb_page()

Only flush user pages, and thus only need to flush the respective user
and kernel ASID.

The last 3 all map to flush_tlb_mm_range() which, through
flush_tlb_func_{local,remote} ends up in flush_tlb_func_common(), which
then uses either __flush_tlb() or __flush_tlb_single().

Both __flush_tlb() (the above function) and __flush_tlb_single() only
(need to) flush the 2 ASIDs that contain the user mapping.

Now the problem is that flush_tlb_kernel_range() is implemented using
either __flush_tlb_all() or __flush_tlb_single(), and it is that last
use that is buggered.

So at the very least we need the below to cure things, but there is
another inconsistency; do_flush_tlb_all() is used by both
flush_tlb_all() and flush_tlb_kernel_range() and increments NR_TLB_*,
do_kernel_range_flush() OTOH does not increment NR_TLB_*. I'm not fixing
that, but I'll leave a comment around or something, so we can later try
and figure out what exact statistics we want.

---

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 9587722162ee..ccaf6e126582 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -388,12 +388,6 @@ static inline void __native_flush_tlb(void)
 	preempt_disable();
 	native_write_cr3(__native_read_cr3());
 	preempt_enable();
-	/*
-	 * Does not need tlb_flush_shared_nonglobals()
-	 * since the CR3 write without PCIDs flushes all
-	 * non-globals.
-	 */
-	return;
 }
 
 static inline void __native_flush_tlb_global_irq_disabled(void)
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 122c48fa6012..24bd86118b46 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -609,6 +609,8 @@ static void do_kernel_range_flush(void *info)
 	/* flush range by one by one 'invlpg' */
 	for (addr = f->start; addr < f->end; addr += PAGE_SIZE)
 		__flush_tlb_single(addr);
+
+	tlb_flush_shared_nonglobals();
 }
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
