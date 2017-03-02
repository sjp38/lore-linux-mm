Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD6106B038C
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:03:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 1so93965720pgz.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:03:02 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b35si7670176plh.80.2017.03.02.07.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 07:03:01 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp: fix another corner case of munlock() vs. THPs
Date: Thu,  2 Mar 2017 18:02:52 +0300
Message-Id: <20170302150252.34120-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "[4.5+]" <stable@vger.kernel.org>

The following test case triggers BUG() in munlock_vma_pages_range():

	int main(int argc, char *argv[])
	{
		int fd;

		system("mount -t tmpfs -o huge=always none /mnt");
		fd = open("/mnt/test", O_CREAT | O_RDWR);
		ftruncate(fd, 4UL << 20);
		mmap(NULL, 4UL << 20, PROT_READ | PROT_WRITE,
				MAP_SHARED | MAP_FIXED | MAP_LOCKED, fd, 0);
		mmap(NULL, 4096, PROT_READ | PROT_WRITE,
				MAP_SHARED | MAP_LOCKED, fd, 0);
		munlockall();
		return 0;
	}

The second mmap() create PTE-mapping of the first huge page in file. It
makes kernel munlock the page as we never keep PTE-mapped page mlocked.

On munlockall() when we handle vma created by the first mmap(),
munlock_vma_page() returns page_mask == 0, as the page is not mlocked
anymore. On next iteration follow_page_mask() return tail page, but
page_mask is HPAGE_NR_PAGES - 1. It makes us skip to the first tail page
of the next huge page and step on VM_BUG_ON_PAGE(PageMlocked(page)).

The fix is not use the page_mask from follow_page_mask() at all. It has
no use for us.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: <stable@vger.kernel.org>    [4.5+]
---
 mm/mlock.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index cdbed8aaa426..665ab75b5533 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -441,7 +441,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 
 	while (start < end) {
 		struct page *page;
-		unsigned int page_mask;
+		unsigned int page_mask = 0;
 		unsigned long page_increm;
 		struct pagevec pvec;
 		struct zone *zone;
@@ -455,8 +455,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		 * suits munlock very well (and if somehow an abnormal page
 		 * has sneaked into the range, we won't oops here: great).
 		 */
-		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
-				&page_mask);
+		page = follow_page(vma, start, FOLL_GET | FOLL_DUMP);
 
 		if (page && !IS_ERR(page)) {
 			if (PageTransTail(page)) {
@@ -467,8 +466,8 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				/*
 				 * Any THP page found by follow_page_mask() may
 				 * have gotten split before reaching
-				 * munlock_vma_page(), so we need to recompute
-				 * the page_mask here.
+				 * munlock_vma_page(), so we need to compute
+				 * the page_mask here instead.
 				 */
 				page_mask = munlock_vma_page(page);
 				unlock_page(page);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
