Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 490116B026F
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 09:50:27 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b8-v6so736568qto.16
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:50:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h37-v6sor489464qtf.123.2018.07.17.06.50.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 06:50:26 -0700 (PDT)
From: Ram Pai <linuxram@us.ibm.com>
Subject: [PATCH v14 11/22] selftests/vm: introduce two arch independent abstraction
Date: Tue, 17 Jul 2018 06:49:14 -0700
Message-Id: <1531835365-32387-12-git-send-email-linuxram@us.ibm.com>
In-Reply-To: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, dave.hansen@intel.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, linuxram@us.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

open_hugepage_file() <- opens the huge page file
get_start_key() <--  provides the first non-reserved key.

cc: Dave Hansen <dave.hansen@intel.com>
cc: Florian Weimer <fweimer@redhat.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
Signed-off-by: Thiago Jung Bauermann <bauerman@linux.ibm.com>
Reviewed-by: Dave Hansen <dave.hansen@intel.com>
---
 tools/testing/selftests/vm/pkey-helpers.h    |   10 ++++++++++
 tools/testing/selftests/vm/pkey-x86.h        |    1 +
 tools/testing/selftests/vm/protection_keys.c |    6 +++---
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/vm/pkey-helpers.h b/tools/testing/selftests/vm/pkey-helpers.h
index ada0146..52a1152 100644
--- a/tools/testing/selftests/vm/pkey-helpers.h
+++ b/tools/testing/selftests/vm/pkey-helpers.h
@@ -179,4 +179,14 @@ static inline void __pkey_write_allow(int pkey, int do_allow_write)
 #define __stringify_1(x...)     #x
 #define __stringify(x...)       __stringify_1(x)
 
+static inline int open_hugepage_file(int flag)
+{
+	return open(HUGEPAGE_FILE, flag);
+}
+
+static inline int get_start_key(void)
+{
+	return 1;
+}
+
 #endif /* _PKEYS_HELPER_H */
diff --git a/tools/testing/selftests/vm/pkey-x86.h b/tools/testing/selftests/vm/pkey-x86.h
index 2b3780d..d5fa299 100644
--- a/tools/testing/selftests/vm/pkey-x86.h
+++ b/tools/testing/selftests/vm/pkey-x86.h
@@ -48,6 +48,7 @@
 #define MB			(1<<20)
 #define pkey_reg_t		u32
 #define PKEY_REG_FMT		"%016x"
+#define HUGEPAGE_FILE		"/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"
 
 static inline u32 pkey_bit_position(int pkey)
 {
diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
index 2565b4c..2e448e0 100644
--- a/tools/testing/selftests/vm/protection_keys.c
+++ b/tools/testing/selftests/vm/protection_keys.c
@@ -788,7 +788,7 @@ void setup_hugetlbfs(void)
 	 * Now go make sure that we got the pages and that they
 	 * are 2M pages.  Someone might have made 1G the default.
 	 */
-	fd = open("/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages", O_RDONLY);
+	fd = open_hugepage_file(O_RDONLY);
 	if (fd < 0) {
 		perror("opening sysfs 2M hugetlb config");
 		return;
@@ -1075,10 +1075,10 @@ void test_kernel_gup_write_to_write_disabled_region(int *ptr, u16 pkey)
 void test_pkey_syscalls_on_non_allocated_pkey(int *ptr, u16 pkey)
 {
 	int err;
-	int i;
+	int i = get_start_key();
 
 	/* Note: 0 is the default pkey, so don't mess with it */
-	for (i = 1; i < NR_PKEYS; i++) {
+	for (; i < NR_PKEYS; i++) {
 		if (pkey == i)
 			continue;
 
-- 
1.7.1
