Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F13E56B0038
	for <linux-mm@kvack.org>; Sun, 16 Apr 2017 17:45:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h87so32922881pfh.2
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 14:45:49 -0700 (PDT)
Received: from mail-pg0-x22e.google.com (mail-pg0-x22e.google.com. [2607:f8b0:400e:c05::22e])
        by mx.google.com with ESMTPS id s5si9026710pgn.235.2017.04.16.14.45.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Apr 2017 14:45:49 -0700 (PDT)
Received: by mail-pg0-x22e.google.com with SMTP id 63so3657462pgh.0
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 14:45:49 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] slab: avoid IPIs when creating kmem caches
Date: Sun, 16 Apr 2017 14:45:44 -0700
Message-Id: <20170416214544.109476-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

Each slab kmem cache has per cpu array caches.  The array caches are
created when the kmem_cache is created, either via kmem_cache_create()
or lazily when the first object is allocated in context of a kmem
enabled memcg.  Array caches are replaced by writing to /proc/slabinfo.

Array caches are protected by holding slab_mutex or disabling
interrupts.  Array cache allocation and replacement is done by
__do_tune_cpucache() which holds slab_mutex and calls
kick_all_cpus_sync() to interrupt all remote processors which confirms
there are no references to the old array caches.

IPIs are needed when replacing array caches.  But when creating a new
array cache, there's no need to send IPIs because there cannot be any
references to the new cache.  Outside of memcg kmem accounting these
IPIs occur at boot time, so they're not a problem.  But with memcg kmem
accounting each container can create kmem caches, so the IPIs are
wasteful.

Avoid unnecessary IPIs when creating array caches.

Test which reports the IPI count of allocating slab in 10000 memcg:
	import os

	def ipi_count():
		with open("/proc/interrupts") as f:
			for l in f:
				if 'Function call interrupts' in l:
					return int(l.split()[1])

	def echo(val, path):
		with open(path, "w") as f:
			f.write(val)

	n = 10000
	os.chdir("/mnt/cgroup/memory")
	pid = str(os.getpid())
	a = ipi_count()
	for i in range(n):
		os.mkdir(str(i))
		echo("1G\n", "%d/memory.limit_in_bytes" % i)
		echo("1G\n", "%d/memory.kmem.limit_in_bytes" % i)
		echo(pid, "%d/cgroup.procs" % i)
		open("/tmp/x", "w").close()
		os.unlink("/tmp/x")
	b = ipi_count()
	print "%d loops: %d => %d (+%d ipis)" % (n, a, b, b-a)
	echo(pid, "cgroup.procs")
	for i in range(n):
		os.rmdir(str(i))

patched:   10000 loops: 1069 => 1170 (+101 ipis)
unpatched: 10000 loops: 1192 => 48933 (+47741 ipis)

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/slab.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 807d86c76908..1880d482a0cb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3879,7 +3879,12 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 
 	prev = cachep->cpu_cache;
 	cachep->cpu_cache = cpu_cache;
-	kick_all_cpus_sync();
+	/*
+	 * Without a previous cpu_cache there's no need to synchronize remote
+	 * cpus, so skip the IPIs.
+	 */
+	if (prev)
+		kick_all_cpus_sync();
 
 	check_irq_on();
 	cachep->batchcount = batchcount;
-- 
2.12.2.762.g0e3151a226-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
