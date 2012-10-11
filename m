Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id BF2AB6B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 04:50:41 -0400 (EDT)
Date: Thu, 11 Oct 2012 10:50:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] memcg: oom: fix totalpages calculation for
 swappiness==0
Message-ID: <20121011085038.GA29295@dhcp22.suse.cz>
References: <20121010141142.GG23011@dhcp22.suse.cz>
 <alpine.DEB.2.00.1210101346010.31237@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1210101346010.31237@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 10-10-12 13:50:21, David Rientjes wrote:
> On Wed, 10 Oct 2012, Michal Hocko wrote:
> 
> > Hi,
> > I am sending the patch below as an RFC because I am not entirely happy
> > about myself and maybe somebody can come up with a different approach
> > which would be less hackish.
> 
> I don't see this as hackish, 

I didn't like how swappiness spreads outside of the LRU scanning code...

> if memory.swappiness limits access to swap then this shouldn't be
> factored into the calculation, and that's what your patch fixes.
> 
> The reason why the process with the largest rss isn't killed in this case 
> is because all processes have CAP_SYS_ADMIN so they get a 3% bonus;

OK I should have mentioned that I have tested it as root which makes a
big difference with the current upstream as totalpages are considered
only if adj!=0. 
I have originally seen the problem in 3.0 kernel (with fe35004f applied)
where the calculation is different (missing a7f638f9) and we always
consider total_pages there so it doesn't depend on root or oom_score_adj.

> when factoring swap into the calculation and subtracting 3% from
> the score in oom_badness(), they all end up having an internal
> score of 1 so they are all considered equal.  It appears like the
> cgroup_iter_next() iteration for memcg ooms does this in reverse
> order, which is actually helpful so it will select the task that is
> newer.
> 
> The only suggestion I have to make is specify this is for 
> memory.swappiness in the patch title, otherwise:

OK. I will also update the changelog to mention oom_score_adj and
CAP_SYS_ADMIN, mark the patch for stable and repost it.

> Acked-by: David Rientjes <rientjes@google.com>

Thanks
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
