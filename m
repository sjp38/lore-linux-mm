Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0ACF56B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 03:47:20 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 41so1582432qtp.8
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 00:47:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d38sor1635542qtd.27.2018.03.14.00.47.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 00:47:19 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH 1/1 v2] x86: pkey-mprotect must allow pkey-0
Date: Wed, 14 Mar 2018 00:46:14 -0700
Message-Id: <1521013574-27041-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

Once an address range is associated with an allocated pkey, it cannot be
reverted back to key-0. There is no valid reason for the above behavior.  On
the contrary applications need the ability to do so.

The patch relaxes the restriction.

Tested on x86_64.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Michael Ellermen <mpe@ellerman.id.au>
cc: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/x86/include/asm/pkeys.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
index a0ba1ff..6ea7486 100644
--- a/arch/x86/include/asm/pkeys.h
+++ b/arch/x86/include/asm/pkeys.h
@@ -52,7 +52,7 @@ bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
 	 * from pkey_alloc().  pkey 0 is special, and never
 	 * returned from pkey_alloc().
 	 */
-	if (pkey <= 0)
+	if (pkey < 0)
 		return false;
 	if (pkey >= arch_max_pkey())
 		return false;
@@ -92,7 +92,8 @@ int mm_pkey_alloc(struct mm_struct *mm)
 static inline
 int mm_pkey_free(struct mm_struct *mm, int pkey)
 {
-	if (!mm_pkey_is_allocated(mm, pkey))
+	/* pkey 0 is special and can never be freed */
+	if (!pkey || !mm_pkey_is_allocated(mm, pkey))
 		return -EINVAL;
 
 	mm_set_pkey_free(mm, pkey);
-- 
1.8.3.1
