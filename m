Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09B28C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9802620820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:02:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="kHdvF9pN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="muwx5J5m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9802620820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D7596B0277; Wed,  3 Apr 2019 22:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B12F6B0278; Wed,  3 Apr 2019 22:01:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 252C36B0279; Wed,  3 Apr 2019 22:01:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0A7C6B0277
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:46 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id m8so932715qka.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=bogrl8ykXE3AE9N3lxqf7+kaVmqboUoXMwOaBKi4kwI=;
        b=X7hfYsD5Yjq0uiG1H/U0J4PfR3WK5CmlhEJZmxHspmQDku60/1Ux3sW4c/6v8AaXN2
         fL570akptrclKRJDaNN0sOP1o+Im4lIXTv/1dUhj2iUP4CgBgCPLTJYThBlbaILxmL8R
         Vw+nPq42/BPxHRv+AKiz/4P5zPe7/YPQ2hueIYSR1rTJq1jAkOrbGjAwmvnwCQz0yaGV
         TZsBTFWrKzkIFMIYYtYy8KS3zhCizWFjZ2p9o8BP421lvTuDw7uYGdLH44EQXG+s+WAs
         jxjh/2bp1nWgnJnSG9ldv+VJVkhlKwi7yD7D5D1Pi7/oDkw7RCvTl4fzd76ETjY8jrNs
         cvjg==
X-Gm-Message-State: APjAAAXVd5pqcCFnVzlLdCIzwXz3gth9hxyB4qwAzasBl7bx19EtJ2Th
	5khGvoQTDfu26f/BKnrLy3BxVKauqF0x20DWZEknPXPoFwbd1SHl2epFye0XP9HTVb3vCQt/SWD
	Nynso84798KvXHHfaZXigf9BhbFzg+Biq9d94hUhjRf1e3k3pYOEQgWS9fhEMvRBmLA==
X-Received: by 2002:aed:3b62:: with SMTP id q31mr3013786qte.82.1554343306739;
        Wed, 03 Apr 2019 19:01:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNuYjuImayzQjueuTij0uIpO778FuyxEfX2dDrdCnkquUe/o3SUTPHIhM614tCBF5FVRyp
X-Received: by 2002:aed:3b62:: with SMTP id q31mr3013734qte.82.1554343305959;
        Wed, 03 Apr 2019 19:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343305; cv=none;
        d=google.com; s=arc-20160816;
        b=Am04fkMvmAhsSIPyOVxCI/ydWcD5U9r7N3fnETK1/c5ieOGEtIvG3hiOug8A67mc1s
         S3/7Zzxu3wVSdeSpQyRsrRjfgKUZNLlFaoJCtuJPGKeBfySAFARq7vY2lLmXuyfPFbE5
         U3NSf9p/YUlZKIFlqQiSg+A4SBaGLHVGtxynWs7Maenv9EXqHLSxylMiukXbhJ8ScEqH
         bmpgLuDhILv2TXZHJNlGoTGfPd/3ov7aXz046l0OjCGIkifuUuxRugQIGrx3lCvfliWB
         uXVAZy4FShPIZ+mJrCuq8jEMlKsIQfu5IEo2AlSSQZjJKPr2XjlX8EshbmU6BnDL7ULT
         ZToQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=bogrl8ykXE3AE9N3lxqf7+kaVmqboUoXMwOaBKi4kwI=;
        b=ANuButLncynQTaKM6igkU/gjH6Wh27AFLwyBnr6FxwrsSeoXEnNDroWGlVrxcmHT5d
         cSjcHcpOetEP4CMRFEUf/SEp1iz/iS1Pc3WHiournxv8xn8jvpm3maV88R/ut8qj4Cbi
         0VJinZwjuDe/4MN24xZ6a72YpgD0Mo89+i2xVHjpDYWZV4M5x0tskuZYbqLEgFk6MV2V
         aPV91dmQpQI5GtFz18/ZbJEpIQM18UuSzu0xPwfmhPFes9NIYFEy95n1e4DCE/U9mV5H
         uNAHMx9roTn+BkCRIqV8V47FOSv2/kujlESaBEdplVkwpmX6eEIMq+dcm7n4J7fvhkKq
         qFWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=kHdvF9pN;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=muwx5J5m;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id r7si1758323qke.34.2019.04.03.19.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=kHdvF9pN;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=muwx5J5m;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id A7A9D228BA;
	Wed,  3 Apr 2019 22:01:45 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=bogrl8ykXE3AE
	9N3lxqf7+kaVmqboUoXMwOaBKi4kwI=; b=kHdvF9pNWcw8D8b8/t/kv8mKy+ArM
	dg62fTqmQKSItiP6KA8Vwk35fnN/5YjdeJl3B6KUd7eTC/44vtAzvWx6+U+A6P4X
	Piy2T6tLbpFFwvQ2a+hjWkv7JxOSb3ASu/brFlmlG25yt/ggco4UjZ0r0ZyOI67S
	ElbA4KNk3VnvoJiER8XoetoJ1c8TnScHn8u4vfIovZovy+2iI437NaUZRPfhB5eR
	uyHiLxigKLp4sKsJEHX9L2eZYqI0HSZ4xleKLKbRdexU3Yjb8nlHav1EKRYvV1H8
	el5AC2pwrLUpjoi2D0HLOyaMF/whe2L9GoIA9+WHf8Jlz6WMIEXvp2e1w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=bogrl8ykXE3AE9N3lxqf7+kaVmqboUoXMwOaBKi4kwI=; b=muwx5J5m
	gMAQYmtcbAweMtV01l1pPYxfGsXWSAAJLKYJxEBbotutU98jcz+0Tg/k8yGEgEYA
	8LClxo10euoBJ8Y0ZNiglPT9zpe0Ey4c3ztZJ91rFOzgjR88n6xGNFMjyNuKgmlq
	qNSkfJPXkAZtYav7jjUYgyhgBx9SU4WeK+VY+bB+DhCzq574mFK3E29FJJ+HB3Dd
	/a73q69lHQO66YxPnncSr7j/XIAvs602pTfDQNiQK35gcPc18+qIhkLsZkdYLm9S
	vYLVnDBAqbX4eM6pQ5ZFHxvCUImu4cajiwkt5yFije7ipZXkBXsYB4xvnXKkcHA4
	IrTV2gn+rhDmxg==
X-ME-Sender: <xms:iWWlXD-YuOXTjzAJ1ccCNATl3kvH47tsdIovXsrPgw3wtouIJTtb1w>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepudej
X-ME-Proxy: <xmx:iWWlXCARb0FZvIxhcRN1bQQAff_ydbcPvtQHs_yo9HjWSlnaSpjU2g>
    <xmx:iWWlXPtnAEyQ2x2UQyBFCqD3jwjNbRf6ZzqiiJFMm6_hHf9svqx0xw>
    <xmx:iWWlXMbdKLicKAyVSHbL6l33Tchuh8AhAmV1_NJfs9q5CUTVt6oTUQ>
    <xmx:iWWlXFWNznFnfHdMmp5vwO9J09zND2pNp8DD5ujIc1JzW8SCVoJs6w>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id B84C610319;
	Wed,  3 Apr 2019 22:01:43 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 18/25] memcg: Add per node memory usage&max stats in memcg.
Date: Wed,  3 Apr 2019 19:00:39 -0700
Message-Id: <20190404020046.32741-19-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

It prepares for the following patches to enable memcg-based NUMA
node page migration. We are going to limit memory usage in each node
on a per-memcg basis.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 include/linux/cgroup-defs.h |  1 +
 include/linux/memcontrol.h  | 67 +++++++++++++++++++++++++++++++++++++
 mm/memcontrol.c             | 80 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 148 insertions(+)

diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 1c70803..7e87f5e 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -531,6 +531,7 @@ struct cftype {
 	struct cgroup_subsys *ss;	/* NULL for cgroup core files */
 	struct list_head node;		/* anchored at ss->cfts */
 	struct kernfs_ops *kf_ops;
+	int numa_node_id;
 
 	int (*open)(struct kernfs_open_file *of);
 	void (*release)(struct kernfs_open_file *of);
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1f3d880..3e40321 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -130,6 +130,7 @@ struct mem_cgroup_per_node {
 	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
 
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
+	unsigned long		max_nr_base_pages;
 
 	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
 
@@ -797,6 +798,51 @@ static inline void memcg_memory_event_mm(struct mm_struct *mm,
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
+static inline unsigned long lruvec_size_memcg_node(enum lru_list lru,
+	struct mem_cgroup *memcg, int nid)
+{
+	if (nid == MAX_NUMNODES)
+		return 0;
+
+	VM_BUG_ON(lru < 0 || lru >= NR_LRU_LISTS);
+	return mem_cgroup_node_nr_lru_pages(memcg, nid, BIT(lru));
+}
+
+static inline unsigned long active_inactive_size_memcg_node(struct mem_cgroup *memcg, int nid, bool active)
+{
+	unsigned long val = 0;
+	enum lru_list lru;
+
+	for_each_evictable_lru(lru) {
+		if ((active  && is_active_lru(lru)) ||
+			(!active && !is_active_lru(lru)))
+			val += mem_cgroup_node_nr_lru_pages(memcg, nid, BIT(lru));
+	}
+
+	return val;
+}
+
+static inline unsigned long memcg_size_node(struct mem_cgroup *memcg, int nid)
+{
+	unsigned long val = 0;
+	int i;
+
+	if (nid == MAX_NUMNODES)
+		return val;
+
+	for (i = 0; i < NR_LRU_LISTS; i++)
+		val += mem_cgroup_node_nr_lru_pages(memcg, nid, BIT(i));
+
+	return val;
+}
+
+static inline unsigned long memcg_max_size_node(struct mem_cgroup *memcg, int nid)
+{
+	if (nid == MAX_NUMNODES)
+		return 0;
+	return memcg->nodeinfo[nid]->max_nr_base_pages;
+}
+
 #else /* CONFIG_MEMCG */
 
 #define MEM_CGROUP_ID_SHIFT	0
@@ -1123,6 +1169,27 @@ static inline
 void count_memcg_event_mm(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline unsigned long lruvec_size_memcg_node(enum lru_list lru,
+	struct mem_cgroup *memcg, int nid)
+{
+	return 0;
+}
+
+static inline unsigned long active_inactive_size_memcg_node(struct mem_cgroup *memcg, int nid, bool active)
+{
+	return 0;
+}
+
+static inline unsigned long memcg_size_node(struct mem_cgroup *memcg, int nid)
+{
+	return 0;
+}
+static inline unsigned long memcg_max_size_node(struct mem_cgroup *memcg, int nid)
+{
+	return 0;
+}
+
 #endif /* CONFIG_MEMCG */
 
 /* idx can be of type enum memcg_stat_item or node_stat_item */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 532e0e2..478d216 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4394,6 +4394,7 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
 	pn->usage_in_excess = 0;
 	pn->on_tree = false;
 	pn->memcg = memcg;
+	pn->max_nr_base_pages = PAGE_COUNTER_MAX;
 
 	memcg->nodeinfo[node] = pn;
 	return 0;
@@ -6700,4 +6701,83 @@ static int __init mem_cgroup_swap_init(void)
 }
 subsys_initcall(mem_cgroup_swap_init);
 
+static int memory_per_node_stat_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct cftype *cur_file = seq_cft(m);
+	int nid = cur_file->numa_node_id;
+	unsigned long val = 0;
+	int i;
+
+	for (i = 0; i < NR_LRU_LISTS; i++)
+		val += mem_cgroup_node_nr_lru_pages(memcg, nid, BIT(i));
+
+	seq_printf(m, "%llu\n", (u64)val * PAGE_SIZE);
+
+	return 0;
+}
+
+static int memory_per_node_max_show(struct seq_file *m, void *v)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
+	struct cftype *cur_file = seq_cft(m);
+	int nid = cur_file->numa_node_id;
+	unsigned long max = READ_ONCE(memcg->nodeinfo[nid]->max_nr_base_pages);
+
+	if (max == PAGE_COUNTER_MAX)
+		seq_puts(m, "max\n");
+	else
+		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
+
+	return 0;
+}
+
+static ssize_t memory_per_node_max_write(struct kernfs_open_file *of,
+				char *buf, size_t nbytes, loff_t off)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	struct cftype *cur_file = of_cft(of);
+	int nid = cur_file->numa_node_id;
+	unsigned long max;
+	int err;
+
+	buf = strstrip(buf);
+	err = page_counter_memparse(buf, "max", &max);
+	if (err)
+		return err;
+
+	xchg(&memcg->nodeinfo[nid]->max_nr_base_pages, max);
+
+	return nbytes;
+}
+
+static struct cftype memcg_per_node_stats_files[N_MEMORY];
+static struct cftype memcg_per_node_max_files[N_MEMORY];
+
+static int __init mem_cgroup_per_node_init(void)
+{
+	int nid;
+
+	for_each_node_state(nid, N_MEMORY) {
+		snprintf(memcg_per_node_stats_files[nid].name, MAX_CFTYPE_NAME,
+				"size_at_node:%d", nid);
+		memcg_per_node_stats_files[nid].flags = CFTYPE_NOT_ON_ROOT;
+		memcg_per_node_stats_files[nid].seq_show = memory_per_node_stat_show;
+		memcg_per_node_stats_files[nid].numa_node_id = nid;
+
+		snprintf(memcg_per_node_max_files[nid].name, MAX_CFTYPE_NAME,
+				"max_at_node:%d", nid);
+		memcg_per_node_max_files[nid].flags = CFTYPE_NOT_ON_ROOT;
+		memcg_per_node_max_files[nid].seq_show = memory_per_node_max_show;
+		memcg_per_node_max_files[nid].write = memory_per_node_max_write;
+		memcg_per_node_max_files[nid].numa_node_id = nid;
+	}
+	WARN_ON(cgroup_add_dfl_cftypes(&memory_cgrp_subsys,
+				memcg_per_node_stats_files));
+	WARN_ON(cgroup_add_dfl_cftypes(&memory_cgrp_subsys,
+				memcg_per_node_max_files));
+	return 0;
+}
+subsys_initcall(mem_cgroup_per_node_init);
+
 #endif /* CONFIG_MEMCG_SWAP */
-- 
2.7.4

