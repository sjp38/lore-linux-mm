Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F2D5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:58:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1AED2070B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:58:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1AED2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 915728E0124; Fri, 22 Feb 2019 12:58:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C38E8E0123; Fri, 22 Feb 2019 12:58:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 765C78E0124; Fri, 22 Feb 2019 12:58:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 047B08E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 12:58:23 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id f16so575833lfk.16
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:58:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=FXrvPnE28ZCya0GQns11qr6NhzRedm1tJTE9BWjd9QM=;
        b=MWl9d7GvyHVNKbfoBSa3LcICGLIL4Zh2z4f+Q8gKkmqbcFGUaYSCqB3aFf7prQvk8I
         cqwYzjySJM48MS/DqommzUn5eNMfI9CP2JN6uDrfGmONVwQGstXZbJVcdeYRXzh5Yzbl
         APs/txVCBgXbeA7G3aix57ROq1YwxBKRYnNP73X2peLZVB5OmZwY91GV2oriP7kTLBtT
         pS8ozECgnRzICjlwJTDcEWBa2pVQit5SHrgcmYjq6fgGRhc2d6nj4Xpr7ziww0FH05BO
         WTKbCaP1hqZcita5o1UQlZI+mXxnXgm8cxoNe4LAqLUTbQZP2ZRj45JGp9G5gQoxuEnQ
         MA5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuaUnd3X0NWo2J3bnp+KVF+Y7xAMogkSWK8/uYTuO1B5tYwCU4Zc
	n6lj+AYdYWe2zuXplBHxNPfJynnU6lSXUDPsHxeeWIb7YATZ+QrptCf+LeW2+ZB5yp66SG/i72m
	8sGYOufrAas6FFqUPPkUzFgUVo3TZfPavIwbQ2NN/ESiUOKCI94FB6LSPzS9t8oxqGg==
X-Received: by 2002:a2e:750a:: with SMTP id q10-v6mr2757092ljc.39.1550858302306;
        Fri, 22 Feb 2019 09:58:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib6hRYpikxz7f18YLqlqm1A91pMoqfHeZbLHctCkNpokUNFwotE4HX855L18P4YNLEFu/bA
X-Received: by 2002:a2e:750a:: with SMTP id q10-v6mr2757050ljc.39.1550858301027;
        Fri, 22 Feb 2019 09:58:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550858301; cv=none;
        d=google.com; s=arc-20160816;
        b=JPN52ffuipEauLp12hq5df2t9gj6Gs28YNV2qbAzYO9ydLkUIUaKyYLKPtWRRjsKcV
         krv+LdEm+ZCWzxbhe/G5klHb/rhcC560GOkNVoruvA6Tw4UNm9MnbSFq08gI1jNcluUW
         MmJZu1wgpVZ2KgBcz+uR26I3V1Uk19TsXXFmKGJymORCMQEjzpty18HBqs/e3f9xRzU8
         OkwFL57MzLD2e6BqNGw2J7vS8Cndzm6gv/Pv+XEqhj3eBaKVEtLZiF5yIG5pjeNrAID4
         DS/7MLB78sX/OVhU4VG9hWkEPngrXYW8AUwEEAjdQMoE62U5Xt7FE7MzopiEjcU3NWsU
         eLSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=FXrvPnE28ZCya0GQns11qr6NhzRedm1tJTE9BWjd9QM=;
        b=t77UFliT6SEjZVUN7yWyuInlPBF1pUafTlw9aMSjWGoOfdIwJpFqXAIi4QcYs2LWCY
         7O7W01FnNaUIEJXrHn7f27+QhsADHxPNV7xs83/ExrVR9myCFbO16TF3BkYJXeNDCci/
         6L4p0OT7vDclAW/ApVZsz/sxy9gZzgZ92aBuvCfyrOEkoue9GFPzOv26ThYvLYTXEg14
         alwgy9NMTRT6oTsLQOJN/Dw8tUw7Tf+ZbZKNWb1jRPZ5six8USGxlz5wWRr5UYAG91vf
         u+Wp45c4a8X1aaLJO2weQ5fZIOX4uPQ7Z78y1Av2l6Eqdt5Xwvhjr5g7oMpCWvauUBXk
         G7ig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id w25si1684791lfc.48.2019.02.22.09.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 09:58:21 -0800 (PST)
Received-SPF: pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aryabinin@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=aryabinin@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.12] (helo=i7.sw.ru)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <aryabinin@virtuozzo.com>)
	id 1gxF5W-000152-An; Fri, 22 Feb 2019 20:58:18 +0300
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>
Subject: [PATCH RFC] mm/vmscan: try to protect active working set of cgroup from reclaim.
Date: Fri, 22 Feb 2019 20:58:25 +0300
Message-Id: <20190222175825.18657-1-aryabinin@virtuozzo.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In a presence of more than 1 memory cgroup in the system our reclaim
logic is just suck. When we hit memory limit (global or a limit on
cgroup with subgroups) we reclaim some memory from all cgroups.
This is sucks because, the cgroup that allocates more often always wins.
E.g. job that allocates a lot of clean rarely used page cache will push
out of memory other jobs with active relatively small all in memory
working set.

To prevent such situations we have memcg controls like low/max, etc which
are supposed to protect jobs or limit them so they to not hurt others.
But memory cgroups are very hard to configure right because it requires
precise knowledge of the workload which may vary during the execution.
E.g. setting memory limit means that job won't be able to use all memory
in the system for page cache even if the rest the system is idle.
Basically our current scheme requires to configure every single cgroup
in the system.

I think we can do better. The idea proposed by this patch is to reclaim
only inactive pages and only from cgroups that have big
(!inactive_is_low()) inactive list. And go back to shrinking active lists
only if all inactive lists are low.

Now, the simple test case to demonstrate the effect of the patch.
The job in one memcg repeatedly compresses one file:

 perf stat -n --repeat 20 gzip -ck sample > /dev/null

and just 'dd' running in parallel reading the disk in another cgroup.

Before:
Performance counter stats for 'gzip -ck sample' (20 runs):
      17.673572290 seconds time elapsed                                          ( +-  5.60% )
After:
Performance counter stats for 'gzip -ck sample' (20 runs):
      11.426193980 seconds time elapsed                                          ( +-  0.20% )

The more often dd cgroup allocates memory, the more gzip suffer.
With 4 parallel dd instead of one:

Before:
Performance counter stats for 'gzip -ck sample' (20 runs):
      499.976782013 seconds time elapsed                                          ( +- 23.13% )
After:
Performance counter stats for 'gzip -ck sample' (20 runs):
      11.307450516 seconds time elapsed                                          ( +-  0.27% )

It would be possible to achieve the similar effect by
setting the memory.low on gzip cgroup, but the best value for memory.low
depends on the size of the 'sample' file. It also possible
to limit the 'dd' job, but just imagine something more sophisticated
than just 'dd', the job that would benefit from occupying all available
memory. The best limit for such job would be something like
'total_memory' - 'sample size' which is again unknown.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Rik van Riel <riel@surriel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>
---
 mm/vmscan.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index efd10d6b9510..2f562c3358ab 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -104,6 +104,8 @@ struct scan_control {
 	/* One of the zones is ready for compaction */
 	unsigned int compaction_ready:1;
 
+	unsigned int may_shrink_active:1;
+
 	/* Allocation order */
 	s8 order;
 
@@ -2489,6 +2491,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 
 		scan >>= sc->priority;
 
+		if (!sc->may_shrink_active && inactive_list_is_low(lruvec,
+						file, memcg, sc, false))
+			scan = 0;
+
 		/*
 		 * If the cgroup's already been deleted, make sure to
 		 * scrape out the remaining cache.
@@ -2733,6 +2739,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long nr_reclaimed, nr_scanned;
 	bool reclaimable = false;
+	bool retry;
 
 	do {
 		struct mem_cgroup *root = sc->target_mem_cgroup;
@@ -2742,6 +2749,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		};
 		struct mem_cgroup *memcg;
 
+		retry = false;
+
 		memset(&sc->nr, 0, sizeof(sc->nr));
 
 		nr_reclaimed = sc->nr_reclaimed;
@@ -2813,6 +2822,13 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
+		if ((sc->nr_scanned - nr_scanned) == 0 &&
+		     !sc->may_shrink_active) {
+			sc->may_shrink_active = 1;
+			retry = true;
+			continue;
+		}
+
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
@@ -2887,7 +2903,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
 			wait_iff_congested(BLK_RW_ASYNC, HZ/10);
 
-	} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
+	} while (retry || should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
 					 sc->nr_scanned - nr_scanned, sc));
 
 	/*
-- 
2.19.2

