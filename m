Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47075C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFC2521734
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 14:54:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFC2521734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 881D06B0269; Thu, 25 Jul 2019 10:54:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 831AE6B026A; Thu, 25 Jul 2019 10:54:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D3978E0002; Thu, 25 Jul 2019 10:54:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42C806B0269
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:54:18 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id l5so19692540oih.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:54:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=Uh4RfgIrY/7DK7JMTFfUymv3qRNsq/JZPjUXpmohIQc=;
        b=WeQIOCZ2hkqr0kR5EUxe5qyHHcl1tTEGbpeU0kHVIyycrH610eVE13HgthwE/HOa+i
         slQITM/ke05DX8+p4hFVmpzFQnUrrlgZUJ687N9rtLSQ1Sg/EZ2sbG5x4b2CdBstRKgR
         1/YfRh7P23pc7ZNWLvmz3l12TX2fL/NknltJK/1VFnX2iQ21PgEIdbav/yuginvQfMu/
         rGPPX8OKr6ROPbfl98ntaKAz77g2GCJOHjF/BkBHSjsN9v/TZMIHOhVfI9GjzyL0C5Lu
         cUZYBFBHm9cMcknQ6Jerfxq/361GlM7NVHA9Dmnkxg9y1jcOf3rRk/cq1Ol7S5N6fZjB
         cIvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 216.200.240.185 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAWQLorhUT3eaQOD7xpd9BmOTapwjI9jOwMX0nnVFUyw2E3mAMZv
	Q75oE0Sxs2Y2SryYi6zXS68IqJvnkxKVcvzX07NVk/bd5w8AiiY8WESYeKwIylHWka+6PBEq9RA
	0YqKxNbBqQ5BRFAgJN9ujOuD+EmdvlSFGxeHWuw8ZfjAuP7KANDTcVHmm0Hk6SQh9dg==
X-Received: by 2002:a54:4813:: with SMTP id j19mr18067565oij.34.1564066457843;
        Thu, 25 Jul 2019 07:54:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqxnuXo5q8EPjQAQSFt35FOHL5Gnmi6S0s/kOLBhaCi12emGg88f0bBmpTtS8Rz1UkDo63
X-Received: by 2002:a54:4813:: with SMTP id j19mr18067521oij.34.1564066456727;
        Thu, 25 Jul 2019 07:54:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564066456; cv=none;
        d=google.com; s=arc-20160816;
        b=0vwJFUpMfQpQWFf0t/I+9jV0T9UPPbJScdj3xh/yZGOlqVhF342gwUH6YlP94gHg+N
         0JvmJ1OGKm1irqNjRbfF89aixKGfmelGnu+fDPfFrZgQ2RKMFgmIFeWNagFfeJmA8RAJ
         peqJVJlcpXBg1EC81ojZ644Nis6tiqT6HGXAS80snRywgTe2ZAmMswdq2P6Y0cP/EJeW
         zT0tlRUtaPfbKELHvRUQEmsfI5yHAkjRR7llwjquYMFxFZKsD9MZHmUPtRxYnPXR3Lba
         nk4sJn/IHb+PB4wiWj+pzq4El/lrFzJ0m5NjTzXzR25uRGEGogJHx33Lc4YPRlZS+QKF
         roEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=Uh4RfgIrY/7DK7JMTFfUymv3qRNsq/JZPjUXpmohIQc=;
        b=dqVuoZD7Ugs8EZ+ABypXHq5x+UfDPGNWezNlB57wYcB4hLQmDaYAE3D1fPiKrst7Zz
         3dsTFWwzQ9op2aJSPZ1xe8w2FlMccnaVp3sHP22vQOEmGneZMhGzlFBhR1nY+1EHw8Bk
         JGzVCZEbNHE/INhEruZetl9QyK41i3u1jeO3PGse8Ug6XligPwdDK1fkYm3Pv3Y25RDC
         ziKSUZV72WID196FHjHSN1hLHKSA19RHINiXRHTIAyCnynXpCuGgVqvhACLzvBfQ+hYQ
         xNd/5M3/6u/2q+KvNzoRjlQaAnkowgReuMZashsdJV+GMVQfasCm46+Dw+GCf+EaEsMq
         YdTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 216.200.240.185 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw02.mediatek.com (mailgw02.mediatek.com. [216.200.240.185])
        by mx.google.com with ESMTPS id r26si31907723otp.85.2019.07.25.07.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 07:54:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 216.200.240.185 as permitted sender) client-ip=216.200.240.185;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 216.200.240.185 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: 68c8c96cfe82444895fc582f3966f561-20190725
X-UUID: 68c8c96cfe82444895fc582f3966f561-20190725
Received: from mtkexhb01.mediatek.inc [(172.21.101.102)] by mailgw02.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(musrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1017426763; Thu, 25 Jul 2019 06:53:06 -0800
Received: from MTKCAS06.mediatek.inc (172.21.101.30) by
 mtkmbs06n2.mediatek.inc (172.21.101.130) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Thu, 25 Jul 2019 22:27:04 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by MTKCAS06.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Thu, 25 Jul 2019 22:27:04 +0800
From: <miles.chen@mediatek.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
CC: <cgroups@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <wsd_upstream@mediatek.com>,
	<linux-mediatek@lists.infradead.org>, Miles Chen <miles.chen@mediatek.com>
Subject: [RFC PATCH] mm: memcontrol: fix use after free in mem_cgroup_iter()
Date: Thu, 25 Jul 2019 22:27:03 +0800
Message-ID: <20190725142703.27276-1-miles.chen@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-TM-SNTS-SMTP:
	BA133858E120E853044F975DFC7A41746A406CCD8C5E6AAF83D767E759F686B22000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Miles Chen <miles.chen@mediatek.com>

This RFC patch is sent to report an use after free in mem_cgroup_iter()
after merging commit: be2657752e9e "mm: memcg: fix use after free in
mem_cgroup_iter()".

I work with android kernel tree (4.9 & 4.14), and the commit:
be2657752e9e "mm: memcg: fix use after free in mem_cgroup_iter()" has
been merged to the trees. However, I can still observe use after free
issues addressed in the commit be2657752e9e.
(on low-end devices, a few times this month)

backtrace:
	css_tryget <- crash here
	mem_cgroup_iter
	shrink_node
	shrink_zones
	do_try_to_free_pages
	try_to_free_pages
	__perform_reclaim
	__alloc_pages_direct_reclaim
	__alloc_pages_slowpath
	__alloc_pages_nodemask

To debug, I poisoned mem_cgroup before freeing it:

static void __mem_cgroup_free(struct mem_cgroup *memcg)
	for_each_node(node)
	free_mem_cgroup_per_node_info(memcg, node);
	free_percpu(memcg->stat);
+       /* poison memcg before freeing it */
+       memset(memcg, 0x78, sizeof(struct mem_cgroup));
	kfree(memcg);
}

The coredump shows the position=0xdbbc2a00 is freed.

(gdb) p/x ((struct mem_cgroup_per_node *)0xe5009e00)->iter[8]
$13 = {position = 0xdbbc2a00, generation = 0x2efd}

0xdbbc2a00:     0xdbbc2e00      0x00000000      0xdbbc2800      0x00000100
0xdbbc2a10:     0x00000200      0x78787878      0x00026218      0x00000000
0xdbbc2a20:     0xdcad6000      0x00000001      0x78787800      0x00000000
0xdbbc2a30:     0x78780000      0x00000000      0x0068fb84      0x78787878
0xdbbc2a40:     0x78787878      0x78787878      0x78787878      0xe3fa5cc0
0xdbbc2a50:     0x78787878      0x78787878      0x00000000      0x00000000
0xdbbc2a60:     0x00000000      0x00000000      0x00000000      0x00000000
0xdbbc2a70:     0x00000000      0x00000000      0x00000000      0x00000000
0xdbbc2a80:     0x00000000      0x00000000      0x00000000      0x00000000
0xdbbc2a90:     0x00000001      0x00000000      0x00000000      0x00100000
0xdbbc2aa0:     0x00000001      0xdbbc2ac8      0x00000000      0x00000000
0xdbbc2ab0:     0x00000000      0x00000000      0x00000000      0x00000000
0xdbbc2ac0:     0x00000000      0x00000000      0xe5b02618      0x00001000
0xdbbc2ad0:     0x00000000      0x78787878      0x78787878      0x78787878
0xdbbc2ae0:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2af0:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b00:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b10:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b20:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b30:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b40:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b50:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b60:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b70:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2b80:     0x78787878      0x78787878      0x00000000      0x78787878
0xdbbc2b90:     0x78787878      0x78787878      0x78787878      0x78787878
0xdbbc2ba0:     0x78787878      0x78787878      0x78787878      0x78787878

In the reclaim path, try_to_free_pages() does not setup
sc.target_mem_cgroup and sc is passed to do_try_to_free_pages(), ...,
shrink_node().

In mem_cgroup_iter(), root is set to root_mem_cgroup because
sc->target_mem_cgroup is NULL.
It is possible to assign a memcg to root_mem_cgroup.nodeinfo.iter in
mem_cgroup_iter().

	try_to_free_pages
		struct scan_control sc = {...}, target_mem_cgroup is 0x0;
	do_try_to_free_pages
	shrink_zones
	shrink_node
		 mem_cgroup *root = sc->target_mem_cgroup;
		 memcg = mem_cgroup_iter(root, NULL, &reclaim);
	mem_cgroup_iter()
		if (!root)
			root = root_mem_cgroup;
		...

		css = css_next_descendant_pre(css, &root->css);
		memcg = mem_cgroup_from_css(css);
		cmpxchg(&iter->position, pos, memcg);

My device uses memcg non-hierarchical mode.
When we release a memcg: invalidate_reclaim_iterators() reaches only
dead_memcg and its parents. If non-hierarchical mode is used,
invalidate_reclaim_iterators() never reaches root_mem_cgroup.

static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
{
	struct mem_cgroup *memcg = dead_memcg;

	for (; memcg; memcg = parent_mem_cgroup(memcg)
	...
}

So the use after free scenario looks like:

CPU1						CPU2

try_to_free_pages
do_try_to_free_pages
shrink_zones
shrink_node
mem_cgroup_iter()
    if (!root)
    	root = root_mem_cgroup;
    ...
    css = css_next_descendant_pre(css, &root->css);
    memcg = mem_cgroup_from_css(css);
    cmpxchg(&iter->position, pos, memcg);

					invalidate_reclaim_iterators(memcg);
					...
					__mem_cgroup_free()
						kfree(memcg);

try_to_free_pages
do_try_to_free_pages
shrink_zones
shrink_node
mem_cgroup_iter()
    if (!root)
    	root = root_mem_cgroup;
    ...
    mz = mem_cgroup_nodeinfo(root, reclaim->pgdat->node_id);
    iter = &mz->iter[reclaim->priority];
    pos = READ_ONCE(iter->position);
    css_tryget(&pos->css) <- use after free

To avoid this, we should also invalidate root_mem_cgroup.nodeinfo.iter in
invalidate_reclaim_iterators().

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/memcontrol.c | 33 +++++++++++++++++++++++----------
 1 file changed, 23 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdbb7a84cb6e..578b02982c9a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1130,26 +1130,39 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
 		css_put(&prev->css);
 }
 
-static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
+static void __invalidate_reclaim_iterators(struct mem_cgroup *from,
+					struct mem_cgroup *dead_memcg)
 {
-	struct mem_cgroup *memcg = dead_memcg;
 	struct mem_cgroup_reclaim_iter *iter;
 	struct mem_cgroup_per_node *mz;
 	int nid;
 	int i;
 
-	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
-		for_each_node(nid) {
-			mz = mem_cgroup_nodeinfo(memcg, nid);
-			for (i = 0; i <= DEF_PRIORITY; i++) {
-				iter = &mz->iter[i];
-				cmpxchg(&iter->position,
-					dead_memcg, NULL);
-			}
+	for_each_node(nid) {
+		mz = mem_cgroup_nodeinfo(from, nid);
+		for (i = 0; i <= DEF_PRIORITY; i++) {
+			iter = &mz->iter[i];
+			cmpxchg(&iter->position,
+				dead_memcg, NULL);
 		}
 	}
 }
 
+static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
+{
+	struct mem_cgroup *memcg = dead_memcg;
+	int invalid_root = 0;
+
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		__invalidate_reclaim_iterators(memcg, dead_memcg);
+		if (memcg == root_mem_cgroup)
+			invalid_root = 1;
+	}
+
+	if (!invalid_root)
+		__invalidate_reclaim_iterators(root_mem_cgroup, dead_memcg);
+}
+
 /**
  * mem_cgroup_scan_tasks - iterate over tasks of a memory cgroup hierarchy
  * @memcg: hierarchy root
-- 
2.18.0

