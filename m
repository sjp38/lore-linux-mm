Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 687856B026D
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 11:48:34 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id f132so8712837wmf.6
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 08:48:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k40si1276168wrf.22.2017.12.27.08.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Dec 2017 08:48:33 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 26/74] x86/mm: Remove hard-coded ASID limit checks
Date: Wed, 27 Dec 2017 17:45:59 +0100
Message-Id: <20171227164615.143855374@linuxfoundation.org>
In-Reply-To: <20171227164614.109898944@linuxfoundation.org>
References: <20171227164614.109898944@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

commit cb0a9144a744e55207e24dcef812f05cd15a499a upstream.

First, it's nice to remove the magic numbers.

Second, PAGE_TABLE_ISOLATION is going to consume half of the available ASID
space.  The space is currently unused, but add a comment to spell out this
new restriction.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
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
 arch/x86/include/asm/tlbflush.h |   20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -69,6 +69,22 @@ static inline u64 inc_mm_tlb_gen(struct
 	return atomic64_inc_return(&mm->context.tlb_gen);
 }
 
+/* There are 12 bits of space for ASIDS in CR3 */
+#define CR3_HW_ASID_BITS		12
+/*
+ * When enabled, PAGE_TABLE_ISOLATION consumes a single bit for
+ * user/kernel switches
+ */
+#define PTI_CONSUMED_ASID_BITS		0
+
+#define CR3_AVAIL_ASID_BITS (CR3_HW_ASID_BITS - PTI_CONSUMED_ASID_BITS)
+/*
+ * ASIDs are zero-based: 0->MAX_AVAIL_ASID are valid.  -1 below to account
+ * for them being zero-based.  Another -1 is because ASID 0 is reserved for
+ * use by non-PCID-aware users.
+ */
+#define MAX_ASID_AVAILABLE ((1 << CR3_AVAIL_ASID_BITS) - 2)
+
 /*
  * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID bits.
  * This serves two purposes.  It prevents a nasty situation in which
@@ -81,7 +97,7 @@ struct pgd_t;
 static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
 {
 	if (static_cpu_has(X86_FEATURE_PCID)) {
-		VM_WARN_ON_ONCE(asid > 4094);
+		VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
 		return __sme_pa(pgd) | (asid + 1);
 	} else {
 		VM_WARN_ON_ONCE(asid != 0);
@@ -91,7 +107,7 @@ static inline unsigned long build_cr3(pg
 
 static inline unsigned long build_cr3_noflush(pgd_t *pgd, u16 asid)
 {
-	VM_WARN_ON_ONCE(asid > 4094);
+	VM_WARN_ON_ONCE(asid > MAX_ASID_AVAILABLE);
 	return __sme_pa(pgd) | (asid + 1) | CR3_NOFLUSH;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
