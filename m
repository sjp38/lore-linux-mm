Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AF72C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBE4B22BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RJzIWT6p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBE4B22BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E5EF6B0010; Thu, 25 Jul 2019 14:44:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 896FA6B0266; Thu, 25 Jul 2019 14:44:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 787838E0002; Thu, 25 Jul 2019 14:44:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 445D36B0010
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:44:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g2so9983900pgj.2
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:44:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J873l7lCPa+QolPzlUg++nHCXxrMC4Fmw1tQXHj9o08=;
        b=qcIcYRnKxff8GSKJ7l3D8Sw0g7WvUpCbc23qaqNJjicRfd6sXa6Mi1kDwgWtVog5k3
         2I2Osq9DiTVKH7nL0+L606fpJDMyOV9qExrh4k/Vb1FSZ70+LYcsSPNCQmqQm5VnAl4G
         6Er6tip9tur2Irz/sFJFSMXek7mHEGpFm9+evMhjKy1Atj6ZbXucIZay8WjRT9S426L0
         qVr4jPIuPbG/hcYRqmpov9IE8XL048DLvRm30h+W62JGbSUUa9ReDIWIFhB7supWoTC7
         TdrZYmOeiNWE7kkZr6bcYcdQhYhva+TTqm4OEMDpYzDMVJ4iNL2MFmnzzUWoEFesEgo/
         6CSQ==
X-Gm-Message-State: APjAAAUTYRq9dsN2e3eSSU2VsNh8LS+MP4rC2pCly1PbwCjQQQhWdLcb
	V9Vayd8f7jr6L/Uctnv/k6xaoumGJ6Qo3KPfrnki9Iv1wh3ZEvw4V2dmCCBq6F2Ebr5LLBmG8n1
	/0cerDlld42+Lyzjk0TEKTTk8aGrGLTAuAKC4kZef4OI0ZyjetpsSH7ewph8oLtEVOg==
X-Received: by 2002:aa7:8108:: with SMTP id b8mr18433348pfi.197.1564080278893;
        Thu, 25 Jul 2019 11:44:38 -0700 (PDT)
X-Received: by 2002:aa7:8108:: with SMTP id b8mr18433280pfi.197.1564080277707;
        Thu, 25 Jul 2019 11:44:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080277; cv=none;
        d=google.com; s=arc-20160816;
        b=0m/zAbgVS4xSHCfg53STvhprYDnWNTG8EgcmdZfn8aiMXycSYP1piUZFGBOt/qzGae
         ady44v+Ji37VXddDAIMwIn65WNbseE7xc+IVLswWPivkzU3RzflkITaXLvS+VE48bz0G
         qOR7dBNqtMS1IygYXFo3J2hRl0WSqulIhNpVvlG4Le8nSzZn+NtqU45Ymc1Dq5Alf+5f
         PgY31ngMXuU+xgY2wuNG3HOBvp+inH2P6iDEZb47p1b8FM8btTlknnw3rkL1J2HGpu1h
         Tm6wsp4p4KgYIxKJ5JaEoKcKgQ5BWhGBi8uK7Hj7AjUTdMINCx2KdaMIb9CQv8bVPzjq
         IWPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=J873l7lCPa+QolPzlUg++nHCXxrMC4Fmw1tQXHj9o08=;
        b=oHv65LT3MwXo0dkfj0+V7p2FS7wMDqrWv8ok4T3Pq5XMI0z6vXDKUOYlAVvEnlZcJV
         modatc7TMSHVDbl+WbYHwCVhJBDqslSVXmpeqU98s0UHVZHWAxYbo/M3wSvEFPP/UBcX
         OsjZWRlxd97eO1jvzfUG8mnrOGVcJWE2lsEX9J1/cIHovm6SzoUPVuaXt8OUXsfB2F3O
         4fv+Dg1OOIRdLIJ+4TjYy7WRZfhbTRhI3XZZshIeBayACL+acCaAcTkzKpTI8oNKkcbR
         xoVvohfhDLO4+cgUK7b97zuTUbXkjjVAHUQpUPz0V5kt0byl4gRGSh1wQ6AYODQnCofk
         fV7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RJzIWT6p;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 125sor10491710pgi.63.2019.07.25.11.44.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:44:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RJzIWT6p;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=J873l7lCPa+QolPzlUg++nHCXxrMC4Fmw1tQXHj9o08=;
        b=RJzIWT6paD7ZJL2tpjW5Ma6HpOCKdfWeXRD2vnTwJZh2N+35UR5DKekXI88Xe4vBOw
         8HtjuDi5CyzP5RL/Fm5lwdn0QgqaPNHF0iFdRcrXtROUqOpmEHs9iscOO8hOcq/Qhx10
         Pr/mm8WfuwKrkXjn+Vg74jX0m5AbHzx84kAt7OjrEpYKMFFsSYKkGYrLolzlvoJ1TIWM
         rsNRywamFxX4lYOCgAWlTZ3qPWxgFXNW37iDXw35a3UdDrZqalhKYFYz0spQ17MO+it4
         Z26oHS5/0o9ysNwzjjtuPA5esNh4pG99SJI+BA6DPnPEog949quGyOohq9IhFJu7x2rA
         GjJg==
X-Google-Smtp-Source: APXvYqwo1eTAvDaBp9lnIuBms8Io2Fugm1ugWOpWhcpk//Dd3/eCcG6T3EvxJjRQep96tUFWHAJ2cQ==
X-Received: by 2002:a63:1765:: with SMTP id 37mr18700674pgx.447.1564080277359;
        Thu, 25 Jul 2019 11:44:37 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.44.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:44:37 -0700 (PDT)
From: Pengfei Li <lpf.vector@gmail.com>
To: akpm@linux-foundation.org
Cc: mgorman@techsingularity.net,
	mhocko@suse.com,
	vbabka@suse.cz,
	cai@lca.pw,
	aryabinin@virtuozzo.com,
	osalvador@suse.de,
	rostedt@goodmis.org,
	mingo@redhat.com,
	pavel.tatashin@microsoft.com,
	rppt@linux.ibm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Pengfei Li <lpf.vector@gmail.com>
Subject: [PATCH 08/10] mm/compaction: use unsigned int for "compact_order_failed" in struct zone
Date: Fri, 26 Jul 2019 02:42:51 +0800
Message-Id: <20190725184253.21160-9-lpf.vector@gmail.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190725184253.21160-1-lpf.vector@gmail.com>
References: <20190725184253.21160-1-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Because "compact_order_failed" will never be negative, so just
make it unsigned int. And modify three related trace functions
accordingly.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/linux/compaction.h        | 12 ++++++------
 include/linux/mmzone.h            |  2 +-
 include/trace/events/compaction.h | 14 +++++++-------
 mm/compaction.c                   |  8 ++++----
 4 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 0201dfa57d44..a8049d582265 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -99,11 +99,11 @@ extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern enum compact_result compaction_suitable(struct zone *zone,
 	unsigned int order, unsigned int alloc_flags, int classzone_idx);
 
-extern void defer_compaction(struct zone *zone, int order);
-extern bool compaction_deferred(struct zone *zone, int order);
-extern void compaction_defer_reset(struct zone *zone, int order,
+extern void defer_compaction(struct zone *zone, unsigned int order);
+extern bool compaction_deferred(struct zone *zone, unsigned int order);
+extern void compaction_defer_reset(struct zone *zone, unsigned int order,
 				bool alloc_success);
-extern bool compaction_restarting(struct zone *zone, int order);
+extern bool compaction_restarting(struct zone *zone, unsigned int order);
 
 /* Compaction has made some progress and retrying makes sense */
 static inline bool compaction_made_progress(enum compact_result result)
@@ -188,11 +188,11 @@ static inline enum compact_result compaction_suitable(struct zone *zone,
 	return COMPACT_SKIPPED;
 }
 
-static inline void defer_compaction(struct zone *zone, int order)
+static inline void defer_compaction(struct zone *zone, unsigned int order)
 {
 }
 
-static inline bool compaction_deferred(struct zone *zone, int order)
+static inline bool compaction_deferred(struct zone *zone, unsigned int order)
 {
 	return true;
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d77d717c620c..0947e7cb4214 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -545,7 +545,7 @@ struct zone {
 	 */
 	unsigned int		compact_considered;
 	unsigned int		compact_defer_shift;
-	int			compact_order_failed;
+	unsigned int		compact_order_failed;
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 1e1e74f6d128..f83ba40f9614 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -243,17 +243,17 @@ DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
 
 DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 
-	TP_PROTO(struct zone *zone, int order),
+	TP_PROTO(struct zone *zone, unsigned int order),
 
 	TP_ARGS(zone, order),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
 		__field(enum zone_type, idx)
-		__field(int, order)
+		__field(unsigned int, order)
 		__field(unsigned int, considered)
 		__field(unsigned int, defer_shift)
-		__field(int, order_failed)
+		__field(unsigned int, order_failed)
 	),
 
 	TP_fast_assign(
@@ -265,7 +265,7 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 		__entry->order_failed = zone->compact_order_failed;
 	),
 
-	TP_printk("node=%d zone=%-8s order=%d order_failed=%d consider=%u limit=%lu",
+	TP_printk("node=%d zone=%-8s order=%u order_failed=%u consider=%u limit=%lu",
 		__entry->nid,
 		__print_symbolic(__entry->idx, ZONE_TYPE),
 		__entry->order,
@@ -276,21 +276,21 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 
 DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_deferred,
 
-	TP_PROTO(struct zone *zone, int order),
+	TP_PROTO(struct zone *zone, unsigned int order),
 
 	TP_ARGS(zone, order)
 );
 
 DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_compaction,
 
-	TP_PROTO(struct zone *zone, int order),
+	TP_PROTO(struct zone *zone, unsigned int order),
 
 	TP_ARGS(zone, order)
 );
 
 DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_reset,
 
-	TP_PROTO(struct zone *zone, int order),
+	TP_PROTO(struct zone *zone, unsigned int order),
 
 	TP_ARGS(zone, order)
 );
diff --git a/mm/compaction.c b/mm/compaction.c
index ac5df82d46e0..aad638ad2cc6 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -139,7 +139,7 @@ EXPORT_SYMBOL(__ClearPageMovable);
  * allocation success. 1 << compact_defer_limit compactions are skipped up
  * to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
  */
-void defer_compaction(struct zone *zone, int order)
+void defer_compaction(struct zone *zone, unsigned int order)
 {
 	zone->compact_considered = 0;
 	zone->compact_defer_shift++;
@@ -154,7 +154,7 @@ void defer_compaction(struct zone *zone, int order)
 }
 
 /* Returns true if compaction should be skipped this time */
-bool compaction_deferred(struct zone *zone, int order)
+bool compaction_deferred(struct zone *zone, unsigned int order)
 {
 	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
 
@@ -178,7 +178,7 @@ bool compaction_deferred(struct zone *zone, int order)
  * which means an allocation either succeeded (alloc_success == true) or is
  * expected to succeed.
  */
-void compaction_defer_reset(struct zone *zone, int order,
+void compaction_defer_reset(struct zone *zone, unsigned int order,
 		bool alloc_success)
 {
 	if (alloc_success) {
@@ -192,7 +192,7 @@ void compaction_defer_reset(struct zone *zone, int order,
 }
 
 /* Returns true if restarting compaction after many failures */
-bool compaction_restarting(struct zone *zone, int order)
+bool compaction_restarting(struct zone *zone, unsigned int order)
 {
 	if (order < zone->compact_order_failed)
 		return false;
-- 
2.21.0

