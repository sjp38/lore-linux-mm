Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 233466B05D5
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 16:06:52 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id q62so12459873pgq.9
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 13:06:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q17si15500338pfc.198.2018.11.15.13.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 13:06:50 -0800 (PST)
Date: Thu, 15 Nov 2018 13:06:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 201699] New: kmemleak in memcg_create_kmem_cache
Message-Id: <20181115130646.6de1029eb1f3b8d7276c3543@linux-foundation.org>
In-Reply-To: <bug-201699-27@https.bugzilla.kernel.org/>
References: <bug-201699-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, bauers@126.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 15 Nov 2018 06:31:19 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=201699
> 
>             Bug ID: 201699
>            Summary: kmemleak in memcg_create_kmem_cache
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.20.0-rc2i 1/4 ?other version include 4.14.52 etc.i 1/4 ?
>           Hardware: Intel
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Slab Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: bauers@126.com
>         Regression: No
> 
> On debian OS, when systemd restart a failed service periodically. It will cause
> memory leak. When I enable kmemleak, the message comes up.
> 
> 
> [ 4658.065578] kmemleak: Found object by alias at 0xffff9d84ba868808
> [ 4658.065581] CPU: 8 PID: 5194 Comm: kworker/8:3 Not tainted 4.20.0-rc2.bm.1+
> #1
> [ 4658.065582] Hardware name: Dell Inc. PowerEdge C6320/082F9M, BIOS 2.1.5
> 04/12/2016
> [ 4658.065586] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [ 4658.065587] Call Trace:
> [ 4658.065590]  dump_stack+0x5c/0x7b
> [ 4658.065594]  lookup_object+0x5e/0x80
> [ 4658.065596]  find_and_get_object+0x29/0x80
> [ 4658.065598]  kmemleak_no_scan+0x31/0xc0
> [ 4658.065600]  setup_kmem_cache_node+0x271/0x350
> [ 4658.065602]  __do_tune_cpucache+0x18c/0x220
> [ 4658.065603]  do_tune_cpucache+0x27/0xb0
> [ 4658.065605]  enable_cpucache+0x80/0x110
> [ 4658.065606]  __kmem_cache_create+0x217/0x3a0
> [ 4658.065609]  ? kmem_cache_alloc+0x1aa/0x280
> [ 4658.065612]  create_cache+0xd9/0x200
> [ 4658.065614]  memcg_create_kmem_cache+0xef/0x120
> [ 4658.065616]  memcg_kmem_cache_create_func+0x1b/0x60
> [ 4658.065619]  process_one_work+0x1d1/0x3d0
> [ 4658.065621]  worker_thread+0x4f/0x3b0
> [ 4658.065623]  ? rescuer_thread+0x360/0x360
> [ 4658.065625]  kthread+0xf8/0x130
> [ 4658.065627]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 4658.065628]  ret_from_fork+0x35/0x40
> [ 4658.065630] kmemleak: Object 0xffff9d84ba868800 (size 128):
> [ 4658.065631] kmemleak:   comm "kworker/8:3", pid 5194, jiffies 4296056196
> [ 4658.065631] kmemleak:   min_count = 1
> [ 4658.065632] kmemleak:   count = 0
> [ 4658.065632] kmemleak:   flags = 0x1
> [ 4658.065633] kmemleak:   checksum = 0
> [ 4658.065633] kmemleak:   backtrace:
> [ 4658.065635]      __do_tune_cpucache+0x18c/0x220
> [ 4658.065636]      do_tune_cpucache+0x27/0xb0
> [ 4658.065637]      enable_cpucache+0x80/0x110
> [ 4658.065638]      __kmem_cache_create+0x217/0x3a0
> [ 4658.065640]      create_cache+0xd9/0x200
> [ 4658.065641]      memcg_create_kmem_cache+0xef/0x120
> [ 4658.065642]      memcg_kmem_cache_create_func+0x1b/0x60
> [ 4658.065644]      process_one_work+0x1d1/0x3d0
> [ 4658.065646]      worker_thread+0x4f/0x3b0
> [ 4658.065647]      kthread+0xf8/0x130
> [ 4658.065648]      ret_from_fork+0x35/0x40
> [ 4658.065649]      0xffffffffffffffff
> [ 4658.065650] kmemleak: Not scanning unknown object at 0xffff9d84ba868808
> [ 4658.065651] CPU: 8 PID: 5194 Comm: kworker/8:3 Not tainted 4.20.0-rc2.bm.1+
> #1
> [ 4658.065652] Hardware name: Dell Inc. PowerEdge C6320/082F9M, BIOS 2.1.5
> 04/12/2016
> [ 4658.065653] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [ 4658.065654] Call Trace:
> [ 4658.065656]  dump_stack+0x5c/0x7b
> [ 4658.065657]  kmemleak_no_scan+0xa0/0xc0
> [ 4658.065659]  setup_kmem_cache_node+0x271/0x350
> [ 4658.065660]  __do_tune_cpucache+0x18c/0x220
> [ 4658.065662]  do_tune_cpucache+0x27/0xb0
> [ 4658.065663]  enable_cpucache+0x80/0x110
> [ 4658.065664]  __kmem_cache_create+0x217/0x3a0
> [ 4658.065667]  ? kmem_cache_alloc+0x1aa/0x280
> [ 4658.065668]  create_cache+0xd9/0x200
> [ 4658.065670]  memcg_create_kmem_cache+0xef/0x120
> [ 4658.065671]  memcg_kmem_cache_create_func+0x1b/0x60
> [ 4658.065673]  process_one_work+0x1d1/0x3d0
> [ 4658.065675]  worker_thread+0x4f/0x3b0
> [ 4658.065677]  ? rescuer_thread+0x360/0x360
> [ 4658.065679]  kthread+0xf8/0x130
> [ 4658.065681]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 4658.065682]  ret_from_fork+0x35/0x40
> [ 4658.065718] kmemleak: Found object by alias at 0xffff9d8cb36bd288
> [ 4658.065720] CPU: 8 PID: 5194 Comm: kworker/8:3 Not tainted 4.20.0-rc2.bm.1+
> #1
> [ 4658.065721] Hardware name: Dell Inc. PowerEdge C6320/082F9M, BIOS 2.1.5
> 04/12/2016
> [ 4658.065722] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [ 4658.065722] Call Trace:
> [ 4658.065724]  dump_stack+0x5c/0x7b
> [ 4658.065726]  lookup_object+0x5e/0x80
> [ 4658.065728]  find_and_get_object+0x29/0x80
> [ 4658.065729]  kmemleak_no_scan+0x31/0xc0
> [ 4658.065730]  setup_kmem_cache_node+0x271/0x350
> [ 4658.065732]  __do_tune_cpucache+0x18c/0x220
> [ 4658.065734]  do_tune_cpucache+0x27/0xb0
> [ 4658.065735]  enable_cpucache+0x80/0x110
> [ 4658.065737]  __kmem_cache_create+0x217/0x3a0
> [ 4658.065739]  ? kmem_cache_alloc+0x1aa/0x280
> [ 4658.065740]  create_cache+0xd9/0x200
> [ 4658.065742]  memcg_create_kmem_cache+0xef/0x120
> [ 4658.065743]  memcg_kmem_cache_create_func+0x1b/0x60
> [ 4658.065745]  process_one_work+0x1d1/0x3d0
> [ 4658.065747]  worker_thread+0x4f/0x3b0
> [ 4658.065750]  ? rescuer_thread+0x360/0x360
> [ 4658.065751]  kthread+0xf8/0x130
> [ 4658.065753]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 4658.065754]  ret_from_fork+0x35/0x40
> [ 4658.065755] kmemleak: Object 0xffff9d8cb36bd280 (size 128):
> [ 4658.065756] kmemleak:   comm "kworker/8:3", pid 5194, jiffies 4296056196
> [ 4658.065757] kmemleak:   min_count = 1
> [ 4658.065757] kmemleak:   count = 0
> [ 4658.065757] kmemleak:   flags = 0x1
> [ 4658.065758] kmemleak:   checksum = 0
> [ 4658.065758] kmemleak:   backtrace:
> [ 4658.065759]      __do_tune_cpucache+0x18c/0x220
> [ 4658.065760]      do_tune_cpucache+0x27/0xb0
> [ 4658.065762]      enable_cpucache+0x80/0x110
> [ 4658.065763]      __kmem_cache_create+0x217/0x3a0
> [ 4658.065764]      create_cache+0xd9/0x200
> [ 4658.065765]      memcg_create_kmem_cache+0xef/0x120
> [ 4658.065766]      memcg_kmem_cache_create_func+0x1b/0x60
> [ 4658.065768]      process_one_work+0x1d1/0x3d0
> [ 4658.065770]      worker_thread+0x4f/0x3b0
> [ 4658.065771]      kthread+0xf8/0x130
> [ 4658.065772]      ret_from_fork+0x35/0x40
> [ 4658.065773]      0xffffffffffffffff
> [ 4658.065774] kmemleak: Not scanning unknown object at 0xffff9d8cb36bd288
> [ 4658.065775] CPU: 8 PID: 5194 Comm: kworker/8:3 Not tainted 4.20.0-rc2.bm.1+
> #1
> [ 4658.065775] Hardware name: Dell Inc. PowerEdge C6320/082F9M, BIOS 2.1.5
> 04/12/2016
> [ 4658.065776] Workqueue: memcg_kmem_cache memcg_kmem_cache_create_func
> [ 4658.065777] Call Trace:
> [ 4658.065779]  dump_stack+0x5c/0x7b
> [ 4658.065780]  kmemleak_no_scan+0xa0/0xc0
> [ 4658.065781]  setup_kmem_cache_node+0x271/0x350
> [ 4658.065783]  __do_tune_cpucache+0x18c/0x220
> [ 4658.065784]  do_tune_cpucache+0x27/0xb0
> [ 4658.065785]  enable_cpucache+0x80/0x110
> [ 4658.065787]  __kmem_cache_create+0x217/0x3a0
> [ 4658.065789]  ? kmem_cache_alloc+0x1aa/0x280
> [ 4658.065790]  create_cache+0xd9/0x200
> [ 4658.065792]  memcg_create_kmem_cache+0xef/0x120
> [ 4658.065793]  memcg_kmem_cache_create_func+0x1b/0x60
> [ 4658.065795]  process_one_work+0x1d1/0x3d0
> [ 4658.065797]  worker_thread+0x4f/0x3b0
> [ 4658.065799]  ? rescuer_thread+0x360/0x360
> [ 4658.065801]  kthread+0xf8/0x130
> [ 4658.065802]  ? kthread_create_worker_on_cpu+0x70/0x70
> [ 4658.065804]  ret_from_fork+0x35/0x40
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.
