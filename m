Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 81D406B0095
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 16:34:07 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so763152pbb.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 13:34:06 -0700 (PDT)
Date: Fri, 19 Oct 2012 13:34:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 06/14] memcg: kmem controller infrastructure
In-Reply-To: <5081269B.5000603@parallels.com>
Message-ID: <alpine.DEB.2.00.1210191331400.17804@chino.kir.corp.google.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-7-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1210171515290.20712@chino.kir.corp.google.com> <507FCA90.8060307@parallels.com>
 <alpine.DEB.2.00.1210181454100.30894@chino.kir.corp.google.com> <5081269B.5000603@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 19 Oct 2012, Glauber Costa wrote:

> >>> What about gfp & __GFP_FS?
> >>>
> >>
> >> Do you intend to prevent or allow OOM under that flag? I personally
> >> think that anything that accepts to be OOM-killed should have GFP_WAIT
> >> set, so that ought to be enough.
> >>
> > 
> > The oom killer in the page allocator cannot trigger without __GFP_FS 
> > because direct reclaim has little chance of being very successful and 
> > thus we end up needlessly killing processes, and that tends to happen 
> > quite a bit if we dont check for it.  Seems like this would also happen 
> > with memcg if mem_cgroup_reclaim() has a large probability of failing?
> > 
> 
> I can indeed see tests for GFP_FS in some key locations in mm/ before
> calling the OOM Killer.
> 
> Should I test for GFP_IO as well?

It's not really necessary, if __GFP_IO isn't set then it wouldn't make 
sense for __GFP_FS to be set.

> If the idea is preventing OOM to
> trigger for allocations that can write their pages back, how would you
> feel about the following test:
> 
> may_oom = (gfp & GFP_KERNEL) && !(gfp & __GFP_NORETRY) ?
> 

I would simply copy the logic from the page allocator and only trigger oom 
for __GFP_FS and !__GFP_NORETRY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
