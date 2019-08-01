Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90EB4C32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53FAF20693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53FAF20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52D5E8E000F; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F6BE8E0014; Wed, 31 Jul 2019 22:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8B2C8E000E; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 765148E000F
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l11so22720414pgc.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=InE1Y+B+w3QLREXMIAwOjwH/1wHm2lDGCCBLdb8TYbk=;
        b=Zb4clE+868133oMW3DpLOMXD89YSAIknBVfIc/FePNrLhoJnK/lnZYbwxMPiwYQWJE
         DPwfr2DE4GLE6hdExc9XBIKb9CQh8HNM2rELXGsQzXo+O1Valif7Icycv7ZO7ztozmlb
         mlYwNmCNJCQCz/G2fK+73E9uGMRaLs/+VOmujqst2Npvg4tuu8ZXB3Db3yq5q/YwE4KD
         V756cYQImKiFDsCp6uy+NjmNUp0UdJjvFTlkz25DJPG1SN661U9TDnLSRSxCVG8NS5af
         1lLlrL+kroA0t+h+aSWVrvAgDI2POhxck/xOmHTBrhai3I8cQey8L5kIVXx7gYq7VOMq
         6cgg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVwhmPF23fvR63MB58swFKNV8h/mqkDT1+/1FiR/zF/rdPdNbJW
	JmfkA/O5Z8FJz/z6xjSECP87lDJ7EU8CqvxszsY8DdPzN6BYVpxgge3DLYRdwRZygBYmJVEN51c
	OiK+4ZpcmKgtiCj16VniT3nR/Y72glP9tOO+fRr1DeelP5i/uymW9r93/hxROBsE=
X-Received: by 2002:a17:902:b582:: with SMTP id a2mr125624462pls.128.1564625891153;
        Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIkgje4beKz0cfRvP/QDVpEeZ9eSAl5wIy1FRoefb4IqU5KVylfW2giP4kZ+w4rm2rUfMY
X-Received: by 2002:a17:902:b582:: with SMTP id a2mr125623968pls.128.1564625881681;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625881; cv=none;
        d=google.com; s=arc-20160816;
        b=YOQPcOUhTST2TyeBLPhFMmPmZD8h/H/tZnCLgG7Qq7G0MGg9TIgkWJFcDhrJaxfuId
         fpFiqWpKBWOAZiVGr0byvN4uWeMP7YkMJBV4ha0FkAMzv3xeuXGtrfIMP6d8lL0ZArZo
         1vDQfGf+obk4dt5qcavb+42rOjyRaQ1cEVMA2icLiapra7PW2UZi4iFcKndOGZkb7wY1
         pNMRqOqExAAYhOl+SDk5h/6/a8oDs/HZy7MOdMTgpueIdTompDFdE+HZ8uEh8ZtZlcnV
         e+VYOK0aniGpXUPrpiHzpUkRWJdpBqpMhi0Oy1LYJYVO1Gs2Ul072Sg54CXIle3hroZb
         asrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=InE1Y+B+w3QLREXMIAwOjwH/1wHm2lDGCCBLdb8TYbk=;
        b=GheQY+Al0IP0LJd1UeDw0Rjq43b2ZatxRv7LD8Jj9yFaxqp7kKVhXpi6X1fhMiEDL+
         aOHwkbFif4jdahhtDIvNi6mfZ/9K8NGiQXlE1uzBJPQiNxtyyyXo/cxrhQyo2mRvO8j/
         LzuUzhR8aospEYrqDFIyAn7mRc7C7gwh0C2Ma3dPMPJ64l8ukt9YRpYNFWm7ikEk2KhJ
         bxK7Z/usUbQdF9WdynPzPX5CAmvJQq0xnPJkUoOEqddZ9DBNUbUzfhePwR1eXKzpXfGa
         eqEXpw8tUSsH0iUi9qKndTUVU3TQ9g1+cn6wvb46ylrWOmSWyX35T0JDhcC/X7gAFpCf
         mlhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id s29si34142829pfd.147.2019.07.31.19.18.01
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id A167C43D891;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aS-PG; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001ke-NI; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 03/24] mm: factor shrinker work calculations
Date: Thu,  1 Aug 2019 12:17:31 +1000
Message-Id: <20190801021752.4986-4-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=KhDYTzbOwxnNCxDT8zYA:9 a=tfnFA0sY_IgnZ8QS:21 a=zMhpCZC8LXQJiyqo:21
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

Start to clean up the shrinker code by factoring out the calculation
that determines how much work to do. This separates the calculation
from clamping and other adjustments that are done before the
shrinker work is run.

Also convert the calculation for the amount of work to be done to
use 64 bit logic so we don't have to keep jumping through hoops to
keep calculations within 32 bits on 32 bit systems.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 mm/vmscan.c | 74 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 47 insertions(+), 27 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index ae3035fe94bc..b7472953b0e6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -464,13 +464,45 @@ EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
 
+/*
+ * Calculate the number of new objects to scan this time around. Return
+ * the work to be done. If there are freeable objects, return that number in
+ * @freeable_objects.
+ */
+static int64_t shrink_scan_count(struct shrink_control *shrinkctl,
+			    struct shrinker *shrinker, int priority,
+			    int64_t *freeable_objects)
+{
+	uint64_t delta;
+	uint64_t freeable;
+
+	freeable = shrinker->count_objects(shrinker, shrinkctl);
+	if (freeable == 0 || freeable == SHRINK_EMPTY)
+		return freeable;
+
+	if (shrinker->seeks) {
+		delta = freeable >> (priority - 2);
+		do_div(delta, shrinker->seeks);
+	} else {
+		/*
+		 * These objects don't require any IO to create. Trim
+		 * them aggressively under memory pressure to keep
+		 * them from causing refetches in the IO caches.
+		 */
+		delta = freeable / 2;
+	}
+
+	*freeable_objects = freeable;
+	return delta > 0 ? delta : 0;
+}
+
 static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 				    struct shrinker *shrinker, int priority)
 {
 	unsigned long freed = 0;
-	unsigned long long delta;
 	long total_scan;
-	long freeable;
+	int64_t freeable_objects = 0;
+	int64_t scan_count;
 	long nr;
 	long new_nr;
 	int nid = shrinkctl->nid;
@@ -481,9 +513,10 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
 		nid = 0;
 
-	freeable = shrinker->count_objects(shrinker, shrinkctl);
-	if (freeable == 0 || freeable == SHRINK_EMPTY)
-		return freeable;
+	scan_count = shrink_scan_count(shrinkctl, shrinker, priority,
+					&freeable_objects);
+	if (scan_count == 0 || scan_count == SHRINK_EMPTY)
+		return scan_count;
 
 	/*
 	 * copy the current shrinker scan count into a local variable
@@ -492,25 +525,11 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 */
 	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
 
-	total_scan = nr;
-	if (shrinker->seeks) {
-		delta = freeable >> priority;
-		delta *= 4;
-		do_div(delta, shrinker->seeks);
-	} else {
-		/*
-		 * These objects don't require any IO to create. Trim
-		 * them aggressively under memory pressure to keep
-		 * them from causing refetches in the IO caches.
-		 */
-		delta = freeable / 2;
-	}
-
-	total_scan += delta;
+	total_scan = nr + scan_count;
 	if (total_scan < 0) {
 		pr_err("shrink_slab: %pS negative objects to delete nr=%ld\n",
 		       shrinker->scan_objects, total_scan);
-		total_scan = freeable;
+		total_scan = scan_count;
 		next_deferred = nr;
 	} else
 		next_deferred = total_scan;
@@ -527,19 +546,20 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 * Hence only allow the shrinker to scan the entire cache when
 	 * a large delta change is calculated directly.
 	 */
-	if (delta < freeable / 4)
-		total_scan = min(total_scan, freeable / 2);
+	if (scan_count < freeable_objects / 4)
+		total_scan = min_t(long, total_scan, freeable_objects / 2);
 
 	/*
 	 * Avoid risking looping forever due to too large nr value:
 	 * never try to free more than twice the estimate number of
 	 * freeable entries.
 	 */
-	if (total_scan > freeable * 2)
-		total_scan = freeable * 2;
+	if (total_scan > freeable_objects * 2)
+		total_scan = freeable_objects * 2;
 
 	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
-				   freeable, delta, total_scan, priority);
+				   freeable_objects, scan_count,
+				   total_scan, priority);
 
 	/*
 	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
@@ -564,7 +584,7 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 * possible.
 	 */
 	while (total_scan >= batch_size ||
-	       total_scan >= freeable) {
+	       total_scan >= freeable_objects) {
 		unsigned long ret;
 		unsigned long nr_to_scan = min(batch_size, total_scan);
 
-- 
2.22.0

