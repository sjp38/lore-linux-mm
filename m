Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id F2AB16B0002
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 14:54:17 -0500 (EST)
Date: Tue, 12 Feb 2013 14:53:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130212195358.GE25235@cmpxchg.org>
References: <20130211192929.GB29000@dhcp22.suse.cz>
 <20130211195824.GB15951@cmpxchg.org>
 <20130211212756.GC29000@dhcp22.suse.cz>
 <20130211223943.GC15951@cmpxchg.org>
 <20130212095419.GB4863@dhcp22.suse.cz>
 <20130212151002.GD15951@cmpxchg.org>
 <20130212154330.GG4863@dhcp22.suse.cz>
 <20130212161051.GQ2666@linux.vnet.ibm.com>
 <20130212172526.GC25235@cmpxchg.org>
 <20130212183148.GW2666@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130212183148.GW2666@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue, Feb 12, 2013 at 10:31:48AM -0800, Paul E. McKenney wrote:
> On Tue, Feb 12, 2013 at 12:25:26PM -0500, Johannes Weiner wrote:
> > On Tue, Feb 12, 2013 at 08:10:51AM -0800, Paul E. McKenney wrote:
> > > On Tue, Feb 12, 2013 at 04:43:30PM +0100, Michal Hocko wrote:
> > > > On Tue 12-02-13 10:10:02, Johannes Weiner wrote:
> > > > > On Tue, Feb 12, 2013 at 10:54:19AM +0100, Michal Hocko wrote:
> > > > > > On Mon 11-02-13 17:39:43, Johannes Weiner wrote:
> > > > > > > On Mon, Feb 11, 2013 at 10:27:56PM +0100, Michal Hocko wrote:
> > > > > > > > On Mon 11-02-13 14:58:24, Johannes Weiner wrote:
> > > > > > > > > That way, if the dead count gives the go-ahead, you KNOW that the
> > > > > > > > > position cache is valid, because it has been updated first.
> > > > > > > > 
> > > > > > > > OK, you are right. We can live without css_tryget because dead_count is
> > > > > > > > either OK which means that css would be alive at least this rcu period
> > > > > > > > (and RCU walk would be safe as well) or it is incremented which means
> > > > > > > > that we have started css_offline already and then css is dead already.
> > > > > > > > So css_tryget can be dropped.
> > > > > > > 
> > > > > > > Not quite :)
> > > > > > > 
> > > > > > > The dead_count check is for completed destructions,
> > > > > > 
> > > > > > Not quite :P. dead_count is incremented in css_offline callback which is
> > > > > > called before the cgroup core releases its last reference and unlinks
> > > > > > the group from the siblinks. css_tryget would already fail at this stage
> > > > > > because CSS_DEACT_BIAS is in place at that time but this doesn't break
> > > > > > RCU walk. So I think we are safe even without css_get.
> > > > > 
> > > > > But you drop the RCU lock before you return.
> > > > >
> > > > > dead_count IS incremented for every destruction, but it's not reliable
> > > > > for concurrent ones, is what I meant.  Again, if there is a dead_count
> > > > > mismatch, your pointer might be dangling, easy case.  However, even if
> > > > > there is no mismatch, you could still race with a destruction that has
> > > > > marked the object dead, and then frees it once you drop the RCU lock,
> > > > > so you need try_get() to check if the object is dead, or you could
> > > > > return a pointer to freed or soon to be freed memory.
> > > > 
> > > > Wait a moment. But what prevents from the following race?
> > > > 
> > > > rcu_read_lock()
> > > > 						mem_cgroup_css_offline(memcg)
> > > > 						root->dead_count++
> > > > iter->last_dead_count = root->dead_count
> > > > iter->last_visited = memcg
> > > > 						// final
> > > > 						css_put(memcg);
> > > > // last_visited is still valid
> > > > rcu_read_unlock()
> > > > [...]
> > > > // next iteration
> > > > rcu_read_lock()
> > > > iter->last_dead_count == root->dead_count
> > > > // KABOOM
> > > > 
> > > > The race window between dead_count++ and css_put is quite big but that
> > > > is not important because that css_put can happen anytime before we start
> > > > the next iteration and take rcu_read_lock.
> > > 
> > > The usual approach is to make sure that there is a grace period (either
> > > synchronize_rcu() or call_rcu()) between the time that the data is
> > > made inaccessible to readers (this would be mem_cgroup_css_offline()?)
> > > and the time it is freed (css_put(), correct?).
> > 
> > Absolutely!  And there is a synchronize_rcu() in between those two
> > operations.
> > 
> > However, we want to keep a weak reference to the cgroup after we drop
> > the rcu read-side lock, so rcu alone is not enough for us to guarantee
> > object life time.  We still have to carefully detect any concurrent
> > offlinings in order to validate the weak reference next time around.
> 
> That would make things more interesting.  ;-)
> 
> Exactly who or what holds the weak reference?  And the idea is that if
> you attempt to use the weak reference beforehand, the css_put() does not
> actually free it, but if you attempt to use it afterwards, you get some
> sort of failure indication?

Yes, exactly.  We are using a seqlock-style cookie comparison to see
if any objects in the pool of objects that we may point to was
destroyed.  We are having trouble to agree on how to safely read the
counter :-)

Long version:

It's an iterator over a hierarchy of cgroups, but page reclaim may
stop iteration at will and might not come back for an indefinite
amount of time (until memory pressure triggers reclaim again).  So we
want to allow cgroups to be destroyed while one of the iterators may
still pointing at it (we have iterators per-node, per-zone, per
reclaim priority level, that's why it's not feasible to invalidate
them pro-actively upon cgroup destruction).

The idea is that we have a counter that counts cgroup destructions in
each cgroup hierarchy and we remember a snapshot of that counter at
the time we remember the iterator position.  If any group in that
group's hierarchy gets killed before we come back to the iterator, the
counter mismatches.  Easy.  If any group is getting killed
concurrently, the counter might match our cookie, but the object could
be marked dead already, while rcu prevents it from being freed.  The
remaining worry is/was that we have two reads of the destruction
counter: one when validating the weak reference, another one when
updating the iterator.  If a destruction starts in between those two,
and modifies the counter, we would miss that destruction and the
object that is now weakly referenced could get freed while the
corresponding snapshot matches the latest value of the destruction
counter.  Michal's idea was to hold off the destruction counter inc
between those reads with synchronize_rcu().  My idea was to simply
read the counter only once and use that same value to both check and
update the iterator with.  That should catch this type of race
condition and save the atomic & the extra synchronize_rcu().  At least
I fail to see the downside of reading it only once:

iteration:
rcu_read_lock()
dead_count = atomic_read(&hierarchy->dead_count)
smp_rmb()
previous = iterator->position
if (iterator->dead_count != dead_count)
   /* A cgroup in our hierarchy was killed, pointer might be dangling */
   don't use iterator
if (!tryget(&previous))
   /* The cgroup is marked dead, don't use it */
   don't use iterator
next = find_next_and_tryget(hierarchy, &previous)
/* what happens if destruction of next starts NOW? */
css_put(previous)
iterator->position = next
smp_wmb()
iterator->dead_count = dead_count /* my suggestion, instead of a second atomic_read() */
rcu_read_unlock()
return next /* caller drops ref eventually, iterator->cgroup becomes weak */

destruction:
bias(cgroup->refcount) /* disables future tryget */
//synchronize_rcu() /* Michal's suggestion */
atomic_inc(&cgroup->hierarchy->dead_count)
synchronize_rcu()
free(cgroup)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
