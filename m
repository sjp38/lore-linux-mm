Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 719136B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 19:02:20 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so61528169wic.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 16:02:19 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id gq1si12631958wib.2.2015.09.26.16.02.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 16:02:19 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so61893774wic.0
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 16:02:19 -0700 (PDT)
Message-ID: <560723F8.3010909@gmail.com>
Date: Sun, 27 Sep 2015 01:02:16 +0200
From: angelo <angelo70@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: fix cpu hangs on truncating last page of a 16t sparse
 file
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Hi all,

running xfstests, generic 308 on whatever 32bit arch is possible
to observe cpu to hang near 100% on unlink.
The test removes a sparse file of length 16tera where only the last
4096 bytes block is mapped.
At line 265 of truncate.c there is a
if (index >= end)
     break;
But if index is, as in this case, a 4294967295, it match -1 used as
eof. Hence the cpu loops 100% just after.

-------------------

On 32bit archs, with CONFIG_LBDAF=y, if truncating last page
of a 16tera file, "index" variable is set to 4294967295, and hence
matches with -1 used as EOF value. This result in an inifite loop
when unlink is executed on this file.

Signed-off-by: Angelo Dureghello <angelo@sysam.it>
---
  mm/truncate.c | 11 ++++++-----
  1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 76e35ad..3751034 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -283,14 +283,15 @@ void truncate_inode_pages_range(struct 
address_space *mapping,
                 pagevec_remove_exceptionals(&pvec);
                 pagevec_release(&pvec);
                 cond_resched();
-               index++;
+               if (index < end)
+                       index++;
         }

         if (partial_start) {
                 struct page *page = find_lock_page(mapping, start - 1);
                 if (page) {
                         unsigned int top = PAGE_CACHE_SIZE;
-                       if (start > end) {
+                       if (start > end && end != -1) {
                                 /* Truncation within a single page */
                                 top = partial_end;
                                 partial_end = 0;
@@ -322,7 +323,7 @@ void truncate_inode_pages_range(struct address_space 
*mapping,
          * If the truncation happened within a single page no pages
          * will be released, just zeroed, so we can bail out now.
          */
-       if (start >= end)
+       if (start >= end && end != -1)
                 return;

         index = start;
@@ -337,7 +338,7 @@ void truncate_inode_pages_range(struct address_space 
*mapping,
                         index = start;
                         continue;
                 }
-               if (index == start && indices[0] >= end) {
+               if (index == start && (indices[0] >= end && end != -1)) {
                         /* All gone out of hole to be punched, we're 
done */
                         pagevec_remove_exceptionals(&pvec);
                         pagevec_release(&pvec);
@@ -348,7 +349,7 @@ void truncate_inode_pages_range(struct address_space 
*mapping,

                         /* We rely upon deletion not changing 
page->index */
                         index = indices[i];
-                       if (index >= end) {
+                       if (index >= end && (end != -1)) {
                                 /* Restart punch to make sure all gone */
                                 index = start - 1;
                                 break;
-- 
2.5.3









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
