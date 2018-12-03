Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 460666B6803
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 03:01:38 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a10so9628678plp.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 00:01:38 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id g6si11884244pgn.57.2018.12.03.00.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 00:01:37 -0800 (PST)
From: Xunlei Pang <xlpang@linux.alibaba.com>
Subject: [PATCH 1/3] mm/memcg: Fix min/low usage in propagate_protected_usage()
Date: Mon,  3 Dec 2018 16:01:17 +0800
Message-Id: <20181203080119.18989-1-xlpang@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

When usage exceeds min, min usage should be min other than 0.
Apply the same for low.

Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
---
 mm/page_counter.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/page_counter.c b/mm/page_counter.c
index de31470655f6..75d53f15f040 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -23,11 +23,7 @@ static void propagate_protected_usage(struct page_counter *c,
 		return;
 
 	if (c->min || atomic_long_read(&c->min_usage)) {
-		if (usage <= c->min)
-			protected = usage;
-		else
-			protected = 0;
-
+		protected = min(usage, c->min);
 		old_protected = atomic_long_xchg(&c->min_usage, protected);
 		delta = protected - old_protected;
 		if (delta)
@@ -35,11 +31,7 @@ static void propagate_protected_usage(struct page_counter *c,
 	}
 
 	if (c->low || atomic_long_read(&c->low_usage)) {
-		if (usage <= c->low)
-			protected = usage;
-		else
-			protected = 0;
-
+		protected = min(usage, c->low);
 		old_protected = atomic_long_xchg(&c->low_usage, protected);
 		delta = protected - old_protected;
 		if (delta)
-- 
2.13.5 (Apple Git-94)
