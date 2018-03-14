Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 207C86B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 03:45:14 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n51so1580581qta.9
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:45:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m93sor1571635qte.88.2018.03.14.00.45.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 00:45:13 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH 1/1 v2] powerpc: pkey-mprotect must allow pkey-0
Date: Wed, 14 Mar 2018 00:45:00 -0700
Message-Id: <1521013500-26740-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

Once an address range is associated with an allocated pkey, it cannot be
reverted back to key-0. There is no valid reason for the above behavior.  On
the contrary applications need the ability to do so.

The patch relaxes the restriction.

Tested on powerpc.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Michael Ellermen <mpe@ellerman.id.au>
cc: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/powerpc/include/asm/pkeys.h | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
index 0409c80..3c1deec 100644
--- a/arch/powerpc/include/asm/pkeys.h
+++ b/arch/powerpc/include/asm/pkeys.h
@@ -101,10 +101,18 @@ static inline u16 pte_to_pkey_bits(u64 pteflags)
 
 static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 {
-	/* A reserved key is never considered as 'explicitly allocated' */
-	return ((pkey < arch_max_pkey()) &&
-		!__mm_pkey_is_reserved(pkey) &&
-		__mm_pkey_is_allocated(mm, pkey));
+	/* pkey 0 is allocated by default. */
+	if (!pkey)
+	       return true;
+
+	if (pkey < 0 || pkey >= arch_max_pkey())
+	       return false;
+
+	/* Reserved keys are never allocated. */
+	if (__mm_pkey_is_reserved(pkey))
+	       return false;
+
+	return __mm_pkey_is_allocated(mm, pkey);
 }
 
 extern void __arch_activate_pkey(int pkey);
@@ -150,7 +158,8 @@ static inline int mm_pkey_free(struct mm_struct *mm, int pkey)
 	if (static_branch_likely(&pkey_disabled))
 		return -1;
 
-	if (!mm_pkey_is_allocated(mm, pkey))
+	/* pkey 0 cannot be freed */
+	if (!pkey || !mm_pkey_is_allocated(mm, pkey))
 		return -EINVAL;
 
 	/*
-- 
1.8.3.1
