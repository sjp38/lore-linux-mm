Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63E96C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 19:23:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25B5B206C1
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 19:23:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="jzC2l9r8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25B5B206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBB436B0003; Mon, 12 Aug 2019 15:23:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6C056B0005; Mon, 12 Aug 2019 15:23:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A810C6B0008; Mon, 12 Aug 2019 15:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 86E466B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:23:21 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 200EF3CEA
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 19:23:21 +0000 (UTC)
X-FDA: 75814749402.26.woman31_747bdb1d6f253
X-HE-Tag: woman31_747bdb1d6f253
X-Filterd-Recvd-Size: 7026
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 19:23:20 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id o13so49963683pgp.12
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:23:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=WbZ4Sjz/PnOqkj9Tyb0eRWLHmMcoPs5r9WlmOIHpeSo=;
        b=jzC2l9r88UaY1IukY7wBl28NxdfPM525Oizdju82oqnG+UjMFtJsmQ4V8Uvx/6+Orm
         fWS1GQxRoaEB2jq5CsZnnU1wxLSuBymvRWSQYQv2k4Fc04be15Oia6PI0grZJI7R2lxH
         IIEMek1SCHJoUx7vl2b0ZqSLUs8sascLRu9JdKIBwCJMo6nAISs6UQ+jEeXfnyNHERRv
         auaqhuzsjPAV71Ee7a+PteY3nAiiXs0DyQhgGfGNjObh9DdA0bOLONSDN10g6v6ng50c
         nzWmlZ4d3goJTdGLPL9hG2fwhhVHCKPrGDEk5V0RvMSdUKKA+J9+ZRo4KaIWYRmCYX2/
         vyyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=WbZ4Sjz/PnOqkj9Tyb0eRWLHmMcoPs5r9WlmOIHpeSo=;
        b=mb7ozNQ2mBRRfVeG+F49hldZI14UwecbrFH35k6RAmELvRlJQRPv7UHk9HeSpUoYmN
         LMQUR6pN8rJU7q96t5Rnvu2EqsW4ioG4zmyo3oJuSN05mmben9A4ILgo5VMzeImVB43D
         XRAq+bLNjVN9s5nqkAxR8nXUpzpJkZJNu6L6nMZdWMfnfVv/NlQb0h4oIs65f8D4GtfF
         cBwSddhg0FdHg9Fx3MKo41j6mPnt6YG+f7Ph1kh4j9KLYUjJAaRuBvpsPFSHvYunRytY
         3wqEDORZ7gvyRY6hFWbMtxvSQ3gmFW375UkMdvCviiYIN1v5zG1FgMx19UFA6DV6emWe
         0ADg==
X-Gm-Message-State: APjAAAXDoppTVa/L5APk4kTcdmOO4Jp65OsBfZ1mPLiQPcFt+fmLtaz4
	s/7OgPaqpJ2ktV93lAwUMQCbgg==
X-Google-Smtp-Source: APXvYqw1S8904a2xrHCvhOv0CHIN7t7zCW5x0903Sd3n3zquB/ZaHzb6mZNsVhdWI0VY78GJibDFVA==
X-Received: by 2002:a65:5188:: with SMTP id h8mr31346069pgq.294.1565637798475;
        Mon, 12 Aug 2019 12:23:18 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::5810])
        by smtp.gmail.com with ESMTPSA id v8sm340554pjb.6.2019.08.12.12.23.17
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 12:23:17 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH] mm: vmscan: do not share cgroup iteration between reclaimers
Date: Mon, 12 Aug 2019 15:23:16 -0400
Message-Id: <20190812192316.13615-1-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

One of our services observed a high rate of cgroup OOM kills in the
presence of large amounts of clean cache. Debugging showed that the
culprit is the shared cgroup iteration in page reclaim.

Under high allocation concurrency, multiple threads enter reclaim at
the same time. Fearing overreclaim when we first switched from the
single global LRU to cgrouped LRU lists, we introduced a shared
iteration state for reclaim invocations - whether 1 or 20 reclaimers
are active concurrently, we only walk the cgroup tree once: the 1st
reclaimer reclaims the first cgroup, the second the second one etc.
With more reclaimers than cgroups, we start another walk from the top.

This sounded reasonable at the time, but the problem is that reclaim
concurrency doesn't scale with allocation concurrency. As reclaim
concurrency increases, the amount of memory individual reclaimers get
to scan gets smaller and smaller. Individual reclaimers may only see
one cgroup per cycle, and that may not have much reclaimable
memory. We see individual reclaimers declare OOM when there is plenty
of reclaimable memory available in cgroups they didn't visit.

This patch does away with the shared iterator, and every reclaimer is
allowed to scan the full cgroup tree and see all of reclaimable
memory, just like it would on a non-cgrouped system. This way, when
OOM is declared, we know that the reclaimer actually had a chance.

To still maintain fairness in reclaim pressure, disallow cgroup
reclaim from bailing out of the tree walk early. Kswapd and regular
direct reclaim already don't bail, so it's not clear why limit reclaim
would have to, especially since it only walks subtrees to begin with.

This change completely eliminates the OOM kills on our service, while
showing no signs of overreclaim - no increased scan rates, %sys time,
or abrupt free memory spikes. I tested across 100 machines that have
64G of RAM and host about 300 cgroups each.

[ It's possible overreclaim never was a *practical* issue to begin
  with - it was simply a concern we had on the mailing lists at the
  time, with no real data to back it up. But we have also added more
  bail-out conditions deeper inside reclaim (e.g. the proportional
  exit in shrink_node_memcg) since. Regardless, now we have data that
  suggests full walks are more reliable and scale just fine. ]

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 22 ++--------------------
 1 file changed, 2 insertions(+), 20 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index dbdc46a84f63..b2f10fa49c88 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2667,10 +2667,6 @@ static bool shrink_node(pg_data_t *pgdat, struct s=
can_control *sc)
=20
 	do {
 		struct mem_cgroup *root =3D sc->target_mem_cgroup;
-		struct mem_cgroup_reclaim_cookie reclaim =3D {
-			.pgdat =3D pgdat,
-			.priority =3D sc->priority,
-		};
 		unsigned long node_lru_pages =3D 0;
 		struct mem_cgroup *memcg;
=20
@@ -2679,7 +2675,7 @@ static bool shrink_node(pg_data_t *pgdat, struct sc=
an_control *sc)
 		nr_reclaimed =3D sc->nr_reclaimed;
 		nr_scanned =3D sc->nr_scanned;
=20
-		memcg =3D mem_cgroup_iter(root, NULL, &reclaim);
+		memcg =3D mem_cgroup_iter(root, NULL, NULL);
 		do {
 			unsigned long lru_pages;
 			unsigned long reclaimed;
@@ -2724,21 +2720,7 @@ static bool shrink_node(pg_data_t *pgdat, struct s=
can_control *sc)
 				   sc->nr_scanned - scanned,
 				   sc->nr_reclaimed - reclaimed);
=20
-			/*
-			 * Kswapd have to scan all memory cgroups to fulfill
-			 * the overall scan target for the node.
-			 *
-			 * Limit reclaim, on the other hand, only cares about
-			 * nr_to_reclaim pages to be reclaimed and it will
-			 * retry with decreasing priority if one round over the
-			 * whole hierarchy is not sufficient.
-			 */
-			if (!current_is_kswapd() &&
-					sc->nr_reclaimed >=3D sc->nr_to_reclaim) {
-				mem_cgroup_iter_break(root, memcg);
-				break;
-			}
-		} while ((memcg =3D mem_cgroup_iter(root, memcg, &reclaim)));
+		} while ((memcg =3D mem_cgroup_iter(root, memcg, NULL)));
=20
 		if (reclaim_state) {
 			sc->nr_reclaimed +=3D reclaim_state->reclaimed_slab;
--=20
2.22.0


