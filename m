Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D06AD680CE3
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 18:32:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j3so460280pga.5
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 15:32:22 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m29si2762927pfk.373.2017.10.31.15.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 15:32:21 -0700 (PDT)
Subject: [PATCH 19/23] x86, mm: remove hard-coded ASID limit checks
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 31 Oct 2017 15:32:20 -0700
References: <20171031223146.6B47C861@viggo.jf.intel.com>
In-Reply-To: <20171031223146.6B47C861@viggo.jf.intel.com>
Message-Id: <20171031223220.09D1C7B6@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


First, it's nice to remove the magic numbers.

Second, KAISER is going to eat up half of the available ASID
space.  We do not use it today, but we need to at least spell
out this new restriction.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/arch/x86/include/asm/tlbflush.h |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-asids-macros arch/x86/include/asm/tlbflush.h
--- a/arch/x86/include/asm/tlbflush.h~kaiser-pcid-pre-build-asids-macros	2017-10-31 15:03:59.132528476 -0700
+++ b/arch/x86/include/asm/tlbflush.h	2017-10-31 15:03:59.135528617 -0700
@@ -74,6 +74,18 @@ static inline u64 inc_mm_tlb_gen(struct
 	return new_tlb_gen;
 }
 
+/* There are 12 bits of space for ASIDS in CR3 */
+#define CR3_HW_ASID_BITS 12
+/* When enabled, KAISER consumes a single bit for user/kernel switches */
+#define KAISER_CONSUMED_ASID_BITS 0
+
+#define CR3_AVAIL_ASID_BITS (CR3_HW_ASID_BITS-KAISER_CONSUMED_ASID_BITS)
+/*
+ * We lose a single extra ASID because 0 is reserved for use
+ * by non-PCID-aware users.
+ */
+#define NR_AVAIL_ASIDS ((1<<CR3_AVAIL_ASID_BITS) - 1)
+
 /*
  * If PCID is on, ASID-aware code paths put the ASID+1 into the PCID
  * bits.  This serves two purposes.  It prevents a nasty situation in
@@ -87,7 +99,7 @@ struct pgd_t;
 static inline unsigned long build_cr3(pgd_t *pgd, u16 asid)
 {
 	if (static_cpu_has(X86_FEATURE_PCID)) {
-		VM_WARN_ON_ONCE(asid > 4094);
+		VM_WARN_ON_ONCE(asid > NR_AVAIL_ASIDS);
 		return __sme_pa(pgd) | (asid + 1);
 	} else {
 		VM_WARN_ON_ONCE(asid != 0);
@@ -97,7 +109,7 @@ static inline unsigned long build_cr3(pg
 
 static inline unsigned long build_cr3_noflush(pgd_t *pgd, u16 asid)
 {
-	VM_WARN_ON_ONCE(asid > 4094);
+	VM_WARN_ON_ONCE(asid > NR_AVAIL_ASIDS);
 	return __sme_pa(pgd) | (asid + 1) | CR3_NOFLUSH;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
