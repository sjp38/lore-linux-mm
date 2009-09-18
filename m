Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8196B008C
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:22:09 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8ICK8Sw030132
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:20:08 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8ICM9uq251932
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:22:09 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8ICIvPG000396
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 08:18:58 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 3/7] Add MAP_HUGETLB example
Date: Fri, 18 Sep 2009 06:21:49 -0600
Message-Id: <462331ca14e2ed47b20b047342e73b92559e1c5b.1253272709.git.ebmunson@us.ibm.com>
In-Reply-To: <08251014d2eb30e9016bab16404133f5c13beacf.1253272709.git.ebmunson@us.ibm.com>
References: <cover.1253272709.git.ebmunson@us.ibm.com>
 <653aa659fd7970f7428f4eb41fa10693064e4daf.1253272709.git.ebmunson@us.ibm.com>
 <08251014d2eb30e9016bab16404133f5c13beacf.1253272709.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1253272709.git.ebmunson@us.ibm.com>
References: <cover.1253272709.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: rdunlap@xenotime.net, michael@ellerman.id.au, ralf@linux-mips.org, wli@holomorphy.com, mel@csn.ul.ie, dhowells@redhat.com, arnd@arndb.de, fengguang.wu@intel.com, shuber2@gmail.com, hugh.dickins@tiscali.co.uk, zohar@us.ibm.com, hugh@veritas.com, mtk.manpages@gmail.com, chris@zankel.net, linux-man@vger.kernel.org, linux-doc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch adds an example of how to use the MAP_HUGETLB flag to the
vm documentation directory and a reference to the example in
hugetlbpage.txt.

Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 Documentation/vm/00-INDEX        |    2 +
 Documentation/vm/hugetlbpage.txt |   14 ++++---
 Documentation/vm/map_hugetlb.c   |   77 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 87 insertions(+), 6 deletions(-)
 create mode 100644 Documentation/vm/map_hugetlb.c

diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
index 2f77ced..aabd973 100644
--- a/Documentation/vm/00-INDEX
+++ b/Documentation/vm/00-INDEX
@@ -20,3 +20,5 @@ slabinfo.c
 	- source code for a tool to get reports about slabs.
 slub.txt
 	- a short users guide for SLUB.
+map_hugetlb.c
+	- an example program that uses the MAP_HUGETLB mmap flag.
diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index ea8714f..6a8feab 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -146,12 +146,14 @@ Regular chown, chgrp, and chmod commands (with right permissions) could be
 used to change the file attributes on hugetlbfs.
 
 Also, it is important to note that no such mount command is required if the
-applications are going to use only shmat/shmget system calls.  Users who
-wish to use hugetlb page via shared memory segment should be a member of
-a supplementary group and system admin needs to configure that gid into
-/proc/sys/vm/hugetlb_shm_group.  It is possible for same or different
-applications to use any combination of mmaps and shm* calls, though the
-mount of filesystem will be required for using mmap calls.
+applications are going to use only shmat/shmget system calls or mmap with
+MAP_HUGETLB.  Users who wish to use hugetlb page via shared memory segment
+should be a member of a supplementary group and system admin needs to
+configure that gid into /proc/sys/vm/hugetlb_shm_group.  It is possible for
+same or different applications to use any combination of mmaps and shm*
+calls, though the mount of filesystem will be required for using mmap calls
+without MAP_HUGETLB.  For an example of how to use mmap with MAP_HUGETLB see
+map_hugetlb.c.
 
 *******************************************************************
 
diff --git a/Documentation/vm/map_hugetlb.c b/Documentation/vm/map_hugetlb.c
new file mode 100644
index 0000000..b6c1931
--- /dev/null
+++ b/Documentation/vm/map_hugetlb.c
@@ -0,0 +1,77 @@
+/*
+ * Example of using hugepage memory in a user application using the mmap
+ * system call with MAP_HUGETLB flag.  Before running this program make
+ * sure the administrator has allocated enough default sized huge pages
+ * to cover the 256 MB allocation.
+ *
+ * For ia64 architecture, Linux kernel reserves Region number 4 for hugepages.
+ * That means the addresses starting with 0x800000... will need to be
+ * specified.  Specifying a fixed address is not required on ppc64, i386
+ * or x86_64.
+ */
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <sys/mman.h>
+#include <fcntl.h>
+
+#define LENGTH (256UL*1024*1024)
+#define PROTECTION (PROT_READ | PROT_WRITE)
+
+#ifndef MAP_HUGETLB
+#define MAP_HUGETLB 0x080000
+#endif
+
+/* Only ia64 requires this */
+#ifdef __ia64__
+#define ADDR (void *)(0x8000000000000000UL)
+#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_FIXED)
+#else
+#define ADDR (void *)(0x0UL)
+#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB)
+#endif
+
+void check_bytes(char *addr)
+{
+	printf("First hex is %x\n", *((unsigned int *)addr));
+}
+
+void write_bytes(char *addr)
+{
+	unsigned long i;
+
+	for (i = 0; i < LENGTH; i++)
+		*(addr + i) = (char)i;
+}
+
+void read_bytes(char *addr)
+{
+	unsigned long i;
+
+	check_bytes(addr);
+	for (i = 0; i < LENGTH; i++)
+		if (*(addr + i) != (char)i) {
+			printf("Mismatch at %lu\n", i);
+			break;
+		}
+}
+
+int main(void)
+{
+	void *addr;
+
+	addr = mmap(ADDR, LENGTH, PROTECTION, FLAGS, 0, 0);
+	if (addr == MAP_FAILED) {
+		perror("mmap");
+		exit(1);
+	}
+
+	printf("Returned address is %p\n", addr);
+	check_bytes(addr);
+	write_bytes(addr);
+	read_bytes(addr);
+
+	munmap(addr, LENGTH);
+
+	return 0;
+}
-- 
1.6.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
