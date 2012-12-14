Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 94C866B0044
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 05:56:29 -0500 (EST)
Date: Fri, 14 Dec 2012 11:56:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg,vmscan: do not break out targeted reclaim without
 reclaimed pages
Message-ID: <20121214105626.GE6898@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <CALWz4ixPmvguxQO8s9mqH+OLEXC5LDfzEVFx_qqe2hBaRcsXiA@mail.gmail.com>
 <20121211155432.GC1612@dhcp22.suse.cz>
 <CALWz4izL7fEuQhEvKa7mUqi0sa25mcFP-xnTnL3vU3Z17k7VHg@mail.gmail.com>
 <20121212090652.GB32081@dhcp22.suse.cz>
 <CALWz4iwq+vRN+rreOk7Jg4rHWWBSmNwBW8Kko45E-D8Vi66eQA@mail.gmail.com>
 <20121212183446.GB10374@dhcp22.suse.cz>
 <20121212184207.GC10374@dhcp22.suse.cz>
 <CALWz4ix7byi=R9_N=LbtpgpvK_rV5UCZGHyWaTECiKqCB2rGwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4ix7byi=R9_N=LbtpgpvK_rV5UCZGHyWaTECiKqCB2rGwQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Thu 13-12-12 17:06:38, Ying Han wrote:
[...]
> Off topic of the following discussion.
> Take the following hierarchy as example:
> 
>                 root
>               /  |   \
>             a   b     c
>                         |  \
>                         d   e
>                         |      \
>                         g      h
> 
> Let's say c hits its hardlimit and then triggers target reclaim. There
> are two reclaimers at the moment and reclaimer_1 starts earlier. The
> cgroup_next_descendant_pre() returns in order : c->d->g->e->h
> 
> Then we might get the reclaim result as the following where each
> reclaimer keep hitting one node of the sub-tree for all the priorities
> like the following:
> 
>                 reclaimer_1  reclaimer_2
> priority 12  c                 d
> ...             c                 d
> ...             c                 d
> ...             c                 d
>            0   c                 d
> 
> However, this is not how global reclaim works:
> 
> the cgroup_next_descendant_pre returns in order: root->a->b->c->d->g->e->h
> 
>                 reclaimer_1  reclaimer_1 reclaimer_1  reclaimer_2
> priority 12  root                 a            b                 c
> ...             root                 a            b                 c
> ...
> ...
> 0
> 
> There is no reason for me to think of why target reclaim behave
> differently from global reclaim, which the later one is just the
> target reclaim of root cgroup.

Well, this is not a fair comparison because global reclaim is not just
targeted reclaim of the root cgroup. The difference is that global
reclaim balances zones while targeted reclaim only tries to get bellow
a threshold (hard or soft limit). So we cannot really do the same thing
for both.

On the other hand you are right that targeted reclaim iteration can be
weird, especially when nodes higher in the hierarchy do not have any
pages to reclaim (if they do not have any tasks then only re-parented
are on the list). Then we would drop the priority rather quickly and
hammering the same group again and again until we exhaust all priorities
and come back to the shrinker which finds out that nothing changed so it
will try again and we will slowly get to something to reclaim (always
starting with DEF_PRIORITY). So true we are doing a lot of work without
any point.

Maybe we shouldn't break out of the loop if we didn't reclaim enough for
targeted reclaim. Something like:
---
