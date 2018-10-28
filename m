Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 186E56B0342
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 02:14:01 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id r125-v6so6359567qke.8
        for <linux-mm@kvack.org>; Sat, 27 Oct 2018 23:14:01 -0700 (PDT)
Received: from sonic309-26.consmr.mail.ir2.yahoo.com (sonic309-26.consmr.mail.ir2.yahoo.com. [77.238.179.84])
        by mx.google.com with ESMTPS id f60si4590898qva.210.2018.10.27.23.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Oct 2018 23:13:59 -0700 (PDT)
From: Gao Xiang <hsiangkao@aol.com>
Subject: [PATCH] mm: simplify get_next_ra_size
Date: Sun, 28 Oct 2018 14:13:26 +0800
Message-Id: <1540707206-19649-1-git-send-email-hsiangkao@aol.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Gao Xiang <hsiangkao@aol.com>

It's a trivial simplification for get_next_ra_size and
clear enough for humans to understand.

It also fixes potential overflow if ra->size(< ra_pages) is too large.

Cc: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Gao Xiang <hsiangkao@aol.com>
---
 mm/readahead.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 4e63014..205ac34 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -272,17 +272,15 @@ static unsigned long get_init_ra_size(unsigned long size, unsigned long max)
  *  return it as the new window size.
  */
 static unsigned long get_next_ra_size(struct file_ra_state *ra,
-						unsigned long max)
+				      unsigned long max)
 {
 	unsigned long cur = ra->size;
-	unsigned long newsize;
 
 	if (cur < max / 16)
-		newsize = 4 * cur;
-	else
-		newsize = 2 * cur;
-
-	return min(newsize, max);
+		return 4 * cur;
+	if (cur <= max / 2)
+		return 2 * cur;
+	return max;
 }
 
 /*
-- 
2.7.4
