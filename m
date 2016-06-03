Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6665E6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 21:26:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so73742307pad.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 18:26:00 -0700 (PDT)
Received: from fiona.linuxhacker.ru (linuxhacker.ru. [217.76.32.60])
        by mx.google.com with ESMTPS id m132si3888663pfc.122.2016.06.02.18.25.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 18:25:59 -0700 (PDT)
From: green@linuxhacker.ru
Subject: [RESEND] [PATCH] mm: Do not discard partial pages with POSIX_FADV_DONTNEED
Date: Thu,  2 Jun 2016 21:25:40 -0400
Message-Id: <1464917140-1506698-1-git-send-email-green@linuxhacker.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "<linux-kernel@vger.kernel.org> Mailing List" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

I noticed that if the logic in fadvise64_64 syscall is incorrect
for partial pages. While first page of the region is correctly skipped
if it is partial, the last page of the region is mistakenly discarded.
This leads to problems for applications that read data in
non-page-aligned chunks discarding already processed data between
the reads.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
A somewhat misguided application that does something like
write(XX bytes (non-page-alligned)); drop the data it just wrote; repeat
gets a significant penalty in performance as the result.

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
