Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id AFCEF6B0031
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 17:17:57 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so6246717pbb.33
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 14:17:57 -0700 (PDT)
Date: Mon, 3 Jun 2013 14:17:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <20130603193147.GC23659@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com> <20130530150539.GA18155@dhcp22.suse.cz> <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com> <20130531081052.GA32491@dhcp22.suse.cz> <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz> <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com> <20130601102058.GA19474@dhcp22.suse.cz> <alpine.DEB.2.02.1306031102480.7956@chino.kir.corp.google.com> <20130603193147.GC23659@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 3 Jun 2013, Michal Hocko wrote:

> > What do you suggest when you read the "tasks" file and it returns -ENOMEM 
> > because kmalloc() fails because the userspace oom handler's memcg is also 
> > oom? 
> 
> That would require that you track kernel allocations which is currently
> done only for explicit caches.
> 

That will not always be the case, and I think this could be a prerequisite 
patch for such support that we have internally.  I'm not sure a userspace 
oom notifier would want to keep a preallocated buffer around that is 
mlocked in memory for all possible lengths of this file.

> > Obviously it's not a situation we want to get into, but unless you 
> > know that handler's exact memory usage across multiple versions, nothing 
> > else is sharing that memcg, and it's a perfect implementation, you can't 
> > guarantee it.  We need to address real world problems that occur in 
> > practice.
> 
> If you really need to have such a guarantee then you can have a _global_
> watchdog observing oom_control of all groups that provide such a vague
> requirements for oom user handlers.
> 

The whole point is to allow the user to implement their own oom policy.  
If the policy was completely encapsulated in kernel code, we don't need to 
ever disable the oom killer even with memory.oom_control.  Users may 
choose to kill the largest process, the newest process, the oldest 
process, sacrifice children instead of parents, prevent forkbombs, 
implement their own priority scoring (which is what we do), kill the 
allocating task, etc.

To not merge this patch, I'd ask that you show an alternative that allows 
users to implement their own userspace oom handlers and not require admin 
intervention when things go wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
