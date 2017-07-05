Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B80AE6B03DC
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 17:23:01 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c18so537455qkb.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:01 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id h67si42289qkf.310.2017.07.05.14.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 14:23:01 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id v31so185567qtb.3
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 14:23:00 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v5 13/38] x86: disallow pkey creation with PKEY_DISABLE_EXECUTE
Date: Wed,  5 Jul 2017 14:21:50 -0700
Message-Id: <1499289735-14220-14-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

x86 does not support disabling execute permissions on a pkey.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/x86/kernel/fpu/xstate.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
index c24ac1e..d582631 100644
--- a/arch/x86/kernel/fpu/xstate.c
+++ b/arch/x86/kernel/fpu/xstate.c
@@ -900,6 +900,9 @@ int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
 	if (!boot_cpu_has(X86_FEATURE_OSPKE))
 		return -EINVAL;
 
+	if (init_val & PKEY_DISABLE_EXECUTE)
+		return -EINVAL;
+
 	/* Set the bits we need in PKRU:  */
 	if (init_val & PKEY_DISABLE_ACCESS)
 		new_pkru_bits |= PKRU_AD_BIT;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
