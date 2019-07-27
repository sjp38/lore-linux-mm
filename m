Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72E93C7618F
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 00:00:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 202DD22BF5
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 00:00:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 202DD22BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A4256B0003; Fri, 26 Jul 2019 20:00:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82DCE8E0003; Fri, 26 Jul 2019 20:00:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CE8E8E0002; Fri, 26 Jul 2019 20:00:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 315EA6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 20:00:09 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j12so29293054pll.14
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 17:00:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=d5MZiXY51oX3ZU/l0ym5m/WRbh2wHwRQJ+E/rEH6FQ4=;
        b=tMYl/CJkSYHIOV+iusTogZnxIMItGNqPaZnwwiqbRa19AKv711QoTroXhhGW9Kj0eR
         iSVGdHYSdlDdxU8i1VfklzucsUACQpFDa7/eS/Ysrm83/0D5bqZHHHtXaCbPazOS4At+
         2vapFZzt3eYaKf0Osa74257j+L4KvYdtdcKS8EH2lXXltpNht065zMofEZoveXuDkaSY
         JSHkxd6yTA5vTRZgJwbKfKnrLCzWsR32W4jXt3sJi1g71tMiWdJgIScen3/+z7o3kGD1
         14MjrK6LQjTX+FxSeCgZovV2y3zy4Kqrphs7lHwc8fARfRV+IzA3PlYuh98xpm3nKDmx
         7hPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAU5bwp55oW1DLl57KtXIZXlFY6Shp4+w/iVOL2/5eU++21d2cTG
	8n6HuIBOl0cBGCRv5lE79KvtDsYGdTHajImf4Vp3uIpDecom+Lzfz3jPUz5t70RsoOZ5SwWJLyy
	LocWpJ06vMWk9G7b6c66My/lKDgvlnfLQQBwrWzITrCKMQKQurzjr3fdb9YYPXKvnbA==
X-Received: by 2002:a17:902:8509:: with SMTP id bj9mr99809476plb.79.1564185608836;
        Fri, 26 Jul 2019 17:00:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1iEhfdoYmb6k+nvrp2U+3Tn9dEyWma70EApfDduwwXjFIAbhO1kU82MzLKzQPWq4gqbLs
X-Received: by 2002:a17:902:8509:: with SMTP id bj9mr99809363plb.79.1564185607529;
        Fri, 26 Jul 2019 17:00:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564185607; cv=none;
        d=google.com; s=arc-20160816;
        b=hBzRSE7/NpezjwezSKUkjQVP9WuBWSQpHjRLpraHRq+V9DyJDYc72KCuK9gYJIjnLw
         9P9bBtFGa/Nq11+CXf7lAJ4GdHwLvdJBIRwKpuWZx+fEs+AdP/JKkf+apTpOGLMwTZ/A
         CpDR7WfzcctpEqYDXAbW0uTaUj1xY3qSre/3tveXGPakQN7VwOSXEKruVeLhStXikskO
         4xpM54zeX6g0miJAol4PNqXfNx9kZbz07/jyIrYJbWL9O4gTOjmXLrE3HhGgnHAbiVZM
         wdrUGU0k9BE1dQ7qQd3/ULKE9yZtokch2U8seX8wi4k6zocu/W67SYaI3DxnDE5Pnoxp
         NwNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=d5MZiXY51oX3ZU/l0ym5m/WRbh2wHwRQJ+E/rEH6FQ4=;
        b=wFdvMa5WjFrSj9/856/IqV82bVDLKaABbFB/AK5thh/RM9JKR1wvFcDDtiN9OXCdui
         MBd+boeZ4J86zrkMXBIcvmk6kV86GRc8EWR+zMWIdqQBviJiIiu6vhXd+ujv6FxMxVFh
         p9UyI4lCDkol+jIm+RoU0pp2ncnYX26fJCig9T+aMrcuadSHhlQ+h2bGiEuBkWk6R18S
         prGpsSQFxZFBZOlMkDd3JJlcK2csXOAzXi/VymvdGJSiyXLxoa8lmPamSYXHEA3XF/b4
         QAItxgH/fnTlS/zPO+k0HI7QWrjy8PSc2FqJT0cv45jmoiwITHkZavbvY3gqUJ9KJQA/
         Dt9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id o4si19905926pgv.157.2019.07.26.17.00.06
        for <linux-mm@kvack.org>;
        Fri, 26 Jul 2019 17:00:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: 2aef6c0802374436a368eb5fb208030d-20190727
X-UUID: 2aef6c0802374436a368eb5fb208030d-20190727
Received: from mtkcas06.mediatek.inc [(172.21.101.30)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 407416634; Sat, 27 Jul 2019 08:00:03 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs06n1.mediatek.inc (172.21.101.129) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Sat, 27 Jul 2019 08:00:03 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Sat, 27 Jul 2019 08:00:03 +0800
From: Miles Chen <miles.chen@mediatek.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
CC: <cgroups@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
	<wsd_upstream@mediatek.com>, Miles Chen <miles.chen@mediatek.com>
Subject: [PATCH v3] mm: memcontrol: fix use after free in mem_cgroup_iter()
Date: Sat, 27 Jul 2019 08:00:02 +0800
Message-ID: <20190727000002.17844-1-miles.chen@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is sent to report an use after free in mem_cgroup_iter()
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

Change since v1:
Add a comment to explain why we need to handle root_mem_cgroup separately.
Rename invalid_root to invalidate_root.

Change since v2:
add fix tag

Fixes: 5ac8fb31ad2e ("mm: memcontrol: convert reclaim iterator to simple css refcounting")
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Miles Chen <miles.chen@mediatek.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 38 ++++++++++++++++++++++++++++----------
 1 file changed, 28 insertions(+), 10 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index cdbb7a84cb6e..7d079e862646 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1130,26 +1130,44 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
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
 
+/*
+ * When cgruop1 non-hierarchy mode is used, parent_mem_cgroup() does
+ * not walk all the way up to the cgroup root (root_mem_cgroup). So
+ * we have to handle dead_memcg from cgroup root separately.
+ */
+static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
+{
+	struct mem_cgroup *memcg = dead_memcg;
+	int invalidate_root = 0;
+
+	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
+		__invalidate_reclaim_iterators(memcg, dead_memcg);
+		if (memcg == root_mem_cgroup)
+			invalidate_root = 1;
+	}
+
+	if (!invalidate_root)
+		__invalidate_reclaim_iterators(root_mem_cgroup, dead_memcg);
+}
+
 /**
  * mem_cgroup_scan_tasks - iterate over tasks of a memory cgroup hierarchy
  * @memcg: hierarchy root
-- 
2.18.0

