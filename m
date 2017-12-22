Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D71D6B0069
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 04:02:40 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w141so5113299wme.1
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 01:02:40 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l192si6220743wmg.223.2017.12.22.01.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 01:02:39 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 097/159] x86/paravirt: Dont patch flush_tlb_single
Date: Fri, 22 Dec 2017 09:46:22 +0100
Message-Id: <20171222084628.988780401@linuxfoundation.org>
In-Reply-To: <20171222084623.668990192@linuxfoundation.org>
References: <20171222084623.668990192@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Borislav Petkov <bpetkov@suse.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, michael.schwarz@iaik.tugraz.at, moritz.lipp@iaik.tugraz.at, richard.fellner@student.tugraz.at, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Thomas Gleixner <tglx@linutronix.de>

commit a035795499ca1c2bd1928808d1a156eda1420383 upstream.

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
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/kernel/paravirt_patch_64.c |    2 --
 1 file changed, 2 deletions(-)

--- a/arch/x86/kernel/paravirt_patch_64.c
+++ b/arch/x86/kernel/paravirt_patch_64.c
@@ -10,7 +10,6 @@ DEF_NATIVE(pv_irq_ops, save_fl, "pushfq;
 DEF_NATIVE(pv_mmu_ops, read_cr2, "movq %cr2, %rax");
 DEF_NATIVE(pv_mmu_ops, read_cr3, "movq %cr3, %rax");
 DEF_NATIVE(pv_mmu_ops, write_cr3, "movq %rdi, %cr3");
-DEF_NATIVE(pv_mmu_ops, flush_tlb_single, "invlpg (%rdi)");
 DEF_NATIVE(pv_cpu_ops, wbinvd, "wbinvd");
 
 DEF_NATIVE(pv_cpu_ops, usergs_sysret64, "swapgs; sysretq");
@@ -60,7 +59,6 @@ unsigned native_patch(u8 type, u16 clobb
 		PATCH_SITE(pv_mmu_ops, read_cr2);
 		PATCH_SITE(pv_mmu_ops, read_cr3);
 		PATCH_SITE(pv_mmu_ops, write_cr3);
-		PATCH_SITE(pv_mmu_ops, flush_tlb_single);
 		PATCH_SITE(pv_cpu_ops, wbinvd);
 #if defined(CONFIG_PARAVIRT_SPINLOCKS)
 		case PARAVIRT_PATCH(pv_lock_ops.queued_spin_unlock):


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
