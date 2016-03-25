Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 402066B0005
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 06:05:31 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id tt10so43756168pab.3
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 03:05:31 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q64si18500971pfi.190.2016.03.25.03.05.29
        for <linux-mm@kvack.org>;
        Fri, 25 Mar 2016 03:05:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: fix regression in remap_file_pages() emulation
Date: Fri, 25 Mar 2016 13:05:23 +0300
Message-Id: <1458900325-77007-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Grazvydas Ignotas has reported a regression in remap_file_pages()
emulation.

Testcase:
	#define _GNU_SOURCE
	#include <assert.h>
	#include <stdlib.h>
	#include <stdio.h>
	#include <sys/mman.h>

	#define SIZE    (4096 * 3)

	int main(int argc, char **argv)
	{
		unsigned long *p;
		long i;

		p = mmap(NULL, SIZE, PROT_READ | PROT_WRITE,
				MAP_SHARED | MAP_ANONYMOUS, -1, 0);
		if (p == MAP_FAILED) {
			perror("mmap");
			return -1;
		}

		for (i = 0; i < SIZE / 4096; i++)
			p[i * 4096 / sizeof(*p)] = i;

		if (remap_file_pages(p, 4096, 0, 1, 0)) {
			perror("remap_file_pages");
			return -1;
		}

		if (remap_file_pages(p, 4096 * 2, 0, 1, 0)) {
			perror("remap_file_pages");
			return -1;
		}

		assert(p[0] == 1);

		munmap(p, SIZE);

		return 0;
	}

The second remap_file_pages() fails with -EINVAL.

The reason is that remap_file_pages() emulation assumes that the target
vma covers whole area we want to over map. That assumption is broken by
first remap_file_pages() call: it split the area into two vma.

The solution is to check next adjacent vmas, if they map the same file
with the same flags.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Grazvydas Ignotas <notasas@gmail.com>
---
 mm/mmap.c | 34 +++++++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 2f2415a7a688..76d1ec29149b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2664,12 +2664,29 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (!vma || !(vma->vm_flags & VM_SHARED))
 		goto out;
 
-	if (start < vma->vm_start || start + size > vma->vm_end)
+	if (start < vma->vm_start)
 		goto out;
 
-	if (pgoff == linear_page_index(vma, start)) {
-		ret = 0;
-		goto out;
+	if (start + size > vma->vm_end) {
+		struct vm_area_struct *next;
+
+		for (next = vma->vm_next; next; next = next->vm_next) {
+			/* hole between vmas ? */
+			if (next->vm_start != next->vm_prev->vm_end)
+				goto out;
+
+			if (next->vm_file != vma->vm_file)
+				goto out;
+
+			if (next->vm_flags != vma->vm_flags)
+				goto out;
+
+			if (start + size <= next->vm_end)
+				break;
+		}
+
+		if (!next)
+			goto out;
 	}
 
 	prot |= vma->vm_flags & VM_READ ? PROT_READ : 0;
@@ -2679,9 +2696,16 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	flags &= MAP_NONBLOCK;
 	flags |= MAP_SHARED | MAP_FIXED | MAP_POPULATE;
 	if (vma->vm_flags & VM_LOCKED) {
+		struct vm_area_struct *tmp;
 		flags |= MAP_LOCKED;
+
 		/* drop PG_Mlocked flag for over-mapped range */
-		munlock_vma_pages_range(vma, start, start + size);
+		for (tmp = vma; tmp->vm_start >= start + size;
+				tmp = tmp->vm_next) {
+			munlock_vma_pages_range(tmp,
+					max(tmp->vm_start, start),
+					min(tmp->vm_end, start + size));
+		}
 	}
 
 	file = get_file(vma->vm_file);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
