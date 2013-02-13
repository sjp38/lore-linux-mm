Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 55B786B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 04:51:17 -0500 (EST)
Date: Wed, 13 Feb 2013 10:51:13 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130213095113.GA23562@dhcp22.suse.cz>
References: <20130211195824.GB15951@cmpxchg.org>
 <20130211212756.GC29000@dhcp22.suse.cz>
 <20130211223943.GC15951@cmpxchg.org>
 <20130212095419.GB4863@dhcp22.suse.cz>
 <20130212151002.GD15951@cmpxchg.org>
 <20130212154330.GG4863@dhcp22.suse.cz>
 <20130212161051.GQ2666@linux.vnet.ibm.com>
 <20130212172526.GC25235@cmpxchg.org>
 <20130212183148.GW2666@linux.vnet.ibm.com>
 <20130212195358.GE25235@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130212195358.GE25235@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue 12-02-13 14:53:58, Johannes Weiner wrote:
[...]
> iteration:
> rcu_read_lock()
> dead_count = atomic_read(&hierarchy->dead_count)
> smp_rmb()
> previous = iterator->position
> if (iterator->dead_count != dead_count)
>    /* A cgroup in our hierarchy was killed, pointer might be dangling */
>    don't use iterator
> if (!tryget(&previous))
>    /* The cgroup is marked dead, don't use it */
>    don't use iterator
> next = find_next_and_tryget(hierarchy, &previous)
> /* what happens if destruction of next starts NOW? */

OK, I thought that this depends on the ordering of CSS_DEACT_BIAS and
dead_count writes - because there is no memory ordering enforced between
those two. But it shouldn't matter because we are checking both. If the
increment is seen sooner then we do not care about css_tryget and if css
is deactivated before dead_count++ then the css_tryget would shout.

More interesting ordering, however, is dead_count++ vs. css_put from
cgroup core. Say we have the following:

	CPU0			CPU1			CPU2

iter->position = A;
iter->dead_count = dead_count;
rcu_read_unlock()
return A

mem_cgroup_iter_break
  css_put(A)					bias(A)
  						css_offline()
  						css_put(A) // in cgroup_destroy_locked
							   // last ref and A will be freed
  			rcu_read_lock()
			read parent->dead_count
						parent->dead_count++ // got reordered from css_offline
			css_tryget(A) // kaboom

The reordering window is really huge and I think it is impossible
to trigger in real life. And mem_cgroup_reparent_charges calls
mem_cgroup_start_move unconditionally which in turn calls
synchronize_rcu() which is a full barrier AFAIU so dead_count++ cannot
be reordered ATM.
But should we rely on that? Shouldn't we add smp_wmb
after dead_count++ as I had in an earlier version of the patch?

> css_put(previous)
> iterator->position = next
> smp_wmb()
> iterator->dead_count = dead_count /* my suggestion, instead of a second atomic_read() */
> rcu_read_unlock()
> return next /* caller drops ref eventually, iterator->cgroup becomes weak */
> 
> destruction:
> bias(cgroup->refcount) /* disables future tryget */
> //synchronize_rcu() /* Michal's suggestion */
> atomic_inc(&cgroup->hierarchy->dead_count)
> synchronize_rcu()
> free(cgroup)

Other than that this should work. I will update the patch accordingly.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
