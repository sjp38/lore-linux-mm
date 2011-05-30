Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 66ACC6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 13:06:22 -0400 (EDT)
Received: by iyh42 with SMTP id 42so4247854iyh.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 10:06:19 -0700 (PDT)
Subject: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
From: Rakib Mullick <rakib.mullick@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 30 May 2011 22:59:04 +0600
Message-ID: <1306774744.4061.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

commit 468fd62ed9 (vmstats: add cond_resched() to refresh_cpu_vm_stats()) added cond_resched() in refresh_cpu_vm_stats. Purpose of that patch was to allow other threads to run in non-preemptive case. This patch, makes sure that cond_resched() gets called when !CONFIG_PREEMPT is set. In a preemptiable kernel we don't need to call cond_resched().

Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
---

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 20c18b7..72cf857 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -461,7 +461,11 @@ void refresh_cpu_vm_stats(int cpu)
 				p->expire = 3;
 #endif
 			}
+
+#ifndef CONFIG_PREEMPT
 		cond_resched();
+#endif
+
 #ifdef CONFIG_NUMA
 		/*
 		 * Deal with draining the remote pageset of this


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
