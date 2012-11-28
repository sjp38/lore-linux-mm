Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 89F256B0062
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 04:33:39 -0500 (EST)
Date: Wed, 28 Nov 2012 10:33:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20121128093336.GD12309@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <50B5CFBF.2090100@jp.fujitsu.com>
 <20121128091745.GC12309@dhcp22.suse.cz>
 <50B5D82D.6010109@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50B5D82D.6010109@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Li Zefan <lizefan@huawei.com>

On Wed 28-11-12 13:23:57, Glauber Costa wrote:
> On 11/28/2012 01:17 PM, Michal Hocko wrote:
> > On Wed 28-11-12 17:47:59, KAMEZAWA Hiroyuki wrote:
> >> (2012/11/27 3:47), Michal Hocko wrote:
> > [...]
> >>> +		/*
> >>> +		 * Even if we found a group we have to make sure it is alive.
> >>> +		 * css && !memcg means that the groups should be skipped and
> >>> +		 * we should continue the tree walk.
> >>> +		 * last_visited css is safe to use because it is protected by
> >>> +		 * css_get and the tree walk is rcu safe.
> >>> +		 */
> >>> +		if (css == &root->css || (css && css_tryget(css)))
> >>> +			memcg = mem_cgroup_from_css(css);
> >>
> >> Could you note that this iterator will never visit dangling(removed)
> >> memcg, somewhere ?
> > 
> > OK, I can add it to the function comment but the behavior hasn't changed
> > so I wouldn't like to confuse anybody.
> > 
> >> Hmm, I'm not sure but it may be trouble at shrkinking dangling
> >> kmem_cache(slab).
> > 
> > We do not shrink slab at all. 
> 
> yet. However...
> 
> > Those objects that are in a dead memcg
> > wait for their owner tho release them which will make the dangling group
> > eventually go away
> > 
> >>
> >> Costa, how do you think ?
> >>
> 
> In general, I particularly believe it is a good idea to skip dead memcgs
> in the iterator. I don't anticipate any problems with shrinking at all.

We even cannot iterate dead ones because their cgroups are gone and so
you do not have any way to iterate. So either make them alive by css_get
or we cannot iterate them.

> Basically, we will only ever actively shrink when the memcg is dying, at
> which point it is still alive.
> After this, it's better to just leave it to vmscan. Whenever there is
> pressure, it will go away.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
