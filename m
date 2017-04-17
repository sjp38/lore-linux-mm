Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59AAD6B0390
	for <linux-mm@kvack.org>; Sun, 16 Apr 2017 22:07:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z185so63671442pgz.11
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 19:07:21 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id m19si2599877pfk.36.2017.04.16.19.07.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Apr 2017 19:07:20 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id c198so22380176pfc.0
        for <linux-mm@kvack.org>; Sun, 16 Apr 2017 19:07:20 -0700 (PDT)
Date: Mon, 17 Apr 2017 11:07:14 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH] slab: avoid IPIs when creating kmem caches
Message-ID: <20170417020712.GB1351@js1304-desktop>
References: <20170416214544.109476-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170416214544.109476-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Apr 16, 2017 at 02:45:44PM -0700, Greg Thelen wrote:
> Each slab kmem cache has per cpu array caches.  The array caches are
> created when the kmem_cache is created, either via kmem_cache_create()
> or lazily when the first object is allocated in context of a kmem
> enabled memcg.  Array caches are replaced by writing to /proc/slabinfo.
> 
> Array caches are protected by holding slab_mutex or disabling
> interrupts.  Array cache allocation and replacement is done by
> __do_tune_cpucache() which holds slab_mutex and calls
> kick_all_cpus_sync() to interrupt all remote processors which confirms
> there are no references to the old array caches.
> 
> IPIs are needed when replacing array caches.  But when creating a new
> array cache, there's no need to send IPIs because there cannot be any
> references to the new cache.  Outside of memcg kmem accounting these
> IPIs occur at boot time, so they're not a problem.  But with memcg kmem
> accounting each container can create kmem caches, so the IPIs are
> wasteful.
> 
> Avoid unnecessary IPIs when creating array caches.
> 
> Test which reports the IPI count of allocating slab in 10000 memcg:
> 	import os
> 
> 	def ipi_count():
> 		with open("/proc/interrupts") as f:
> 			for l in f:
> 				if 'Function call interrupts' in l:
> 					return int(l.split()[1])
> 
> 	def echo(val, path):
> 		with open(path, "w") as f:
> 			f.write(val)
> 
> 	n = 10000
> 	os.chdir("/mnt/cgroup/memory")
> 	pid = str(os.getpid())
> 	a = ipi_count()
> 	for i in range(n):
> 		os.mkdir(str(i))
> 		echo("1G\n", "%d/memory.limit_in_bytes" % i)
> 		echo("1G\n", "%d/memory.kmem.limit_in_bytes" % i)
> 		echo(pid, "%d/cgroup.procs" % i)
> 		open("/tmp/x", "w").close()
> 		os.unlink("/tmp/x")
> 	b = ipi_count()
> 	print "%d loops: %d => %d (+%d ipis)" % (n, a, b, b-a)
> 	echo(pid, "cgroup.procs")
> 	for i in range(n):
> 		os.rmdir(str(i))
> 
> patched:   10000 loops: 1069 => 1170 (+101 ipis)
> unpatched: 10000 loops: 1192 => 48933 (+47741 ipis)
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
