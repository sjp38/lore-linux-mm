Date: Thu, 26 Oct 2006 13:47:39 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 2/3] hugetlb: fix prio_tree unit
Message-ID: <20061026034739.GA6046@localhost.localdomain>
References: <Pine.LNX.4.64.0610250828020.8576@blonde.wat.veritas.com> <000001c6f890$373fb960$12d0180a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001c6f890$373fb960$12d0180a@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Hugh Dickins' <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 25, 2006 at 04:49:29PM -0700, Chen, Kenneth W wrote:
> Hugh Dickins wrote on Wednesday, October 25, 2006 12:41 AM
> > On Wed, 25 Oct 2006, David Gibson wrote:
> > > 
> > > Hugh, I'd like to add a testcase to the libhugetlbfs testsuite which
> > > will trigger this bug, but from the description above I'm not sure
> > > exactly how to tickle it.  Can you give some more details of what
> > > sequence of calls will cause the BUG_ON() to be called.
> > > 
> > > I've attached the skeleton test I have now, but I'm not sure if it's
> > > even close to what's really required for this.
> > 
> > I'll take a look, or reconstruct my own sequence, later on today and
> > send it just to you.  The BUG_ON was not at all what I was expecting,
> > and I spent quite a while working out how it came about (v_offset
> > wrapped, so vm_start + v_offset less than vm_start, so the huge unmap
> > applied to a non-huge vma before it).  Though I'm dubious whether it's
> > really worthwhile devising such a test now.
> 
> It's fairly easy to reproduce.  I got a test cases that easily trigger
> kernel oops and even got a sequence to screw up hugepage_rsvd count.
> All I have to do is to place vm_start high enough and combined with large
> enough v_offset, the add "vma->vm_start + v_offset" will overflow. It
> doesn't even need to be over 4GB.
> 
> Hugh, if you haven't got time to reconstruct the bug sequence, don't
> bother. I'll give my test cases to David.

Actually, Hugh already sent me a testcase by direct mail.  But more
testcases are already good.

I don't really understand your case1.c, though.  It didn't cause any
oops on my laptop (i386) and I couldn't see what else was expected to
behave differently between the "pass" and "fail" cases.  It returns an
uninitialized variable as exit code, btw..

So, I've integrated both Hugh's testcase and case2.c into the
libhugetlbfs testsuite.  A patch to libhugetlbfs is below.  It would
be good if we could get Signed-off-by lines for it from Hugh and
Kenneth, to keep the lawyer types happy, then Adam should be able to
merge it into libhugetlbfs.  It applies on top of my earlier patch
adding testcases for the i_size related reserve count wraparound.

Btw, Adam, while checking this, I discovered there are some other
failures in the testsuite on i386.  We should fix those...

libhugetlbfs: Test cases for prio_tree brokenness

A misconversion of hugetlb_vmtruncate_list to a prio_tree has meant
that on 32-bit machines, certain combinations of mapping and
truncations can truncate incorrect pages, or overwrite pmds from other
VMAs, triggering BUG_ON()s or other wierdness.

Hugh Dickins has submitted a kernel patch to fix the bug.  This patch
adds a couple of different test cases to libhugetlbfs to exercise it.
The test case logic is from Hugh Dickins and Kenneth Chen, I've
adapated it slightly to fold into the testsuite.

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Index: libhugetlbfs/tests/Makefile
===================================================================
--- libhugetlbfs.orig/tests/Makefile	2006-10-26 13:26:29.000000000 +1000
+++ libhugetlbfs/tests/Makefile	2006-10-26 13:26:31.000000000 +1000
@@ -4,7 +4,8 @@ LIB_TESTS = gethugepagesize test_root fi
 	readback truncate shared private empty_mounts meminfo_nohuge \
 	ptrace-write-hugepage icache-hygeine slbpacaflush \
 	chunk-overcommit mprotect alloc-instantiate-race mlock \
-	truncate_reserve_wraparound truncate_sigbus_versus_oom
+	truncate_reserve_wraparound truncate_sigbus_versus_oom \
+	map_high_truncate_2 truncate_above_4GB
 LIB_TESTS_64 = straddle_4GB huge_at_4GB_normal_below \
 	huge_below_4GB_normal_above
 NOLIB_TESTS = malloc malloc_manysmall dummy
Index: libhugetlbfs/tests/run_tests.sh
===================================================================
--- libhugetlbfs.orig/tests/run_tests.sh	2006-10-26 13:26:29.000000000 +1000
+++ libhugetlbfs/tests/run_tests.sh	2006-10-26 13:26:31.000000000 +1000
@@ -118,6 +118,8 @@ functional_tests () {
     run_test_bits 64 straddle_4GB
     run_test_bits 64 huge_at_4GB_normal_below
     run_test_bits 64 huge_below_4GB_normal_above
+    run_test map_high_truncate_2
+    run_test truncate_above_4GB
 
 # Tests requiring an active mount and hugepage COW
     run_test private
Index: libhugetlbfs/tests/truncate_above_4GB.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ libhugetlbfs/tests/truncate_above_4GB.c	2006-10-26 13:26:31.000000000 +1000
@@ -0,0 +1,136 @@
+/*
+ * libhugetlbfs - Easy use of Linux hugepages
+ * Copyright (C) 2005-2006 David Gibson & Adam Litke, IBM Corporation.
+ * Copyright (C) 2006 Hugh Dickins <hugh@veritas.com>
+ *
+ * This library is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public License
+ * as published by the Free Software Foundation; either version 2.1 of
+ * the License, or (at your option) any later version.
+ *
+ * This library is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * Lesser General Public License for more details.
+ *
+ * You should have received a copy of the GNU Lesser General Public
+ * License along with this library; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+#define _LARGEFILE64_SOURCE
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <signal.h>
+#include <sys/mman.h>
+
+#include <hugetlbfs.h>
+
+#include "hugetests.h"
+
+/*
+ * Test rationale:
+ *
+ * At one stage, a misconversion of hugetlb_vmtruncate_list to a
+ * prio_tree meant that on 32-bit machines, truncates at or above 4GB
+ * could truncate lower pages, resulting in BUG_ON()s.
+ */
+#define FOURGIG ((off64_t)0x100000000ULL)
+
+static void sigbus_handler_fail(int signum, siginfo_t *si, void *uc)
+{
+	FAIL("Unexpected SIGBUS");
+}
+
+static void sigbus_handler_pass(int signum, siginfo_t *si, void *uc)
+{
+	PASS();
+}
+
+int main(int argc, char *argv[])
+{
+	int page_size;
+	int hpage_size;
+	long long buggy_offset;
+	int fd;
+	void *p, *q;
+	volatile unsigned int *pi, *qi;
+	int err;
+	struct sigaction sa_fail = {
+		.sa_sigaction = sigbus_handler_fail,
+		.sa_flags = SA_SIGINFO,
+	};
+	struct sigaction sa_pass = {
+		.sa_sigaction = sigbus_handler_pass,
+		.sa_flags = SA_SIGINFO,
+	};
+
+	test_init(argc, argv);
+
+	page_size = getpagesize();
+	hpage_size = gethugepagesize();
+	if (hpage_size < 0)
+		CONFIG("No hugepage kernel support");
+
+	fd = hugetlbfs_unlinked_fd();
+	if (fd < 0)
+		FAIL("hugetlbfs_unlinked_fd()");
+
+	/* First get arena of three hpages size, at file offset 4GB */
+	q = mmap64(NULL, 3*hpage_size, PROT_READ|PROT_WRITE,
+		 MAP_PRIVATE, fd, FOURGIG);
+	if (q == MAP_FAILED)
+		FAIL("mmap() offset 4GB");
+	qi = q;
+	/* Touch the high page */
+	*qi = 0;
+
+	/* This part of the test makes the problem more obvious, but
+	 * is not essential.  It can't be done on powerpc, where
+	 * segment restrictions prohibit us from performing such a
+	 * mapping, so skip it there */
+#if !defined(__powerpc__) && !defined(__powerpc64__)
+	/* Replace middle hpage by tinypage mapping to trigger
+	 * nr_ptes BUG */
+	p = mmap64(q + hpage_size, hpage_size, PROT_READ|PROT_WRITE,
+		   MAP_FIXED|MAP_PRIVATE|MAP_ANON, -1, 0);
+	if (p != q + hpage_size)
+		FAIL("mmap() before low hpage");
+	pi = p;
+	/* Touch one page to allocate its page table */
+	*pi = 0;
+#endif
+
+	/* Replace top hpage by hpage mapping at confusing file offset */
+	buggy_offset = FOURGIG / (hpage_size / page_size);
+	p = mmap64(q + 2*hpage_size, hpage_size, PROT_READ|PROT_WRITE,
+		 MAP_FIXED|MAP_PRIVATE, fd, buggy_offset);
+	if (p != q + 2*hpage_size)
+		FAIL("mmap() buggy offset 0x%llx", buggy_offset);
+	pi = p;
+	/* Touch the low page with something non-zero */
+	*pi = 1;
+
+	err = ftruncate64(fd, FOURGIG);
+	if (err)
+		FAIL("ftruncate(): %s", strerror(errno));
+
+	err = sigaction(SIGBUS, &sa_fail, NULL);
+	if (err)
+		FAIL("sigaction() fail");
+
+	if (*pi != 1)
+		FAIL("Data 1 has changed to %u", *pi);
+
+	err = sigaction(SIGBUS, &sa_pass, NULL);
+	if (err)
+		FAIL("sigaction() pass");
+
+	*qi;
+
+	/* Should have SIGBUSed above */
+	FAIL("Didn't SIGBUS on truncated page.");
+}
Index: libhugetlbfs/hugeutils.c
===================================================================
--- libhugetlbfs.orig/hugeutils.c	2006-10-26 13:26:29.000000000 +1000
+++ libhugetlbfs/hugeutils.c	2006-10-26 13:26:31.000000000 +1000
@@ -235,7 +235,7 @@ int hugetlbfs_unlinked_fd(void)
 	strncat(name, "/libhugetlbfs.tmp.XXXXXX", sizeof(name)-1);
 	/* FIXME: deal with overflows */
 
-	fd = mkstemp(name);
+	fd = mkstemp64(name);
 
 	if (fd < 0) {
 		ERROR("mkstemp() failed: %s\n", strerror(errno));
Index: libhugetlbfs/tests/map_high_truncate_2.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ libhugetlbfs/tests/map_high_truncate_2.c	2006-10-26 13:32:21.000000000 +1000
@@ -0,0 +1,93 @@
+/*
+ * libhugetlbfs - Easy use of Linux hugepages
+ * Copyright (C) 2005-2006 David Gibson & Adam Litke, IBM Corporation.
+ *
+ * This library is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public License
+ * as published by the Free Software Foundation; either version 2.1 of
+ * the License, or (at your option) any later version.
+ *
+ * This library is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * Lesser General Public License for more details.
+ *
+ * You should have received a copy of the GNU Lesser General Public
+ * License along with this library; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+#define _LARGEFILE64_SOURCE
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <errno.h>
+#include <signal.h>
+#include <sys/mman.h>
+
+#include <hugetlbfs.h>
+
+#include "hugetests.h"
+
+/*
+ * Test rationale:
+ *
+ * At one stage, a misconversion of hugetlb_vmtruncate_list to a
+ * prio_tree meant that on 32-bit machines, certain combinations of
+ * mapping and truncations could truncate incorrect pages, or
+ * overwrite pmds from other VMAs, triggering BUG_ON()s or other
+ * wierdness.
+ *
+ * Test adapted to the libhugetlbfs framework from an example by
+ * Kenneth Chen <kenneth.w.chen@intel.com>
+ */
+#define MAP_LENGTH	(4 * hpage_size)
+#define TRUNCATE_POINT	0x60000000UL
+#define HIGH_ADDR	0xa0000000UL
+
+int main(int argc, char *argv[])
+{
+	int hpage_size;
+	int fd;
+	char *p, *q;
+	unsigned long i;
+	int err;
+
+	test_init(argc, argv);
+
+	hpage_size = gethugepagesize();
+	if (hpage_size < 0)
+		CONFIG("No hugepage kernel support");
+
+	fd = hugetlbfs_unlinked_fd();
+	if (fd < 0)
+		FAIL("hugetlbfs_unlinked_fd()");
+
+	/* First mapping */
+	p = mmap(0, MAP_LENGTH + TRUNCATE_POINT, PROT_READ | PROT_WRITE,
+		 MAP_PRIVATE, fd, 0);
+	if (p == MAP_FAILED)
+		FAIL("mmap() 1");
+
+	munmap(p, 4*hpage_size + TRUNCATE_POINT);
+
+	q = mmap((void *)HIGH_ADDR, MAP_LENGTH, PROT_READ | PROT_WRITE,
+		 MAP_PRIVATE, fd, 0);
+	if (q == MAP_FAILED)
+		FAIL("mmap() 2");
+
+	verbose_printf("High map at %p\n", q);
+
+	for (i = 0; i < MAP_LENGTH; i += hpage_size)
+		q[i] = 1;
+
+	err = ftruncate(fd, TRUNCATE_POINT);
+	if (err != 0)
+		FAIL("ftruncate()");
+
+	if (q[0] != 1)
+		FAIL("data mismatch");
+
+	PASS();
+}


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
