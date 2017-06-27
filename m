Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D25596B02F3
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 06:12:19 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v19so9984250qkl.12
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:19 -0700 (PDT)
Received: from mail-qk0-x243.google.com (mail-qk0-x243.google.com. [2607:f8b0:400d:c09::243])
        by mx.google.com with ESMTPS id t127si2395414qkd.279.2017.06.27.03.12.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 03:12:19 -0700 (PDT)
Received: by mail-qk0-x243.google.com with SMTP id 16so3246049qkg.2
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 03:12:19 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v4 03/17] x86: key creation with PKEY_DISABLE_EXECUTE disallowed
Date: Tue, 27 Jun 2017 03:11:45 -0700
Message-Id: <1498558319-32466-4-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
References: <1498558319-32466-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

x86 does not support disabling execute permissions on a pkey.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 arch/x86/kernel/fpu/xstate.c | 3 +++
 1 file changed, 3 insertions(+)

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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
