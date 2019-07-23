Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,URIBL_SBL,URIBL_SBL_A,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3401C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:08:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37F73223A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:08:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ylt8+rC8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37F73223A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E4C16B0003; Tue, 23 Jul 2019 04:08:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 995E36B0005; Tue, 23 Jul 2019 04:08:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ABAA8E0002; Tue, 23 Jul 2019 04:08:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 56E976B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:08:42 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x19so25483307pgx.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:08:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=5Ljakoy2txq+LWSZiGJ2ER6jX3S3ukmTQZERAI/EP28=;
        b=ioiyUdy59/f627IgHeFuVOjEkyizxE+jFS3gbVtB70zG2byGsvhqUfSPkn+vCzZcvQ
         DMXM0A8mfICPW3ive43eXR7dnWf4haNjCSV0plX+zYwkqNXOJdf/406vh3NUc2cCkJKj
         m7gOsT/m4oYvl+e3o/77MO2X+buWz5DqfegMDyxY19zsw6dDTFBYKLoL+UYA4eFtXwlS
         gQ1PRMiO83HDsx3w0XtAkK6dfEPPLN5eaR9kb8uurG+zwanalhHmAZHK/Jtao/UM/GTh
         N+5CC2lxUrh1upDQxXhVXJBRf/PGxie1CopDr6XxkA+qvj1AaCSNV7Sn14/EYyvIFYBX
         J5Dw==
X-Gm-Message-State: APjAAAVU5XYoUd1JjvmDdIztEjUdqau83+E1F4/60pSHUTwz89U9PKs6
	DjlMGqjs+FpXRKzLcYBwrg/EQPw/F0W+gkUeMfD20EQ3pmZolDThborZ5w+TjI6OjJH/oy+2nO5
	BDvk7ge2G1FK0jp/Rqqp6QIFTeBxctXboyp+XTc3YpYY7D3QlsHOD4OHq7iWgl4PP/g==
X-Received: by 2002:a62:5c3:: with SMTP id 186mr4509653pff.144.1563869321936;
        Tue, 23 Jul 2019 01:08:41 -0700 (PDT)
X-Received: by 2002:a62:5c3:: with SMTP id 186mr4509586pff.144.1563869320845;
        Tue, 23 Jul 2019 01:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563869320; cv=none;
        d=google.com; s=arc-20160816;
        b=Ijr/93YT/7Io7mNYZKyxGcu4IjJourMGxfNkt6k+qjaVIqTUXcsVXZvu+HXZUu8Pt5
         rSKSkxhXMn7IK7w9eOFBRBofykcBkWqT4yXoyRh1eLPUEipGVuSpC9XDPLiLytkBb6Jg
         ZCw5c5b02deO/h9rNv6J5DC+YiSfLJhJDPxIL2tRIFbcJGQozFpBIDaGjpPxBYtS4hUg
         HOhwgcDC2Dn78N6/+JCE5i9OxU1uOKbVlu2lnliXGPuEyMGd3hcbrWdPXrsJnwXSGsjM
         g0poEo/w3YXQ9To6+ySPW6lvBES/mrNET2+c38+AzxbUb2H9ZG9vDXRpGEU5pI9I86uB
         RIwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=5Ljakoy2txq+LWSZiGJ2ER6jX3S3ukmTQZERAI/EP28=;
        b=kbQnBmJY7Q3WFy0n09gxoyyJRYDJMBLLwH3FnbxGf+ya7zPGh9nhj7DNlxZGvxNUms
         sg4Q9/1gnr50UxHMLjF7hqvffJaKUBaEvvtMpkctjlbodEvBbxo0tr4n+aU//wR2h+f2
         l5g/SeMN98YZsWh4xe3sTPkCFwmXZCo3Gecl77EHVnX36lCEF0gbn/b/ROXUJKcJ1aYS
         AfnmPz6T4UAZoAnFx98AsppFtRNHMYqdZoJ7JjlIHAuwZeQNFPdmYYmaKzZMWKK/kmS7
         Gb6i1dcUFsTsnulaMfm3jgrRRUdvaHA++btCs/pMFNcNVkgOlrR9chyxjucz5ZOSPibL
         GCLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ylt8+rC8;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t4sor51994064plq.45.2019.07.23.01.08.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 01:08:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ylt8+rC8;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=5Ljakoy2txq+LWSZiGJ2ER6jX3S3ukmTQZERAI/EP28=;
        b=Ylt8+rC8069E6u8FyqM4uLSgJV2dx50fDtx2PKFYgu991k+51qr2rst+T1N5E4gMQ8
         3DvUSqIV7Qlqd7uigoRUK+uyvEbdFRfEcuLX7bd9blVutAR8SrpO4MgPdU+pDD9Zj0ti
         aY5QrJWV+xGpOH39Y3G5NhBUlx6Qf9cjOjazqESQONe8AZqDSAYss4Wor7odYQhhusSl
         WCaKMK+mbuj0iOzCGsXO7cR7fnF+M53slnOGnnBEK87+hZdXZOzMCoYe3CS72OUjhVXn
         bwQS73yPASt7NrWsHVU/kz/6CQI0AgPPhghKenj2+dwVgshD+OOTQ01wUUIugA/XPP2a
         D1Xw==
X-Google-Smtp-Source: APXvYqzMNT4Z0OsD+gSwEN8VCppNjNaEtTnQnh6+l6V9MHIVLJm2mRvaq241ptJi6+/DeMba4j+Efw==
X-Received: by 2002:a17:902:1004:: with SMTP id b4mr80629421pla.325.1563869320530;
        Tue, 23 Jul 2019 01:08:40 -0700 (PDT)
Received: from bogon.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id q4sm39271136pjq.27.2019.07.23.01.08.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 01:08:39 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	Yafang Shao <laoar.shao@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: [PATCH] mm/compaction: introduce a helper compact_zone_counters_init()
Date: Tue, 23 Jul 2019 04:08:15 -0400
Message-Id: <1563869295-25748-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is the follow-up of the
commit "mm/compaction.c: clear total_{migrate,free}_scanned before scanning a new zone".

These counters are used to track activities during compacting a zone,
and they will be set to zero before compacting a new zone in all compact
paths. Move all these common settings into compact_zone() for better
management. A new helper compact_zone_counters_init() is introduced for
this purpose.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Yafang Shao <shaoyafang@didiglobal.com>
---
 mm/compaction.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a109b45..356348b 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2065,6 +2065,19 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	return false;
 }
 
+
+/*
+ * Bellow counters are used to track activities during compacting a zone.
+ * Before compacting a new zone, we should init these counters first.
+ */
+static void compact_zone_counters_init(struct compact_control *cc)
+{
+	cc->total_migrate_scanned = 0;
+	cc->total_free_scanned = 0;
+	cc->nr_migratepages = 0;
+	cc->nr_freepages = 0;
+}
+
 static enum compact_result
 compact_zone(struct compact_control *cc, struct capture_control *capc)
 {
@@ -2075,6 +2088,7 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 	const bool sync = cc->mode != MIGRATE_ASYNC;
 	bool update_cached;
 
+	compact_zone_counters_init(cc);
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
 							cc->classzone_idx);
@@ -2278,10 +2292,6 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
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
@@ -2418,10 +2428,6 @@ static void compact_node(int nid)
 		if (!populated_zone(zone))
 			continue;
 
-		cc.nr_freepages = 0;
-		cc.nr_migratepages = 0;
-		cc.total_migrate_scanned = 0;
-		cc.total_free_scanned = 0;
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
@@ -2526,8 +2532,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 	struct compact_control cc = {
 		.order = pgdat->kcompactd_max_order,
 		.search_order = pgdat->kcompactd_max_order,
-		.total_migrate_scanned = 0,
-		.total_free_scanned = 0,
 		.classzone_idx = pgdat->kcompactd_classzone_idx,
 		.mode = MIGRATE_SYNC_LIGHT,
 		.ignore_skip_hint = false,
@@ -2551,10 +2555,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 							COMPACT_CONTINUE)
 			continue;
 
-		cc.nr_freepages = 0;
-		cc.nr_migratepages = 0;
-		cc.total_migrate_scanned = 0;
-		cc.total_free_scanned = 0;
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
-- 
1.8.3.1

