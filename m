Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id BAAE26B005A
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 13:42:10 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so364631eaa.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 10:42:09 -0800 (PST)
Date: Wed, 12 Dec 2012 19:42:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup
 iterators
Message-ID: <20121212184207.GC10374@dhcp22.suse.cz>
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz>
 <1353955671-14385-4-git-send-email-mhocko@suse.cz>
 <CALWz4ixPmvguxQO8s9mqH+OLEXC5LDfzEVFx_qqe2hBaRcsXiA@mail.gmail.com>
 <20121211155432.GC1612@dhcp22.suse.cz>
 <CALWz4izL7fEuQhEvKa7mUqi0sa25mcFP-xnTnL3vU3Z17k7VHg@mail.gmail.com>
 <20121212090652.GB32081@dhcp22.suse.cz>
 <CALWz4iwq+vRN+rreOk7Jg4rHWWBSmNwBW8Kko45E-D8Vi66eQA@mail.gmail.com>
 <20121212183446.GB10374@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121212183446.GB10374@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Wed 12-12-12 19:34:46, Michal Hocko wrote:
> On Wed 12-12-12 10:09:43, Ying Han wrote:
> [...]
> > But If i look at the callers of mem_cgroup_iter(), they all look like
> > the following:
> > 
> > memcg = mem_cgroup_iter(root, NULL, &reclaim);
> > do {
> > 
> >     // do something
> > 
> >     memcg = mem_cgroup_iter(root, memcg, &reclaim);
> > } while (memcg);
> > 
> > So we get out of the loop when memcg returns as NULL, where the
> > last_visited is cached as NULL as well thus no css_get(). That is what
> > I meant by "each reclaim thread closes the loop".
> 
> OK
> 
> > If that is true, the current implementation of mem_cgroup_iter_break()
> > changes that.
> 
> I do not understand this though. Why should we touch the zone-iter
> there?  Just consider, if we did that then all the parallel targeted

Bahh, parallel is only confusing here. Say first child triggers a hard
limit reclaim then root of the hierarchy will be reclaimed first.
iter_break would reset iter->last_visited. Then B triggers the same
reclaim but we will start again from root rather than the first child
because it doesn't know where the other one stopped.

Hope this clarifies it and sorry for all the confusion.

> reclaimers (! global case) would hammer the first node (root) as they
> wouldn't continue where the last one finished.
> 
> [...]
> 
> Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
