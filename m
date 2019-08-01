Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A492C41514
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F02A120693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F02A120693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC51F8E0011; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E25608E000F; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA5478E0010; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 595B08E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so38647041plo.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cdJt571N0eKeazYtNbEQv7Yth90iWql1zac5B5tB+u0=;
        b=Eo7kHwt5/GW3RuGolOKhR6f+YBIFzr2f3tk+uOjFLIAp1XoWeiScS6r0U33ZXkDGZz
         cj3ObJzl99DYt4MLlwFVdvmkXi2k3ckt6fUi8icbQxKkC39J3+Ll9Aq6CStLifYmqAPi
         fM3qLhHA7B7oiiLAZPnI8V2J32TyfwFu2zvPTcqCenOsC4f9TYwj1Tw6DCyU88qQwQ//
         RglbYJ8W2nAuXcTB4yFJlbGPaaWU+B+lLLepc0nPG2bZrCkJ61fnv5tr+7GpFtq/zgcH
         WKz7x4G76f5wEK3Oo28rDRKgvSi4H5PfFz4vp1FkTocpdcZCd+s7HmEXayLC/q4qtFON
         C+0g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUcLZVfbpomPXgS5sNs1T6D4f1/RpuGVpfphPUMBimkUwo6fEUh
	k5d4gBvnRvz0Q7Nd1YdrIqt6FbkcdfDETCcfQvZ1jJ6S5gxzo+V0NfAtkKqI/rXz/1+7coz63iH
	z6Z8o7y4NnUpHDSaJPLSZdRDhvEpLDCPznlp3ezbkZwe9DVERKgv0jWK7+KvuXAU=
X-Received: by 2002:a17:90a:fa07:: with SMTP id cm7mr5746390pjb.138.1564625891028;
        Wed, 31 Jul 2019 19:18:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgUVSae6l5WfvsR7xPvqgs8ngiUhGEzOVi7OBVhLLWUbu+VdzodISx3vcQ1odghTIUgDOH
X-Received: by 2002:a17:90a:fa07:: with SMTP id cm7mr5745894pjb.138.1564625881611;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625881; cv=none;
        d=google.com; s=arc-20160816;
        b=hT3MwgW2P0hI4WRPZsDTuyqjcW39xMWxthxGaUod6v33Ddrx12xS945lTkOIQPKsZf
         2gEOb+di8JZ0Ofn70B8nlfFlWdqDBZzli3wrcwwQKZ7fHHkWxDxGBcD3Dn1GxDqMmTep
         DnHmpgYMeW/uafZh5iIEC33WUHxCcYeMEv5aWN4nanXKCw2YMEdlMZ2S6DQpVnlMqUnc
         beDml31yhkIqGmQ5JEMC5MJI1xAH6zooPfgq+fbe+nf1a9bGpAqokSTkQikl97ced+TO
         8IXcN5ARoZoDc42k67s8EpJr95fO81HSik5/lOg+KDwJaPxZjYHnqvGzZfqTTjLeqEV5
         kH3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cdJt571N0eKeazYtNbEQv7Yth90iWql1zac5B5tB+u0=;
        b=ArCzy3fD7FyoJkRTGykcw+uLqqxOVWoE8pai5rpx7v0TSB9Wbb7cCtwFJclAEmCzW7
         AbkbuCIYlsEPqWaKwAb+pJOY/VTr/lfg6zqHfYi3yAq6OUvElaOI3zggxuEw60T/dQIW
         I5Z3XiGSsUhqBnRrfwj9aAJHChlsNSJnjwxOgP//zSbV0igKrESNlYAC6s3DVZtH1TDQ
         pP/VuajIsMo48MTnlFydenEvlnqxGO9WC1DRUh00SjHbzutUVy2VInC9GNSNSUMMBvY1
         tYmKPoa75PJQEV+WG3g5jYOkgmF7yVPhCQCGnqsD3Y1cIhYAtlSgCFVspo7KEqXTSGRJ
         TVOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id j69si31122906pgd.589.2019.07.31.19.18.01
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id B21DD43C95D;
	Thu,  1 Aug 2019 12:17:57 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eA-0003aa-Ts; Thu, 01 Aug 2019 12:16:50 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fG-0001ks-Rd; Thu, 01 Aug 2019 12:17:58 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 07/24] mm: back off direct reclaim on excessive shrinker deferral
Date: Thu,  1 Aug 2019 12:17:35 +1000
Message-Id: <20190801021752.4986-8-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=c3jh6I83BcSAbW0NpfQA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

When the majority of possible shrinker reclaim work is deferred by
the shrinkers (e.g. due to GFP_NOFS context), and there is more work
defered than LRU pages were scanned, back off reclaim if there are
large amounts of IO in progress.

This tends to occur when there are inode cache heavy workloads that
have little page cache or application memory pressure on filesytems
like XFS. Inode cache heavy workloads involve lots of IO, so if we
are getting device congestion it is indicative of memory reclaim
running up against an IO throughput limitation. in this situation
we need to throttle direct reclaim as we nee dto wait for kswapd to
get some of the deferred work done.

However, if there is no device congestion, then the system is
keeping up with both the workload and memory reclaim and so there's
no need to throttle.

Hence we should only back off scanning for a bit if we see this
condition and there is block device congestion present.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/swap.h |  2 ++
 mm/vmscan.c          | 30 +++++++++++++++++++++++++++++-
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 978e6cd5c05a..1a3502a9bc1f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -131,6 +131,8 @@ union swap_header {
  */
 struct reclaim_state {
 	unsigned long	reclaimed_pages;	/* pages freed by shrinkers */
+	unsigned long	scanned_objects;	/* quantity of work done */ 
+	unsigned long	deferred_objects;	/* work that wasn't done */
 };
 
 #ifdef __KERNEL__
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 231ddcfcd046..4dc8e333f2c6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -569,8 +569,11 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 	 * If the shrinker can't run (e.g. due to gfp_mask constraints), then
 	 * defer the work to a context that can scan the cache.
 	 */
-	if (shrinkctl->will_defer)
+	if (shrinkctl->will_defer) {
+		if (current->reclaim_state)
+			current->reclaim_state->deferred_objects += scan_count;
 		goto done;
+	}
 
 	/*
 	 * Normally, we should not scan less than batch_size objects in one
@@ -605,6 +608,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 
 		cond_resched();
 	}
+	if (current->reclaim_state)
+		current->reclaim_state->scanned_objects += scanned_objects;
 
 done:
 	/*
@@ -2766,7 +2771,30 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_pages;
+
+			/*
+			 * If we are deferring more work than we are actually
+			 * doing in the shrinkers, and we are scanning more
+			 * objects than we are pages, the we have a large amount
+			 * of slab caches we are deferring work to kswapd for.
+			 * We better back off here for a while, otherwise
+			 * we risk priority windup, swap storms and OOM kills
+			 * once we empty the page lists but still can't make
+			 * progress on the shrinker memory.
+			 *
+			 * kswapd won't ever defer work as it's run under a
+			 * GFP_KERNEL context and can always do work.
+			 */
+			if ((reclaim_state->deferred_objects >
+					sc->nr_scanned - nr_scanned) &&
+			    (reclaim_state->deferred_objects >
+					reclaim_state->scanned_objects)) {
+				wait_iff_congested(BLK_RW_ASYNC, HZ/50);
+			}
+
 			reclaim_state->reclaimed_pages = 0;
+			reclaim_state->deferred_objects = 0;
+			reclaim_state->scanned_objects = 0;
 		}
 
 		/* Record the subtree's reclaim efficiency */
-- 
2.22.0

