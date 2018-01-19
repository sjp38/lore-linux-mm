Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7CA6B0268
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:52:00 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id b8so309918qtj.21
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:52:00 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q126sor5937259qkb.89.2018.01.18.17.51.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 17:51:59 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v10 07/27] powerpc: cleanup AMR, IAMR when a key is allocated or freed
Date: Thu, 18 Jan 2018 17:50:28 -0800
Message-Id: <1516326648-22775-8-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

Cleanup the bits corresponding to a key in the AMR, and IAMR
register, when the key is newly allocated/activated or is freed.
We dont want some residual bits cause the hardware enforce
unintended behavior when the key is activated or freed.

Reviewed-by: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/pkeys.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 1e8cef2..9964b46 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -69,6 +69,8 @@ static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 		__mm_pkey_is_allocated(mm, pkey));
 }
 
+extern void __arch_activate_pkey(int pkey);
+extern void __arch_deactivate_pkey(int pkey);
 /*
  * Returns a positive, 5-bit key on success, or -1 on failure.
  * Relies on the mmap_sem to protect against concurrency in mm_pkey_alloc() and
@@ -96,6 +98,12 @@ static inline int mm_pkey_alloc(struct mm_struct *mm)
 
 	ret = ffz((u32)mm_pkey_allocation_map(mm));
 	__mm_pkey_allocated(mm, ret);
+
+	/*
+	 * Enable the key in the hardware
+	 */
+	if (ret > 0)
+		__arch_activate_pkey(ret);
 	return ret;
 }
 
@@ -107,6 +115,10 @@ static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
 	if (!mm_pkey_is_allocated(mm, pkey))
 		return -EINVAL;
 
+	/*
+	 * Disable the key in the hardware
+	 */
+	__arch_deactivate_pkey(pkey);
 	__mm_pkey_free(mm, pkey);
 
 	return 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
