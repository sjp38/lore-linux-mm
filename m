Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12F672803C7
	for <linux-mm@kvack.org>; Wed, 10 May 2017 02:54:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b5so17359149pfe.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 23:54:03 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id u22si1245774plk.91.2017.05.09.23.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 23:54:02 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id w69so2754525pfk.1
        for <linux-mm@kvack.org>; Tue, 09 May 2017 23:54:02 -0700 (PDT)
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: [PATCH] mm/vmscan: fix unsequenced modification and access warning
Date: Tue,  9 May 2017 23:53:28 -0700
Message-Id: <20170510065328.9215-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Desaulniers <nick.desaulniers@gmail.com>

Clang flags this file with the -Wunsequenced error that GCC does not
have.

unsequenced modification and access to 'gfp_mask'

It seems that gfp_mask is both read and written without a sequence point
in between, which is undefined behavior.

Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>
---
 mm/vmscan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4e7ed65842af..74785908822c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2958,7 +2958,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
+		.gfp_mask = current_gfp_context(gfp_mask),
 		.reclaim_idx = gfp_zone(gfp_mask),
 		.order = order,
 		.nodemask = nodemask,
@@ -2968,6 +2968,8 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_swap = 1,
 	};
 
+	gfp_mask = sc.gfp_mask;
+
 	/*
 	 * Do not enter reclaim if fatal signal was delivered while throttled.
 	 * 1 is returned so that the page allocator does not OOM kill at this
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
