Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 37D8C6B006A
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 03:49:27 -0500 (EST)
From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] MM: slqb, fix per_cpu access
Date: Mon,  2 Nov 2009 09:49:23 +0100
Message-Id: <1257151763-11507-1-git-send-email-jirislaby@gmail.com>
In-Reply-To: <4AEE5EA2.6010905@kernel.org>
References: <4AEE5EA2.6010905@kernel.org>
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

Use slqb_ prefix for the global variable so that we don't collide
even with the rest of the kernel (s390 and alpha need this).

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Tejun Heo <tj@kernel.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 mm/slqb.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/slqb.c b/mm/slqb.c
index e745d9a..e4bb53f 100644
--- a/mm/slqb.c
+++ b/mm/slqb.c
@@ -2766,11 +2766,12 @@ out:
 	schedule_delayed_work(work, round_jiffies_relative(3*HZ));
 }
 
-static DEFINE_PER_CPU(struct delayed_work, cache_trim_work);
+static DEFINE_PER_CPU(struct delayed_work, slqb_cache_trim_work);
 
 static void __cpuinit start_cpu_timer(int cpu)
 {
-	struct delayed_work *cache_trim_work = &per_cpu(cache_trim_work, cpu);
+	struct delayed_work *cache_trim_work = &per_cpu(slqb_cache_trim_work,
+			cpu);
 
 	/*
 	 * When this gets called from do_initcalls via cpucache_init(),
@@ -3136,8 +3137,9 @@ static int __cpuinit slab_cpuup_callback(struct notifier_block *nfb,
 
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
-		cancel_rearming_delayed_work(&per_cpu(cache_trim_work, cpu));
-		per_cpu(cache_trim_work, cpu).work.func = NULL;
+		cancel_rearming_delayed_work(&per_cpu(slqb_cache_trim_work,
+					cpu));
+		per_cpu(slqb_cache_trim_work, cpu).work.func = NULL;
 		break;
 
 	case CPU_UP_CANCELED:
-- 
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
