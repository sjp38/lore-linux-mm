Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5EE4403DD
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 04:00:11 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id u20so6606418qtu.0
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 01:00:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o70sor8180830qki.71.2017.11.06.01.00.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 01:00:10 -0800 (PST)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v9 40/51] selftest/vm: fix alloc_random_pkey() to make it really random
Date: Mon,  6 Nov 2017 00:57:32 -0800
Message-Id: <1509958663-18737-41-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, linuxram@us.ibm.com

alloc_random_pkey() was allocating the same pkey every time.
Not all pkeys were geting tested. fixed it.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/protection_keys.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 2823d4d..1a14027 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -24,6 +24,7 @@
 #define _GNU_SOURCE
 #include <errno.h>
 #include <linux/futex.h>
+#include <time.h>
 #include <sys/time.h>
 #include <sys/syscall.h>
 #include <string.h>
@@ -602,13 +603,15 @@ int alloc_random_pkey(void)
 	int alloced_pkeys[NR_PKEYS];
 	int nr_alloced = 0;
 	int random_index;
+
 	memset(alloced_pkeys, 0, sizeof(alloced_pkeys));
+	srand((unsigned int)time(NULL));
 
 	/* allocate every possible key and make a note of which ones we got */
 	max_nr_pkey_allocs = NR_PKEYS;
-	max_nr_pkey_allocs = 1;
 	for (i = 0; i < max_nr_pkey_allocs; i++) {
 		int new_pkey = alloc_pkey();
+
 		if (new_pkey < 0)
 			break;
 		alloced_pkeys[nr_alloced++] = new_pkey;
@@ -624,13 +627,14 @@ int alloc_random_pkey(void)
 	/* go through the allocated ones that we did not want and free them */
 	for (i = 0; i < nr_alloced; i++) {
 		int free_ret;
+
 		if (!alloced_pkeys[i])
 			continue;
 		free_ret = sys_pkey_free(alloced_pkeys[i]);
 		pkey_assert(!free_ret);
 	}
-	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n", __func__,
-			__LINE__, ret, __rdpkey_reg(), shadow_pkey_reg);
+	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%016lx\n",
+		__func__, __LINE__, ret, __rdpkey_reg(), shadow_pkey_reg);
 	return ret;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
