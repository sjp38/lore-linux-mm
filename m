Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3AD6B027A
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 23:16:54 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id i7so14695167plt.3
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 20:16:54 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id 17si9949822pgh.538.2017.12.22.20.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 20:16:53 -0800 (PST)
From: "=?UTF-8?B?5Y2B5YiA?=" <shidao.ytt@alibaba-inc.com>
Subject: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
Date: Sat, 23 Dec 2017 12:16:08 +0800
Message-Id: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@techsingularity.net, green@linuxhacker.ru
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, =?UTF-8?B?5p2o5YuHKOaZuuW9uyk=?= <zhiche.yy@alibaba-inc.com>, =?UTF-8?B?5aS35YiZKENhc3Bhcik=?= <jinli.zjl@alibaba-inc.com>, =?UTF-8?B?5Y2B5YiA?= <shidao.ytt@alibaba-inc.com>

From: "shidao.ytt" <shidao.ytt@alibaba-inc.com>

in commit 441c228f817f7 ("mm: fadvise: document the
fadvise(FADV_DONTNEED) behaviour for partial pages") Mel Gorman
explained why partial pages should be preserved instead of discarded
when using fadvise(FADV_DONTNEED), however the actual codes to calcuate
end_index was unexpectedly wrong, the code behavior didn't match to the
statement in comments; Luckily in another commit 18aba41cbf
("mm/fadvise.c: do not discard partial pages with POSIX_FADV_DONTNEED")
Oleg Drokin fixed this behavior

Here I come up with a new idea that actually we can still discard the
last parital page iff the page-unaligned endbyte is also the end of
file, since no one else will use the rest of the page and it should be
safe enough to discard.

Signed-off-by: shidao.ytt <shidao.ytt@alibaba-inc.com>
Signed-off-by: Caspar Zhang <jinli.zjl@alibaba-inc.com>
---
 mm/fadvise.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/fadvise.c b/mm/fadvise.c
index ec70d6e..f74b21e 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -127,7 +127,8 @@
 		 */
 		start_index = (offset+(PAGE_SIZE-1)) >> PAGE_SHIFT;
 		end_index = (endbyte >> PAGE_SHIFT);
-		if ((endbyte & ~PAGE_MASK) != ~PAGE_MASK) {
+		if ((endbyte & ~PAGE_MASK) != ~PAGE_MASK &&
+				endbyte != inode->i_size - 1) {
 			/* First page is tricky as 0 - 1 = -1, but pgoff_t
 			 * is unsigned, so the end_index >= start_index
 			 * check below would be true and we'll discard the whole
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
