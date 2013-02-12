Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B57206B0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 12:50:06 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 12 Feb 2013 12:50:05 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 12D5A38CB16B
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 11:29:29 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1CGTP6h039264
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 11:29:26 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1CGTKob007290
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 09:29:21 -0700
Date: Tue, 12 Feb 2013 08:10:51 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130212161051.GQ2666@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20130208193318.GA15951@cmpxchg.org>
 <20130211151649.GD19922@dhcp22.suse.cz>
 <20130211175619.GC13218@cmpxchg.org>
 <20130211192929.GB29000@dhcp22.suse.cz>
 <20130211195824.GB15951@cmpxchg.org>
 <20130211212756.GC29000@dhcp22.suse.cz>
 <20130211223943.GC15951@cmpxchg.org>
 <20130212095419.GB4863@dhcp22.suse.cz>
 <20130212151002.GD15951@cmpxchg.org>
 <20130212154330.GG4863@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130212154330.GG4863@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Tue, Feb 12, 2013 at 04:43:30PM +0100, Michal Hocko wrote:
> On Tue 12-02-13 10:10:02, Johannes Weiner wrote:
> > On Tue, Feb 12, 2013 at 10:54:19AM +0100, Michal Hocko wrote:
> > > On Mon 11-02-13 17:39:43, Johannes Weiner wrote:
> > > > On Mon, Feb 11, 2013 at 10:27:56PM +0100, Michal Hocko wrote:
> > > > > On Mon 11-02-13 14:58:24, Johannes Weiner wrote:
> > > > > > That way, if the dead count gives the go-ahead, you KNOW that the
> > > > > > position cache is valid, because it has been updated first.
> > > > > 
> > > > > OK, you are right. We can live without css_tryget because dead_count is
> > > > > either OK which means that css would be alive at least this rcu period
> > > > > (and RCU walk would be safe as well) or it is incremented which means
> > > > > that we have started css_offline already and then css is dead already.
> > > > > So css_tryget can be dropped.
> > > > 
> > > > Not quite :)
> > > > 
> > > > The dead_count check is for completed destructions,
> > > 
> > > Not quite :P. dead_count is incremented in css_offline callback which is
> > > called before the cgroup core releases its last reference and unlinks
> > > the group from the siblinks. css_tryget would already fail at this stage
> > > because CSS_DEACT_BIAS is in place at that time but this doesn't break
> > > RCU walk. So I think we are safe even without css_get.
> > 
> > But you drop the RCU lock before you return.
> >
> > dead_count IS incremented for every destruction, but it's not reliable
> > for concurrent ones, is what I meant.  Again, if there is a dead_count
> > mismatch, your pointer might be dangling, easy case.  However, even if
> > there is no mismatch, you could still race with a destruction that has
> > marked the object dead, and then frees it once you drop the RCU lock,
> > so you need try_get() to check if the object is dead, or you could
> > return a pointer to freed or soon to be freed memory.
> 
> Wait a moment. But what prevents from the following race?
> 
> rcu_read_lock()
> 						mem_cgroup_css_offline(memcg)
> 						root->dead_count++
> iter->last_dead_count = root->dead_count
> iter->last_visited = memcg
> 						// final
> 						css_put(memcg);
> // last_visited is still valid
> rcu_read_unlock()
> [...]
> // next iteration
> rcu_read_lock()
> iter->last_dead_count == root->dead_count
> // KABOOM
> 
> The race window between dead_count++ and css_put is quite big but that
> is not important because that css_put can happen anytime before we start
> the next iteration and take rcu_read_lock.

The usual approach is to make sure that there is a grace period (either
synchronize_rcu() or call_rcu()) between the time that the data is
made inaccessible to readers (this would be mem_cgroup_css_offline()?)
and the time it is freed (css_put(), correct?).

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
