Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA976B0AAE
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 12:50:10 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id m13-v6so10317473lji.15
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 09:50:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u5-v6sor17282848lja.17.2018.11.16.09.50.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 09:50:08 -0800 (PST)
Date: Fri, 16 Nov 2018 20:50:05 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-ID: <20181116175005.3dcfpyhuj57oaszm@esperanza>
References: <bug-201699-27@https.bugzilla.kernel.org/>
 <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bauers@126.com
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 15, 2018 at 01:06:46PM -0800, Andrew Morton wrote:
> > On debian OS, when systemd restart a failed service periodically. It will cause
> > memory leak. When I enable kmemleak, the message comes up.

What made you think there was a memory leak in the first place?

> > 
> > 
> > [ 4658.065578] kmemleak: Found object by alias at 0xffff9d84ba868808
> > [ 4658.065581] CPU: 8 PID: 5194 Comm: kworker/8:3 Not tainted 4.20.0-rc2.bm.1+
> > #1
> > [ 4658.065582] Hardware name: Dell Inc. PowerEdge C6320/082F9M, BIOS 2.1.5
> > 04/12/2016
> > [ 4658.065586] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> > [ 4658.065587] Call Trace:
> > [ 4658.065590]  dump_stack+0x5c/0x7b
> > [ 4658.065594]  lookup_object+0x5e/0x80
> > [ 4658.065596]  find_and_get_object+0x29/0x80
> > [ 4658.065598]  kmemleak_no_scan+0x31/0xc0
> > [ 4658.065600]  setup_kmem_cache_node+0x271/0x350
> > [ 4658.065602]  __do_tune_cpucache+0x18c/0x220
> > [ 4658.065603]  do_tune_cpucache+0x27/0xb0
> > [ 4658.065605]  enable_cpucache+0x80/0x110
> > [ 4658.065606]  __kmem_cache_create+0x217/0x3a0
> > [ 4658.065609]  ? kmem_cache_alloc+0x1aa/0x280
> > [ 4658.065612]  create_cache+0xd9/0x200
> > [ 4658.065614]  memcg_create_kmem_cache+0xef/0x120
> > [ 4658.065616]  memcg_kmem_cache_create_func+0x1b/0x60
> > [ 4658.065619]  process_one_work+0x1d1/0x3d0
> > [ 4658.065621]  worker_thread+0x4f/0x3b0
> > [ 4658.065623]  ? rescuer_thread+0x360/0x360
> > [ 4658.065625]  kthread+0xf8/0x130
> > [ 4658.065627]  ? kthread_create_worker_on_cpu+0x70/0x70
> > [ 4658.065628]  ret_from_fork+0x35/0x40
> > [ 4658.065630] kmemleak: Object 0xffff9d84ba868800 (size 128):
> > [ 4658.065631] kmemleak:   comm "kworker/8:3", pid 5194, jiffies 4296056196
> > [ 4658.065631] kmemleak:   min_count = 1
> > [ 4658.065632] kmemleak:   count = 0
> > [ 4658.065632] kmemleak:   flags = 0x1
> > [ 4658.065633] kmemleak:   checksum = 0
> > [ 4658.065633] kmemleak:   backtrace:
> > [ 4658.065635]      __do_tune_cpucache+0x18c/0x220
> > [ 4658.065636]      do_tune_cpucache+0x27/0xb0
> > [ 4658.065637]      enable_cpucache+0x80/0x110
> > [ 4658.065638]      __kmem_cache_create+0x217/0x3a0
> > [ 4658.065640]      create_cache+0xd9/0x200
> > [ 4658.065641]      memcg_create_kmem_cache+0xef/0x120
> > [ 4658.065642]      memcg_kmem_cache_create_func+0x1b/0x60
> > [ 4658.065644]      process_one_work+0x1d1/0x3d0
> > [ 4658.065646]      worker_thread+0x4f/0x3b0
> > [ 4658.065647]      kthread+0xf8/0x130
> > [ 4658.065648]      ret_from_fork+0x35/0x40
> > [ 4658.065649]      0xffffffffffffffff
> > [ 4658.065650] kmemleak: Not scanning unknown object at 0xffff9d84ba868808

This doesn't look like kmemleak reporting a leak to me, although this
does look weird. What does /sys/kernel/debug/kmemleak show?
