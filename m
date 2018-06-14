Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 561E56B028E
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 20:47:33 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w203-v6so3537836qkb.16
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 17:47:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c14-v6sor1838806qvn.38.2018.06.13.17.47.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 17:47:32 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v13 24/24] selftests/vm: test correct behavior of pkey-0
Date: Wed, 13 Jun 2018 17:45:15 -0700
Message-Id: <1528937115-10132-25-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

Ensure pkey-0 is allocated on start.  Ensure pkey-0 can be attached
dynamically in various modes, without failures.  Ensure pkey-0 can be
freed and allocated.

Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/protection_keys.c |   66 +++++++++++++++++++++++++-
 1 files changed, 64 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index cbd87f8..f37b031 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -1003,6 +1003,67 @@ void close_test_fds(void)
 	return *ptr;
 }
 
+void test_pkey_alloc_free_attach_pkey0(int *ptr, u16 pkey)
+{
+	int i, err;
+	int max_nr_pkey_allocs;
+	int alloced_pkeys[NR_PKEYS];
+	int nr_alloced = 0;
+	int newpkey;
+	long size;
+
+	assert(pkey_last_malloc_record);
+	size = pkey_last_malloc_record->size;
+	/*
+	 * This is a bit of a hack.  But mprotect() requires
+	 * huge-page-aligned sizes when operating on hugetlbfs.
+	 * So, make sure that we use something that's a multiple
+	 * of a huge page when we can.
+	 */
+	if (size >= HPAGE_SIZE)
+		size = HPAGE_SIZE;
+
+
+	/* allocate every possible key and make sure key-0 never got allocated */
+	max_nr_pkey_allocs = NR_PKEYS;
+	for (i = 0; i < max_nr_pkey_allocs; i++) {
+		int new_pkey = alloc_pkey();
+		assert(new_pkey != 0);
+
+		if (new_pkey < 0)
+			break;
+		alloced_pkeys[nr_alloced++] = new_pkey;
+	}
+	/* free all the allocated keys */
+	for (i = 0; i < nr_alloced; i++) {
+		int free_ret;
+
+		if (!alloced_pkeys[i])
+			continue;
+		free_ret = sys_pkey_free(alloced_pkeys[i]);
+		pkey_assert(!free_ret);
+	}
+
+	/* attach key-0 in various modes */
+	err = sys_mprotect_pkey(ptr, size, PROT_READ, 0);
+	pkey_assert(!err);
+	err = sys_mprotect_pkey(ptr, size, PROT_WRITE, 0);
+	pkey_assert(!err);
+	err = sys_mprotect_pkey(ptr, size, PROT_EXEC, 0);
+	pkey_assert(!err);
+	err = sys_mprotect_pkey(ptr, size, PROT_READ|PROT_WRITE, 0);
+	pkey_assert(!err);
+	err = sys_mprotect_pkey(ptr, size, PROT_READ|PROT_WRITE|PROT_EXEC, 0);
+	pkey_assert(!err);
+
+	/* free key-0 */
+	err = sys_pkey_free(0);
+	pkey_assert(!err);
+
+	newpkey = sys_pkey_alloc(0, 0x0);
+	assert(newpkey == 0);
+}
+
 void test_read_of_write_disabled_region(int *ptr, u16 pkey)
 {
 	int ptr_contents;
@@ -1153,10 +1214,10 @@ void test_kernel_gup_write_to_write_disabled_region(int *ptr, u16 pkey)
 void test_pkey_syscalls_on_non_allocated_pkey(int *ptr, u16 pkey)
 {
 	int err;
-	int i = get_start_key();
+	int i;
 
 	/* Note: 0 is the default pkey, so don't mess with it */
-	for (; i < NR_PKEYS; i++) {
+	for (i=1; i < NR_PKEYS; i++) {
 		if (pkey == i)
 			continue;
 
@@ -1465,6 +1526,7 @@ void test_mprotect_pkey_on_unsupported_cpu(int *ptr, u16 pkey)
 	test_pkey_syscalls_on_non_allocated_pkey,
 	test_pkey_syscalls_bad_args,
 	test_pkey_alloc_exhaust,
+	test_pkey_alloc_free_attach_pkey0,
 };
 
 void run_tests_once(void)
-- 
1.7.1
