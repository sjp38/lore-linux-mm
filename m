Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 1DC186B0002
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 12:12:21 -0500 (EST)
Date: Tue, 12 Feb 2013 18:12:16 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130212171216.GA17663@dhcp22.suse.cz>
References: <20130211192929.GB29000@dhcp22.suse.cz>
 <20130211195824.GB15951@cmpxchg.org>
 <20130211212756.GC29000@dhcp22.suse.cz>
 <20130211223943.GC15951@cmpxchg.org>
 <20130212095419.GB4863@dhcp22.suse.cz>
 <20130212151002.GD15951@cmpxchg.org>
 <20130212154330.GG4863@dhcp22.suse.cz>
 <20130212161332.GI4863@dhcp22.suse.cz>
 <20130212162442.GJ4863@dhcp22.suse.cz>
 <63d3b5fa-dbc6-4bc9-8867-f9961e644305@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <63d3b5fa-dbc6-4bc9-8867-f9961e644305@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue 12-02-13 11:41:03, Johannes Weiner wrote:
> 
> 
> Michal Hocko <mhocko@suse.cz> wrote:
> 
> >On Tue 12-02-13 17:13:32, Michal Hocko wrote:
> >> On Tue 12-02-13 16:43:30, Michal Hocko wrote:
> >> [...]
> >> The example was not complete:
> >> 
> >> > Wait a moment. But what prevents from the following race?
> >> > 
> >> > rcu_read_lock()
> >> 
> >> cgroup_next_descendant_pre
> >> css_tryget(css);
> >> memcg = mem_cgroup_from_css(css)		atomic_add(CSS_DEACT_BIAS,
> >&css->refcnt)
> >> 
> >> > 						mem_cgroup_css_offline(memcg)
> >> 
> >> We should be safe if we did synchronize_rcu() before
> >root->dead_count++,
> >> no?
> >> Because then we would have a guarantee that if css_tryget(memcg)
> >> suceeded then we wouldn't race with dead_count++ it triggered.
> >> 
> >> > 						root->dead_count++
> >> > iter->last_dead_count = root->dead_count
> >> > iter->last_visited = memcg
> >> > 						// final
> >> > 						css_put(memcg);
> >> > // last_visited is still valid
> >> > rcu_read_unlock()
> >> > [...]
> >> > // next iteration
> >> > rcu_read_lock()
> >> > iter->last_dead_count == root->dead_count
> >> > // KABOOM
> >
> >Ohh I have missed that we took a reference on the current memcg which
> >will be stored into last_visited. And then later, during the next
> >iteration it will be still alive until we are done because previous
> >patch moved css_put to the very end.
> >So this race is not possible. I still need to think about parallel
> >iteration and a race with removal.
> 
> I thought the whole point was to not have a reference in last_visited
> because have the iterator might be unused indefinitely :-)

OK, it seems that I managed to confuse ;)

> We only store a pointer and validate it before use the next time
> around.  So I think the race is still possible, but we can deal with
> it by not losing concurrent dead count changes, i.e. one atomic read
> in the iterator function.

All reads from root->dead_count are atomic already, so I am not sure
what you mean here. Anyway, I hope I won't make this even more confusing
if I post what I have right now:
---
