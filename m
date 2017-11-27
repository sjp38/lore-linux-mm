Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6714D6B0261
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 16:13:54 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id d93so13224321oic.4
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 13:13:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z92si10035478otb.547.2017.11.27.13.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 13:13:53 -0800 (PST)
Date: Mon, 27 Nov 2017 15:13:45 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [patch 1/4] x86/paravirt: Dont patch flush_tlb_single
Message-ID: <20171127211345.g7qxhhmgfcz66xhl@treble>
References: <20171127203416.236563829@linutronix.de>
 <20171127204257.497387357@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20171127204257.497387357@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Juergen Gross <jgross@suse.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Mon, Nov 27, 2017 at 09:34:17PM +0100, Thomas Gleixner wrote:
> native_flush_tlb_single() is not just INLVPG anymore. With
> X86_FEATURE_INVPCID_SINGLE and KAISER enabled it flushes also the shadow
> mapping. But even with KAISER disabled flushing the particular ASID is the
> right thing to do.
> 
> Remove the paravirt patching for it.
> 
> Fixes: 1fde25dc8ef4 ("x86/mm/kaiser: Use PCID feature to make user and kernel switches faster")
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> ---
>  arch/x86/kernel/paravirt_patch_64.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> --- a/arch/x86/kernel/paravirt_patch_64.c
> +++ b/arch/x86/kernel/paravirt_patch_64.c
> @@ -10,7 +10,6 @@ DEF_NATIVE(pv_irq_ops, save_fl, "pushfq;
>  DEF_NATIVE(pv_mmu_ops, read_cr2, "movq %cr2, %rax");
>  DEF_NATIVE(pv_mmu_ops, read_cr3, "movq %cr3, %rax");
>  DEF_NATIVE(pv_mmu_ops, write_cr3, "movq %rdi, %cr3");
> -DEF_NATIVE(pv_mmu_ops, flush_tlb_single, "invlpg (%rdi)");
>  DEF_NATIVE(pv_cpu_ops, wbinvd, "wbinvd");
>  
>  DEF_NATIVE(pv_cpu_ops, usergs_sysret64, "swapgs; sysretq");
> @@ -60,7 +59,6 @@ unsigned native_patch(u8 type, u16 clobb
>  		PATCH_SITE(pv_mmu_ops, read_cr2);
>  		PATCH_SITE(pv_mmu_ops, read_cr3);
>  		PATCH_SITE(pv_mmu_ops, write_cr3);
> -		PATCH_SITE(pv_mmu_ops, flush_tlb_single);
>  		PATCH_SITE(pv_cpu_ops, wbinvd);
>  #if defined(CONFIG_PARAVIRT_SPINLOCKS)
>  		case PARAVIRT_PATCH(pv_lock_ops.queued_spin_unlock):

Nice find!

Reviewed-and-tested-by: Josh Poimboeuf <jpoimboe@redhat.com>

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
