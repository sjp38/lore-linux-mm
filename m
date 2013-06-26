Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 6C42A6B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 19:18:14 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz11so212335pad.16
        for <linux-mm@kvack.org>; Wed, 26 Jun 2013 16:18:13 -0700 (PDT)
Date: Wed, 26 Jun 2013 16:18:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <51C8F4B9.9060604@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1306261606050.27897@chino.kir.corp.google.com>
References: <20130603193147.GC23659@dhcp22.suse.cz> <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com> <20130604095514.GC31242@dhcp22.suse.cz> <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com> <20130605093937.GK15997@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com> <20130610142321.GE5138@dhcp22.suse.cz> <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com> <20130612202348.GA17282@dhcp22.suse.cz> <alpine.DEB.2.02.1306121408490.24902@chino.kir.corp.google.com>
 <20130613151602.GG23070@dhcp22.suse.cz> <alpine.DEB.2.02.1306131508300.8686@chino.kir.corp.google.com> <51BA6A2A.3060107@jp.fujitsu.com> <alpine.DEB.2.02.1306140254590.8780@chino.kir.corp.google.com> <51C8F4B9.9060604@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 25 Jun 2013, Kamezawa Hiroyuki wrote:

> Considering only memcg, bypassing all charge-limit-check will work.
> But as you say, that will not work against global-oom.

I think it will since we have per-zone memory reserves that can be 
bypassed in the page allocator, not to the level of PF_MEMALLOC or 
TIF_MEMDIE but perhaps to the min watermark / 4, for example.  A userspace 
global oom handler will obviously be mlocked in memory and this reserve is 
used only for true kmem accounting so that reading things like the memcg 
tasks file or reading /proc/pid/stat works, or dynamically allocate a 
buffer to store data to iterate over.  This is why 
memory.oom_delay_millisecs is crucial: we want the same functionality that 
the "user root" has for global oom conditions at the memcg root level and 
in case reserves are exhausted that the kernel will kill something (which 
should be rare, but possible) and use the rest of memory reserves to allow 
to exit.

> > Even with all of the above (which is not actually that invasive of a
> > patch), I still think we need memory.oom_delay_millisecs.  I probably made
> > a mistake in describing what that is addressing if it seems like it's
> > trying to address any of the above.
> > 
> > If a userspace oom handler fails to respond even with access to those
> > "memcg reserves",
> 
> How this happens ?
> 

If the memcg reserves are exhausted, then the kernel needs to kill 
something even in global oom conditions (consider a "user root" memcg tree 
to be the same as a global oom condition for processes attached to that 
tree) since otherwise the machine hangs.  There's no guarantee that some 
root process sitting in the root memcg would be able to enforce this delay 
as Michal suggests since reserves could be depleted.  It's important we 
don't do something as extreme as PF_MEMALLOC so all per-zone reserves are 
depleted so that the kernel can still intervene and kill something when 
userspace is unresponsive.

> Someone may be against that kind of control and say "Hey, I have better idea".
> That was another reason that oom-scirpiting was discussed. No one can
> implement
> general-purpose-victim-selection-logic.
> 

Completely agreed, and our experience shows that users who manipulate 
their own "user root" memcgs have their own logic, this is why we're 
trying to make userspace oom handling as powerful as possible without 
risking making the machine unresponsive.

> IMHO, it will be difficult but allowing to write script/filter for oom-killing
> will be worth to try. like..
> 
> ==
> for_each_process :
>   if comm == mem_manage_daemon :
>      continue
>   if user == root              :
>      continue
>   score = default_calc_score()
>   if score > high_score :
>      selected = current
> ==
> 

This is effectively what already happens with the oom delay as proposed 
here, the userspace oom handler is given access to "memcg reserves" and a 
period of time to respond; if that fails, then the kernel will kill 
something the next time we try to charge to the memcg.

> BTW, if you love the logic in the userland oom daemon, why you can't implement
> it in the kernel ? Does that do some pretty things other than sending SIGKILL
> ?
> 

Some do "pretty" things like collect stats and dump it before killing 
something, but we also want oom handlers that don't do SIGKILL at all.  An 
example: we statically allocate hugepages at boot because we need a large 
percentage of memory to be backed by hugepages for a certain class of 
applications and it's only available at boot.  We also have a userspace 
that runs on these machines that is shared between hugepage machines and 
non-hugepage machines.  At times, this userspace becomes oom because the 
remainder of available memory is allocated as hugetlb pages when in 
reality they are unmapped and sitting in a free pool.  In that case, our 
userspace oom handler wants to free those hugetlb pages back to the kernel 
down to a certain watermark and then opportunistically reallocate them to 
the pool when memory usage on the system is lower due to spikes in the 
userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
