Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0A19C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6312B20693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6312B20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A98588E000D; Wed, 31 Jul 2019 22:33:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A22D68E0001; Wed, 31 Jul 2019 22:33:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EB258E000D; Wed, 31 Jul 2019 22:33:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31F5D8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:33:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z14so37112139pgr.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:33:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O2FiJFNkWUsACgIBXN1RU4QxZLI1SuXi5C0U1Ljd/vs=;
        b=TI+AfC8ZOZr0VVvtpMPGxZuw1V5b3ijC9DpY+K1Be+A+g1zjUKF4becrpNy0RPV984
         uKtem4bFVYCDe9sxDp0obelTZxFVwdcj1PITuuhyTgGOeVoUerWpWcEVB5jB/MT2wxRf
         aIIJU3Xeeqlh3IGNYvz/dB4gxc8s6O3feLxVxcmF/muGQVhU7WNRRmSLrjLaVA1wpQ+s
         G6Fb6hn7GPlSwl9zVyNvzLHO38kPrRhsYFwbbA9JXzbcLM7PRbXo/AZ7J0JMGvs3eNU4
         Ht7laC3OjRf89vGS/MNC0H8H3RLr64RTkqrhTMeddC3acO9nvY6Y5Ct/ViHPJob/ve9v
         Ogew==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWUlkWp93tXHhtG+bAvacfo5jE0dIs86PdZ9nQeM620axbiBDyq
	KGhFcQE8s9GArCWGVDnkuRglEwmbmwo6TAz5uBkzN0FRdMLjCCV6KKKpqZkvVhiiDbbN7l51KtT
	KyLczF8S4Tc98jZAvGxEk9SBEkQnz/fKF3RoOidTwd4Y2JO9+GSI6Fa2LA1dsLZ4=
X-Received: by 2002:a17:902:9b94:: with SMTP id y20mr123109195plp.260.1564626812853;
        Wed, 31 Jul 2019 19:33:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBf2OTHE3MIuCc9tednBmt3F+NVc5nW7s2PeN9eWKVRV/0JLFTuButwfIq5fsGtoZYtQ7A
X-Received: by 2002:a17:902:9b94:: with SMTP id y20mr123109147plp.260.1564626811717;
        Wed, 31 Jul 2019 19:33:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564626811; cv=none;
        d=google.com; s=arc-20160816;
        b=in/Xg/e8m4QgCfJrjLCoo4EiDEl+6E7Xu0WT086jOlF/eF3YXt8xsjQFR57XAx86Mu
         kzQIVQXKzZuIkLagBu0vIPdt6GaWPmTKqIJuiU3BkXtZ2fgmblnk4irKvi+sP6NeMT7i
         yWJHg0ppTK5mgzMoRqm7OoaW4et081gTtQd6TLXN4nqbKDfRhx6LgBseuixwIn68zmih
         53UN6LAOj3voVT8X/DMp4bktuYrYpToTUJKCfTDYW43d6wkrgR6YHzawT8gzfMPezF6g
         +kHoTEDogv9H25DLX0pWTZRdun6qciI6Lajf+Ydwp9jSxvCZOnkIF2juil9049jDDXp0
         Io6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=O2FiJFNkWUsACgIBXN1RU4QxZLI1SuXi5C0U1Ljd/vs=;
        b=lJo8357p9KSZTOQPGg3kfrBC5LgX7GbuA7h+BwMPO//TMa+pbSgRXLw1Vcn9uA81An
         ZTzpAB5gFHQWF5n0r/oEFUcLxpd7m6z6cYV2urFc+QI1VocreA7c2iXSyBFmM9LpPRXn
         TxalaCpEHZJPendnLhN5o8+lGJQ7a/LVMjtecbIjvV3WQhVk03QeG9eOBNdPCJNB5u7F
         Xurb07rrm3ZLtd+lAn1T0+5W0FkuhWCMHt4bJjmKvHxksyE1ebiPMC0r6pRVfq8iFMlL
         eKHrzDMgfcRjBxF/EEM5T/VuU0OnakUx5wn6SaLyzrKcvnu8uduX271Mlq9KXnWkpWFU
         H2xA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id e90si30942678plb.309.2019.07.31.19.33.31
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:33:31 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 4211743DA5A
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:33:30 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aU-QO; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001ki-OR; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 04/24] shrinker: defer work only to kswapd
Date: Thu,  1 Aug 2019 12:17:32 +1000
Message-Id: <20190801021752.4986-5-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=CHVq44adYJMzgTTYFj8A:9 a=WRIbabeltRbYLjNO:21 a=R37gaMtEP60o-D4u:21
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Right now deferred work is picked up by whatever GFP_KERNEL context
reclaimer that wins the race to empty the node's deferred work
counter. However, if there are lots of direct reclaimers, that
work might be continually picked up by contexts taht can't do any
work and so the opportunities to do the work are missed by contexts
that could do them.

A further problem with the current code is that the deferred work
can be picked up by a random direct reclaimer, resulting in that
specific process having to do all the deferred reclaim work and
hence can take extremely long latencies if the reclaim work blocks
regularly. This is not good for direct reclaim fairness or for
minimising long tail latency events.

To avoid these problems, simply limit deferred work to kswapd
contexts. We know kswapd is a context that can always do reclaim
work, and hence deferring work to kswapd allows the deferred work to
be done in the background and not adversely affect any specific
process context doing direct reclaim.

The advantage of this is that amount of work to be done in direct
reclaim is now bound and predictable - it is entirely based on
the cache's freeable objects and the reclaim priority. hence all
direct reclaimers running at the same time should be doing
relatively equal amounts of work, thereby reducing the incidence of
long tail latencies due to uneven reclaim workloads.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 mm/vmscan.c | 93 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 50 insertions(+), 43 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index b7472953b0e6..c583b4efb9bf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -500,15 +500,15 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 				    struct shrinker *shrinker, int priority)
 {
 	unsigned long freed = 0;
-	long total_scan;
 	int64_t freeable_objects = 0;
 	int64_t scan_count;
-	long nr;
+	int64_t scanned_objects = 0;
+	int64_t next_deferred = 0;
+	int64_t deferred_count = 0;
 	long new_nr;
 	int nid = shrinkctl->nid;
 	long batch_size = shrinker->batch ? shrinker->batch
 					  : SHRINK_BATCH;
-	long scanned = 0, next_deferred;
 
 	if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 		nid = 0;
@@ -519,47 +519,53 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		return scan_count;
 
 	/*
-	 * copy the current shrinker scan count into a local variable
-	 * and zero it so that other concurrent shrinker invocations
-	 * don't also do this scanning work.
+	 * If kswapd, we take all the deferred work and do it here. We don't let
+	 * direct reclaim do this, because then it means some poor sod is going
+	 * to have to do somebody else's GFP_NOFS reclaim, and it hides the real
+	 * amount of reclaim work from concurrent kswapd operations. Hence we do
+	 * the work in the wrong place, at the wrong time, and it's largely
+	 * unpredictable.
+	 *
+	 * By doing the deferred work only in kswapd, we can schedule the work
+	 * according the the reclaim priority - low priority reclaim will do
+	 * less deferred work, hence we'll do more of the deferred work the more
+	 * desperate we become for free memory. This avoids the need for needing
+	 * to specifically avoid deferred work windup as low amount os memory
+	 * pressure won't excessive trim caches anymore.
 	 */
-	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
+	if (current_is_kswapd()) {
+		int64_t	deferred_scan;
 
-	total_scan = nr + scan_count;
-	if (total_scan < 0) {
-		pr_err("shrink_slab: %pS negative objects to delete nr=%ld\n",
-		       shrinker->scan_objects, total_scan);
-		total_scan = scan_count;
-		next_deferred = nr;
-	} else
-		next_deferred = total_scan;
+		deferred_count = atomic64_xchg(&shrinker->nr_deferred[nid], 0);
 
-	/*
-	 * We need to avoid excessive windup on filesystem shrinkers
-	 * due to large numbers of GFP_NOFS allocations causing the
-	 * shrinkers to return -1 all the time. This results in a large
-	 * nr being built up so when a shrink that can do some work
-	 * comes along it empties the entire cache due to nr >>>
-	 * freeable. This is bad for sustaining a working set in
-	 * memory.
-	 *
-	 * Hence only allow the shrinker to scan the entire cache when
-	 * a large delta change is calculated directly.
-	 */
-	if (scan_count < freeable_objects / 4)
-		total_scan = min_t(long, total_scan, freeable_objects / 2);
+		/* we want to scan 5-10% of the deferred work here at minimum */
+		deferred_scan = deferred_count;
+		if (priority)
+			do_div(deferred_scan, priority);
+		scan_count += deferred_scan;
+
+		/*
+		 * If there is more deferred work than the number of freeable
+		 * items in the cache, limit the amount of work we will carry
+		 * over to the next kswapd run on this cache. This prevents
+		 * deferred work windup.
+		 */
+		if (deferred_count > freeable_objects * 2)
+			deferred_count = freeable_objects * 2;
+
+	}
 
 	/*
 	 * Avoid risking looping forever due to too large nr value:
 	 * never try to free more than twice the estimate number of
 	 * freeable entries.
 	 */
-	if (total_scan > freeable_objects * 2)
-		total_scan = freeable_objects * 2;
+	if (scan_count > freeable_objects * 2)
+		scan_count = freeable_objects * 2;
 
-	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
+	trace_mm_shrink_slab_start(shrinker, shrinkctl, deferred_count,
 				   freeable_objects, scan_count,
-				   total_scan, priority);
+				   scan_count, priority);
 
 	/*
 	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
@@ -583,10 +589,10 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 * scanning at high prio and therefore should try to reclaim as much as
 	 * possible.
 	 */
-	while (total_scan >= batch_size ||
-	       total_scan >= freeable_objects) {
+	while (scan_count >= batch_size ||
+	       scan_count >= freeable_objects) {
 		unsigned long ret;
-		unsigned long nr_to_scan = min(batch_size, total_scan);
+		unsigned long nr_to_scan = min_t(long, batch_size, scan_count);
 
 		shrinkctl->nr_to_scan = nr_to_scan;
 		shrinkctl->nr_scanned = nr_to_scan;
@@ -596,17 +602,17 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		freed += ret;
 
 		count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
-		total_scan -= shrinkctl->nr_scanned;
-		scanned += shrinkctl->nr_scanned;
+		scan_count -= shrinkctl->nr_scanned;
+		scanned_objects += shrinkctl->nr_scanned;
 
 		cond_resched();
 	}
 
 done:
-	if (next_deferred >= scanned)
-		next_deferred -= scanned;
-	else
-		next_deferred = 0;
+	if (deferred_count)
+		next_deferred = deferred_count - scanned_objects;
+	else if (scan_count > 0)
+		next_deferred = scan_count;
 	/*
 	 * move the unused scan count back into the shrinker in a
 	 * manner that handles concurrent updates. If we exhausted the
@@ -618,7 +624,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	else
 		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
 
-	trace_mm_shrink_slab_end(shrinker, nid, freed, nr, new_nr, total_scan);
+	trace_mm_shrink_slab_end(shrinker, nid, freed, deferred_count, new_nr,
+					scan_count);
 	return freed;
 }
 
-- 
2.22.0

