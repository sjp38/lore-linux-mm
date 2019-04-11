Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FBE9C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:57:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C0942133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:57:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C0942133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4F126B0005; Wed, 10 Apr 2019 23:57:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AB666B0006; Wed, 10 Apr 2019 23:57:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8867B6B0008; Wed, 10 Apr 2019 23:57:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D9DD6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:57:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so3406169pfa.0
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:57:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=zT5IRyMHrSI4fnrzELRIPvo8b6vbfkc3L02HfOTWYA0=;
        b=bxCcfI2uYSBdhwdfx6YFCuyDZYCoiLA9isj0j383c4R3DHu6++35srWHzFgeazjnwK
         JL3YfASJglN+eGsrPeNdD4MQVVVzU4raKvMeVHbL8artkBbKcU7OLa/s94z3BRq5t/T9
         x/FPOcpAkUSSxEe7Oo14Z1oFAYMfwJZ1a6Ys4MNd0LGbo0UiNDTs0pJo1S1ypTjQFZIv
         KYwMILMaNbBB40rUw3UHgVUD7JTDfBMZyt1BoZSk6uEbyL3qFXB/WDWwzi4DMTRwERyS
         sLK9AQUgUzf6g24zTltRnk5++TjggN7ET/zzWXbDfeSlEikDE5BJHPxHRdSEWydNojux
         TaRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXgTTbSIDUCeMyEl9jxVsk6UsWkIl9ta4WdzZO4BR3QTqW89npB
	+c0e2kpaaMh3bohzyXa5pMX/mwL9SeeSrX0oGOf+0R6ITiVP8IMbga757vTs/9h+JA2K4YRuy/D
	/b4PWj3iAiMBB8gufajflSEHacrgEu5hvSJ9XK+8KxGnS+oK3l9N+oj/g0lSDvtNxOw==
X-Received: by 2002:a63:e850:: with SMTP id a16mr42823238pgk.195.1554955045686;
        Wed, 10 Apr 2019 20:57:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyLWpd07NhCUJF6+l2ljPHMRzx0/pqZmNlVYqP6pLpUe+5XEPw0Z1UVeuf/wcUkrrkhyE2
X-Received: by 2002:a63:e850:: with SMTP id a16mr42823161pgk.195.1554955044144;
        Wed, 10 Apr 2019 20:57:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554955044; cv=none;
        d=google.com; s=arc-20160816;
        b=BuujULZAouVhuMaDLtROx5mZcnLy7Cpscf2464+CjwZb8ODRrB+1NaEr24XmYUfRFv
         5mAoBT3FiHrA2f18DjZm1Riaa0U84cnXyMSGvjVWZt1j8CiiXBklpP9L+bDZW29jtnOu
         Ags4KIk0/4Y+NieJK6i2Ukjo+kAQkUEq5DtAQEWO0wRVMeyP3wWNPYOFOp38G4D/o6Cv
         pxDbkcE5RWAKbAhaL7aNJYpb98HzHYOjcgTpuje/Icl0o2S3KBOjsBbujHfoZuWMVw7M
         n/rdzYft2mROQxJNbBQu2QNc1g5olfbLw5KjLphf8NXmoUY10BO/XpL5VuEMCfbNYLRi
         umdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=zT5IRyMHrSI4fnrzELRIPvo8b6vbfkc3L02HfOTWYA0=;
        b=b/c58pCu0HXZVK+QPFkLln4Gc2nbdV0IZBxqeNfl7MV13HOVlS3e/Kv97Vr415mV4T
         A8gMTIfpduw0GqW9SddzfGUV2vxzyiYw9S562SgDagTtejkY6AIS9Xkh/3rfI5oOjSbY
         GVbeQQaRQN+g+9HKHzMPzc/C/y8DSVbLZCNjv8SlxZnzTDURWEh7HhBhhXm48IVC9wHg
         OZB3WWHyAfaomf4/tBHwlUqRB05VgBgK8ifm5T4RDxAXY3IZnMrnS1iYDPuLWVYuljfQ
         IvekdwGcjtu7NFvZs1t3OTBLrSKeVP5j26kT05FBWiUm7krSpNEGfXHSGxScMiOFmZc/
         whAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id i19si15607342pfr.246.2019.04.10.20.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:57:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) client-ip=115.124.30.130;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.130 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R761e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TP0I5rB_1554955031;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TP0I5rB_1554955031)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 11 Apr 2019 11:57:22 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH 1/9] mm: define N_CPU_MEM node states
Date: Thu, 11 Apr 2019 11:56:51 +0800
Message-Id: <1554955019-29472-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Kernel has some pre-defined node masks called node states, i.e.
N_MEMORY, N_CPU, etc.  But, there might be cpuless nodes, i.e. PMEM
nodes, and some architectures, i.e. Power, may have memoryless nodes.
It is not very straight forward to get the nodes with both CPUs and
memory.  So, define N_CPU_MEMORY node states.  The nodes with both CPUs
and memory are called "primary" nodes.  /sys/devices/system/node/primary
would show the current online "primary" nodes.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 drivers/base/node.c      |  2 ++
 include/linux/nodemask.h |  3 ++-
 mm/memory_hotplug.c      |  6 ++++++
 mm/page_alloc.c          |  1 +
 mm/vmstat.c              | 11 +++++++++--
 5 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd9..1b963b2 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -634,6 +634,7 @@ static ssize_t show_node_state(struct device *dev,
 #endif
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
+	[N_CPU_MEM] = _NODE_ATTR(primary, N_CPU_MEM),
 };
 
 static struct attribute *node_state_attrs[] = {
@@ -645,6 +646,7 @@ static ssize_t show_node_state(struct device *dev,
 #endif
 	&node_state_attr[N_MEMORY].attr.attr,
 	&node_state_attr[N_CPU].attr.attr,
+	&node_state_attr[N_CPU_MEM].attr.attr,
 	NULL
 };
 
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 27e7fa3..66a8964 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -398,7 +398,8 @@ enum node_states {
 	N_HIGH_MEMORY = N_NORMAL_MEMORY,
 #endif
 	N_MEMORY,		/* The node has memory(regular, high, movable) */
-	N_CPU,		/* The node has one or more cpus */
+	N_CPU,			/* The node has one or more cpus */
+	N_CPU_MEM,		/* The node has both cpus and memory */
 	NR_NODE_STATES
 };
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f767582..1140f3b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -729,6 +729,9 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 
 	if (arg->status_change_nid >= 0)
 		node_set_state(node, N_MEMORY);
+
+	if (node_state(node, N_CPU))
+		node_set_state(node, N_CPU_MEM);
 }
 
 static void __meminit resize_zone_range(struct zone *zone, unsigned long start_pfn,
@@ -1569,6 +1572,9 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 
 	if (arg->status_change_nid >= 0)
 		node_clear_state(node, N_MEMORY);
+
+	if (node_state(node, N_CPU))
+		node_clear_state(node, N_CPU_MEM);
 }
 
 static int __ref __offline_pages(unsigned long start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 03fcf73..7cd88a4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -122,6 +122,7 @@ struct pcpu_drain {
 #endif
 	[N_MEMORY] = { { [0] = 1UL } },
 	[N_CPU] = { { [0] = 1UL } },
+	[N_CPU_MEM] = { { [0] = 1UL } },
 #endif	/* NUMA */
 };
 EXPORT_SYMBOL(node_states);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 36b56f8..1a431dc 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1910,15 +1910,22 @@ static void __init init_cpu_node_state(void)
 	int node;
 
 	for_each_online_node(node) {
-		if (cpumask_weight(cpumask_of_node(node)) > 0)
+		if (cpumask_weight(cpumask_of_node(node)) > 0) {
 			node_set_state(node, N_CPU);
+			if (node_state(node, N_MEMORY))
+				node_set_state(node, N_CPU_MEM);
+		}
 	}
 }
 
 static int vmstat_cpu_online(unsigned int cpu)
 {
+	int node = cpu_to_node(cpu);
+
 	refresh_zone_stat_thresholds();
-	node_set_state(cpu_to_node(cpu), N_CPU);
+	node_set_state(node, N_CPU);
+	if (node_state(node, N_MEMORY))
+		node_set_state(node, N_CPU_MEM);
 	return 0;
 }
 
-- 
1.8.3.1

