Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AAEA46B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 17:13:01 -0500 (EST)
From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] MM: slqb, fix per_cpu access
Date: Sun,  1 Nov 2009 23:12:58 +0100
Message-Id: <1257113578-1584-1-git-send-email-jirislaby@gmail.com>
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Tejun Heo <tj@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

We cannot use the same local variable name as the declared per_cpu
variable since commit "percpu: remove per_cpu__ prefix."

Otherwise we would see crashes like:
general protection fault: 0000 [#1] SMP
last sysfs file:
CPU 1
Modules linked in:
Pid: 1, comm: swapper Tainted: G        W  2.6.32-rc5-mm1_64 #860
RIP: 0010:[<ffffffff8142ff94>]  [<ffffffff8142ff94>] start_cpu_timer+0x2b/0x87
...

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Tejun Heo <tj@kernel.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 mm/slqb.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/slqb.c b/mm/slqb.c
index e745d9a..27f5025 100644
--- a/mm/slqb.c
+++ b/mm/slqb.c
@@ -2770,16 +2770,16 @@ static DEFINE_PER_CPU(struct delayed_work, cache_trim_work);
 
 static void __cpuinit start_cpu_timer(int cpu)
 {
-	struct delayed_work *cache_trim_work = &per_cpu(cache_trim_work, cpu);
+	struct delayed_work *_cache_trim_work = &per_cpu(cache_trim_work, cpu);
 
 	/*
 	 * When this gets called from do_initcalls via cpucache_init(),
 	 * init_workqueues() has already run, so keventd will be setup
 	 * at that time.
 	 */
-	if (keventd_up() && cache_trim_work->work.func == NULL) {
-		INIT_DELAYED_WORK(cache_trim_work, cache_trim_worker);
-		schedule_delayed_work_on(cpu, cache_trim_work,
+	if (keventd_up() && _cache_trim_work->work.func == NULL) {
+		INIT_DELAYED_WORK(_cache_trim_work, cache_trim_worker);
+		schedule_delayed_work_on(cpu, _cache_trim_work,
 					__round_jiffies_relative(HZ, cpu));
 	}
 }
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
