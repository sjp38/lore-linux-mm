Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C2786B027C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:50:46 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u68-v6so845437qku.5
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:50:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m3-v6sor489255qth.149.2018.07.17.06.50.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 06:50:45 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v14 20/22] selftests/vm: testcases must restore pkey-permissions
Date: Tue, 17 Jul 2018 06:49:23 -0700
Message-Id: <1531835365-32387-21-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

Generally the signal handler restores the state of the pkey register
before returning. However there are times when the read/write operation
can legitamely fail without invoking the signal handler.  Eg: A
sys_read() operaton to a write-protected page should be disallowed.  In
such a case the state of the pkey register is not restored to its
original state.  Test cases may not remember to restoring the key
register state. During cleanup generically restore the key permissions.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/protection_keys.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 8a6afdd..ea3cf04 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -1476,8 +1476,13 @@ void run_tests_once(void)
 		pkey_tests[test_nr](ptr, pkey);
 		dprintf1("freeing test memory: %p\n", ptr);
 		free_pkey_malloc(ptr);
+
+		/* restore the permission on the key after use */
+		pkey_access_allow(pkey);
+		pkey_write_allow(pkey);
 		sys_pkey_free(pkey);
 
+
 		dprintf1("pkey_faults: %d\n", pkey_faults);
 		dprintf1("orig_pkey_faults: %d\n", orig_pkey_faults);
 
-- 
1.7.1
