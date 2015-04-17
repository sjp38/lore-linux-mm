Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1641E6B0070
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 08:20:49 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so126590804pdb.1
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 05:20:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ko11si16488883pbd.90.2015.04.17.05.20.47
        for <linux-mm@kvack.org>;
        Fri, 17 Apr 2015 05:20:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: fix mprotect() behaviour on VM_LOCKED VMAs
Date: Fri, 17 Apr 2015 15:20:08 +0300
Message-Id: <1429273208-168364-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On mlock(2) we trigger COW on private writable VMA to avoid faults in
future.

mm/gup.c:
 840 long populate_vma_page_range(struct vm_area_struct *vma,
 841                 unsigned long start, unsigned long end, int *nonblocking)
 842 {
 ...
 855          * We want to touch writable mappings with a write fault in order
 856          * to break COW, except for shared mappings because these don't COW
 857          * and we would not want to dirty them for nothing.
 858          */
 859         if ((vma->vm_flags & (VM_WRITE | VM_SHARED)) == VM_WRITE)
 860                 gup_flags |= FOLL_WRITE;

But we miss this case when we make VM_LOCKED VMA writeable via
mprotect(2). The test case:

	#define _GNU_SOURCE
	#include <fcntl.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <sys/mman.h>
	#include <sys/resource.h>
	#include <sys/stat.h>
	#include <sys/time.h>
	#include <sys/types.h>

	#define PAGE_SIZE 4096

	int main(int argc, char **argv)
	{
		struct rusage usage;
		long before;
		char *p;
		int fd;

		/* Create a file and populate first page of page cache */
		fd = open("/tmp", O_TMPFILE | O_RDWR, S_IRUSR | S_IWUSR);
		write(fd, "1", 1);

		/* Create a *read-only* *private* mapping of the file */
		p = mmap(NULL, PAGE_SIZE, PROT_READ, MAP_PRIVATE, fd, 0);

		/*
		 * Since the mapping is read-only, mlock() will populate the mapping
		 * with PTEs pointing to page cache without triggering COW.
		 */
		mlock(p, PAGE_SIZE);

		/*
		 * Mapping became read-write, but it's still populated with PTEs
		 * pointing to page cache.
		 */
		mprotect(p, PAGE_SIZE, PROT_READ | PROT_WRITE);

		getrusage(RUSAGE_SELF, &usage);
		before = usage.ru_minflt;

		/* Trigger COW: fault in mlock()ed VMA. */
		*p = 1;

		getrusage(RUSAGE_SELF, &usage);
		printf("faults: %ld\n", usage.ru_minflt - before);

		return 0;
	}

	$ ./test
	faults: 1

Let's fix it by triggering populating of VMA in mprotect_fixup() on this
condition. We don't care about population error as we don't in other
similar cases i.e. mremap.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mprotect.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 88584838e704..911fb9070b2b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -29,6 +29,8 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#include "internal.h"
+
 /*
  * For a prot_numa update we only hold mmap_sem for read so there is a
  * potential race with faulting where a pmd was temporarily none. This
@@ -322,6 +324,15 @@ success:
 	change_protection(vma, start, end, vma->vm_page_prot,
 			  dirty_accountable, 0);
 
+	/*
+	 * Private VM_LOCKED VMA become writable: trigger COW to avoid major
+	 * fault on access.
+	 */
+	if ((oldflags & (VM_WRITE | VM_SHARED | VM_LOCKED)) == VM_LOCKED &&
+			(newflags & VM_WRITE)) {
+		populate_vma_page_range(vma, start, end, NULL);
+	}
+
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	perf_event_mmap(vma);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
