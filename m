Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD7A56B000C
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 11:12:35 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id p127-v6so2364058ywg.1
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 08:12:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d137-v6sor2632477ywb.85.2018.07.24.08.12.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 08:12:30 -0700 (PDT)
Date: Tue, 24 Jul 2018 11:15:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180724151519.GA11598@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <CAKTCnzmt_CnfZMMdK9_-rBrL4kUmoE70nVbnE58CJp++FP0CCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnzmt_CnfZMMdK9_-rBrL4kUmoE70nVbnE58CJp++FP0CCQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, surenb@google.com, Vinayak Menon <vinmenon@codeaurora.org>, Christoph Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-team@fb.com

Hi Balbir,

On Tue, Jul 24, 2018 at 07:14:02AM +1000, Balbir Singh wrote:
> Does the mechanism scale? I am a little concerned about how frequently
> this infrastructure is monitored/read/acted upon.

I expect most users to poll in the frequency ballpark of the running
averages (10s, 1m, 5m). Our OOMD defaults to 5s polling of the 10s
average; we collect the 1m average once per minute from our machines
and cgroups to log the system/workload health trends in our fleet.

Suren has been experimenting with adaptive polling down to the
millisecond range on Android.

> Why aren't existing mechanisms sufficient

Our existing stuff gives a lot of indication when something *may* be
an issue, like the rate of page reclaim, the number of refaults, the
average number of active processes, one task waiting on a resource.

But the real difference between an issue and a non-issue is how much
it affects your overall goal of making forward progress or reacting to
a request in time. And that's the only thing users really care
about. It doesn't matter whether my system is doing 2314 or 6723 page
refaults per minute, or scanned 8495 pages recently. I need to know
whether I'm losing 1% or 20% of my time on overcommitted memory.

Delayacct is time-based, so it's a step in the right direction, but it
doesn't aggregate tasks and CPUs into compound productivity states to
tell you if only parts of your workload are seeing delays (which is
often tolerable for the purpose of ensuring maximum HW utilization) or
your system overall is not making forward progress. That aggregation
isn't something you can do in userspace with polled delayacct data.

> -- why is the avg delay calculation in the kernel?

For one, as per above, most users will probably be using the standard
averaging windows, and we already have this highly optimizd
infrastructure from the load average. I don't see why we shouldn't use
that instead of exporting an obscure number that requires most users
to have an additional library or copy-paste the loadavg code.

I also mentioned the OOM killer as a likely in-kernel user of the
pressure percentages to protect from memory livelocks out of the box,
in which case we have to do this calculation in the kernel anyway.

> There is no talk about the overhead this introduces in general, may be
> the details are in the patches. I'll read through them

I sent an email on benchmarks and overhead in one of the subthreads, I
will include that information in the cover letter in v3.

https://lore.kernel.org/lkml/20180718215644.GB2838@cmpxchg.org/

Thanks!
