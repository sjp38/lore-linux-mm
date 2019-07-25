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
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB268C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5AB222BEF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tJBS9eBY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5AB222BEF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B5556B0008; Thu, 25 Jul 2019 14:44:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 366AE6B0269; Thu, 25 Jul 2019 14:44:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 255CF8E0002; Thu, 25 Jul 2019 14:44:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3BD46B0008
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:44:55 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id e95so26795653plb.9
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:44:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=p7anoNZvbE1SmPE7vSkzLr+EkemuOAJ6vumDZVqMY6I=;
        b=TZv53C9u4VM045c7ymhTC++P/v2W1EaNOLYSwhLPwRj3nriasgp12UyxV0l5rvn0DZ
         Dla4Zi6T8rbjdHI7eUahGDjIdEDVTD46UYvNIwVXC87kWmZflA05E6NGCRNffGThoWWG
         WXALz1KTJRmLmH10Nt9XM7GLje9s1f276gg7WLhxwUJKzgmSk47RMdWK+0Un6zxe4+uU
         4b7FJPfB02jGqWhjR2J+54rk5ILvgH4Pg1/AlvDaaNqwDYuyiv7/fA6AfeOjsZRhr52M
         xsfl/V1Ckp7Tst9NMzeB1vu6qiTdZ2zKmfje8G73dTmau8j6FTUroiB/jfNGwDp5OSYj
         v5Hw==
X-Gm-Message-State: APjAAAWeIKZHvcot5uD3A1UHVW8LqN+Qv+iGW6Gcw9IPHIWuqKtAcwrw
	arYI2M1TNpJUCe2ti91RjIkBm2iEB9UAFWe7DO3b/WSz8UOTpZt9cd5YMzo0JQLTknUWacXw+c3
	wV0gGgxQ/Gg4CLAsig3YK+HN/Z6sR8QixMjg3mJL61A+0TW/AJUym6pCNfpAOF+2wpA==
X-Received: by 2002:a65:4189:: with SMTP id a9mr60778674pgq.399.1564080295520;
        Thu, 25 Jul 2019 11:44:55 -0700 (PDT)
X-Received: by 2002:a65:4189:: with SMTP id a9mr60778626pgq.399.1564080294312;
        Thu, 25 Jul 2019 11:44:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080294; cv=none;
        d=google.com; s=arc-20160816;
        b=QMRlXtImTJBLSVGTRavWD7b5cvfdWAGRWNIEAYfvMQmHYVKQU5J+oyJ/kSVR29wGbq
         sUgbtToEQkVnyUI0H3u3OCb67hGO7wVpRLjJ20fLBClYFBcoImC03nGNVACAJx3umrSK
         X+sMnMRKCkuTemaFlqqoPR6ICzlR8THifeqXP4Gu39rd//OH9RE1f8s01IKH0L6WUADK
         8S/J3ROvMol8MGTz7uV/TrH/M9zNpEH06v8+0rfiAfjWOYP6eCdUrB2OtSA05UnF/Ibn
         mCtEe8ABMYIqK/3RDVAmyGQ0IU8K6l8wFuI5kckc80g9OW3ACz/cGVsWDabxF3NoThgf
         TjkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=p7anoNZvbE1SmPE7vSkzLr+EkemuOAJ6vumDZVqMY6I=;
        b=EuA9JWDcMPWmv1yRjcwLHaPNXFB88DJ/++j4I0G+Yg2o+l/opZPW9wJ9e4k/hrcb6j
         9B77sXbHeNHBi33HGl0gROcec4cunZG5/XUlddF8FCWwmTMi4RzBa531Hend/t6eaUK3
         IcuK7fH6k5OJUJw/G9sz4CQNf6MPgbAEVKiuMfEYVMjcudhs3OlmvkabT/tJkhzaFL+i
         zIMXB5Kctl26jjIUYKABn8vmhJ9JdTmWuzZG21FVgtN88EigJqcw8TDru/7EdGNiCEE+
         N1TTzDZ/O4K/T6UObhAF0VEScS1L8IMEPme79F7wGSN8Rw8F5bSQOFrEHikHQITc31g4
         m4Jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tJBS9eBY;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g85sor31819079pfb.62.2019.07.25.11.44.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:44:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tJBS9eBY;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=p7anoNZvbE1SmPE7vSkzLr+EkemuOAJ6vumDZVqMY6I=;
        b=tJBS9eBYwj5uFnvpYiOFMVcvakA/gNlpWBLT8ABmrbAMIlcvS5T5oRS5m3dKEQ25Bl
         8AusFNV4/jIOLj3fBavzY82wfCx5RoXf+dE20Nnnt0xXpvKquTSMiItJLWgEOoXsjt7Y
         ehfj3CQf43o371r/d1vAi+eeSeWV++2ZZLt+1LdWwluIeWLw4/IzgQy0a4pGLmLGhYiP
         IwGkgvsELiIEgxhha6sbuvNuy18XtzADZ4I90Aa5Rn1QRu8q7RPpr/KsyDRof+JXMBOT
         J1XUbuzl4K3hgKDfOEBKjMXC1MSMvMyfGeUljO6JpN+OJqdSyd/zp5ddzuqhZmKN42C2
         kfFw==
X-Google-Smtp-Source: APXvYqwZbtVPZxFGTdpe3wuAozXuab4sqkGSpbGjI1Hce0XSqcULaSlK3GMHEQ89iHU3g+UWizUZYQ==
X-Received: by 2002:a62:1444:: with SMTP id 65mr17795430pfu.145.1564080293985;
        Thu, 25 Jul 2019 11:44:53 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.44.46
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:44:53 -0700 (PDT)
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
Subject: [PATCH 10/10] mm/vmscan: use unsigned int for "kswapd_order" in struct pglist_data
Date: Fri, 26 Jul 2019 02:42:53 +0800
Message-Id: <20190725184253.21160-11-lpf.vector@gmail.com>
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

Because "kswapd_order" will never be negative, so just make it
unsigned int. And modify wakeup_kswapd(), kswapd_try_to_sleep()
and trace_mm_vmscan_kswapd_wake() accordingly.

Besides, make "order" unsigned int in two related trace functions.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/linux/mmzone.h            |  4 ++--
 include/trace/events/compaction.h | 10 +++++-----
 include/trace/events/vmscan.h     |  4 ++--
 mm/vmscan.c                       |  6 +++---
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 60bebdf47661..1196ed0cee67 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -717,7 +717,7 @@ typedef struct pglist_data {
 	wait_queue_head_t pfmemalloc_wait;
 	struct task_struct *kswapd;	/* Protected by
 					   mem_hotplug_begin/end() */
-	int kswapd_order;
+	unsigned int kswapd_order;
 	enum zone_type kswapd_classzone_idx;
 
 	int kswapd_failures;		/* Number of 'reclaimed == 0' runs */
@@ -802,7 +802,7 @@ static inline bool pgdat_is_empty(pg_data_t *pgdat)
 #include <linux/memory_hotplug.h>
 
 void build_all_zonelists(pg_data_t *pgdat);
-void wakeup_kswapd(struct zone *zone, gfp_t gfp_mask, int order,
+void wakeup_kswapd(struct zone *zone, gfp_t gfp_mask, unsigned int order,
 		   enum zone_type classzone_idx);
 bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			 int classzone_idx, unsigned int alloc_flags,
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index f83ba40f9614..34a9fac3b4d6 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -314,13 +314,13 @@ TRACE_EVENT(mm_compaction_kcompactd_sleep,
 
 DECLARE_EVENT_CLASS(kcompactd_wake_template,
 
-	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
+	TP_PROTO(int nid, unsigned int order, enum zone_type classzone_idx),
 
 	TP_ARGS(nid, order, classzone_idx),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
-		__field(int, order)
+		__field(unsigned int, order)
 		__field(enum zone_type, classzone_idx)
 	),
 
@@ -330,7 +330,7 @@ DECLARE_EVENT_CLASS(kcompactd_wake_template,
 		__entry->classzone_idx = classzone_idx;
 	),
 
-	TP_printk("nid=%d order=%d classzone_idx=%-8s",
+	TP_printk("nid=%d order=%u classzone_idx=%-8s",
 		__entry->nid,
 		__entry->order,
 		__print_symbolic(__entry->classzone_idx, ZONE_TYPE))
@@ -338,14 +338,14 @@ DECLARE_EVENT_CLASS(kcompactd_wake_template,
 
 DEFINE_EVENT(kcompactd_wake_template, mm_compaction_wakeup_kcompactd,
 
-	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
+	TP_PROTO(int nid, unsigned int order, enum zone_type classzone_idx),
 
 	TP_ARGS(nid, order, classzone_idx)
 );
 
 DEFINE_EVENT(kcompactd_wake_template, mm_compaction_kcompactd_wake,
 
-	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
+	TP_PROTO(int nid, unsigned int order, enum zone_type classzone_idx),
 
 	TP_ARGS(nid, order, classzone_idx)
 );
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c37e2280e6dd..13c214f3750b 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -74,7 +74,7 @@ TRACE_EVENT(mm_vmscan_kswapd_wake,
 
 TRACE_EVENT(mm_vmscan_wakeup_kswapd,
 
-	TP_PROTO(int nid, int zid, int order, gfp_t gfp_flags),
+	TP_PROTO(int nid, int zid, unsigned int order, gfp_t gfp_flags),
 
 	TP_ARGS(nid, zid, order, gfp_flags),
 
@@ -92,7 +92,7 @@ TRACE_EVENT(mm_vmscan_wakeup_kswapd,
 		__entry->gfp_flags	= gfp_flags;
 	),
 
-	TP_printk("nid=%d order=%d gfp_flags=%s",
+	TP_printk("nid=%d order=%u gfp_flags=%s",
 		__entry->nid,
 		__entry->order,
 		show_gfp_flags(__entry->gfp_flags))
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f4fd02ae233e..9d98a2e5f736 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3781,8 +3781,8 @@ static enum zone_type kswapd_classzone_idx(pg_data_t *pgdat,
 	return pgdat->kswapd_classzone_idx;
 }
 
-static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
-				unsigned int classzone_idx)
+static void kswapd_try_to_sleep(pg_data_t *pgdat, unsigned int alloc_order,
+			unsigned int reclaim_order, unsigned int classzone_idx)
 {
 	long remaining = 0;
 	DEFINE_WAIT(wait);
@@ -3956,7 +3956,7 @@ static int kswapd(void *p)
  * has failed or is not needed, still wake up kcompactd if only compaction is
  * needed.
  */
-void wakeup_kswapd(struct zone *zone, gfp_t gfp_flags, int order,
+void wakeup_kswapd(struct zone *zone, gfp_t gfp_flags, unsigned int order,
 		   enum zone_type classzone_idx)
 {
 	pg_data_t *pgdat;
-- 
2.21.0

