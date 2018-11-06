Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id C92236B0396
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 15:34:33 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id o204-v6so7118976itg.0
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 12:34:33 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m189-v6si2398713itb.89.2018.11.06.12.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 12:34:32 -0800 (PST)
Date: Tue, 6 Nov 2018 12:34:11 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181106203411.pdce6tgs7dncwflh@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
 <20181106084911.GA22504@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106084911.GA22504@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, rjw@rjwysocki.net, linux-pm@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

On Tue, Nov 06, 2018 at 09:49:11AM +0100, Peter Zijlstra wrote:
> On Mon, Nov 05, 2018 at 11:55:46AM -0500, Daniel Jordan wrote:
> > +Concept
> > +=======
> > +
> > +ktask is built on unbound workqueues to take advantage of the thread management
> > +facilities it provides: creation, destruction, flushing, priority setting, and
> > +NUMA affinity.
> > +
> > +A little terminology up front:  A 'task' is the total work there is to do and a
> > +'chunk' is a unit of work given to a thread.
> 
> So I hate on the task naming. We already have a task, lets not overload
> that name.

Ok, agreed, it's a crowded field with 'task', 'work', 'thread'...

Maybe 'job', since nothing seems to have taken that in kernel/.

> I see no mention of padata anywhere; I also don't see mention of the
> async init stuff. Both appear to me to share, at least in part, the same
> reason for existence.

padata is news to me.  From reading its doc, it comes with some special
requirements of its own, like softirqs disabled during the parallel callback,
and some ktask users need to sleep.  I'll check whether it could be reworked to
handle this.

And yes, async shares the same basic infrastructure, but ktask callers need to
wait, so the two seem fundamentally at odds.  I'll add this explanation in.

> 
> > +Scheduler Interaction
> > +=====================
...
> > +It is possible for a helper thread to start running and then be forced off-CPU
> > +by a higher priority thread.  With the helper's CPU time curtailed by MAX_NICE,
> > +the main thread may wait longer for the task to finish than it would have had
> > +it not started any helpers, so to ensure forward progress at a single-threaded
> > +pace, once the main thread is finished with all outstanding work in the task,
> > +the main thread wills its priority to one helper thread at a time.  At least
> > +one thread will then always be running at the priority of the calling thread.
> 
> What isn't clear is if this calling thread is waiting or not. Only do
> this inheritance trick if it is actually waiting on the work. If it is
> not, nobody cares.

The calling thread waits.  Even if it didn't though, the inheritance trick
would still be desirable for timely completion of the job.

> 
> > +Cgroup Awareness
> > +================
> > +
> > +Given the potentially large amount of CPU time ktask threads may consume, they
> > +should be aware of the cgroup of the task that called into ktask and
> > +appropriately throttled.
> > +
> > +TODO: Implement cgroup-awareness in unbound workqueues.
> 
> Yes.. that needs done.

Great.

> 
> > +Power Management
> > +================
> > +
> > +Starting additional helper threads may cause the system to consume more energy,
> > +which is undesirable on energy-conscious devices.  Therefore ktask needs to be
> > +aware of cpufreq policies and scaling governors.
> > +
> > +If an energy-conscious policy is in use (e.g. powersave, conservative) on any
> > +part of the system, that is a signal that the user has strong power management
> > +preferences, in which case ktask is disabled.
> > +
> > +TODO: Implement this.
> 
> No, don't do that, its broken. Also, we're trying to move to a single
> cpufreq governor for all.
>
> Sure we'll retain 'performance', but powersave and conservative and all
> that nonsense should go away eventually.

Ok, good to know.

> That's not saying you don't need a knob for this; but don't look at
> cpufreq for this.

Ok, I'll dig through power management to see what else is there.  Maybe there's
some way to ask "is this machine energy conscious?"

Thanks for looking through this!
