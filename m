Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6256B000D
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 17:03:55 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w140so2977636qkb.15
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 14:03:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g55sor2877451qtg.15.2018.03.14.14.03.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 14:03:54 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v3] powerpc: treat pkey-0 special
Date: Wed, 14 Mar 2018 14:01:35 -0700
Message-Id: <1521061295-22605-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com, Ulrich.Weigand@de.ibm.com

Applications need the ability to associate an address-range with some
key and latter revert to its initial default key. Pkey-0 comes close to
providing this function but falls short, because the current
implementation disallows applications to explicitly associate pkey-0 to
the address range.

This patch clarifies the semantics of pkey-0 and provides the
corresponding implementation on powerpc.

Pkey-0 is special with the following semantics.
(a) it is implicitly allocated and can never be freed. It always exists.
(b) it is the default key assigned to any address-range.
(c) it can be explicitly associated with any address-range.

Tested on powerpc.

History:
    v3 : added clarification of the semantics of pkey0.
    		-- suggested by Dave Hansen
    v2 : split the patch into two, one for x86 and one for powerpc
    		-- suggested by Michael Ellermen

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
