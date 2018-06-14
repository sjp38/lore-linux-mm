Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1E216B027A
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 20:47:13 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l10-v6so3350515qth.14
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 17:47:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t14-v6sor2312017qtg.80.2018.06.13.17.47.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Jun 2018 17:47:12 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v13 14/24] selftests/vm: generic cleanup
Date: Wed, 13 Jun 2018 17:45:05 -0700
Message-Id: <1528937115-10132-15-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

cleanup the code to satisfy coding styles.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
---
 tools/testing/selftests/vm/protection_keys.c |   64 +++++++++++++++++--------
 1 files changed, 43 insertions(+), 21 deletions(-)

diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index adcae4a..f43a319 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -4,7 +4,7 @@
  *
  * There are examples in here of:
  *  * how to set protection keys on memory
- *  * how to set/clear bits in pkey registers (the rights register)
+ *  * how to set/clear bits in Protection Key registers (the rights register)
  *  * how to handle SEGV_PKUERR signals and extract pkey-relevant
  *    information from the siginfo
  *
@@ -13,13 +13,18 @@
  *	prefault pages in at malloc, or not
  *	protect MPX bounds tables with protection keys?
  *	make sure VMA splitting/merging is working correctly
- *	OOMs can destroy mm->mmap (see exit_mmap()), so make sure it is immune to pkeys
- *	look for pkey "leaks" where it is still set on a VMA but "freed" back to the kernel
- *	do a plain mprotect() to a mprotect_pkey() area and make sure the pkey sticks
+ *	OOMs can destroy mm->mmap (see exit_mmap()),
+ *			so make sure it is immune to pkeys
+ *	look for pkey "leaks" where it is still set on a VMA
+ *			 but "freed" back to the kernel
+ *	do a plain mprotect() to a mprotect_pkey() area and make
+ *			 sure the pkey sticks
  *
  * Compile like this:
- *	gcc      -o protection_keys    -O2 -g -std=gnu99 -pthread -Wall protection_keys.c -lrt -ldl -lm
- *	gcc -m32 -o protection_keys_32 -O2 -g -std=gnu99 -pthread -Wall protection_keys.c -lrt -ldl -lm
+ *	gcc      -o protection_keys    -O2 -g -std=gnu99
+ *			 -pthread -Wall protection_keys.c -lrt -ldl -lm
+ *	gcc -m32 -o protection_keys_32 -O2 -g -std=gnu99
+ *			 -pthread -Wall protection_keys.c -lrt -ldl -lm
  */
 #define _GNU_SOURCE
 #include <errno.h>
@@ -263,10 +268,12 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
 			__read_pkey_reg());
 	dprintf1("pkey from siginfo: %jx\n", siginfo_pkey);
 	*(u64 *)pkey_reg_ptr = 0x00000000;
-	dprintf1("WARNING: set PRKU=0 to allow faulting instruction to continue\n");
+	dprintf1("WARNING: set PKEY_REG=0 to allow faulting instruction "
+			"to continue\n");
 	pkey_faults++;
 	dprintf1("<<<<==================================================\n");
 	dprint_in_signal = 0;
+	return;
 }
 
 int wait_all_children(void)
@@ -384,7 +391,7 @@ void pkey_disable_set(int pkey, int flags)
 {
 	unsigned long syscall_flags = 0;
 	int ret;
-	int pkey_rights;
+	u32 pkey_rights;
 	pkey_reg_t orig_pkey_reg = read_pkey_reg();
 
 	dprintf1("START->%s(%d, 0x%x)\n", __func__,
@@ -487,9 +494,10 @@ int sys_mprotect_pkey(void *ptr, size_t size, unsigned long orig_prot,
 	return sret;
 }
 
-int sys_pkey_alloc(unsigned long flags, unsigned long init_val)
+int sys_pkey_alloc(unsigned long flags, u64 init_val)
 {
 	int ret = syscall(SYS_pkey_alloc, flags, init_val);
+
 	dprintf1("%s(flags=%lx, init_val=%lx) syscall ret: %d errno: %d\n",
 			__func__, flags, init_val, ret, errno);
 	return ret;
@@ -513,7 +521,7 @@ void pkey_set_shadow(u32 key, u64 init_val)
 int alloc_pkey(void)
 {
 	int ret;
-	unsigned long init_val = 0x0;
+	u64 init_val = 0x0;
 
 	dprintf1("%s()::%d, pkey_reg: "PKEY_REG_FMT" shadow: "PKEY_REG_FMT"\n",
 			__func__, __LINE__, __read_pkey_reg(), shadow_pkey_reg);
@@ -672,7 +680,9 @@ void record_pkey_malloc(void *ptr, long size, int prot)
 		/* every record is full */
 		size_t old_nr_records = nr_pkey_malloc_records;
 		size_t new_nr_records = (nr_pkey_malloc_records * 2 + 1);
-		size_t new_size = new_nr_records * sizeof(struct pkey_malloc_record);
+		size_t new_size = new_nr_records *
+				sizeof(struct pkey_malloc_record);
+
 		dprintf2("new_nr_records: %zd\n", new_nr_records);
 		dprintf2("new_size: %zd\n", new_size);
 		pkey_malloc_records = realloc(pkey_malloc_records, new_size);
@@ -698,9 +708,11 @@ void free_pkey_malloc(void *ptr)
 {
 	long i;
 	int ret;
+
 	dprintf3("%s(%p)\n", __func__, ptr);
 	for (i = 0; i < nr_pkey_malloc_records; i++) {
 		struct pkey_malloc_record *rec = &pkey_malloc_records[i];
+
 		dprintf4("looking for ptr %p at record[%ld/%p]: {%p, %ld}\n",
 				ptr, i, rec, rec->ptr, rec->size);
 		if ((ptr <  rec->ptr) ||
@@ -781,11 +793,13 @@ void setup_hugetlbfs(void)
 	char buf[] = "123";
 
 	if (geteuid() != 0) {
-		fprintf(stderr, "WARNING: not run as root, can not do hugetlb test\n");
+		fprintf(stderr,
+			"WARNING: not run as root, can not do hugetlb test\n");
 		return;
 	}
 
-	cat_into_file(__stringify(GET_NR_HUGE_PAGES), "/proc/sys/vm/nr_hugepages");
+	cat_into_file(__stringify(GET_NR_HUGE_PAGES),
+				"/proc/sys/vm/nr_hugepages");
 
 	/*
 	 * Now go make sure that we got the pages and that they
@@ -806,7 +820,8 @@ void setup_hugetlbfs(void)
 	}
 
 	if (atoi(buf) != GET_NR_HUGE_PAGES) {
-		fprintf(stderr, "could not confirm 2M pages, got: '%s' expected %d\n",
+		fprintf(stderr, "could not confirm 2M pages, got:"
+			       " '%s' expected %d\n",
 			buf, GET_NR_HUGE_PAGES);
 		return;
 	}
@@ -948,6 +963,7 @@ void __save_test_fd(int fd)
 int get_test_read_fd(void)
 {
 	int test_fd = open("/etc/passwd", O_RDONLY);
+
 	__save_test_fd(test_fd);
 	return test_fd;
 }
@@ -989,7 +1005,8 @@ void test_read_of_access_disabled_region(int *ptr, u16 pkey)
 {
 	int ptr_contents;
 
-	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n", pkey, ptr);
+	dprintf1("disabling access to PKEY[%02d], doing read @ %p\n",
+			 pkey, ptr);
 	read_pkey_reg();
 	pkey_access_deny(pkey);
 	ptr_contents = read_ptr(ptr);
@@ -1111,13 +1128,14 @@ void test_pkey_syscalls_bad_args(int *ptr, u16 pkey)
 /* Assumes that all pkeys other than 'pkey' are unallocated */
 void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 {
-	int err;
+	int err = 0;
 	int allocated_pkeys[NR_PKEYS] = {0};
 	int nr_allocated_pkeys = 0;
 	int i;
 
 	for (i = 0; i < NR_PKEYS*2; i++) {
 		int new_pkey;
+
 		dprintf1("%s() alloc loop: %d\n", __func__, i);
 		new_pkey = alloc_pkey();
 		dprintf4("%s()::%d, err: %d pkey_reg: 0x"PKEY_REG_FMT
@@ -1125,9 +1143,11 @@ void test_pkey_alloc_exhaust(int *ptr, u16 pkey)
 				__func__, __LINE__, err, __read_pkey_reg(),
 				shadow_pkey_reg);
 		read_pkey_reg(); /* for shadow checking */
-		dprintf2("%s() errno: %d ENOSPC: %d\n", __func__, errno, ENOSPC);
+		dprintf2("%s() errno: %d ENOSPC: %d\n",
+				__func__, errno, ENOSPC);
 		if ((new_pkey == -1) && (errno == ENOSPC)) {
-			dprintf2("%s() failed to allocate pkey after %d tries\n",
+			dprintf2("%s() failed to allocate pkey "
+					"after %d tries\n",
 				__func__, nr_allocated_pkeys);
 			break;
 		}
@@ -1419,7 +1439,8 @@ void run_tests_once(void)
 		tracing_off();
 		close_test_fds();
 
-		printf("test %2d PASSED (iteration %d)\n", test_nr, iteration_nr);
+		printf("test %2d PASSED (iteration %d)\n",
+				test_nr, iteration_nr);
 		dprintf1("======================\n\n");
 	}
 	iteration_nr++;
@@ -1431,7 +1452,7 @@ int main(void)
 
 	setup_handlers();
 
-	printf("has pku: %d\n", cpu_has_pku());
+	printf("has pkey: %d\n", cpu_has_pku());
 
 	if (!cpu_has_pku()) {
 		int size = PAGE_SIZE;
@@ -1439,7 +1460,8 @@ int main(void)
 
 		printf("running PKEY tests for unsupported CPU/OS\n");
 
-		ptr  = mmap(NULL, size, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
+		ptr  = mmap(NULL, size, PROT_NONE,
+				MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
 		assert(ptr != (void *)-1);
 		test_mprotect_pkey_on_unsupported_cpu(ptr, 1);
 		exit(0);
-- 
1.7.1
