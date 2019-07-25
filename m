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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98013C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52E552190F
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 18:44:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vUtykOa0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52E552190F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00C866B000D; Thu, 25 Jul 2019 14:44:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFEB66B000E; Thu, 25 Jul 2019 14:44:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA0CF6B0010; Thu, 25 Jul 2019 14:44:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A611D6B000D
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 14:44:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id w5so31254256pgs.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 11:44:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=abO8zis5qyQ9jMy/dQEIxCIeoB176hkWi+GQror9w/4=;
        b=EsUbPu1QBTAqkiwNJj2Ejy1AuJZpMHGFPnVT0mM66uivBkoyqi3bLdP/YrbcsT2CJh
         BXk2nYlVrZC7BrdSfRx98/uf0/jAmydLlRm1io2RopWfqWsHaKwDKO79aP2RPeJlb8VK
         ZprWbjvpaxARETLkHhZkToLZf7EmGxobF5E3RI+J7JnYwc39Lrtw6pjMDzHW9vhewEWy
         xvxIqtq49jljZ/yCXhHHlcRxoDmNhbqnUBKy2vCajO1RSJoB/OTHkSaToUvWXpPjMyRv
         Q/X5UhNTfWYvjdMtsOjoZcIDU/XwqxKIXj/x2FvBfzz0eaiTKgnRR7h79FjKDmx3lXNr
         pNiw==
X-Gm-Message-State: APjAAAXloX7zkzA8bhjEu0d43YsMnT0hn4//DAzSBr9mb7hIorydeT5w
	tFLGQKaVExpAT7LgHCWOHZJPGUZXqVkDjQwFiS1fjIqFb8M9NeihVN2W3iJeHKofMOTYfGEDQyj
	B+0SkuWJpfsMgG1kyfOR38Piqca7nTq5WKf5B2LXsK9SLkvE9PMEDnED6R/r3T/YRIg==
X-Received: by 2002:a62:1a8e:: with SMTP id a136mr17799440pfa.22.1564080262365;
        Thu, 25 Jul 2019 11:44:22 -0700 (PDT)
X-Received: by 2002:a62:1a8e:: with SMTP id a136mr17799379pfa.22.1564080261107;
        Thu, 25 Jul 2019 11:44:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564080261; cv=none;
        d=google.com; s=arc-20160816;
        b=wR6PsTrH5Rt49HIDboQKV8JBLR/Z4NnWj/yRgI/lWTwIGW/idd7PRGHn6vBFyxRfmN
         DSj8FA5YUVm6J+NB5E0sIku+5ZjI6EbXrCq5VbtkOGdm9/ZwqUIgy1uc/Ki5wq6dwJpa
         W0r/fB4jBmMdKOlZujuoGi2PVOA+DOHvPhbs5t4cec+mg5Ir4e7WHw0TTvqP5bVELJgL
         3iuK+/duurfViMmtHXQuLguCGcI1XnIC1tgh7hGhVFbWPJI1SjxPuD0XyhSLb8T+lcmn
         YUJrDK7qVd/8glCXPeIsVKsQNyOCMOD9r2iZmOLl3lGkvo7VcO05/bkHKPwC6Qx/tuNN
         axRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=abO8zis5qyQ9jMy/dQEIxCIeoB176hkWi+GQror9w/4=;
        b=XfgsXv+VFR/WUEm7mMs3eBdaJ4Cde7p2GQU3phyZBlVU8tWFiHpsU32ThqxV7tzyLg
         u4ge2PXNMiAJUxnkD3IxtmwGhJWno89a8HVOB380zWQkq9HeHXZ7TpEXppChyw29Gr+3
         vqqgA/Hy/oGNL/6RDEBe03dvq8VO/prlbVjNKGhIVRz87WEtC4ciDy1aFRGT6Bd2L1Yf
         3Ma0++BOG4rbc6rNpDQZwdIYEnL+YZVdgD7JE/i74GCEcZNXNIP3DFJrN3tPvNx2Uapj
         yQdbgRf8QBmrY6Hik1CT+F3YciU4sVNUfOb8sYVhIKfzoXs3VAaOR5FVygTwBOSTENg7
         0Tpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vUtykOa0;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13sor7411520pgi.71.2019.07.25.11.44.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 11:44:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vUtykOa0;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=abO8zis5qyQ9jMy/dQEIxCIeoB176hkWi+GQror9w/4=;
        b=vUtykOa02Pa10uCbtLnoIvcUdFu3JThtZDgo7uW93gVBQuQ6Dc6mKJH4uPVqsVU8sm
         i3zJWEzbfjRWgBmpct25rX/J1WFFmQve2ve4ubTiw18sLQ4FYkdeyrDOw+4/zgtp8BH5
         9jCeL2BIcDFv+r5lDJ3aWMEFu1UqN2LoN7OvZ9e+t0kt5VAG7L4hRS2R22GRIai/hOwX
         pezFLT9P8x3g0sId1DVpAF21XwTxPKS15UmJxeL38Jn92SA8bD7OsQy0F/vXKuA4OIQ3
         IZ/5y9xvKWRRRKi9FOiV7vi5XrTFGoMZHdYAwycNVE6aGnoWCpR2Et1Uy8LS72Xkrzup
         tjEg==
X-Google-Smtp-Source: APXvYqwJOb28TKf+TbxnRmxPgCBkeIkNDYkj3cI7IIoSwn/D3InHcQUxaF6kTZhxG3DdTaQjTi0y/A==
X-Received: by 2002:a63:f13:: with SMTP id e19mr87244311pgl.132.1564080260681;
        Thu, 25 Jul 2019 11:44:20 -0700 (PDT)
Received: from localhost.localdomain.localdomain ([2408:823c:c11:624:b8c3:8577:bf2f:3])
        by smtp.gmail.com with ESMTPSA id w3sm43818257pgl.31.2019.07.25.11.44.12
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 11:44:20 -0700 (PDT)
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
Subject: [PATCH 06/10] mm/compaction: make "order" unsigned int in compaction.c
Date: Fri, 26 Jul 2019 02:42:49 +0800
Message-Id: <20190725184253.21160-7-lpf.vector@gmail.com>
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

Since compact_control->order and compact_control->search_order
have been modified to unsigned int in the previous commit, then
some of the functions in compaction.c are modified accordingly.

Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
---
 include/linux/compaction.h | 12 ++++++------
 mm/compaction.c            | 21 ++++++++++-----------
 2 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 9569e7c786d3..0201dfa57d44 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -96,8 +96,8 @@ extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
 		const struct alloc_context *ac, enum compact_priority prio,
 		struct page **page);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
-extern enum compact_result compaction_suitable(struct zone *zone, int order,
-		unsigned int alloc_flags, int classzone_idx);
+extern enum compact_result compaction_suitable(struct zone *zone,
+	unsigned int order, unsigned int alloc_flags, int classzone_idx);
 
 extern void defer_compaction(struct zone *zone, int order);
 extern bool compaction_deferred(struct zone *zone, int order);
@@ -170,8 +170,8 @@ static inline bool compaction_withdrawn(enum compact_result result)
 }
 
 
-bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
-					int alloc_flags);
+bool compaction_zonelist_suitable(struct alloc_context *ac,
+				unsigned int order, int alloc_flags);
 
 extern int kcompactd_run(int nid);
 extern void kcompactd_stop(int nid);
@@ -182,8 +182,8 @@ static inline void reset_isolation_suitable(pg_data_t *pgdat)
 {
 }
 
-static inline enum compact_result compaction_suitable(struct zone *zone, int order,
-					int alloc_flags, int classzone_idx)
+static inline enum compact_result compaction_suitable(struct zone *zone,
+		unsigned int order, int alloc_flags, int classzone_idx)
 {
 	return COMPACT_SKIPPED;
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index e47d8fa943a6..ac5df82d46e0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1639,7 +1639,7 @@ static unsigned long fast_find_migrateblock(struct compact_control *cc)
 	unsigned long distance;
 	unsigned long pfn = cc->migrate_pfn;
 	unsigned long high_pfn;
-	int order;
+	unsigned int order;
 
 	/* Skip hints are relied on to avoid repeats on the fast search */
 	if (cc->ignore_skip_hint)
@@ -1958,10 +1958,9 @@ static enum compact_result compact_finished(struct compact_control *cc)
  *   COMPACT_SUCCESS  - If the allocation would succeed without compaction
  *   COMPACT_CONTINUE - If compaction should run now
  */
-static enum compact_result __compaction_suitable(struct zone *zone, int order,
-					unsigned int alloc_flags,
-					int classzone_idx,
-					unsigned long wmark_target)
+static enum compact_result __compaction_suitable(struct zone *zone,
+		unsigned int order, unsigned int alloc_flags,
+		int classzone_idx, unsigned long wmark_target)
 {
 	unsigned long watermark;
 
@@ -1998,7 +1997,7 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	return COMPACT_CONTINUE;
 }
 
-enum compact_result compaction_suitable(struct zone *zone, int order,
+enum compact_result compaction_suitable(struct zone *zone, unsigned int order,
 					unsigned int alloc_flags,
 					int classzone_idx)
 {
@@ -2036,7 +2035,7 @@ enum compact_result compaction_suitable(struct zone *zone, int order,
 	return ret;
 }
 
-bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
+bool compaction_zonelist_suitable(struct alloc_context *ac, unsigned int order,
 		int alloc_flags)
 {
 	struct zone *zone;
@@ -2278,10 +2277,10 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 	return ret;
 }
 
-static enum compact_result compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum compact_priority prio,
-		unsigned int alloc_flags, int classzone_idx,
-		struct page **capture)
+static enum compact_result compact_zone_order(struct zone *zone,
+		unsigned int order, gfp_t gfp_mask,
+		enum compact_priority prio, unsigned int alloc_flags,
+		int classzone_idx, struct page **capture)
 {
 	enum compact_result ret;
 	struct compact_control cc = {
-- 
2.21.0

