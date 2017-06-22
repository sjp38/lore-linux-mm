Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D14FF6B02F4
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:39:58 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d79so1127694qkj.8
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:39:58 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id e34si66523qtf.222.2017.06.21.18.39.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 18:39:58 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id d14so365870qkb.1
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:39:57 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v3 03/23] powerpc: introduce get_hidx_gslot helper
Date: Wed, 21 Jun 2017 18:39:19 -0700
Message-Id: <1498095579-6790-4-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
References: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Introduce get_hidx_gslot() which returns the slot number of the HPTE
in the global hash table.

This function will come in handy as we work towards re-arranging the
PTE bits in the later patches.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/hash.h |  3 +++
 arch/powerpc/mm/hash_utils_64.c           | 14 ++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
index ac049de..e7cf03a 100644
--- a/arch/powerpc/include/asm/book3s/64/hash.h
+++ b/arch/powerpc/include/asm/book3s/64/hash.h
@@ -162,6 +162,9 @@ static inline bool hpte_soft_invalid(unsigned long slot)
 	return ((slot & 0xfUL) == 0xfUL);
 }
 
+unsigned long get_hidx_gslot(unsigned long vpn, unsigned long shift,
+		int ssize, real_pte_t rpte, unsigned int subpg_index);
+
 /* This low level function performs the actual PTE insertion
  * Setting the PTE depends on the MMU type and other factors. It's
  * an horrible mess that I'm not going to try to clean up now but
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 1b494d0..99f97754c 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -1591,6 +1591,20 @@ static inline void tm_flush_hash_page(int local)
 }
 #endif
 
+unsigned long get_hidx_gslot(unsigned long vpn, unsigned long shift,
+			int ssize, real_pte_t rpte, unsigned int subpg_index)
+{
+	unsigned long hash, slot, hidx;
+
+	hash = hpt_hash(vpn, shift, ssize);
+	hidx = __rpte_to_hidx(rpte, subpg_index);
+	if (hidx & _PTEIDX_SECONDARY)
+		hash = ~hash;
+	slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
+	slot += hidx & _PTEIDX_GROUP_IX;
+	return slot;
+}
+
 /* WARNING: This is called from hash_low_64.S, if you change this prototype,
  *          do not forget to update the assembly call site !
  */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
