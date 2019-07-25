Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8051C76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 00:25:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 412E121880
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 00:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="LIc1TAPT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 412E121880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1F078E001B; Wed, 24 Jul 2019 20:25:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CFFE6B027C; Wed, 24 Jul 2019 20:25:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E58E8E001B; Wed, 24 Jul 2019 20:25:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 59B5D6B027B
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 20:25:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so29667225pfz.10
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 17:25:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=O5xV93RI+1R8a2Kv26vbR0St/EoEI2Ak0aw7BOA/tUw=;
        b=cnujk1zVAECIOAxtddRQbK37GIA3u4lqjPiVnTE0tMl2pnlgVb7hy1bUtQXRTI0G7M
         lG+/IVlYzKfICt2n17bSmlk+hqxVZEY39sJm9xoNBd5KGCGE9/jQM8htJIiZrkVe03La
         TqiEAIwNgGAfBKZD+Cxx/dSqTjyQ6GqYHWeASvgGvrFzSCRIAYlm0i1pcLj7xD35pclx
         KzcEb/W43VdSpi4Nt2yY2aIwxd/hIV7dSA+tfb+d+dgXTegu7KCTrWA7ICngzm9LpOqX
         dHSvyn/Uguawcv0EbAAe2jsrYMs8gCohfwvc3/6xeJCwV9uQrtz7ZdFd6sddcB+G9iNG
         Rc3Q==
X-Gm-Message-State: APjAAAUrwzHbWaN/Q1fdsB/T7YQ7Ajru4aqIDmlqlJ/e5Hyr02hsr36M
	afoN4XUcEaRqNFnxP8JLhEnRBvMSR313X9Ad5GgNDUHbDMfMriPvGvgvUUeMHo9n4PnDNCDLfyS
	S2jpoaU5NHABx5prmr2ac847GP7KPutYPldBncX0PxoHpaS30jsIbbNmjavwAEgOlVQ==
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr85163897plb.203.1564014331023;
        Wed, 24 Jul 2019 17:25:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUmVc4iTmP/i2AtOOMPaQcpvgJzgtTVB9mFyvtY9OJKCrLf6GT9tA2DnBUHdhen9cdffDO
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr85163848plb.203.1564014329849;
        Wed, 24 Jul 2019 17:25:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564014329; cv=none;
        d=google.com; s=arc-20160816;
        b=QPjUyBSAy6LoHi2XgFN3mo1MonoGdbYhrKRPJBQIGZGvWCtPmjRY7bZoi8NCPWgo3v
         uVjXn8JedHgGEL7Mnmhz41Gg2uihtWKju2ZKpPxqIvNlS27nFRZiNW9SKv1h675uIqZ1
         UY21kL+/OsYCvu2QmU+1C8I90kWxdWyX9tIKpRp06s8FbkZ0XfHlHOHzkJVWIOOZOsaU
         XSwpT/ttpH0bda/WQAtxZxP+aHpz9J2GC3/IH4dSc6YiqgBez9MJWVjHBcEpoyoD8p+6
         kdyr58JzJq0uz8jMTTd1xXaQhiBFubdumwxO336Bsq7xTkFtUzalDPdY3Qk7g5NdLlz+
         0ljw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:to:from:date:dkim-signature;
        bh=O5xV93RI+1R8a2Kv26vbR0St/EoEI2Ak0aw7BOA/tUw=;
        b=PpOKLxTZUtlFZIGFXbearsbodlL6TEMB7EGNguFSx68c8KLwMvjeTnn3z1iy4II50p
         Bjrrx0xvA0Iv/LADyh6aO2V2B49kCRb/2vHbY5HwQbJLBZ6DoZamhmSXnh2ExyqOWHEu
         f8fS87Ud66azlsbgNkuyWVJaqX2aKuv6+xx0D5IcAIcQ1ecSwcquA44om8PGNa7LencV
         ZebmwmWchGPbSfWJcmOgBEe1tMDpGh+Gw1XfBHyw2nAcCZAbqXL9JgkOHU9K5VeRY3UD
         MDyQycynxvvXmfU6j+4qNIUiod7YBZnyP7suEjdkRXl3nVukLT3OWrVnOMcRJ1GDirHu
         7CXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=LIc1TAPT;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i13si15581988pgf.335.2019.07.24.17.25.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 17:25:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=LIc1TAPT;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2BDB021855;
	Thu, 25 Jul 2019 00:25:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564014329;
	bh=moO5JkUBPWMun/f37ZODFGaeDpFivYbXYj6molFpfp0=;
	h=Date:From:To:Subject:In-Reply-To:References:From;
	b=LIc1TAPTk3DCtD0W1Hc7kaSumMYLqYNBqUfSGkm/eGB4CbxawWOvKG2pjmICJvGFA
	 eZoRAKn0h/uZBnlA4BYANIT6lygg0Yg9CuUB4IsLApsqYk7aJsG9tqJihenk2v1SzX
	 WQieywDBtW5F7GFNTqSXhrsQmEDKdo2pCPeuMVw4=
Date: Wed, 24 Jul 2019 17:25:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Yafang
 Shao <laoar.shao@gmail.com>, linux-mm@kvack.org, Mel Gorman
 <mgorman@techsingularity.net>, Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH] mm/compaction: introduce a helper
 compact_zone_counters_init()
Message-Id: <20190724172528.aa65e746231fcdc6646dacf9@linux-foundation.org>
In-Reply-To: <20190724171945.c81db3079162a1eb4730bd20@linux-foundation.org>
References: <1563869295-25748-1-git-send-email-laoar.shao@gmail.com>
	<20190723081218.GD4552@dhcp22.suse.cz>
	<20190723144007.9660c3c98068caeba2109ded@linux-foundation.org>
	<1fb6f7da-f776-9e42-22f8-bbb79b030b98@suse.cz>
	<20190724171945.c81db3079162a1eb4730bd20@linux-foundation.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jul 2019 17:19:45 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> And this?

Here's the current rolled-up state of this patch.

 mm/compaction.c |   35 +++++++++++++----------------------
 1 file changed, 13 insertions(+), 22 deletions(-)

--- a/mm/compaction.c~mm-compaction-clear-total_migratefree_scanned-before-scanning-a-new-zone
+++ a/mm/compaction.c
@@ -2078,6 +2078,17 @@ compact_zone(struct compact_control *cc,
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 	bool update_cached;
 
+	/*
+	 * These counters track activities during zone compaction.  Initialize
+	 * them before compacting a new zone.
+	 */
+	cc->total_migrate_scanned = 0;
+	cc->total_free_scanned = 0;
+	cc->nr_migratepages = 0;
+	cc->nr_freepages = 0;
+	INIT_LIST_HEAD(&cc->freepages);
+	INIT_LIST_HEAD(&cc->migratepages);
+
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
@@ -2281,10 +2292,6 @@ static enum compact_result compact_zone_
 {
 	enum compact_result ret;
 	struct compact_control cc = {
-		.nr_freepages = 0,
-		.nr_migratepages = 0,
-		.total_migrate_scanned = 0,
-		.total_free_scanned = 0,
 		.order = order,
 		.search_order = order,
 		.gfp_mask = gfp_mask,
@@ -2305,8 +2312,6 @@ static enum compact_result compact_zone_
 
 	if (capture)
 		current->capture_control = &capc;
-	INIT_LIST_HEAD(&cc.freepages);
-	INIT_LIST_HEAD(&cc.migratepages);
 
 	ret = compact_zone(&cc, &capc);
 
@@ -2408,8 +2413,6 @@ static void compact_node(int nid)
 	struct zone *zone;
 	struct compact_control cc = {
 		.order = -1,
-		.total_migrate_scanned = 0,
-		.total_free_scanned = 0,
 		.mode = MIGRATE_SYNC,
 		.ignore_skip_hint = true,
 		.whole_zone = true,
@@ -2423,11 +2426,7 @@ static void compact_node(int nid)
 		if (!populated_zone(zone))
 			continue;
 
-		cc.nr_freepages = 0;
-		cc.nr_migratepages = 0;
 		cc.zone = zone;
-		INIT_LIST_HEAD(&cc.freepages);
-		INIT_LIST_HEAD(&cc.migratepages);
 
 		compact_zone(&cc, NULL);
 
@@ -2529,8 +2528,6 @@ static void kcompactd_do_work(pg_data_t
 	struct compact_control cc = {
 		.order = pgdat->kcompactd_max_order,
 		.search_order = pgdat->kcompactd_max_order,
-		.total_migrate_scanned = 0,
-		.total_free_scanned = 0,
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
 		.mode = MIGRATE_SYNC_LIGHT,
 		.ignore_skip_hint = false,
@@ -2554,16 +2551,10 @@ static void kcompactd_do_work(pg_data_t
 							COMPACT_CONTINUE)
 			continue;
 
-		cc.nr_freepages = 0;
-		cc.nr_migratepages = 0;
-		cc.total_migrate_scanned = 0;
-		cc.total_free_scanned = 0;
-		cc.zone = zone;
-		INIT_LIST_HEAD(&cc.freepages);
-		INIT_LIST_HEAD(&cc.migratepages);
-
 		if (kthread_should_stop())
 			return;
+
+		cc.zone = zone;
 		status = compact_zone(&cc, NULL);
 
 		if (status == COMPACT_SUCCESS) {
_

