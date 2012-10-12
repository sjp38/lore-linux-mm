Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 3FB916B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 09:01:45 -0400 (EDT)
Date: Fri, 12 Oct 2012 15:01:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: oom: fix totalpages calculation for
 memory.swappiness==0
Message-ID: <20121012130141.GA22083@dhcp22.suse.cz>
References: <20121011085038.GA29295@dhcp22.suse.cz>
 <1349945859-1350-1-git-send-email-mhocko@suse.cz>
 <20121011122037.GE31863@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121011122037.GE31863@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 11-10-12 08:20:37, Johannes Weiner wrote:
> On Thu, Oct 11, 2012 at 10:57:39AM +0200, Michal Hocko wrote:
> > oom_badness takes totalpages argument which says how many pages are
> > available and it uses it as a base for the score calculation. The value
> > is calculated by mem_cgroup_get_limit which considers both limit and
> > total_swap_pages (resp. memsw portion of it).
> > 
> > This is usually correct but since fe35004f (mm: avoid swapping out
> > with swappiness==0) we do not swap when swappiness is 0 which means
> > that we cannot really use up all the totalpages pages. This in turn
> > confuses oom score calculation if the memcg limit is much smaller than
> > the available swap because the used memory (capped by the limit) is
> > negligible comparing to totalpages so the resulting score is too small
> > if adj!=0 (typically task with CAP_SYS_ADMIN or non zero oom_score_adj).
> > A wrong process might be selected as result.
> > 
> > The same issue exists for the global oom killer as well but it is not
> > that problematic as the amount of the RAM is usually much bigger than
> > the swap space.
> > 
> > The problem can be worked around by checking mem_cgroup_swappiness==0
> > and not considering swap at all in such a case.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > Acked-by: David Rientjes <rientjes@google.com>
> > Cc: stable [3.5+]
> 
> I also don't think it's hackish, the limit depends very much on
> whether reclaim can swap, so it's natural that swappiness shows up
> here.

OK, maybe I was just a bit over sensitive here. The other reason I
didn't like it is that swappiness might change over time we some of the
tasks could be already swapped out. oom_score already considers
MM_SWAPENTS but this just tells the number of swapped out ptes not the
pages. So we could still kill something that is resident with much
smaller memory footprint. But this is a different issue and probably a
corner case.

> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
