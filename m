Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 065516B02DC
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 03:49:18 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id x5-v6so2119650pfn.22
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 00:49:17 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u68-v6si47847077pfa.28.2018.11.06.00.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Nov 2018 00:49:16 -0800 (PST)
Date: Tue, 6 Nov 2018 09:49:11 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181106084911.GA22504@hirez.programming.kicks-ass.net>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105165558.11698-2-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Mon, Nov 05, 2018 at 11:55:46AM -0500, Daniel Jordan wrote:
> +Concept
> +=======
> +
> +ktask is built on unbound workqueues to take advantage of the thread management
> +facilities it provides: creation, destruction, flushing, priority setting, and
> +NUMA affinity.
> +
> +A little terminology up front:  A 'task' is the total work there is to do and a
> +'chunk' is a unit of work given to a thread.

So I hate on the task naming. We already have a task, lets not overload
that name.

> +To complete a task using the ktask framework, a client provides a thread
> +function that is responsible for completing one chunk.  The thread function is
> +defined in a standard way, with start and end arguments that delimit the chunk
> +as well as an argument that the client uses to pass data specific to the task.
> +
> +In addition, the client supplies an object representing the start of the task
> +and an iterator function that knows how to advance some number of units in the
> +task to yield another object representing the new task position.  The framework
> +uses the start object and iterator internally to divide the task into chunks.
> +
> +Finally, the client passes the total task size and a minimum chunk size to
> +indicate the minimum amount of work that's appropriate to do in one chunk.  The
> +sizes are given in task-specific units (e.g. pages, inodes, bytes).  The
> +framework uses these sizes, along with the number of online CPUs and an
> +internal maximum number of threads, to decide how many threads to start and how
> +many chunks to divide the task into.
> +
> +For example, consider the task of clearing a gigantic page.  This used to be
> +done in a single thread with a for loop that calls a page clearing function for
> +each constituent base page.  To parallelize with ktask, the client first moves
> +the for loop to the thread function, adapting it to operate on the range passed
> +to the function.  In this simple case, the thread function's start and end
> +arguments are just addresses delimiting the portion of the gigantic page to
> +clear.  Then, where the for loop used to be, the client calls into ktask with
> +the start address of the gigantic page, the total size of the gigantic page,
> +and the thread function.  Internally, ktask will divide the address range into
> +an appropriate number of chunks and start an appropriate number of threads to
> +complete these chunks.

I see no mention of padata anywhere; I also don't see mention of the
async init stuff. Both appear to me to share, at least in part, the same
reason for existence.

> +Scheduler Interaction
> +=====================
> +
> +Even within the resource limits, ktask must take care to run a number of
> +threads appropriate for the system's current CPU load.  Under high CPU usage,
> +starting excessive helper threads may disturb other tasks, unfairly taking CPU
> +time away from them for the sake of an optimized kernel code path.
> +
> +ktask plays nicely in this case by setting helper threads to the lowest
> +scheduling priority on the system (MAX_NICE).  This way, helpers' CPU time is
> +appropriately throttled on a busy system and other tasks are not disturbed.
> +
> +The main thread initiating the task remains at its original priority so that it
> +still makes progress on a busy system.
> +
> +It is possible for a helper thread to start running and then be forced off-CPU
> +by a higher priority thread.  With the helper's CPU time curtailed by MAX_NICE,
> +the main thread may wait longer for the task to finish than it would have had
> +it not started any helpers, so to ensure forward progress at a single-threaded
> +pace, once the main thread is finished with all outstanding work in the task,
> +the main thread wills its priority to one helper thread at a time.  At least
> +one thread will then always be running at the priority of the calling thread.

What isn't clear is if this calling thread is waiting or not. Only do
this inheritance trick if it is actually waiting on the work. If it is
not, nobody cares.

> +Cgroup Awareness
> +================
> +
> +Given the potentially large amount of CPU time ktask threads may consume, they
> +should be aware of the cgroup of the task that called into ktask and
> +appropriately throttled.
> +
> +TODO: Implement cgroup-awareness in unbound workqueues.

Yes.. that needs done.

> +Power Management
> +================
> +
> +Starting additional helper threads may cause the system to consume more energy,
> +which is undesirable on energy-conscious devices.  Therefore ktask needs to be
> +aware of cpufreq policies and scaling governors.
> +
> +If an energy-conscious policy is in use (e.g. powersave, conservative) on any
> +part of the system, that is a signal that the user has strong power management
> +preferences, in which case ktask is disabled.
> +
> +TODO: Implement this.

No, don't do that, its broken. Also, we're trying to move to a single
cpufreq governor for all.

Sure we'll retain 'performance', but powersave and conservative and all
that nonsense should go away eventually.

That's not saying you don't need a knob for this; but don't look at
cpufreq for this.
