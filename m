Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C777C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D21520842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:16:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="hLC/ybu2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D21520842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7BE18E0010; Mon, 25 Feb 2019 15:16:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D66C88E000F; Mon, 25 Feb 2019 15:16:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE31E8E000E; Mon, 25 Feb 2019 15:16:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 913DE8E000D
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:16:46 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id h7so7064310ybq.18
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:16:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=WI+9Fv62m14v2/0bpOh7WDTjNt03Efg6c77ftf67isoxzsD3vTozWCPZxfLsk+wCy3
         5yNQsyg3QH5SBHFfezHQGb0G87CJDnw3MjG4giYYm6B2BZKWBxsOtHD2NUPZwrYsVqW2
         Wd23VRQg/CnNEmA4Ngu4L3AOq1AnUsxDNLdIXk3+b5/6Tc0fQeD/vniz/MI5G19gmT9D
         TMu2afqXg1uKFIRdVTuXu3uS0QudCBm3N7JVOIAZKrN8o9XluO6b20zwhzrexJCuLLRF
         S2fSSwO0rjIzRfOTqGer8pjUSDqKXyzPNV+Y0t9aaRwFwgPSJwmHkDymuba28+P956lh
         qHpw==
X-Gm-Message-State: AHQUAubrIEZGuscY6dTyxsfsZnZ5qVG+Wv5AHnO8N5VtXu0u92jIcNEO
	DWnneR68DaXyOXdSWGmSsax8JqTxCx6PogZMNieUgVqrbCAWAwZHadMlsUWoWFyG4y8m+csTC9a
	J0QZ7HtjscY/JmJjM01tjr9LNtQq7aiEeJUePNGy5myV1z5dFEMERCkdoLg+zXkEpBbCuwfcVuG
	BeJLAXzr3/gtKgvxNjb9BNhlVQ862jKqLbHCXGbCz56/hIR19C2hfKN4zWXoUSi7A7mb7+wFu5D
	h+Q/M3inNAKdWJLWCn7lqJFXLQDsxr48Dd+l8ND2qG20MXPaztZFuwm10dqX5iN53H1YEBJar6t
	Vr5bFu7WdgXqgRSPcgTEqxXmDRrXy6iBLMzXACOEpvJPbWlpt2R/44FyCeXSE0n4yHVy24+NNw7
	R
X-Received: by 2002:a81:9257:: with SMTP id j84mr15453739ywg.401.1551125806214;
        Mon, 25 Feb 2019 12:16:46 -0800 (PST)
X-Received: by 2002:a81:9257:: with SMTP id j84mr15453690ywg.401.1551125805534;
        Mon, 25 Feb 2019 12:16:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551125805; cv=none;
        d=google.com; s=arc-20160816;
        b=XC00XC44P7aQsy5lk9D68ixvSaGRdwHsdKjUIHSHST5lRCvuvjrcJlMooDhCcdppOC
         K6cb/UQH8OGRHlyq0esYS4MpQ1SG433ZCHhV4J7kanTGkhbWARWCp4CpeDkNVnqpPSoy
         Ai96mVgkTSLlAUV3ZHrHJIfjdYUHqW4UzFu430gwIIVRgAiPqBZZyWo3NegvnnjaLSNZ
         2UfI/+C2aoCl9wj/C/EObfRKw0JLQvBQr8Vc+2cs6ZB60j4tlg2lR5s0J6cPNZ5JnMsq
         elIeA6EaYaSJwLbryxYgXZWDL9w71uyJCvExU8Cxd8vnnhw+gaZD6w8SrMiga3LaT/S7
         co7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=Q+vtekyuYbPPn8cTbNKpnHeIJKOr14aYk9xdhBuqpJhEf7Ox0fpeY2v9e9hKd3Gtx7
         pQuqxQU/vz+DiMdIVrG+X30CjgMqa0CR8tkp5C8Xd37oZwmT+G5UuBDk61GyA9b61++N
         wCfZt5LxPzTCFydolmC3OE1+zYlu+ZcRwr5KeVB7KXD8yIv0dVkau6aaFPq7svfEUojq
         9EsGKNSsh+rXYcb0G1WjYIrYVcfrwNjgl+pYUAXv8zGnl4+QAY4JiNg0P9XgK6Sp0FOC
         mq//P2Sphed716B/MKVVbHdEWNByOXj7H81dCcancWBf7m2KE6YAkG19NG1mo9/7u21L
         keQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="hLC/ybu2";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n205sor1983750ywb.170.2019.02.25.12.16.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 12:16:43 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b="hLC/ybu2";
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references:reply-to
         :mime-version:content-transfer-encoding;
        bh=NSVRB4KCxOzLiCcKtVzLdp3bqBiDRMqjw6+T+tZutHo=;
        b=hLC/ybu208J5Hr28U656XFMsm9P1dk8LEEsg6XGPhjZA6SfujvqBD8s9vRFAJJDaib
         54/ixxnjJVDCavglvjLEZdVhdBRWdDRyhDo4ICJaZkj2zeHdgVHrWeq/l6qxrh8+iFdo
         U318XvKGX5sshyIAom8DJv/6BYI0LlSERV9YK8SaKkfMthMYXp+zW62i8WYpb41pPE9u
         OF52KB4e33SQCt3g5H/NVqNI9lg73+aRs22cTGf9t9QaSveeACLYUVU2wEV/5TDOU+4/
         MxtaYvcNiFptMo2n6wvPCNOn+OxL6Oig8CUSVE48JrBguUrdrGvxH++xSZTZFsbcaoHb
         OMEA==
X-Google-Smtp-Source: AHgI3IYGY1ofN9SNL0IlNKXLqksZQv6irjIM+ASKc2I45LfowTLRtuta55q6EKDXjoyKLwGbcJg0/Q==
X-Received: by 2002:a81:9895:: with SMTP id p143mr15352221ywg.159.1551125803492;
        Mon, 25 Feb 2019 12:16:43 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::2:5fab])
        by smtp.gmail.com with ESMTPSA id 207sm1452295yww.22.2019.02.25.12.16.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 25 Feb 2019 12:16:42 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 1/6] mm: memcontrol: track LRU counts in the vmstats array
Date: Mon, 25 Feb 2019 15:16:30 -0500
Message-Id: <20190225201635.4648-2-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190225201635.4648-1-hannes@cmpxchg.org>
References: <20190225201635.4648-1-hannes@cmpxchg.org>
Reply-To: "[PATCH 0/6]"@kvack.org, "mm:memcontrol:clean"@kvack.org,
	up@kvack.org, the@kvack.org, LRU@kvack.org, counts@kvack.org,
	tracking@kvack.org
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The memcg code currently maintains private per-zone breakdowns of the
LRU counters. This is necessary for reclaim decisions which are still
zone-based, but there are a variety of users of these counters that
only want the aggregate per-lruvec or per-memcg LRU counts, and they
need to painfully sum up the zone counters on each request for that.

These would be better served using the memcg vmstats arrays, which
track VM statistics at the desired scope already. They just don't have
the LRU counts right now.

So to kick off the conversion, begin tracking LRU counts in those.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm_inline.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 04ec454d44ce..6f2fef7b0784 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -29,7 +29,7 @@ static __always_inline void __update_lru_size(struct lruvec *lruvec,
 {
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 
-	__mod_node_page_state(pgdat, NR_LRU_BASE + lru, nr_pages);
+	__mod_lruvec_state(lruvec, NR_LRU_BASE + lru, nr_pages);
 	__mod_zone_page_state(&pgdat->node_zones[zid],
 				NR_ZONE_LRU_BASE + lru, nr_pages);
 }
-- 
2.20.1

