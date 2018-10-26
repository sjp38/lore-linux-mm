Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBC0A6B0306
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 07:19:09 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d8-v6so406431pgq.3
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 04:19:09 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d2-v6si10541046pgo.299.2018.10.26.04.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 04:19:08 -0700 (PDT)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH 4.18] Revert "mm: slowly shrink slabs with a relatively small number of objects"
Date: Fri, 26 Oct 2018 07:18:59 -0400
Message-Id: <20181026111859.23807-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org
Cc: stable@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, Sasha Levin <sashal@kernel.org>

This reverts commit 62aad93f09c1952ede86405894df1b22012fd5ab.

Which was upstream commit 172b06c32b94 ("mm: slowly shrink slabs with a
relatively small number of objects").

The upstream commit was found to cause regressions. While there is a
proposed fix upstream, revent this patch from stable trees for now as
testing the fix will take some time.

Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/vmscan.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fc0436407471..03822f86f288 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -386,17 +386,6 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	delta = freeable >> priority;
 	delta *= 4;
 	do_div(delta, shrinker->seeks);
-
-	/*
-	 * Make sure we apply some minimal pressure on default priority
-	 * even on small cgroups. Stale objects are not only consuming memory
-	 * by themselves, but can also hold a reference to a dying cgroup,
-	 * preventing it from being reclaimed. A dying cgroup with all
-	 * corresponding structures like per-cpu stats and kmem caches
-	 * can be really big, so it may lead to a significant waste of memory.
-	 */
-	delta = max_t(unsigned long long, delta, min(freeable, batch_size));
-
 	total_scan += delta;
 	if (total_scan < 0) {
 		pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
-- 
2.17.1
