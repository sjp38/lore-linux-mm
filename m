Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C40666B03A4
	for <linux-mm@kvack.org>; Mon, 17 Apr 2017 18:25:53 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z127so61189126pgb.12
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 15:25:53 -0700 (PDT)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id m8si12492337pln.260.2017.04.17.15.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Apr 2017 15:25:52 -0700 (PDT)
Received: by mail-pg0-x233.google.com with SMTP id 63so17957888pgh.0
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 15:25:52 -0700 (PDT)
Date: Mon, 17 Apr 2017 15:25:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: avoid IPIs when creating kmem caches
In-Reply-To: <20170416214544.109476-1-gthelen@google.com>
Message-ID: <alpine.DEB.2.10.1704171525350.46404@chino.kir.corp.google.com>
References: <20170416214544.109476-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 16 Apr 2017, Greg Thelen wrote:

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

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
