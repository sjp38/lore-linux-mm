Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id AB4CB6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 05:25:26 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c41so17353876eek.14
        for <linux-mm@kvack.org>; Mon, 02 Jan 2012 02:25:26 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v5 5/8] slub: Only IPI CPUs that have per cpu obj to flush
Date: Mon,  2 Jan 2012 12:24:16 +0200
Message-Id: <1325499859-2262-6-git-send-email-gilad@benyossef.com>
In-Reply-To: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

flush_all() is called for each kmem_cahce_destroy(). So every cache
being destroyed dynamically ended up sending an IPI to each CPU in the
system, regardless if the cache has ever been used there.

For example, if you close the Infinband ipath driver char device file,
the close file ops calls kmem_cache_destroy(). So running some
infiniband config tool on one a single CPU dedicated to system tasks
might interrupt the rest of the 127 CPUs I dedicated to some CPU
intensive task.

I suspect there is a good chance that every line in the output of "git
grep kmem_cache_destroy linux/ | grep '\->'" has a similar scenario.

This patch attempts to rectify this issue by sending an IPI to flush
the per cpu objects back to the free lists only to CPUs that seems to
have such objects.

The check which CPU to IPI is racy but we don't care since asking a
CPU without per cpu objects to flush does no damage and as far as I
can tell the flush_all by itself is racy against allocs on remote
CPUs anyway, so if you meant the flush_all to be determinstic, you
had to arrange for locking regardless.

Without this patch the following artificial test case:

$ cd /sys/kernel/slab
$ for DIR in *; do cat $DIR/alloc_calls > /dev/null; done

produces 166 IPIs on an cpuset isolated CPU. With it it produces none.

The code path of memory allocation failure for CPUMASK_OFFSTACK=y
config was tested using fault injection framework.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
Acked-by: Pekka Enberg <penberg@kernel.org>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: linux-fsdevel@vger.kernel.org
CC: Avi Kivity <avi@redhat.com>
---

 The Acks were for a previous version that had the code
 of on_each_cpu_cond() inlined at the call site.

 mm/slub.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ed3334d..c53aa2c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2013,9 +2013,17 @@ static void flush_cpu_slab(void *d)
 	__flush_cpu_slab(s, smp_processor_id());
 }
 
+static int has_cpu_slab(int cpu, void *info)
+{
+	struct kmem_cache *s = info;
+	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+
+	return !!(c->page);
+}
+
 static void flush_all(struct kmem_cache *s)
 {
-	on_each_cpu(flush_cpu_slab, s, 1);
+	on_each_cpu_cond(has_cpu_slab, flush_cpu_slab, s, 1);
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
