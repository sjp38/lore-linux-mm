Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D75886B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 16:23:03 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id t20so1841941wju.5
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 13:23:03 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 79si210226wmy.132.2017.01.05.13.23.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 13:23:02 -0800 (PST)
Date: Thu, 5 Jan 2017 16:22:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Message-ID: <20170105212252.GA17613@cmpxchg.org>
References: <bug-190841-27@https.bugzilla.kernel.org/>
 <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, bugzilla-daemon@bugzilla.kernel.org, frolvlad@gmail.com, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed, Jan 04, 2017 at 05:30:37PM -0800, Andrew Morton wrote:
> > My simplified workflow looks like this:
> > 
> > 1. Create a Memory CGroup with memory limit
> > 2. Exec a child process
> > 3. Add the child process PID into the Memory CGroup
> > 4. Wait for the child process to finish
> > 5. Remove the Memory CGroup
> > 
> > The child processes usually run less than 0.1 seconds, but I have lots of them.
> > Normally, I could run over 10000 child processes per minute, but with newer
> > kernels, I can only do 400-500 executions per minute, and my system becomes
> > extremely sluggish (the only indicator of the weirdness I found is an unusually
> > high load average, which sometimes goes over 250!).
> > 
> > Here is a simple reproduction script:
> > 
> > #!/bin/sh
> > CGROUP_BASE=/sys/fs/cgroup/memory/qq
> > 
> > for $i in $(seq 1000); do
> >     echo "Iteration #$i"
> >     sh -c "
> >         mkdir '$CGROUP_BASE'
> >         sh -c 'echo \$$ > $CGROUP_BASE/tasks ; sleep 0.0'
> >         rmdir '$CGROUP_BASE' || true
> >     "
> > done
> > # ===

You're not even running anything concurrently. While I agree with
Michal that cgroup creation and destruction are not the fastest paths,
a load of 250 from a single-threaded testcase is silly.

We recently had a load spikee issue with the on-demand memcg slab
cache duplication, but that should have happened in 4.6 already. I
don't see anything suspicious going into memcontrol.c after 4.6.

When the load is high like this, can you check with ps what the
blocked tasks are?

A run with perf record -a also might give us an idea if cycles go to
the wrong place.

I'll try to reproduce this once I have access to my test machine again
next week.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
