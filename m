Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E9EAD6B0035
	for <linux-mm@kvack.org>; Sun, 25 May 2014 22:02:42 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so6883376pbb.22
        for <linux-mm@kvack.org>; Sun, 25 May 2014 19:02:42 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id bc4si12639913pbb.71.2014.05.25.19.02.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 25 May 2014 19:02:42 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so6809797pad.23
        for <linux-mm@kvack.org>; Sun, 25 May 2014 19:02:41 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] swap: Avoid scanning invalidated region for cheap seek
Date: Mon, 26 May 2014 10:00:59 +0800
Message-Id: <1401069659-29589-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ddstreet@ieee.org, mgorman@suse.de, hughd@google.com, shli@kernel.org, k.kozlowski@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Yucong <slaoub@gmail.com>

For cheap seek, when we scan the region between si->lowset_bit
and scan_base, if san_base is greater than si->highest_bit, the
scan operation between si->highest_bit and scan_base is not
unnecessary.

This patch can be used to avoid scanning invalidated region for
cheap seek.

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/swapfile.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index beeeef8..7f0f27e 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -489,6 +489,7 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 {
 	unsigned long offset;
 	unsigned long scan_base;
+	unsigned long upper_bound;
 	unsigned long last_in_cluster = 0;
 	int latency_ration = LATENCY_LIMIT;
 
@@ -551,9 +552,11 @@ static unsigned long scan_swap_map(struct swap_info_struct *si,
 
 		offset = si->lowest_bit;
 		last_in_cluster = offset + SWAPFILE_CLUSTER - 1;
+		upper_bound = (scan_base <= si->highest_bit) ?
+				scan_base : (si->highest_bit + 1);
 
 		/* Locate the first empty (unaligned) cluster */
-		for (; last_in_cluster < scan_base; offset++) {
+		for (; last_in_cluster < upper_bound; offset++) {
 			if (si->swap_map[offset])
 				last_in_cluster = offset + SWAPFILE_CLUSTER;
 			else if (offset == last_in_cluster) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
