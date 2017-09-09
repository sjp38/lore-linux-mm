Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC7E6B02C3
	for <linux-mm@kvack.org>; Sat,  9 Sep 2017 04:45:57 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 11so8441947pge.4
        for <linux-mm@kvack.org>; Sat, 09 Sep 2017 01:45:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i70sor1689796pfi.35.2017.09.09.01.45.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Sep 2017 01:45:55 -0700 (PDT)
Date: Sat, 9 Sep 2017 01:45:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
In-Reply-To: <alpine.DEB.2.20.1709081601310.27965@nuc-kabylake>
Message-ID: <alpine.DEB.2.10.1709090132590.53827@chino.kir.corp.google.com>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-6-guro@fb.com> <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz> <20170905215344.GA27427@cmpxchg.org> <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz> <alpine.DEB.2.20.1709071122360.20082@nuc-kabylake>
 <alpine.DEB.2.10.1709071502430.143767@chino.kir.corp.google.com> <alpine.DEB.2.20.1709081601310.27965@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 8 Sep 2017, Christopher Lameter wrote:

> Ok. Certainly there were scalability issues (lots of them) and the sysctl
> may have helped there if set globally. But the ability to kill the
> allocating tasks was primarily used in cpusets for constrained allocation.
> 

I remember discussing it with him and he had some data with pretty extreme 
numbers for how long the tasklist iteration was taking.  Regardless, I 
agree it's not pertinent to the discussion if anybody is actively using 
the sysctl, just fun to try to remember the discussions from 10 years ago.  

The problem I'm having with the removal, though, is that the kernel source 
actually uses it itself in tools/testing/fault-injection/failcmd.sh.  
That, to me, suggests there are people outside the kernel source that are 
also probably use it.  We use it as part of our unit testing, although we 
could convert away from it.

These are things that can probably be worked around, but I'm struggling to 
see the whole benefit of it.  It's only defined, there's generic sysctl 
handling, and there's a single conditional in the oom killer.  I wouldn't 
risk the potential userspace breakage.

> The issue of scaling is irrelevant in the context of deciding what to do
> about the sysctl. You can address the issue differently if it still
> exists. The systems with super high NUMA nodes (hundreds to a
> thousand) have somehow fallen out of fashion a bit. So I doubt that this
> is still an issue. And no one of the old stakeholders is speaking up.
> 
> What is the current approach for an OOM occuring in a cpuset or cgroup
> with a restricted numa node set?
> 

It's always been shaky, we simply exclude potential kill victims based on 
whether or not they share mempolicy nodes or cpuset mems with the 
allocating process.  Of course, this could result in no memory freeing 
because a potential victim being allowed to allocate on a particular node 
right now doesn't mean killing it will free memory on that node.  It's 
just more probable in practice.  Nobody has complained about that 
methodology, but we do have internal code that simply kills current for 
mempolicy ooms.  That is because we have priority based oom killing much 
like this patchset implements and then extends it even further to 
processes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
