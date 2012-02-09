Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id BB5336B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 20:46:35 -0500 (EST)
Date: Thu, 9 Feb 2012 09:46:22 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH 3/3 v2] move hugepage test examples to
 tools/testing/selftests/vm
Message-ID: <20120209014622.GA5143@darkstar.nay.redhat.com>
References: <20120205081555.GA2249@darkstar.redhat.com>
 <20120206155340.b9075240.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120206155340.b9075240.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com, Frederic Weisbecker <fweisbec@gmail.com>

On Mon, Feb 06, 2012 at 03:53:40PM -0800, Andrew Morton wrote:
> On Sun, 5 Feb 2012 16:15:55 +0800
> Dave Young <dyoung@redhat.com> wrote:
> 
> > hugepage-mmap.c, hugepage-shm.c and map_hugetlb.c in Documentation/vm are
> > simple pass/fail tests, It's better to promote them to tools/testing/selftests
> > 
> > Thanks suggestion of Andrew Morton about this. They all need firstly setting up
> > proper nr_hugepages and hugepage-mmap need to mount hugetlbfs. So I add a shell
> > script run_test to do such work which will call the three test programs and
> > check the return value of them.
> > 
> > Changes to original code including below:
> > a. add run_test script
> > b. return error when read_bytes mismatch with writed bytes.
> > c. coding style fixes: do not use assignment in if condition
> > 
> 
> I think Frederic is doing away with tools/testing/selftests/run_tests
> in favour of a Makefile target?  ("make run_tests", for example).
> 
> Until we see such a patch we cannot finalise your patch and if I apply
> your patch, his patch will need more work.  Not that this is rocket
> science ;)
> 
> > 
> > ...
> >
> > --- /dev/null
> > +++ b/tools/testing/selftests/vm/run_test
> 
> (We now have a "run_tests" and a "run_test".  The difference in naming
> is irritating)
> 
> Your vm/run_test file does quite a lot of work and we couldn't sensibly
> move all its functionality into Makefile, I expect.
> 
> So I think it's OK to retain a script for this, but I do think that we
> should think up a standardized way of invoking it from vm/Makefile, so
> the top-level Makefile in tools/testing/selftests can simply do "cd
> vm;make run_test", where the run_test target exists in all
> subdirectories.  The vm/Makefile run_test target can then call out to
> the script.
> 
> Also, please do not assume that the script has the x bit set.  The x
> bit easily gets lost on kernel scripts (patch(1) can lose it) so it is
> safer to invoke the script via "/bin/sh script-name" or $SHELL or
> whatever.
> 
> Anyway, we should work with Frederic on sorting out some standard
> behavior before we can finalize this work, please.
> 

Andrew, updated the patch as below, is it ok to you?
---

hugepage-mmap.c, hugepage-shm.c and map_hugetlb.c in Documentation/vm are
simple pass/fail tests, It's better to promote them to tools/testing/selftests

Thanks suggestion of Andrew Morton about this. They all need firstly setting up
proper nr_hugepages and hugepage-mmap need to mount hugetlbfs. So I add a shell
script run_vmtests to do such work which will call the three test programs and
check the return value of them.

Changes to original code including below:
a. add run_vmtests script
b. return error when read_bytes mismatch with writed bytes.
c. coding style fixes: do not use assignment in if condition

[v1 -> v2]:
1. [akpm:] rebased on runing make run_tests from Makefile
2. [akpm:] rename test script from run_test ro run_vmtests
2. fix a bug about shell exit code checking 

Signed-off-by: Dave Young <dyoung@redhat.com>
---
 Documentation/vm/Makefile                  |    8 --
 Documentation/vm/hugepage-mmap.c           |   91 --------------------------
 Documentation/vm/hugepage-shm.c            |   98 ----------------------------
 Documentation/vm/map_hugetlb.c             |   77 ----------------------
 tools/testing/selftests/Makefile           |    2 
 tools/testing/selftests/vm/Makefile        |   14 ++++
 tools/testing/selftests/vm/hugepage-mmap.c |   92 ++++++++++++++++++++++++++
 tools/testing/selftests/vm/hugepage-shm.c  |  100 +++++++++++++++++++++++++++++
 tools/testing/selftests/vm/map_hugetlb.c   |   79 ++++++++++++++++++++++
 tools/testing/selftests/vm/run_vmtests     |   77 ++++++++++++++++++++++
 10 files changed, 363 insertions(+), 275 deletions(-)

--- linux-2.6.orig/Documentation/vm/Makefile	2012-02-09 09:25:05.053163733 +0800
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,8 +0,0 @@
-# kbuild trick to avoid linker error. Can be omitted if a module is built.
-obj- := dummy.o
-
-# List of programs to build
-hostprogs-y := hugepage-mmap hugepage-shm map_hugetlb
-
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
--- linux-2.6.orig/Documentation/vm/hugepage-mmap.c	2012-02-09 09:25:05.053163733 +0800
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,91 +0,0 @@
-/*
- * hugepage-mmap:
- *
- * Example of using huge page memory in a user application using the mmap
- * system call.  Before running this application, make sure that the
- * administrator has mounted the hugetlbfs filesystem (on some directory
- * like /mnt) using the command mount -t hugetlbfs nodev /mnt. In this
- * example, the app is requesting memory of size 256MB that is backed by
- * huge pages.
- *
- * For the ia64 architecture, the Linux kernel reserves Region number 4 for
- * huge pages.  That means that if one requires a fixed address, a huge page
- * aligned address starting with 0x800000... will be required.  If a fixed
- * address is not required, the kernel will select an address in the proper
- * range.
- * Other architectures, such as ppc64, i386 or x86_64 are not so constrained.
- */
-
-#include <stdlib.h>
-#include <stdio.h>
-#include <unistd.h>
-#include <sys/mman.h>
-#include <fcntl.h>
-
-#define FILE_NAME "/mnt/hugepagefile"
-#define LENGTH (256UL*1024*1024)
-#define PROTECTION (PROT_READ | PROT_WRITE)
-
-/* Only ia64 requires this */
-#ifdef __ia64__
-#define ADDR (void *)(0x8000000000000000UL)
-#define FLAGS (MAP_SHARED | MAP_FIXED)
-#else
-#define ADDR (void *)(0x0UL)
-#define FLAGS (MAP_SHARED)
-#endif
-
-static void check_bytes(char *addr)
-{
-	printf("First hex is %x\n", *((unsigned int *)addr));
-}
-
-static void write_bytes(char *addr)
-{
-	unsigned long i;
-
-	for (i = 0; i < LENGTH; i++)
-		*(addr + i) = (char)i;
-}
-
-static void read_bytes(char *addr)
-{
-	unsigned long i;
-
-	check_bytes(addr);
-	for (i = 0; i < LENGTH; i++)
-		if (*(addr + i) != (char)i) {
-			printf("Mismatch at %lu\n", i);
-			break;
-		}
-}
-
-int main(void)
-{
-	void *addr;
-	int fd;
-
-	fd = open(FILE_NAME, O_CREAT | O_RDWR, 0755);
-	if (fd < 0) {
-		perror("Open failed");
-		exit(1);
-	}
-
-	addr = mmap(ADDR, LENGTH, PROTECTION, FLAGS, fd, 0);
-	if (addr == MAP_FAILED) {
-		perror("mmap");
-		unlink(FILE_NAME);
-		exit(1);
-	}
-
-	printf("Returned address is %p\n", addr);
-	check_bytes(addr);
-	write_bytes(addr);
-	read_bytes(addr);
-
-	munmap(addr, LENGTH);
-	close(fd);
-	unlink(FILE_NAME);
-
-	return 0;
-}
--- linux-2.6.orig/Documentation/vm/hugepage-shm.c	2012-02-09 09:25:05.053163733 +0800
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,98 +0,0 @@
-/*
- * hugepage-shm:
- *
- * Example of using huge page memory in a user application using Sys V shared
- * memory system calls.  In this example the app is requesting 256MB of
- * memory that is backed by huge pages.  The application uses the flag
- * SHM_HUGETLB in the shmget system call to inform the kernel that it is
- * requesting huge pages.
- *
- * For the ia64 architecture, the Linux kernel reserves Region number 4 for
- * huge pages.  That means that if one requires a fixed address, a huge page
- * aligned address starting with 0x800000... will be required.  If a fixed
- * address is not required, the kernel will select an address in the proper
- * range.
- * Other architectures, such as ppc64, i386 or x86_64 are not so constrained.
- *
- * Note: The default shared memory limit is quite low on many kernels,
- * you may need to increase it via:
- *
- * echo 268435456 > /proc/sys/kernel/shmmax
- *
- * This will increase the maximum size per shared memory segment to 256MB.
- * The other limit that you will hit eventually is shmall which is the
- * total amount of shared memory in pages. To set it to 16GB on a system
- * with a 4kB pagesize do:
- *
- * echo 4194304 > /proc/sys/kernel/shmall
- */
-
-#include <stdlib.h>
-#include <stdio.h>
-#include <sys/types.h>
-#include <sys/ipc.h>
-#include <sys/shm.h>
-#include <sys/mman.h>
-
-#ifndef SHM_HUGETLB
-#define SHM_HUGETLB 04000
-#endif
-
-#define LENGTH (256UL*1024*1024)
-
-#define dprintf(x)  printf(x)
-
-/* Only ia64 requires this */
-#ifdef __ia64__
-#define ADDR (void *)(0x8000000000000000UL)
-#define SHMAT_FLAGS (SHM_RND)
-#else
-#define ADDR (void *)(0x0UL)
-#define SHMAT_FLAGS (0)
-#endif
-
-int main(void)
-{
-	int shmid;
-	unsigned long i;
-	char *shmaddr;
-
-	if ((shmid = shmget(2, LENGTH,
-			    SHM_HUGETLB | IPC_CREAT | SHM_R | SHM_W)) < 0) {
-		perror("shmget");
-		exit(1);
-	}
-	printf("shmid: 0x%x\n", shmid);
-
-	shmaddr = shmat(shmid, ADDR, SHMAT_FLAGS);
-	if (shmaddr == (char *)-1) {
-		perror("Shared memory attach failure");
-		shmctl(shmid, IPC_RMID, NULL);
-		exit(2);
-	}
-	printf("shmaddr: %p\n", shmaddr);
-
-	dprintf("Starting the writes:\n");
-	for (i = 0; i < LENGTH; i++) {
-		shmaddr[i] = (char)(i);
-		if (!(i % (1024 * 1024)))
-			dprintf(".");
-	}
-	dprintf("\n");
-
-	dprintf("Starting the Check...");
-	for (i = 0; i < LENGTH; i++)
-		if (shmaddr[i] != (char)i)
-			printf("\nIndex %lu mismatched\n", i);
-	dprintf("Done.\n");
-
-	if (shmdt((const void *)shmaddr) != 0) {
-		perror("Detach failure");
-		shmctl(shmid, IPC_RMID, NULL);
-		exit(3);
-	}
-
-	shmctl(shmid, IPC_RMID, NULL);
-
-	return 0;
-}
--- linux-2.6.orig/Documentation/vm/map_hugetlb.c	2012-02-09 09:25:05.053163733 +0800
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,77 +0,0 @@
-/*
- * Example of using hugepage memory in a user application using the mmap
- * system call with MAP_HUGETLB flag.  Before running this program make
- * sure the administrator has allocated enough default sized huge pages
- * to cover the 256 MB allocation.
- *
- * For ia64 architecture, Linux kernel reserves Region number 4 for hugepages.
- * That means the addresses starting with 0x800000... will need to be
- * specified.  Specifying a fixed address is not required on ppc64, i386
- * or x86_64.
- */
-#include <stdlib.h>
-#include <stdio.h>
-#include <unistd.h>
-#include <sys/mman.h>
-#include <fcntl.h>
-
-#define LENGTH (256UL*1024*1024)
-#define PROTECTION (PROT_READ | PROT_WRITE)
-
-#ifndef MAP_HUGETLB
-#define MAP_HUGETLB 0x40000 /* arch specific */
-#endif
-
-/* Only ia64 requires this */
-#ifdef __ia64__
-#define ADDR (void *)(0x8000000000000000UL)
-#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_FIXED)
-#else
-#define ADDR (void *)(0x0UL)
-#define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB)
-#endif
-
-static void check_bytes(char *addr)
-{
-	printf("First hex is %x\n", *((unsigned int *)addr));
-}
-
-static void write_bytes(char *addr)
-{
-	unsigned long i;
-
-	for (i = 0; i < LENGTH; i++)
-		*(addr + i) = (char)i;
-}
-
-static void read_bytes(char *addr)
-{
-	unsigned long i;
-
-	check_bytes(addr);
-	for (i = 0; i < LENGTH; i++)
-		if (*(addr + i) != (char)i) {
-			printf("Mismatch at %lu\n", i);
-			break;
-		}
-}
-
-int main(void)
-{
-	void *addr;
-
-	addr = mmap(ADDR, LENGTH, PROTECTION, FLAGS, 0, 0);
-	if (addr == MAP_FAILED) {
-		perror("mmap");
-		exit(1);
-	}
-
-	printf("Returned address is %p\n", addr);
-	check_bytes(addr);
-	write_bytes(addr);
-	read_bytes(addr);
-
-	munmap(addr, LENGTH);
-
-	return 0;
-}
--- linux-2.6.orig/tools/testing/selftests/Makefile	2012-02-09 09:25:05.056497066 +0800
+++ linux-2.6/tools/testing/selftests/Makefile	2012-02-09 09:25:45.963161759 +0800
@@ -1,4 +1,4 @@
-TARGETS = breakpoints
+TARGETS = breakpoints vm
 
 all:
 	for TARGET in $(TARGETS); do \
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/tools/testing/selftests/vm/Makefile	2012-02-09 09:26:16.843160268 +0800
@@ -0,0 +1,14 @@
+# Makefile for vm selftests
+
+CC = $(CROSS_COMPILE)gcc
+CFLAGS = -Wall -Wextra
+
+all: hugepage-mmap hugepage-shm  map_hugetlb
+%: %.c
+	$(CC) $(CFLAGS) -o $@ $^
+
+run_tests:
+	/bin/sh ./run_vmtests
+
+clean:
+	$(RM) hugepage-mmap hugepage-shm  map_hugetlb
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/tools/testing/selftests/vm/hugepage-mmap.c	2012-02-09 09:25:45.966495092 +0800
@@ -0,0 +1,92 @@
+/*
+ * hugepage-mmap:
+ *
+ * Example of using huge page memory in a user application using the mmap
+ * system call.  Before running this application, make sure that the
+ * administrator has mounted the hugetlbfs filesystem (on some directory
+ * like /mnt) using the command mount -t hugetlbfs nodev /mnt. In this
+ * example, the app is requesting memory of size 256MB that is backed by
+ * huge pages.
+ *
+ * For the ia64 architecture, the Linux kernel reserves Region number 4 for
+ * huge pages.  That means that if one requires a fixed address, a huge page
+ * aligned address starting with 0x800000... will be required.  If a fixed
+ * address is not required, the kernel will select an address in the proper
+ * range.
+ * Other architectures, such as ppc64, i386 or x86_64 are not so constrained.
+ */
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+#include <sys/mman.h>
+#include <fcntl.h>
+
+#define FILE_NAME "huge/hugepagefile"
+#define LENGTH (256UL*1024*1024)
+#define PROTECTION (PROT_READ | PROT_WRITE)
+
+/* Only ia64 requires this */
+#ifdef __ia64__
+#define ADDR (void *)(0x8000000000000000UL)
+#define FLAGS (MAP_SHARED | MAP_FIXED)
+#else
+#define ADDR (void *)(0x0UL)
+#define FLAGS (MAP_SHARED)
+#endif
+
+static void check_bytes(char *addr)
+{
+	printf("First hex is %x\n", *((unsigned int *)addr));
+}
+
+static void write_bytes(char *addr)
+{
+	unsigned long i;
+
+	for (i = 0; i < LENGTH; i++)
+		*(addr + i) = (char)i;
+}
+
+static int read_bytes(char *addr)
+{
+	unsigned long i;
+
+	check_bytes(addr);
+	for (i = 0; i < LENGTH; i++)
+		if (*(addr + i) != (char)i) {
+			printf("Mismatch at %lu\n", i);
+			return 1;
+		}
+	return 0;
+}
+
+int main(void)
+{
+	void *addr;
+	int fd, ret;
+
+	fd = open(FILE_NAME, O_CREAT | O_RDWR, 0755);
+	if (fd < 0) {
+		perror("Open failed");
+		exit(1);
+	}
+
+	addr = mmap(ADDR, LENGTH, PROTECTION, FLAGS, fd, 0);
+	if (addr == MAP_FAILED) {
+		perror("mmap");
+		unlink(FILE_NAME);
+		exit(1);
+	}
+
+	printf("Returned address is %p\n", addr);
+	check_bytes(addr);
+	write_bytes(addr);
+	ret = read_bytes(addr);
+
+	munmap(addr, LENGTH);
+	close(fd);
+	unlink(FILE_NAME);
+
+	return ret;
+}
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/tools/testing/selftests/vm/hugepage-shm.c	2012-02-09 09:25:45.966495092 +0800
@@ -0,0 +1,100 @@
+/*
+ * hugepage-shm:
+ *
+ * Example of using huge page memory in a user application using Sys V shared
+ * memory system calls.  In this example the app is requesting 256MB of
+ * memory that is backed by huge pages.  The application uses the flag
+ * SHM_HUGETLB in the shmget system call to inform the kernel that it is
+ * requesting huge pages.
+ *
+ * For the ia64 architecture, the Linux kernel reserves Region number 4 for
+ * huge pages.  That means that if one requires a fixed address, a huge page
+ * aligned address starting with 0x800000... will be required.  If a fixed
+ * address is not required, the kernel will select an address in the proper
+ * range.
+ * Other architectures, such as ppc64, i386 or x86_64 are not so constrained.
+ *
+ * Note: The default shared memory limit is quite low on many kernels,
+ * you may need to increase it via:
+ *
+ * echo 268435456 > /proc/sys/kernel/shmmax
+ *
+ * This will increase the maximum size per shared memory segment to 256MB.
+ * The other limit that you will hit eventually is shmall which is the
+ * total amount of shared memory in pages. To set it to 16GB on a system
+ * with a 4kB pagesize do:
+ *
+ * echo 4194304 > /proc/sys/kernel/shmall
+ */
+
+#include <stdlib.h>
+#include <stdio.h>
+#include <sys/types.h>
+#include <sys/ipc.h>
+#include <sys/shm.h>
+#include <sys/mman.h>
+
+#ifndef SHM_HUGETLB
+#define SHM_HUGETLB 04000
+#endif
+
+#define LENGTH (256UL*1024*1024)
+
+#define dprintf(x)  printf(x)
+
+/* Only ia64 requires this */
+#ifdef __ia64__
+#define ADDR (void *)(0x8000000000000000UL)
+#define SHMAT_FLAGS (SHM_RND)
+#else
+#define ADDR (void *)(0x0UL)
+#define SHMAT_FLAGS (0)
+#endif
+
+int main(void)
+{
+	int shmid;
+	unsigned long i;
+	char *shmaddr;
+
+	shmid = shmget(2, LENGTH, SHM_HUGETLB | IPC_CREAT | SHM_R | SHM_W);
+	if (shmid < 0) {
+		perror("shmget");
+		exit(1);
+	}
+	printf("shmid: 0x%x\n", shmid);
+
+	shmaddr = shmat(shmid, ADDR, SHMAT_FLAGS);
+	if (shmaddr == (char *)-1) {
+		perror("Shared memory attach failure");
+		shmctl(shmid, IPC_RMID, NULL);
+		exit(2);
+	}
+	printf("shmaddr: %p\n", shmaddr);
+
+	dprintf("Starting the writes:\n");
+	for (i = 0; i < LENGTH; i++) {
+		shmaddr[i] = (char)(i);
+		if (!(i % (1024 * 1024)))
+			dprintf(".");
+	}
+	dprintf("\n");
+
+	dprintf("Starting the Check...");
+	for (i = 0; i < LENGTH; i++)
+		if (shmaddr[i] != (char)i) {
+			printf("\nIndex %lu mismatched\n", i);
+			exit(3);
+		}
+	dprintf("Done.\n");
+
+	if (shmdt((const void *)shmaddr) != 0) {
+		perror("Detach failure");
+		shmctl(shmid, IPC_RMID, NULL);
+		exit(4);
+	}
+
+	shmctl(shmid, IPC_RMID, NULL);
+
+	return 0;
+}
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/tools/testing/selftests/vm/map_hugetlb.c	2012-02-09 09:25:45.966495092 +0800
@@ -0,0 +1,79 @@
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
+#define MAP_HUGETLB 0x40000 /* arch specific */
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
+static void check_bytes(char *addr)
+{
+	printf("First hex is %x\n", *((unsigned int *)addr));
+}
+
+static void write_bytes(char *addr)
+{
+	unsigned long i;
+
+	for (i = 0; i < LENGTH; i++)
+		*(addr + i) = (char)i;
+}
+
+static int read_bytes(char *addr)
+{
+	unsigned long i;
+
+	check_bytes(addr);
+	for (i = 0; i < LENGTH; i++)
+		if (*(addr + i) != (char)i) {
+			printf("Mismatch at %lu\n", i);
+			return 1;
+		}
+	return 0;
+}
+
+int main(void)
+{
+	void *addr;
+	int ret;
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
+	ret = read_bytes(addr);
+
+	munmap(addr, LENGTH);
+
+	return ret;
+}
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/tools/testing/selftests/vm/run_vmtests	2012-02-09 09:27:12.163157528 +0800
@@ -0,0 +1,77 @@
+#!/bin/bash
+#please run as root
+
+#we need 256M, below is the size in kB
+needmem=262144
+mnt=./huge
+
+#get pagesize and freepages from /proc/meminfo
+while read name size unit; do
+	if [ "$name" = "HugePages_Free:" ]; then
+		freepgs=$size
+	fi
+	if [ "$name" = "Hugepagesize:" ]; then
+		pgsize=$size
+	fi
+done < /proc/meminfo
+
+#set proper nr_hugepages
+if [ -n "$freepgs" ] && [ -n "$pgsize" ]; then
+	nr_hugepgs=`cat /proc/sys/vm/nr_hugepages`
+	needpgs=`expr $needmem / $pgsize`
+	if [ $freepgs -lt $needpgs ]; then
+		lackpgs=$(( $needpgs - $freepgs ))
+		echo $(( $lackpgs + $nr_hugepgs )) > /proc/sys/vm/nr_hugepages
+		if [ $? -ne 0 ]; then
+			echo "Please run this test as root"
+			exit 1
+		fi
+	fi
+else
+	echo "no hugetlbfs support in kernel?"
+	exit 1
+fi
+
+mkdir $mnt
+mount -t hugetlbfs none $mnt
+
+echo "--------------------"
+echo "runing hugepage-mmap"
+echo "--------------------"
+./hugepage-mmap
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
+
+shmmax=`cat /proc/sys/kernel/shmmax`
+shmall=`cat /proc/sys/kernel/shmall`
+echo 268435456 > /proc/sys/kernel/shmmax
+echo 4194304 > /proc/sys/kernel/shmall
+echo "--------------------"
+echo "runing hugepage-shm"
+echo "--------------------"
+./hugepage-shm
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
+echo $shmmax > /proc/sys/kernel/shmmax
+echo $shmall > /proc/sys/kernel/shmall
+
+echo "--------------------"
+echo "runing map_hugetlb"
+echo "--------------------"
+./map_hugetlb
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
+
+#cleanup
+umount $mnt
+rm -rf $mnt
+echo $nr_hugepgs > /proc/sys/vm/nr_hugepages

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
