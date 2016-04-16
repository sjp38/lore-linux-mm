Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A8486B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 23:29:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a140so31322467wma.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 20:29:29 -0700 (PDT)
Received: from fiona.linuxhacker.ru (linuxhacker.ru. [217.76.32.60])
        by mx.google.com with ESMTPS id u194si27920113lfd.134.2016.04.15.20.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 20:29:27 -0700 (PDT)
From: green@linuxhacker.ru
Subject: [PATCH] mm: Do not discard partial pages with POSIX_FADV_DONTNEED
Date: Fri, 15 Apr 2016 23:28:54 -0400
Message-Id: <1460777334-3484107-1-git-send-email-green@linuxhacker.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.com>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

I noticed that the logic in fadvise64_64 syscall is incorrect
for partial pages. While first page of the region is correctly skipped
if it is partial, the last page of the region is mistakenly discarded.
This leads to problems for applications that read data in
non-page-aligned chunks discarding already processed data between
the reads.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 mm/fadvise.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index b8024fa..6c707bf 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -126,6 +126,17 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 		 */
 		start_index = (offset+(PAGE_SIZE-1)) >> PAGE_SHIFT;
 		end_index = (endbyte >> PAGE_SHIFT);
+		if ((endbyte & ~PAGE_MASK) != ~PAGE_MASK) {
+			/* First page is tricky as 0 - 1 = -1, but pgoff_t
+			 * is unsigned, so the end_index >= start_index
+			 * check below would be true and we'll discard the whole
+			 * file cache which is not what was asked.
+			 */
+			if (end_index == 0)
+				break;
+
+			end_index--;
+		}
 
 		if (end_index >= start_index) {
 			unsigned long count = invalidate_mapping_pages(mapping,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
