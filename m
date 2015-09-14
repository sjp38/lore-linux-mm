Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id A7C146B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 02:31:07 -0400 (EDT)
Received: by igxx6 with SMTP id x6so75024517igx.1
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 23:31:07 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id qh7si6781276igb.96.2015.09.13.23.31.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 13 Sep 2015 23:31:06 -0700 (PDT)
Message-ID: <55F6684F.4010007@huawei.com>
Date: Mon, 14 Sep 2015 14:25:19 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] numa-balancing: fix confusion in /proc/sys/kernel/numa_balancing
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang@huawei.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

We can only echo 0 or 1 > "/proc/sys/kernel/numa_balancing", usually 1 means
enable and 0 means disable. But when echo 1, it shows the value is 65536, this
is confusion.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 kernel/sched/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 3595403..e97a348 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -2135,7 +2135,7 @@ int sysctl_numa_balancing(struct ctl_table *table, int write,
 {
 	struct ctl_table t;
 	int err;
-	int state = numabalancing_enabled;
+	int state = !!numabalancing_enabled;
 
 	if (write && !capable(CAP_SYS_ADMIN))
 		return -EPERM;
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
