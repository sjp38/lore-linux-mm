Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id E6CD26B0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 12:56:57 -0500 (EST)
Date: Tue, 12 Feb 2013 18:56:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130212175651.GC17663@dhcp22.suse.cz>
References: <20130211151649.GD19922@dhcp22.suse.cz>
 <20130211175619.GC13218@cmpxchg.org>
 <20130211192929.GB29000@dhcp22.suse.cz>
 <20130211195824.GB15951@cmpxchg.org>
 <20130211212756.GC29000@dhcp22.suse.cz>
 <20130211223943.GC15951@cmpxchg.org>
 <20130212095419.GB4863@dhcp22.suse.cz>
 <20130212151002.GD15951@cmpxchg.org>
 <20130212154330.GG4863@dhcp22.suse.cz>
 <20130212161051.GQ2666@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130212161051.GQ2666@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue 12-02-13 08:10:51, Paul E. McKenney wrote:
> On Tue, Feb 12, 2013 at 04:43:30PM +0100, Michal Hocko wrote:
> > On Tue 12-02-13 10:10:02, Johannes Weiner wrote:
> > > On Tue, Feb 12, 2013 at 10:54:19AM +0100, Michal Hocko wrote:
> > > > On Mon 11-02-13 17:39:43, Johannes Weiner wrote:
> > > > > On Mon, Feb 11, 2013 at 10:27:56PM +0100, Michal Hocko wrote:
> > > > > > On Mon 11-02-13 14:58:24, Johannes Weiner wrote:
> > > > > > > That way, if the dead count gives the go-ahead, you KNOW that the
> > > > > > > position cache is valid, because it has been updated first.
> > > > > > 
> > > > > > OK, you are right. We can live without css_tryget because dead_count is
> > > > > > either OK which means that css would be alive at least this rcu period
> > > > > > (and RCU walk would be safe as well) or it is incremented which means
> > > > > > that we have started css_offline already and then css is dead already.
> > > > > > So css_tryget can be dropped.
> > > > > 
> > > > > Not quite :)
> > > > > 
> > > > > The dead_count check is for completed destructions,
> > > > 
> > > > Not quite :P. dead_count is incremented in css_offline callback which is
> > > > called before the cgroup core releases its last reference and unlinks
> > > > the group from the siblinks. css_tryget would already fail at this stage
> > > > because CSS_DEACT_BIAS is in place at that time but this doesn't break
> > > > RCU walk. So I think we are safe even without css_get.
> > > 
> > > But you drop the RCU lock before you return.
> > >
> > > dead_count IS incremented for every destruction, but it's not reliable
> > > for concurrent ones, is what I meant.  Again, if there is a dead_count
> > > mismatch, your pointer might be dangling, easy case.  However, even if
> > > there is no mismatch, you could still race with a destruction that has
> > > marked the object dead, and then frees it once you drop the RCU lock,
> > > so you need try_get() to check if the object is dead, or you could
> > > return a pointer to freed or soon to be freed memory.
> > 
> > Wait a moment. But what prevents from the following race?
> > 
> > rcu_read_lock()
> > 						mem_cgroup_css_offline(memcg)
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
> > 
> > The race window between dead_count++ and css_put is quite big but that
> > is not important because that css_put can happen anytime before we start
> > the next iteration and take rcu_read_lock.
> 
> The usual approach is to make sure that there is a grace period (either
> synchronize_rcu() or call_rcu()) between the time that the data is
> made inaccessible to readers (this would be mem_cgroup_css_offline()?)
> and the time it is freed (css_put(), correct?).

Yes, that was my suggestion and I put it before dead_count is
incremented down the mem_cgroup_css_offline road.

Johannes still thinks we can do without it if we reduce the number of
atomic_read(dead_count) which sounds like a way to go but I will rather
think about it with a fresh head tomorrow.

Anyway, thanks for jumping in. Earth is always a bit shaky when all the
barriers and rcu mix together.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
