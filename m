Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 5443C6B0002
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 11:24:45 -0500 (EST)
Date: Tue, 12 Feb 2013 17:24:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130212162442.GJ4863@dhcp22.suse.cz>
References: <20130211151649.GD19922@dhcp22.suse.cz>
 <20130211175619.GC13218@cmpxchg.org>
 <20130211192929.GB29000@dhcp22.suse.cz>
 <20130211195824.GB15951@cmpxchg.org>
 <20130211212756.GC29000@dhcp22.suse.cz>
 <20130211223943.GC15951@cmpxchg.org>
 <20130212095419.GB4863@dhcp22.suse.cz>
 <20130212151002.GD15951@cmpxchg.org>
 <20130212154330.GG4863@dhcp22.suse.cz>
 <20130212161332.GI4863@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130212161332.GI4863@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue 12-02-13 17:13:32, Michal Hocko wrote:
> On Tue 12-02-13 16:43:30, Michal Hocko wrote:
> [...]
> The example was not complete:
> 
> > Wait a moment. But what prevents from the following race?
> > 
> > rcu_read_lock()
> 
> cgroup_next_descendant_pre
> css_tryget(css);
> memcg = mem_cgroup_from_css(css)		atomic_add(CSS_DEACT_BIAS, &css->refcnt)
> 
> > 						mem_cgroup_css_offline(memcg)
> 
> We should be safe if we did synchronize_rcu() before root->dead_count++,
> no?
> Because then we would have a guarantee that if css_tryget(memcg)
> suceeded then we wouldn't race with dead_count++ it triggered.
> 
> > 						root->dead_count++
> > iter->last_dead_count = root->dead_count
> > iter->last_visited = memcg
> > 						// final
> > 						css_put(memcg);
> > // last_visited is still valid
> > rcu_read_unlock()
> > [...]
> > // next iteration
> > rcu_read_lock()
> > iter->last_dead_count == root->dead_count
> > // KABOOM

Ohh I have missed that we took a reference on the current memcg which
will be stored into last_visited. And then later, during the next
iteration it will be still alive until we are done because previous
patch moved css_put to the very end.
So this race is not possible. I still need to think about parallel
iteration and a race with removal.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
