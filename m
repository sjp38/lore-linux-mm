Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71B7C6B0253
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 13:07:01 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id o12so109288120lfg.7
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 10:07:01 -0800 (PST)
Received: from smtp42.i.mail.ru (smtp42.i.mail.ru. [94.100.177.102])
        by mx.google.com with ESMTPS id 200si3309641lfa.131.2017.01.27.10.06.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 10:07:00 -0800 (PST)
Date: Fri, 27 Jan 2017 21:06:56 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [PATCH 06/10] slab: implement slab_root_caches list
Message-ID: <20170127180656.GC4332@esperanza>
References: <20170117235411.9408-1-tj@kernel.org>
 <20170117235411.9408-7-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117235411.9408-7-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 17, 2017 at 03:54:07PM -0800, Tejun Heo wrote:
> With kmem cgroup support enabled, kmem_caches can be created and
> destroyed frequently and a great number of near empty kmem_caches can
> accumulate if there are a lot of transient cgroups and the system is
> not under memory pressure.  When memory reclaim starts under such
> conditions, it can lead to consecutive deactivation and destruction of
> many kmem_caches, easily hundreds of thousands on moderately large
> systems, exposing scalability issues in the current slab management
> code.  This is one of the patches to address the issue.
> 
> slab_caches currently lists all caches including root and memcg ones.
> This is the only data structure which lists the root caches and
> iterating root caches can only be done by walking the list while
> skipping over memcg caches.  As there can be a huge number of memcg
> caches, this can become very expensive.
> 
> This also can make /proc/slabinfo behave very badly.  seq_file
> processes reads in 4k chunks and seeks to the previous Nth position on
> slab_caches list to resume after each chunk.  With a lot of memcg
> cache churns on the list, reading /proc/slabinfo can become very slow
> and its content often ends up with duplicate and/or missing entries.
> 
> This patch adds a new list slab_root_caches which lists only the root
> caches.  When memcg is not enabled, it becomes just an alias of
> slab_caches.  memcg specific list operations are collected into
> memcg_[un]link_cache().
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-by: Jay Vana <jsvana@fb.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Vladimir Davydov <vdavydov@tarantool.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
