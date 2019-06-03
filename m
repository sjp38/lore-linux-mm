Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 283DBC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D95ED241B1
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:08:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="GiZl3I0/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D95ED241B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C2D46B0271; Mon,  3 Jun 2019 17:08:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FD5E6B0272; Mon,  3 Jun 2019 17:08:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 476956B0273; Mon,  3 Jun 2019 17:08:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 111436B0271
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:08:31 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id o184so3890516pfg.1
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:08:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hW9XEaleHf0fxFzrzaLu3/5nxBFHbI/f8wU4NVTruL4=;
        b=Ze2H44b4Pyg0CWjLtwsEl6XxSi0E2HchtsSihVBqgIF9Qwabg3ERbZQrdzZmye9Zg4
         Ouvl4eT8LW9IiYmhl7QnIRXmaI44S964IeYPKz+tHeS40WA3fwSYe+bvSABFdDkvFcUk
         gdl78lnVrY4ekH3fEgWlOn2MBIbynX77f9YrWqH3LgFqtv8+klgQ86KQZbDF93eM7YBi
         5/c+8/H4IGoGbDh9qMPFu9yAdDv9ITRMRE/huQqGrohHQ9M5a59m5ZycTKweNkPwNfVB
         iA7ra+z9YfYCj53peaooBkObuj1pfxsyLnT3ePzQhw1PMI4nbpEfE7S3ixTC6fiBPRLn
         UyRQ==
X-Gm-Message-State: APjAAAUrsYDVhSBBw1IlF7XgCcyoLiMqOcAUmVVOn7DY5c2xFIm5gQH1
	40UYiKnIr+fmB2z/ZnFW2nfJBRn2uVOVFx6Ljqc6Xx1TFszdBNQG6OM5L5Q097oM7HU8JlZl4fo
	+3xgl0MtV27fvzDzGQPQbVwlmyyHiVKBb5P8NKRy+6R/s4oqnIS6qpfmMbwCYSLapEg==
X-Received: by 2002:a63:e408:: with SMTP id a8mr31653746pgi.146.1559596110485;
        Mon, 03 Jun 2019 14:08:30 -0700 (PDT)
X-Received: by 2002:a63:e408:: with SMTP id a8mr31653624pgi.146.1559596109456;
        Mon, 03 Jun 2019 14:08:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596109; cv=none;
        d=google.com; s=arc-20160816;
        b=yWIzWiRoswgZB38DqPePLEWEjZp4GMC/xRMduHJNxD0eijk26zfVoyc0ksiZlFonGh
         rZ+7pfE/5gtkDko0Xv62kxtTBne7mq1wchH8kEPckNnnkrIT7ywdL7Ggus72MsxtPaEW
         gsOaPGUinHdD5NSzIX2HkatB6LxoiPggznj6v3sSubtvE5VCrrQ9jj2DYMSC6NUEl5qb
         FwUTjNkI6awqZq2j23y8rCTq1NWLybTGVPI4WSluWDqdS5Dj8LDeqvqJG/JJ08ZFou3A
         TdI/We8XLPah5e9GxfyhoUaVU43P76sSxNA2ZAKYjHYbVliquGkTn0GR6I/RAntB0V0X
         K7Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hW9XEaleHf0fxFzrzaLu3/5nxBFHbI/f8wU4NVTruL4=;
        b=nR2Q6NZWElt1ZG56AOmsddEID7obZn8kZJvV3pJrR+Uxm8jV4u6MCHBc2vYBJ9evZG
         ajhUvTtiWs0Jn5pPqoSLsW/u7UPeK6nAedHw7+TlOs+faAfepSZVCU/c/wrVOEKlZIcv
         jyYf+rN6ktou6gfQm5rsOASY6G4KxWlD46jTv6BnMgocMMTXW4DvjeJmy81AwXrxGvc0
         gUPQGVIxq0M/8sBxe2qCI7m7VRqFC0X7f4o2q2OIzi93ssqo7TdrdwbpV6W1SzXGlLD8
         9UTKUFFCyKNpcuWz0zlqM6s1woe+tOFMwYinLNAnzwI16OPGgDuLvECcZCfkGOq+f0jt
         MSVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="GiZl3I0/";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bx5sor18153568pjb.22.2019.06.03.14.08.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:08:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="GiZl3I0/";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=hW9XEaleHf0fxFzrzaLu3/5nxBFHbI/f8wU4NVTruL4=;
        b=GiZl3I0/1nrhXFLsEYVx8i8I4at3od658KebcT8wvAtJDzTnhyqemuN29q2/fcr3KW
         tDsgy9TzZFg8DTfH/bgCfQ9DMl4vc7J4plUg5mA9cty9aXI8rxvDidvnbUu121RWDy3r
         e1RxDwqqABcmlJXwZaGPTzP0keY1G2zSdow7H3XEkR3F49wcmjR9HuHqyQb5DFvxXdrE
         L+ebT5LxPIX7aGWwOApYSGaixnBATTA3AvWr+WjSjHJsz0lxIbyDxEPuHK3xJkUAPctk
         yP5msqE7q+xLnKa1SZBpeRAnKA5wg+rgZtDOy4sVffJyMyZx1w3RUzvp12AR2PMSm3mf
         jkdA==
X-Google-Smtp-Source: APXvYqxRKIe7ZlIxfiZR5KZpvX0iyzwEdC5f5c2JCVHHT7fr7Ha6rZsuX4a/y9QMM1RAzJK5pY+vwA==
X-Received: by 2002:a17:90a:30a1:: with SMTP id h30mr33354770pjb.14.1559596109171;
        Mon, 03 Jun 2019 14:08:29 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:9fa4])
        by smtp.gmail.com with ESMTPSA id p18sm3454267pff.93.2019.06.03.14.08.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:08:28 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 03/11] mm: vmscan: simplify lruvec_lru_size()
Date: Mon,  3 Jun 2019 17:07:38 -0400
Message-Id: <20190603210746.15800-4-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190603210746.15800-1-hannes@cmpxchg.org>
References: <20190603210746.15800-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This function currently takes the node or lruvec size and subtracts
the zones that are excluded by the classzone index of the
allocation. It uses four different types of counters to do this.

Just add up the eligible zones.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 19 +++++--------------
 1 file changed, 5 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 853be16ee5e2..69c4c82a9b5a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -342,30 +342,21 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
  */
 unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx)
 {
-	unsigned long lru_size;
+	unsigned long size = 0;
 	int zid;
 
-	if (!mem_cgroup_disabled())
-		lru_size = lruvec_page_state_local(lruvec, NR_LRU_BASE + lru);
-	else
-		lru_size = node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
-
-	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
+	for (zid = 0; zid <= zone_idx; zid++) {
 		struct zone *zone = &lruvec_pgdat(lruvec)->node_zones[zid];
-		unsigned long size;
 
 		if (!managed_zone(zone))
 			continue;
 
 		if (!mem_cgroup_disabled())
-			size = mem_cgroup_get_zone_lru_size(lruvec, lru, zid);
+			size += mem_cgroup_get_zone_lru_size(lruvec, lru, zid);
 		else
-			size = zone_page_state(&lruvec_pgdat(lruvec)->node_zones[zid],
-				       NR_ZONE_LRU_BASE + lru);
-		lru_size -= min(size, lru_size);
+			size += zone_page_state(zone, NR_ZONE_LRU_BASE + lru);
 	}
-
-	return lru_size;
+	return size;
 
 }
 
-- 
2.21.0

