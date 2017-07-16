Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BEEE26B0633
	for <linux-mm@kvack.org>; Sat, 15 Jul 2017 23:58:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q66so59367825qki.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:09 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id c11si12002893qka.280.2017.07.15.20.58.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 20:58:09 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id q66so17062833qki.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 20:58:08 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 03/62] powerpc: introduce pte_set_hash_slot() helper
Date: Sat, 15 Jul 2017 20:56:05 -0700
Message-Id: <1500177424-13695-4-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Introduce pte_set_hash_slot().It  sets the (H_PAGE_F_SECOND|H_PAGE_F_GIX)
bits at  the   appropriate   location   in   the   PTE  of  4K  PTE.  For
64K PTE, it  sets  the  bits  in  the  second  part  of  the  PTE. Though
the implementation  for the former just needs the slot parameter, it does
take some additional parameters to keep the prototype consistent.

This function  will  be  handy  as  we   work   towards  re-arranging the
bits in the later patches.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash-4k.h  |   15 +++++++++++++++
 arch/powerpc/include/asm/book3s/64/hash-64k.h |   25 +++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
index d2cf949..dc153c6 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
@@ -53,6 +53,21 @@ static inline int hash__hugepd_ok(hugepd_t hpd)
 }
 #endif
 
+/*
+ * 4k pte format is  different  from  64k  pte  format.  Saving  the
+ * hash_slot is just a matter of returning the pte bits that need to
+ * be modified. On 64k pte, things are a  little  more  involved and
+ * hence  needs   many   more  parameters  to  accomplish  the  same.
+ * However we  want  to abstract this out from the caller by keeping
+ * the prototype consistent across the two formats.
+ */
+static inline unsigned long pte_set_hash_slot(pte_t *ptep, real_pte_t rpte,
+			unsigned int subpg_index, unsigned long slot)
+{
+	return (slot << H_PAGE_F_GIX_SHIFT) &
+		(H_PAGE_F_SECOND | H_PAGE_F_GIX);
+}
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
 static inline char *get_hpte_slot_array(pmd_t *pmdp)
diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
index c281f18..89ef5a9 100644
--- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
+++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
@@ -67,6 +67,31 @@ static inline unsigned long __rpte_to_hidx(real_pte_t rpte, unsigned long index)
 	return ((rpte.hidx >> (index<<2)) & 0xfUL);
 }
 
+/*
+ * Commit the hash slot and return pte bits that needs to be modified.
+ * The caller is expected to modify the pte bits accordingly and
+ * commit the pte to memory.
+ */
+static inline unsigned long pte_set_hash_slot(pte_t *ptep, real_pte_t rpte,
+		unsigned int subpg_index, unsigned long slot)
+{
+	unsigned long *hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
+
+	rpte.hidx &= ~(0xfUL << (subpg_index << 2));
+	*hidxp = rpte.hidx  | (slot << (subpg_index << 2));
+	/*
+	 * Commit the hidx bits to memory before returning.
+	 * Anyone reading  pte  must  ensure hidx bits are
+	 * read  only  after  reading the pte by using the
+	 * read-side  barrier  smp_rmb(). __real_pte() can
+	 * help ensure that.
+	 */
+	smp_wmb();
+
+	/* no pte bits to be modified, return 0x0UL */
+	return 0x0UL;
+}
+
 #define __rpte_to_pte(r)	((r).pte)
 extern bool __rpte_sub_valid(real_pte_t rpte, unsigned long index);
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
