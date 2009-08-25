Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A1FA66B00AF
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:14:12 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7QBIPjb012504
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 07:18:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7PBF2p8228246
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 07:17:52 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7PBF15e024976
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 07:15:01 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 3/3] Add MAP_HUGETLB example
Date: Tue, 25 Aug 2009 12:14:54 +0100
Message-Id: <068d6084ae44efac5507c5fda075b6ac4ec2a0ed.1251197514.git.ebmunson@us.ibm.com>
In-Reply-To: <8504342f7be19e416ef769d1edd24b8549f8dc39.1251197514.git.ebmunson@us.ibm.com>
References: <cover.1251197514.git.ebmunson@us.ibm.com>
 <25614b0d0581e2d49e1024dc1671b282f193e139.1251197514.git.ebmunson@us.ibm.com>
 <8504342f7be19e416ef769d1edd24b8549f8dc39.1251197514.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1251197514.git.ebmunson@us.ibm.com>
References: <cover.1251197514.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: linux-man@vger.kernel.org, mtk.manpages@gmail.com, randy.dunlap@oracle.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch adds an example of how to use the MAP_HUGETLB flag to the
vm documentation directory and a reference to the example in
hugetlbpage.txt.

Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
Acked-by: David Rientjes <rientjes@google.com>
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
index 0000000..e2bdae3
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
+#define MAP_HUGETLB 0x40
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
