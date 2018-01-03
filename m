Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E41B46B037C
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 15:13:18 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g13so135964wrh.19
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 12:13:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d30si1447958wrb.217.2018.01.03.12.13.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 12:13:17 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 32/37] x86/paravirt: Dont patch flush_tlb_single
Date: Wed,  3 Jan 2018 21:11:38 +0100
Message-Id: <20180103195058.503981922@linuxfoundation.org>
In-Reply-To: <20180103195056.837404126@linuxfoundation.org>
References: <20180103195056.837404126@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Borislav Petkov <bpetkov@suse.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@suse.de>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Thomas Gleixner <tglx@linutronix.de>


commit a035795499ca1c2bd1928808d1a156eda1420383 upstream

native_flush_tlb_single() will be changed with the upcoming
PAGE_TABLE_ISOLATION feature. This requires to have more code in
there than INVLPG.

Remove the paravirt patching for it.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Josh Poimboeuf <jpoimboe@redhat.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Borislav Petkov <bpetkov@suse.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
Cc: michael.schwarz@iaik.tugraz.at
Cc: moritz.lipp@iaik.tugraz.at
Cc: richard.fellner@student.tugraz.at
Link: https://lkml.kernel.org/r/20171204150606.828111617@linutronix.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Acked-by: Borislav Petkov <bp@suse.de>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/x86/kernel/paravirt_patch_64.c |    2 --
 1 file changed, 2 deletions(-)

--- a/arch/x86/kernel/paravirt_patch_64.c
+++ b/arch/x86/kernel/paravirt_patch_64.c
@@ -9,7 +9,6 @@ DEF_NATIVE(pv_irq_ops, save_fl, "pushfq;
 DEF_NATIVE(pv_mmu_ops, read_cr2, "movq %cr2, %rax");
 DEF_NATIVE(pv_mmu_ops, read_cr3, "movq %cr3, %rax");
 DEF_NATIVE(pv_mmu_ops, write_cr3, "movq %rdi, %cr3");
-DEF_NATIVE(pv_mmu_ops, flush_tlb_single, "invlpg (%rdi)");
 DEF_NATIVE(pv_cpu_ops, clts, "clts");
 DEF_NATIVE(pv_cpu_ops, wbinvd, "wbinvd");
 
@@ -62,7 +61,6 @@ unsigned native_patch(u8 type, u16 clobb
 		PATCH_SITE(pv_mmu_ops, read_cr3);
 		PATCH_SITE(pv_mmu_ops, write_cr3);
 		PATCH_SITE(pv_cpu_ops, clts);
-		PATCH_SITE(pv_mmu_ops, flush_tlb_single);
 		PATCH_SITE(pv_cpu_ops, wbinvd);
 #if defined(CONFIG_PARAVIRT_SPINLOCKS) && defined(CONFIG_QUEUED_SPINLOCKS)
 		case PARAVIRT_PATCH(pv_lock_ops.queued_spin_unlock):


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
