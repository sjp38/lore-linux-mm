Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6806B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 21:21:21 -0500 (EST)
Received: by mail-yk0-f169.google.com with SMTP id q9so6883864ykb.0
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 18:21:21 -0800 (PST)
Received: from mail-vb0-x249.google.com (mail-vb0-x249.google.com [2607:f8b0:400c:c02::249])
        by mx.google.com with ESMTPS id s6si8601121yho.14.2014.01.21.18.21.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 18:21:20 -0800 (PST)
Received: by mail-vb0-f73.google.com with SMTP id w18so792953vbj.4
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 18:21:19 -0800 (PST)
From: Jamie Liu <jamieliu@google.com>
Subject: [PATCH] swap: do not skip lowest_bit in scan_swap_map() scan loop
Date: Tue, 21 Jan 2014 18:21:16 -0800
Message-Id: <1390357276-16521-1-git-send-email-jamieliu@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fusionio.com>, Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Akinobu Mita <akinobu.mita@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jamie Liu <jamieliu@google.com>

In the second half of scan_swap_map()'s scan loop, offset is set to
si->lowest_bit and then incremented before entering the loop for the
first time, causing si->swap_map[si->lowest_bit] to be skipped.

Signed-off-by: Jamie Liu <jamieliu@google.com>
---
 mm/swapfile.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 612a7c9..6635081 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -616,7 +616,7 @@ scan:
 		}
 	}
 	offset = si->lowest_bit;
-	while (++offset < scan_base) {
+	while (offset < scan_base) {
 		if (!si->swap_map[offset]) {
 			spin_lock(&si->lock);
 			goto checks;
@@ -629,6 +629,7 @@ scan:
 			cond_resched();
 			latency_ration = LATENCY_LIMIT;
 		}
+		offset++;
 	}
 	spin_lock(&si->lock);
 
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
