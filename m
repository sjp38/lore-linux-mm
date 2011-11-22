Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C3B2F6B0072
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 06:09:50 -0500 (EST)
Received: by mail-ey0-f169.google.com with SMTP id 4so42549eye.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 03:09:49 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v4 4/5] slub: Only IPI CPUs that have per cpu obj to flush
Date: Tue, 22 Nov 2011 13:08:47 +0200
Message-Id: <1321960128-15191-5-git-send-email-gilad@benyossef.com>
In-Reply-To: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>

flush_all() is called for each kmem_cahce_destroy(). So every cache being destroyed dynamically ended up sending an IPI to each CPU in the system, regardless if the cache has ever been used there.

For example, if you close the Infinband ipath driver char device file, the close file ops calls kmem_cache_destroy(). So running some infiniband config tool on one a single CPU dedicated to system tasks might interrupt the rest of the 127 CPUs I dedicated to some CPU intensive task.

I suspect there is a good chance that every line in the output of "git grep kmem_cache_destroy linux/ | grep '\->'" has a similar scenario.

This patch attempts to rectify this issue by sending an IPI to flush the per cpu objects back to the free lists only to CPUs that seems to have such objects.

The check which CPU to IPI is racy but we don't care since asking a CPU without per cpu objects to flush does no damage and as far as I can tell the flush_all by itself is racy against allocs on remote CPUs anyway, so if you meant the flush_all to be determinstic, you had to arrange for locking regardless.

Without this patch the following artificial test case:

$ cd /sys/kernel/slab
$ for DIR in *; do cat $DIR/alloc_calls > /dev/null; done

produces 166 IPIs on an cpuset isolated CPU. With it it produces none.

The code path of memory allocation failure for CPUMASK_OFFSTACK=y config was tested using fault injection framework.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
---
 mm/slub.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7d2a996..1f18006 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2006,7 +2006,20 @@ static void flush_cpu_slab(void *d)
 
 static void flush_all(struct kmem_cache *s)
 {
-	on_each_cpu(flush_cpu_slab, s, 1);
+	cpumask_var_t cpus;
+	struct kmem_cache_cpu *c;
+	int cpu;
+
+	if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
+		for_each_online_cpu(cpu) {
+			c = per_cpu_ptr(s->cpu_slab, cpu);
+			if (c->page)
+				cpumask_set_cpu(cpu, cpus);
+		}
+		on_each_cpu_mask(cpus, flush_cpu_slab, s, 1);
+		free_cpumask_var(cpus);
+	} else
+		on_each_cpu(flush_cpu_slab, s, 1);
 }
 
 /*
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
