Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 26F206B0071
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 09:29:04 -0400 (EDT)
Received: by pwi7 with SMTP id 7so506051pwi.14
        for <linux-mm@kvack.org>; Thu, 10 Jun 2010 06:29:02 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 1/2] Cleanup: use for_each_online_cpu in vmstat
Date: Thu, 10 Jun 2010 22:28:46 +0900
Message-Id: <1276176526-2952-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

The sum_vm_events passes cpumask for for_each_cpu.
But it's useless since we have for_each_online_cpu.
Althougth it's tirival overhead, it's not good about
coding consistency.

Let's use for_each_online_cpu instead of for_each_cpu with
cpumask argument.

Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmstat.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7759941..15a14b1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -22,14 +22,14 @@
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);
 
-static void sum_vm_events(unsigned long *ret, const struct cpumask *cpumask)
+static void sum_vm_events(unsigned long *ret)
 {
 	int cpu;
 	int i;
 
 	memset(ret, 0, NR_VM_EVENT_ITEMS * sizeof(unsigned long));
 
-	for_each_cpu(cpu, cpumask) {
+	for_each_online_cpu(cpu) {
 		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
 
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
@@ -45,7 +45,7 @@ static void sum_vm_events(unsigned long *ret, const struct cpumask *cpumask)
 void all_vm_events(unsigned long *ret)
 {
 	get_online_cpus();
-	sum_vm_events(ret, cpu_online_mask);
+	sum_vm_events(ret);
 	put_online_cpus();
 }
 EXPORT_SYMBOL_GPL(all_vm_events);
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
