Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 595456B026A
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:48:28 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k2so11006243wrh.16
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:48:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j77si13457977wmi.266.2017.12.27.08.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:48:27 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 24/74] x86/mm: Add comments to clarify which TLB-flush functions are supposed to flush what
Date: Wed, 27 Dec 2017 17:45:57 +0100
Message-Id: <20171227164615.068071173@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Peter Zijlstra <peterz@infradead.org>

commit 3f67af51e56f291d7417d77c4f67cd774633c5e1 upstream.

Per popular request..

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/tlbflush.h |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -228,6 +228,9 @@ static inline void cr4_set_bits_and_upda
 
 extern void initialize_tlbstate_and_flush(void);
 
+/*
+ * flush the entire current user mapping
+ */
 static inline void __native_flush_tlb(void)
 {
 	/*
@@ -240,6 +243,9 @@ static inline void __native_flush_tlb(vo
 	preempt_enable();
 }
 
+/*
+ * flush everything
+ */
 static inline void __native_flush_tlb_global(void)
 {
 	unsigned long cr4, flags;
@@ -269,17 +275,27 @@ static inline void __native_flush_tlb_gl
 	raw_local_irq_restore(flags);
 }
 
+/*
+ * flush one page in the user mapping
+ */
 static inline void __native_flush_tlb_single(unsigned long addr)
 {
 	asm volatile("invlpg (%0)" ::"r" (addr) : "memory");
 }
 
+/*
+ * flush everything
+ */
 static inline void __flush_tlb_all(void)
 {
-	if (boot_cpu_has(X86_FEATURE_PGE))
+	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		__flush_tlb_global();
-	else
+	} else {
+		/*
+		 * !PGE -> !PCID (setup_pcid()), thus every flush is total.
+		 */
 		__flush_tlb();
+	}
 
 	/*
 	 * Note: if we somehow had PCID but not PGE, then this wouldn't work --
@@ -290,6 +306,9 @@ static inline void __flush_tlb_all(void)
 	 */
 }
 
+/*
+ * flush one page in the kernel mapping
+ */
 static inline void __flush_tlb_one(unsigned long addr)
 {
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
