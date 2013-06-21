Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 159D06B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 18:35:44 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp16so8425397pbb.0
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 15:35:43 -0700 (PDT)
Date: Fri, 21 Jun 2013 15:35:33 -0700
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH v6] memcg: event control at vmpressure.
Message-ID: <20130621223533.GA22338@lizard>
References: <20130618110151.GI13677@dhcp22.suse.cz>
 <00fd01ce6ce0$82eac0a0$88c041e0$%kim@samsung.com>
 <20130619125329.GB16457@dhcp22.suse.cz>
 <000401ce6d5c$566ac620$03405260$%kim@samsung.com>
 <20130620121649.GB27196@dhcp22.suse.cz>
 <001e01ce6e15$3d183bd0$b748b370$%kim@samsung.com>
 <001f01ce6e15$b7109950$2531cbf0$%kim@samsung.com>
 <20130621012234.GF11659@bbox>
 <20130621091944.GC12424@dhcp22.suse.cz>
 <20130621162743.GA2837@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20130621162743.GA2837@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hyunhee Kim <hyunhee.kim@samsung.com>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

Hi Minchan,

Thanks for your thoughtful reviews!

On Sat, Jun 22, 2013 at 01:27:43AM +0900, Minchan Kim wrote:
> On Fri, Jun 21, 2013 at 11:19:44AM +0200, Michal Hocko wrote:
> > On Fri 21-06-13 10:22:34, Minchan Kim wrote:
> > > On Fri, Jun 21, 2013 at 09:24:38AM +0900, Hyunhee Kim wrote:
> > > > In the original vmpressure, events are triggered whenever there is a reclaim
> > > > activity. This becomes overheads to user space module and also increases
> > > 
> > > Not true.
> > > We have lots of filter to not trigger event even if reclaim is going on.
> > > Your statement would make confuse.
> > 
> > Where is the filter implemented? In the kernel? I do not see any
> > throttling in the current mm tree.
> 
> 1. mem_cgroup_soft_limit_reclaim
> 2. reclaim caused by DMA zone
> 3. vmpressure_win

(Which is going to be machine-size dependant. Plus, it is also an option
to add more filters into the kernel, userland does not need to know all
these "details".)

> > yes, this is the risk of the edge triggering and the user has to be
> > prepared for that. I still think that it makes some sense to have the
> > two modes.
> 
> I'm not sure it's good idea.

After your explanations, it sounds like a bad idea to me. :)

> How could user overcome above problem?
[...]
> So, the description should include how to overcome above situation in
> userspace efficiently even though memory is really tight, which we don't
> have extra memory to read vmstat.

Exactly. What userland would do is it will try to play games with vmstat,
e.g. polling it until it makes sure (by some heuristics) that it is
[again] safe to rely on the notifications. This makes the edge-triggered
interface simply unpredictible.

Until we find any better scheme for filtering, I'd suggest abandon the
idea of the edge tirggered stuff. Instead, I see a possible solution in
defining a new pressure level, or even a new scale (alongside with the
current "low/mid/critical" one), which will have a well-defined behaviour
and that will suit Samsung's needs.

(And for the time being the userland can perfectly fine play the vmstat
games after closing or not reading eventfd, that way you won't receive the
notifications and thus will still able to implement kind of "filtering" in
userland. Surely it is a hack, but much better than the unpredictible
behaviour on the kernel side.)

Thanks,

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
