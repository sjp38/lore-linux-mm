Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58BCCC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 091E420693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 091E420693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 238348E0010; Wed, 31 Jul 2019 22:18:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDDE78E0014; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B7538E0003; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4438E0012
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n9so40670720pgq.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cfjpC4ZufL8zFJ9iILIMiNwPpuYb7M9uLZGTu5lO0a0=;
        b=RyC5grk2oxYO+l2/ZCVbABNB9rH13qEmT6QkoNjmpB+sFNQM0Lw4LjIt31iEKoLMIM
         GqIspjdE2a7/w06U45t2Iwj3WUIvu2tBrcX4GT5qxs0uGJfSVkxcS59Di8QXAQKnIHf8
         HNBDyCS2dpiQhSkdKs8X9GFAsYj+DFaIU0nA/D25KJxJGXcvKwKc148uiHy/5WjSmh6F
         /dKvsvq9Tqa7mK5EVp6G51csmeMe6MTuoS0E2HksvkUEm0DSY2jBZDFLc98cbOtgjrXi
         jZg1XnFo8rp73Hn1VVKMwECNjCiyq7jxYJ65dIVEJyyVDHV+4SFZvxjJAdZg+6TQNBqt
         N1Jw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAV7LLvtqWV3m2oZ7DyzWT5AcNTXQDG+yESpq3icXSGsqjf4Blhw
	sOyG8jA5zXwKLSm3NrDGKp4R9ULrc3cjl0OEhatVss7manMDg2ZE7wThjahfX/tS2DIVtT4WfwZ
	O8UYf1ZdE9suTvmsIzl6XAZadtHHxnqoo/Ujk1IxetJLpSSKQeF2b/upLxLwCH2I=
X-Received: by 2002:a62:5214:: with SMTP id g20mr50588045pfb.187.1564625891673;
        Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEhyB0HQyBhEASZVkYdQ3mGrCAR9a93epWsfaZpWKnBIrZYCM5U9bnMH9kLuKwnfefocsF
X-Received: by 2002:a62:5214:: with SMTP id g20mr50587486pfb.187.1564625881817;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625881; cv=none;
        d=google.com; s=arc-20160816;
        b=DkJaU1a6i+MzNbvPchoGEYsW3ZKBJGWxTEyrCoYo81ltjtu+qWxW0jv9+2ppDEdldZ
         glAwLH0rRUB7TM9K11YcGLcxrHgam9ovpZPB6XL+6xcd/x19ReeXSq0T3GauN2bpIoUn
         zYwkByx8oSUrxuR+N+HzZ4tx7XsMvIs0JMqbncJBhbfyMOY2GMfRO26s7fkSX4ooi6we
         xlOvFOIGJqv/OhTkxn34B/Sz3xUYjkegAQTWDIEglUeSOez1kWE6Pqy5YYeee/xyuG23
         J3Ld1f1GEhLyo+hpjyq/ZshnnJlgb2EXNTCQ7DupqIZ7rbkXVWAxDTiBmUtzRWk/8dDl
         /QPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cfjpC4ZufL8zFJ9iILIMiNwPpuYb7M9uLZGTu5lO0a0=;
        b=PZAA6zYkIXuBWKCATKBVHipisbbSrAfHg/BeS5FsTbzw31lUBbZ17tW2dGXf9O0XAM
         8nVLWbK1IbSz9cWHWHmWTHKb3zlspqrPQWWDivI3wydWNu4eNd0amn2kiRQ2sndbnqAs
         +3Yn00GsP1OMDuaZ+MWoa/ZZ0KgbU7ERCLxh8/opCrjKB7N3U7mWgSJjSWZkB84ifYws
         yRyE6L9pQ9zJ7/AEkXT89zKqMImWzmb/LU5LdhS57MELf7TWYKl45AekyzkjQznoPIQQ
         De6l9j1NZwXj7yWe2UbulyONUvF8wfekDKq+YpPwuFtmLl9hDVutI6J4xDnO7hRAdL8z
         lwOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id 33si30601057pli.144.2019.07.31.19.18.01
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id B0A413617D2;
	Thu,  1 Aug 2019 12:17:57 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aW-RG; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001km-PT; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 05/24] shrinker: clean up variable types and tracepoints
Date: Thu,  1 Aug 2019 12:17:33 +1000
Message-Id: <20190801021752.4986-6-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=dfQxWFgAP5TgkvwPFjsA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

The tracepoint information in the shrinker code don't make a lot of
sense anymore and contain redundant information as a result of the
changes in the patchset. Refine the information passed to the
tracepoints so they expose the operation of the shrinkers more
precisely and clean up the remaining code and varibles in the
shrinker code so it all makes sense.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/trace/events/vmscan.h | 69 ++++++++++++++++-------------------
 mm/vmscan.c                   | 24 +++++-------
 2 files changed, 41 insertions(+), 52 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index a5ab2973e8dc..110637d9efa5 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -184,84 +184,77 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_re
 
 TRACE_EVENT(mm_shrink_slab_start,
 	TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
-		long nr_objects_to_shrink, unsigned long cache_items,
-		unsigned long long delta, unsigned long total_scan,
-		int priority),
+		int64_t deferred_count, int64_t freeable_objects,
+		int64_t scan_count, int priority),
 
-	TP_ARGS(shr, sc, nr_objects_to_shrink, cache_items, delta, total_scan,
+	TP_ARGS(shr, sc, deferred_count, freeable_objects, scan_count,
 		priority),
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
 		__field(void *, shrink)
 		__field(int, nid)
-		__field(long, nr_objects_to_shrink)
-		__field(gfp_t, gfp_flags)
-		__field(unsigned long, cache_items)
-		__field(unsigned long long, delta)
-		__field(unsigned long, total_scan)
+		__field(int64_t, deferred_count)
+		__field(int64_t, freeable_objects)
+		__field(int64_t, scan_count)
 		__field(int, priority)
+		__field(gfp_t, gfp_flags)
 	),
 
 	TP_fast_assign(
 		__entry->shr = shr;
 		__entry->shrink = shr->scan_objects;
 		__entry->nid = sc->nid;
-		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
-		__entry->gfp_flags = sc->gfp_mask;
-		__entry->cache_items = cache_items;
-		__entry->delta = delta;
-		__entry->total_scan = total_scan;
+		__entry->deferred_count = deferred_count;
+		__entry->freeable_objects = freeable_objects;
+		__entry->scan_count = scan_count;
 		__entry->priority = priority;
+		__entry->gfp_flags = sc->gfp_mask;
 	),
 
-	TP_printk("%pS %p: nid: %d objects to shrink %ld gfp_flags %s cache items %ld delta %lld total_scan %ld priority %d",
+	TP_printk("%pS %p: nid: %d scan count %lld freeable items %lld deferred count %lld priority %d gfp_flags %s",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
-		__entry->nr_objects_to_shrink,
-		show_gfp_flags(__entry->gfp_flags),
-		__entry->cache_items,
-		__entry->delta,
-		__entry->total_scan,
-		__entry->priority)
+		__entry->scan_count,
+		__entry->freeable_objects,
+		__entry->deferred_count,
+		__entry->priority,
+		show_gfp_flags(__entry->gfp_flags))
 );
 
 TRACE_EVENT(mm_shrink_slab_end,
-	TP_PROTO(struct shrinker *shr, int nid, int shrinker_retval,
-		long unused_scan_cnt, long new_scan_cnt, long total_scan),
+	TP_PROTO(struct shrinker *shr, int nid, int64_t freed_objects,
+		int64_t scanned_objects, int64_t deferred_scan),
 
-	TP_ARGS(shr, nid, shrinker_retval, unused_scan_cnt, new_scan_cnt,
-		total_scan),
+	TP_ARGS(shr, nid, freed_objects, scanned_objects,
+		deferred_scan),
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
 		__field(int, nid)
 		__field(void *, shrink)
-		__field(long, unused_scan)
-		__field(long, new_scan)
-		__field(int, retval)
-		__field(long, total_scan)
+		__field(long long, freed_objects)
+		__field(long long, scanned_objects)
+		__field(long long, deferred_scan)
 	),
 
 	TP_fast_assign(
 		__entry->shr = shr;
 		__entry->nid = nid;
 		__entry->shrink = shr->scan_objects;
-		__entry->unused_scan = unused_scan_cnt;
-		__entry->new_scan = new_scan_cnt;
-		__entry->retval = shrinker_retval;
-		__entry->total_scan = total_scan;
+		__entry->freed_objects = freed_objects;
+		__entry->scanned_objects = scanned_objects;
+		__entry->deferred_scan = deferred_scan;
 	),
 
-	TP_printk("%pS %p: nid: %d unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+	TP_printk("%pS %p: nid: %d freed objects %lld scanned objects %lld, deferred scan %lld",
 		__entry->shrink,
 		__entry->shr,
 		__entry->nid,
-		__entry->unused_scan,
-		__entry->new_scan,
-		__entry->total_scan,
-		__entry->retval)
+		__entry->freed_objects,
+		__entry->scanned_objects,
+		__entry->deferred_scan)
 );
 
 TRACE_EVENT(mm_vmscan_lru_isolate,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c583b4efb9bf..d5ce26b4d49d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -505,7 +505,6 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	int64_t scanned_objects = 0;
 	int64_t next_deferred = 0;
 	int64_t deferred_count = 0;
-	long new_nr;
 	int nid = shrinkctl->nid;
 	long batch_size = shrinker->batch ? shrinker->batch
 					  : SHRINK_BATCH;
@@ -564,8 +563,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 		scan_count = freeable_objects * 2;
 
 	trace_mm_shrink_slab_start(shrinker, shrinkctl, deferred_count,
-				   freeable_objects, scan_count,
-				   scan_count, priority);
+				   freeable_objects, scan_count, priority);
 
 	/*
 	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
@@ -609,23 +607,21 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 done:
+	/*
+	 * Calculate the remaining work that we need to defer to kswapd, and
+	 * store it in a manner that handles concurrent updates. If we exhausted
+	 * the scan, there is no need to do an update.
+	 */
 	if (deferred_count)
 		next_deferred = deferred_count - scanned_objects;
 	else if (scan_count > 0)
 		next_deferred = scan_count;
-	/*
-	 * move the unused scan count back into the shrinker in a
-	 * manner that handles concurrent updates. If we exhausted the
-	 * scan, there is no need to do an update.
-	 */
+
 	if (next_deferred > 0)
-		new_nr = atomic_long_add_return(next_deferred,
-						&shrinker->nr_deferred[nid]);
-	else
-		new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
+		atomic_long_add(next_deferred, &shrinker->nr_deferred[nid]);
 
-	trace_mm_shrink_slab_end(shrinker, nid, freed, deferred_count, new_nr,
-					scan_count);
+	trace_mm_shrink_slab_end(shrinker, nid, freed, scanned_objects,
+				 next_deferred);
 	return freed;
 }
 
-- 
2.22.0

