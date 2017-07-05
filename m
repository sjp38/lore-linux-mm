Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD60B6B0405
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o8so669169qtc.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:52 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id 55si117367qtq.162.2017.07.05.14.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:51 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id p21so206401qke.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:51 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 34/38] procfs: display the protection-key number associated with a vma
Date: Wed,  5 Jul 2017 14:22:11 -0700
Message-Id: <1499289735-14220-35-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

Display the pkey number associated with the vma in smaps of a task.
The key will be seen as below:

ProtectionKey: 0

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/kernel/setup_64.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index f35ff9d..ebc82b3 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -37,6 +37,7 @@
 #include <linux/memblock.h>
 #include <linux/memory.h>
 #include <linux/nmi.h>
+#include <linux/pkeys.h>
 
 #include <asm/io.h>
 #include <asm/kdump.h>
@@ -745,3 +746,10 @@ static int __init disable_hardlockup_detector(void)
 }
 early_initcall(disable_hardlockup_detector);
 #endif
+
+#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
+void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
+{
+	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
+}
+#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
