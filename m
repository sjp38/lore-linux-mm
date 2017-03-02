Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 47A5A6B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:12:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e66so12886427pfe.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:12:04 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z15si7655227pfg.211.2017.03.02.07.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:12:03 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] rmap: fix NULL-pointer dereference on THP munlocking
Date: Thu,  2 Mar 2017 18:11:59 +0300
Message-Id: <20170302151159.30592-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The following test case triggers NULL-pointer derefernce in
try_to_unmap_one():

	#include <fcntl.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <sys/mman.h>

	int main(int argc, char *argv[])
	{
		int fd;

		system("mount -t tmpfs -o huge=always none /mnt");
		fd = open("/mnt/test", O_CREAT | O_RDWR);
		ftruncate(fd, 2UL << 20);
		mmap(NULL, 2UL << 20, PROT_READ | PROT_WRITE,
				MAP_SHARED | MAP_FIXED | MAP_LOCKED, fd, 0);
		mmap(NULL, 2UL << 20, PROT_READ | PROT_WRITE,
				MAP_SHARED | MAP_LOCKED, fd, 0);
		munlockall();
		return 0;
	}

Apparently, there's a case when we call try_to_unmap() on huge PMDs:
it's TTU_MUNLOCK.

Let's handle this case correctly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Fixes: c7ab0d2fdc84 ("mm: convert try_to_unmap_one() to use page_vma_mapped_walk()")
---
 mm/rmap.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 8774791e2809..48ac9ae9bad0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1314,12 +1314,6 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	while (page_vma_mapped_walk(&pvmw)) {
-		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
-		address = pvmw.address;
-
-		/* Unexpected PMD-mapped THP? */
-		VM_BUG_ON_PAGE(!pvmw.pte, page);
-
 		/*
 		 * If the page is mlock()d, we cannot swap it out.
 		 * If it's recently referenced (perhaps page_referenced
@@ -1343,6 +1337,13 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 				continue;
 		}
 
+		/* Unexpected PMD-mapped THP? */
+		VM_BUG_ON_PAGE(!pvmw.pte, page);
+
+		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
+		address = pvmw.address;
+
+
 		if (!(flags & TTU_IGNORE_ACCESS)) {
 			if (ptep_clear_flush_young_notify(vma, address,
 						pvmw.pte)) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
