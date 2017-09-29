Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC2396B026B
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 05:57:34 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id f72so1182495ioj.7
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 02:57:34 -0700 (PDT)
Received: from szxga04-in.huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id u130si3703292iod.20.2017.09.29.02.57.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Sep 2017 02:57:33 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v2 1/1] mm: only dispaly online cpus of the numa node
Date: Fri, 29 Sep 2017 17:53:25 +0800
Message-ID: <1506678805-15392-2-git-send-email-thunder.leizhen@huawei.com>
In-Reply-To: <1506678805-15392-1-git-send-email-thunder.leizhen@huawei.com>
References: <1506678805-15392-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-api <linux-api@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>
Cc: Tianhong Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Libin <huawei.libin@huawei.com>, Kefeng Wang <wangkefeng.wang@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

When I executed numactl -H(which read /sys/devices/system/node/nodeX/cpumap
and display cpumask_of_node for each node), but I got different result on
X86 and arm64. For each numa node, the former only displayed online CPUs,
and the latter displayed all possible CPUs. Unfortunately, both Linux
documentation and numactl manual have not described it clear.

I sent a mail to ask for help, and Michal Hocko <mhocko@kernel.org> replied
that he preferred to print online cpus because it doesn't really make much
sense to bind anything on offline nodes.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 drivers/base/node.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 3855902..aae2402 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -27,13 +27,21 @@ static struct bus_type node_subsys = {
 
 static ssize_t node_read_cpumap(struct device *dev, bool list, char *buf)
 {
+	ssize_t n;
+	cpumask_var_t mask;
 	struct node *node_dev = to_node(dev);
-	const struct cpumask *mask = cpumask_of_node(node_dev->dev.id);
 
 	/* 2008/04/07: buf currently PAGE_SIZE, need 9 chars per 32 bits. */
 	BUILD_BUG_ON((NR_CPUS/32 * 9) > (PAGE_SIZE-1));
 
-	return cpumap_print_to_pagebuf(list, buf, mask);
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return 0;
+
+	cpumask_and(mask, cpumask_of_node(node_dev->dev.id), cpu_online_mask);
+	n = cpumap_print_to_pagebuf(list, buf, mask);
+	free_cpumask_var(mask);
+
+	return n;
 }
 
 static inline ssize_t node_read_cpumask(struct device *dev,
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
