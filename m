Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B17E76B0055
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:13:32 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7BMCfqs018717
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:12:41 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7BMDUFI254108
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:13:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7BMAfr5018698
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 18:10:41 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH 3/3] Add MAP_LARGEPAGE example to vm/hugetlbpage.txt
Date: Tue, 11 Aug 2009 23:13:19 +0100
Message-Id: <c5882be4e782296c6e02ff20927b87d72dad418f.1249999949.git.ebmunson@us.ibm.com>
In-Reply-To: <a45eb555ca7d9e23e5eb051e27f757ae70a6b0c5.1249999949.git.ebmunson@us.ibm.com>
References: <cover.1249999949.git.ebmunson@us.ibm.com>
 <2154e5ac91c7acd5505c5fc6c55665980cbc1bf8.1249999949.git.ebmunson@us.ibm.com>
 <a45eb555ca7d9e23e5eb051e27f757ae70a6b0c5.1249999949.git.ebmunson@us.ibm.com>
In-Reply-To: <cover.1249999949.git.ebmunson@us.ibm.com>
References: <cover.1249999949.git.ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: linux-man@vger.kernel.org, mtk.manpages@gmail.com, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch adds an example of how to use the MAP_LARGEPAGE flag to
the vm documentation.

Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
---
 Documentation/vm/hugetlbpage.txt |   80 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 80 insertions(+), 0 deletions(-)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index ea8714f..fec7fc1 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -337,3 +337,83 @@ int main(void)
 
 	return 0;
 }
+
+*******************************************************************
+
+/*
+ * Example of using hugepage memory in a user application using the mmap
+ * system call with MAP_LARGEPAGE flag.  Before running this program make
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
+#ifndef MAP_LARGEPAGE
+#define MAP_LARGEPAGE 0x40
+#endif
+
+/* Only ia64 requires this */
+#ifdef __ia64__
+#define ADDR (void *)(0x8000000000000000UL)
+#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_LARGEPAGE | MAP_FIXED)
+#else
+#define ADDR (void *)(0x0UL)
+#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_LARGEPAGE)
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
