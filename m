Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 590DCC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2822822DBF
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 09:49:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2822822DBF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B19B46B000D; Tue, 20 Aug 2019 05:49:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA3C06B000C; Tue, 20 Aug 2019 05:49:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F7D16B0010; Tue, 20 Aug 2019 05:49:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0097.hostedemail.com [216.40.44.97])
	by kanga.kvack.org (Postfix) with ESMTP id 6884D6B000C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 05:49:40 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 03F768248AB7
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:40 +0000 (UTC)
X-FDA: 75842334120.05.ducks15_544a095b41032
X-HE-Tag: ducks15_544a095b41032
X-Filterd-Recvd-Size: 4893
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com [47.88.44.36])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:49:38 +0000 (UTC)
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R301e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=alex.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0Ta-6uiR_1566294572;
Received: from localhost(mailfrom:alex.shi@linux.alibaba.com fp:SMTPD_---0Ta-6uiR_1566294572)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 20 Aug 2019 17:49:32 +0800
From: Alex Shi <alex.shi@linux.alibaba.com>
To: cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tejun Heo <tj@kernel.org>
Cc: Alex Shi <alex.shi@linux.alibaba.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Chris Down <chris@chrisdown.name>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH 02/14] lru/memcg: move the lruvec->pgdat sync out lru_lock
Date: Tue, 20 Aug 2019 17:48:25 +0800
Message-Id: <1566294517-86418-3-git-send-email-alex.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
References: <1566294517-86418-1-git-send-email-alex.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We are going to move lruvec getting out of lru_lock, the only unsafe
part is lruvec->pgdat syncing when memory node hot pluging.

Splitting out the lruvec->pgdat assignment now and will put it in
lruvec lru_lock protection.

No function changes in this patch now.

Signed-off-by: Alex Shi <alex.shi@linux.alibaba.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Chris Down <chris@chrisdown.name>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/linux/memcontrol.h | 24 +++++++++++++++++-------
 mm/memcontrol.c            |  8 +-------
 2 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 2cd4359cb38c..95b3d9885ab6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -359,6 +359,17 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
 	return memcg->nodeinfo[nid];
 }
 
+static void sync_lruvec_pgdat(struct lruvec *lruvec, struct pglist_data *pgdat)
+{
+	/*
+	 * Since a node can be onlined after the mem_cgroup was created,
+	 * we have to be prepared to initialize lruvec->pgdat here;
+	 * and if offlined then reonlined, we need to reinitialize it.
+	 */
+	if (!mem_cgroup_disabled() && unlikely(lruvec->pgdat != pgdat))
+		lruvec->pgdat = pgdat;
+}
+
 /**
  * mem_cgroup_lruvec - get the lru list vector for a node or a memcg zone
  * @node: node of the wanted lruvec
@@ -382,13 +393,7 @@ static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
 	mz = mem_cgroup_nodeinfo(memcg, pgdat->node_id);
 	lruvec = &mz->lruvec;
 out:
-	/*
-	 * Since a node can be onlined after the mem_cgroup was created,
-	 * we have to be prepared to initialize lruvec->pgdat here;
-	 * and if offlined then reonlined, we need to reinitialize it.
-	 */
-	if (unlikely(lruvec->pgdat != pgdat))
-		lruvec->pgdat = pgdat;
+	sync_lruvec_pgdat(lruvec, pgdat);
 	return lruvec;
 }
 
@@ -857,6 +862,11 @@ static inline void mem_cgroup_migrate(struct page *old, struct page *new)
 {
 }
 
+static inline void sync_lruvec_pgdat(struct lruvec *lruvec,
+						struct pglist_data *pgdat)
+{
+}
+
 static inline struct lruvec *mem_cgroup_lruvec(struct pglist_data *pgdat,
 				struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2792b8ed405f..e8a1b0d95ba8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1257,13 +1257,7 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgd
 	mz = mem_cgroup_page_nodeinfo(memcg, page);
 	lruvec = &mz->lruvec;
 out:
-	/*
-	 * Since a node can be onlined after the mem_cgroup was created,
-	 * we have to be prepared to initialize lruvec->zone here;
-	 * and if offlined then reonlined, we need to reinitialize it.
-	 */
-	if (unlikely(lruvec->pgdat != pgdat))
-		lruvec->pgdat = pgdat;
+	sync_lruvec_pgdat(lruvec, pgdat);
 	return lruvec;
 }
 
-- 
1.8.3.1


