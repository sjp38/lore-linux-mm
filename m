Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF5736B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 17:54:02 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id d6-v6so3215751ybn.14
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:54:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z127-v6sor1261224yba.197.2018.07.18.14.53.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 14:53:59 -0700 (PDT)
Date: Wed, 18 Jul 2018 17:56:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718215644.GB2838@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180717100347.GD2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717100347.GD2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jul 17, 2018 at 12:03:47PM +0200, Peter Zijlstra wrote:
> This is still a scary amount of accounting; not to mention you'll be
> adding O(cgroup-depth) to this in a later patch.
> 
> Where are the performance numbers for all this?

I benchmarked it using our two most scheduling sensitive workloads:
memcache and webserver. They handle a ton of small requests - lots of
wakeups and sleeps with little actual work in between - so they tend
to be canaries for scheduler regressions.

In the tests, the boxes were handling live traffic over the course of
several hours. Half the machines, the control, ran with CONFIG_PSI=n.

For memcache I used eight machines total. They're 2-socket, 14 core,
56 thread boxes. The test runs for half the test period, flips the
test and control kernels on the hardware to rule out HW factors, DC
location etc., then runs the other half of the test.

For the webservers, I used 32 machines total. They're single socket,
16 core, 32 thread machines.

During the memcache test, CPU load was nopsi=78.05% psi=78.98% in the
first half and nopsi=77.52% psi=78.25%, so psi added between 0.7 and
0.9 percentage points to the CPU load, a difference of about 1%.

As far as end-to-end request latency from the client perspective goes,
we don't sample those finely enough to capture the requests going to
those particular machines during the test, but we know the p50
turnaround time in this workload is 54us, and perf bench sched pipe on
those machines show nopsi=5.232666 us/op and psi=5.587347 us/op, so
this doesn't add much here either.

The profile for the pipe benchmark shows:

     0.87%  sched-pipe  [kernel.vmlinux]    [k] psi_group_change
     0.83%  perf.real   [kernel.vmlinux]    [k] psi_group_change
     0.82%  perf.real   [kernel.vmlinux]    [k] psi_task_change
     0.58%  sched-pipe  [kernel.vmlinux]    [k] psi_task_change


The webserver load is running inside 4 nested cgroup levels. The CPU
load with both nopsi and psi kernels was indistinguishable at 81%.

For comparison, we had to disable the cgroup cpu controller on the
webservers because it added 4 percentage points to the CPU% during
this same exact test.

Versions of this accounting code now run on 80% of our fleet. None of
our workloads have reported regressions during the rollout.

[ Also note that the webservers that tested the nopsi kernel were
  during that time susceptible to swap storms, memory livelocks, and
  eventual hardresets because without psi they couldn't run our full
  resource isolation stack that would prevent that ;) ]

Let me know if there are other tests I could run.
