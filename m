Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7BF6B0282
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 22:04:00 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l132so24364589wmf.0
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 19:04:00 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o137si6441599wmd.113.2016.09.27.19.03.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 19:03:59 -0700 (PDT)
Date: Tue, 27 Sep 2016 22:03:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug 172981] New: [bisected] SLAB: extreme load averages and
 over 2000 kworker threads
Message-ID: <20160928020347.GA21129@cmpxchg.org>
References: <bug-172981-27@https.bugzilla.kernel.org/>
 <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160927111059.282a35c89266202d3cb2f953@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, bugzilla-daemon@bugzilla.kernel.org, dsmythies@telus.net, linux-mm@kvack.org

[CC Vladimir]

These are the delayed memcg cache allocations, where in a fresh memcg
that doesn't have per-memcg caches yet, every accounted allocation
schedules a kmalloc work item in __memcg_schedule_kmem_cache_create()
until the cache is finally available. It looks like those can be many
more than the number of slab caches in existence, if there is a storm
of slab allocations before the workers get a chance to run.

Vladimir, what do you think of embedding the work item into the
memcg_cache_array? That way we make sure we have exactly one work per
cache and not an unbounded number of them. The downside of course is
that we'd have to keep these things around as long as the memcg is in
existence, but that's the only place I can think of that allows us to
serialize this.

On Tue, Sep 27, 2016 at 11:10:59AM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 27 Sep 2016 17:57:08 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=172981
> > 
> >             Bug ID: 172981
> >            Summary: [bisected] SLAB: extreme load averages and over 2000
> >                     kworker threads
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 4.7+
> >           Hardware: All
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Slab Allocator
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: dsmythies@telus.net
> >         Regression: No
> > 
> > Immediately after boot, extreme load average numbers and over 2000 kworker
> > processes are being observed on my main linux test computer (basically a Ubuntu
> > 16.04 server, no GUI). The worker threads appear to be idle, and do disappear
> > after the nominal 5 minute timeout, depending on whatever other stuff might run
> > in the meantime. However, the number of threads can hugely increase again. The
> > issue occurs with ease for kernels compiled using SLAB.
> > 
> > For SLAB, kernel bisection gave:
> > 801faf0db8947e01877920e848a4d338dd7a99e7
> > "mm/slab: lockless decision to grow cache"
> > 
> > The following monitoring script was used for the below examples:
> > 
> > #!/bin/dash
> > 
> > while [ 1 ];
> > do
> >   echo $(uptime) ::: $(ps -A --no-headers | wc -l) ::: $(ps aux | grep kworker
> > | grep -v u | grep -v H | wc -l)
> >   sleep 10.0
> > done
> > 
> > Example (SLAB):
> > 
> > After boot:
> > 
> > 22:26:21 up 1 min, 2 users, load average: 295.98, 85.67, 29.47 ::: 2240 :::
> > 2074
> > 22:26:31 up 1 min, 2 users, load average: 250.47, 82.85, 29.15 ::: 2240 :::
> > 2074
> > 22:26:41 up 1 min, 2 users, load average: 211.96, 80.12, 28.84 ::: 2240 :::
> > 2074
> > ...
> > 22:52:34 up 27 min, 3 users, load average: 0.00, 0.43, 5.40 ::: 165 ::: 17
> > 22:52:44 up 27 min, 3 users, load average: 0.00, 0.42, 5.34 ::: 165 ::: 17
> > 
> > Now type: sudo echo "bla":
> > 
> > 22:53:14 up 27 min, 3 users, load average: 0.00, 0.38, 5.17 ::: 493 ::: 345
> > 22:53:24 up 28 min, 3 users, load average: 0.00, 0.36, 5.11 ::: 493 ::: 345
> > 
> > Caused 328 new kworker threads.
> > Now queue just a few (8 in this case) very simple jobs.
> > 
> > 22:55:45 up 30 min, 3 users, load average: 0.11, 0.27, 4.38 ::: 493 ::: 345
> > 22:55:55 up 30 min, 3 users, load average: 0.09, 0.26, 4.34 ::: 2207 ::: 2059
> > 22:56:05 up 30 min, 3 users, load average: 0.08, 0.25, 4.29 ::: 2207 ::: 2059
> > 
> > If I look at linux/Documentation/workqueue.txt and do:
> > 
> > echo workqueue:workqueue_queue_work > /sys/kernel/debug/tracing/set_event
> > 
> > and:
> > 
> > cat /sys/kernel/debug/tracing/trace_pipe > out.txt
> > 
> > I get somewhere between 10,000 and 20,000 occurrences of
> > memcg_kmem_cache_create_func in the file (using my simple test method).
> > 
> > Also tested with kernel 4.8-rc7.
> > 
> > -- 
> > You are receiving this mail because:
> > You are the assignee for the bug.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
