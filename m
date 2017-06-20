Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1766B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 08:55:10 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id s7so64739587otb.0
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 05:55:10 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id c25si5466768ote.140.2017.06.20.05.55.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Jun 2017 05:55:09 -0700 (PDT)
From: Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH 1/1] mm: only dispaly online cpus of the numa node
Date: Tue, 20 Jun 2017 20:43:28 +0800
Message-ID: <1497962608-12756-1-git-send-email-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, linux-api <linux-api@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>
Cc: Zefan Li <lizefan@huawei.com>, Xinwei Hu <huxinwei@huawei.com>, Tianhong
 Ding <dingtianhong@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, Zhen Lei <thunder.leizhen@huawei.com>

When I executed numactl -H(which read /sys/devices/system/node/nodeX/cpumap
and display cpumask_of_node for each node), but I got different result on
X86 and arm64. For each numa node, the former only displayed online CPUs,
and the latter displayed all possible CPUs. Unfortunately, both Linux
documentation and numactl manual have not described it clear.

I sent a mail to ask for help, and Michal Hocko <mhocko@kernel.org> replied
that he preferred to print online cpus because it doesn't really make much
sense to bind anything on offline nodes.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 drivers/base/node.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f96..d5e7ce7 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -28,12 +28,14 @@ static struct bus_type node_subsys = {
 static ssize_t node_read_cpumap(struct device *dev, bool list, char *buf)
 {
 	struct node *node_dev = to_node(dev);
-	const struct cpumask *mask = cpumask_of_node(node_dev->dev.id);
+	struct cpumask mask;
+
+	cpumask_and(&mask, cpumask_of_node(node_dev->dev.id), cpu_online_mask);

 	/* 2008/04/07: buf currently PAGE_SIZE, need 9 chars per 32 bits. */
 	BUILD_BUG_ON((NR_CPUS/32 * 9) > (PAGE_SIZE-1));

-	return cpumap_print_to_pagebuf(list, buf, mask);
+	return cpumap_print_to_pagebuf(list, buf, &mask);
 }

 static inline ssize_t node_read_cpumask(struct device *dev,
--
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
