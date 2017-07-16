Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9366B068A
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:00:09 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id f67so10674350qkc.14
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:09 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id u66si11873819qkd.138.2017.07.15.21.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jul 2017 21:00:08 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id m54so14730383qtb.1
        for <linux-mm@kvack.org>; Sat, 15 Jul 2017 21:00:08 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [RFC v6 51/62] selftest/vm: pkey register should match shadow pkey
Date: Sat, 15 Jul 2017 20:56:53 -0700
Message-Id: <1500177424-13695-52-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, linuxram@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

expected_pkey_fault() is comparing the contents of pkey
register with 0. This may not be true all the time. There
could be bits set by default by the architecture
which can never be changed. Hence compare the value against
shadow pkey register, which is supposed to track the bits
accurately all throughout

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/protection_keys.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 20bab6d..f21e177 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -926,10 +926,10 @@ void expected_pkey_fault(int pkey)
 	pkey_assert(last_pkey_faults + 1 == pkey_faults);
 	pkey_assert(last_si_pkey == pkey);
 	/*
-	 * The signal handler shold have cleared out PKEY register to let the
+	 * The signal handler shold have cleared out pkey-register to let the
 	 * test program continue.  We now have to restore it.
 	 */
-	if (__rdpkey_reg() != 0)
+	if (__rdpkey_reg() != shadow_pkey_reg)
 		pkey_assert(0);
 
 	__wrpkey_reg(shadow_pkey_reg);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
