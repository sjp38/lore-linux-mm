Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5564C6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 07:33:45 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id xr1so120556974wjb.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 04:33:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k9si81647957wmk.86.2017.01.05.04.33.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 04:33:43 -0800 (PST)
Date: Thu, 5 Jan 2017 13:33:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Message-ID: <20170105123341.GQ21618@dhcp22.suse.cz>
References: <bug-190841-27@https.bugzilla.kernel.org/>
 <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, bugzilla-daemon@bugzilla.kernel.org, frolvlad@gmail.com, linux-mm@kvack.org

On Wed 04-01-17 17:30:37, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed, 21 Dec 2016 19:56:16 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=190841
> > 
> >             Bug ID: 190841
> >            Summary: [REGRESSION] Intensive Memory CGroup removal leads to
> >                     high load average 10+
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 4.7.0-rc1+
> >           Hardware: All
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Other
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: frolvlad@gmail.com
> >         Regression: No
> > 
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

Well, yes, rmdir is not the cheapest operation... Since b2052564e66d
("mm: memcontrol: continue cache reclaim from offlined groups") we are
postponing the real memcg removal to later, when there is a memory
pressure. 73f576c04b94 ("mm: memcontrol: fix cgroup creation failure
after many small jobs") fixed unbound id space consumption. I would be
quite surprised if this caused a new regression. But the report says
that this is 4.7+ thing. I would expect older kernels would just refuse
the create new cgroups... Maybe that happens in your script and just
gets unnoticed?

We might come up with some more harderning in the offline path (e.g.
count the number of dead memcgs and force their reclaim after some
number gets accumulated). But all that just adds more code and risk of
regression for something that is not used very often. Cgroups
creation/destruction are too heavy operations to be done for very
shortlived process. Even without memcg involved. Are there any strong
reasons you cannot reuse an existing cgroup?

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

one possible workaround would be to do
            echo 1 > $CGROUP_BASE/memory.force_empty

before you remove the cgroup. That should drop the existing charges - at
least for the page cache which might be what keeps those memcgs alive.

> >         rmdir '$CGROUP_BASE' || true
> >     "
> > done
> > # ===

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
