Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB4D7280246
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:58:45 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id 10so6532863qty.10
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:58:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v54sor8308175qtc.160.2017.11.06.00.58.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 00:58:45 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 09/51] powerpc: ability to create execute-disabled pkeys
Date: Mon,  6 Nov 2017 00:57:01 -0800
Message-Id: <1509958663-18737-10-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

powerpc has hardware support to disable execute on a pkey.
This patch enables the ability to create execute-disabled
keys.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/uapi/asm/mman.h |    6 ++++++
 arch/powerpc/mm/pkeys.c              |   16 ++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index e63bc37..65065ce 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -30,4 +30,10 @@
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
 
+/* Override any generic PKEY permission defines */
+#define PKEY_DISABLE_EXECUTE   0x4
+#undef PKEY_ACCESS_MASK
+#define PKEY_ACCESS_MASK       (PKEY_DISABLE_ACCESS |\
+				PKEY_DISABLE_WRITE  |\
+				PKEY_DISABLE_EXECUTE)
 #endif /* _UAPI_ASM_POWERPC_MMAN_H */
diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 4a01c2f..3ddc13a 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -29,6 +29,14 @@ void __init pkey_initialize(void)
 	int os_reserved, i;
 
 	/*
+	 * We define PKEY_DISABLE_EXECUTE in addition to the arch-neutral
+	 * generic defines for PKEY_DISABLE_ACCESS and PKEY_DISABLE_WRITE.
+	 * Ensure that the bits a distinct.
+	 */
+	BUILD_BUG_ON(PKEY_DISABLE_EXECUTE &
+		     (PKEY_DISABLE_ACCESS | PKEY_DISABLE_WRITE));
+
+	/*
 	 * Disable the pkey system till everything is in place. A subsequent
 	 * patch will enable it.
 	 */
@@ -171,10 +179,18 @@ int __arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 				unsigned long init_val)
 {
 	u64 new_amr_bits = 0x0ul;
+	u64 new_iamr_bits = 0x0ul;
 
 	if (!is_pkey_enabled(pkey))
 		return -EINVAL;
 
+	if (init_val & PKEY_DISABLE_EXECUTE) {
+		if (!pkey_execute_disable_supported)
+			return -EINVAL;
+		new_iamr_bits |= IAMR_EX_BIT;
+	}
+	init_iamr(pkey, new_iamr_bits);
+
 	/* Set the bits we need in AMR: */
 	if (init_val & PKEY_DISABLE_ACCESS)
 		new_amr_bits |= AMR_RD_BIT | AMR_WR_BIT;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
