Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 2C6CA6B0078
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 05:49:11 -0400 (EDT)
Date: Mon, 15 Oct 2012 11:49:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] memcg: oom: fix totalpages calculation for
 swappiness==0
Message-ID: <20121015094907.GE29069@dhcp22.suse.cz>
References: <20121010141142.GG23011@dhcp22.suse.cz>
 <507BD33C.4030209@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <507BD33C.4030209@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 15-10-12 18:11:24, KAMEZAWA Hiroyuki wrote:
> (2012/10/10 23:11), Michal Hocko wrote:
[...]
> > From 445c2ced957cd77cbfca44d0e3f5056fed252a34 Mon Sep 17 00:00:00 2001
> >From: Michal Hocko <mhocko@suse.cz>
> >Date: Wed, 10 Oct 2012 15:46:54 +0200
> >Subject: [PATCH] memcg: oom: fix totalpages calculation for swappiness==0
> >
> >oom_badness takes totalpages argument which says how many pages are
> >available and it uses it as a base for the score calculation. The value
> >is calculated by mem_cgroup_get_limit which considers both limit and
> >total_swap_pages (resp. memsw portion of it).
> >
> >This is usually correct but since fe35004f (mm: avoid swapping out
> >with swappiness==0) we do not swap when swappiness is 0 which means
> >that we cannot really use up all the totalpages pages. This in turn
> >confuses oom score calculation if the memcg limit is much smaller
> >than the available swap because the used memory (capped by the limit)
> >is negligible comparing to totalpages so the resulting score is too
> >small. A wrong process might be selected as result.
> >
> >The same issue exists for the global oom killer as well but it is not
> >that problematic as the amount of the RAM is usually much bigger than
> >the swap space.
> >
> >The problem can be worked around by checking swappiness==0 and not
> >considering swap at all.
> >
> >Signed-off-by: Michal Hocko <mhocko@suse.cz>@jp.fujitsu.com>
> 
> Hm...where should we describe this behavior....
> Documentation/cgroup/memory.txt "5.3 swappiness" ?

Hmm. The swappiness behavior is consistent with the global knob. On the
other hand the visible effects are still "stronger" as the environment
is much more constrained with memcgs so the corner cases are hit more
frequently. But this is somehow expected so I am not sure whether we
need to be explicit about this one.
Maybe we could be more explicit about the swappiness==0 behavior in
Documentation/sysctl/vm.txt because the current description is quite
vague as it doesn't say anything about the range. Maybe a patch bellow
will help to clarify this?

> Anyway, the patch itself seems good.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thanks!

---
