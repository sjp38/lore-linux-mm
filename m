Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1D54403DD
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 04:00:17 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id p1so6532808qtg.18
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 01:00:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n19sor8196471qtf.78.2017.11.06.01.00.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 01:00:16 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 42/51] selftest/vm: pkey register should match shadow pkey
Date: Mon,  6 Nov 2017 00:57:34 -0800
Message-Id: <1509958663-18737-43-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

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
index 19ae991..2600f7a 100644
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
