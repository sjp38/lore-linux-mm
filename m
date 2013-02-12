Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 2D1C16B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 04:54:27 -0500 (EST)
Date: Tue, 12 Feb 2013 10:54:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 4/7] memcg: remove memcg from the reclaim iterators
Message-ID: <20130212095419.GB4863@dhcp22.suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
 <1357235661-29564-5-git-send-email-mhocko@suse.cz>
 <20130208193318.GA15951@cmpxchg.org>
 <20130211151649.GD19922@dhcp22.suse.cz>
 <20130211175619.GC13218@cmpxchg.org>
 <20130211192929.GB29000@dhcp22.suse.cz>
 <20130211195824.GB15951@cmpxchg.org>
 <20130211212756.GC29000@dhcp22.suse.cz>
 <20130211223943.GC15951@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130211223943.GC15951@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

On Mon 11-02-13 17:39:43, Johannes Weiner wrote:
> On Mon, Feb 11, 2013 at 10:27:56PM +0100, Michal Hocko wrote:
> > On Mon 11-02-13 14:58:24, Johannes Weiner wrote:
> > > On Mon, Feb 11, 2013 at 08:29:29PM +0100, Michal Hocko wrote:
> > > > On Mon 11-02-13 12:56:19, Johannes Weiner wrote:
> > > > > On Mon, Feb 11, 2013 at 04:16:49PM +0100, Michal Hocko wrote:
> > > > > > Maybe we could keep the counter per memcg but that would mean that we
> > > > > > would need to go up the hierarchy as well. We wouldn't have to go over
> > > > > > node-zone-priority cleanup so it would be much more lightweight.
> > > > > > 
> > > > > > I am not sure this is necessarily better than explicit cleanup because
> > > > > > it brings yet another kind of generation number to the game but I guess
> > > > > > I can live with it if people really thing the relaxed way is much
> > > > > > better.
> > > > > > What do you think about the patch below (untested yet)?
> > > > > 
> > > > > Better, but I think you can get rid of both locks:
> > > > 
> > > > What is the other lock you have in mind.
> > > 
> > > The iter lock itself.  I mean, multiple reclaimers can still race but
> > > there won't be any corruption (if you make iter->dead_count a long,
> > > setting it happens atomically, we nly need the memcg->dead_count to be
> > > an atomic because of the inc) and the worst that could happen is that
> > > a reclaim starts at the wrong point in hierarchy, right?
> > 
> > The lack of synchronization basically means that 2 parallel reclaimers
> > can reclaim every group exactly once (ideally) or up to each group
> > twice in the worst case.
> > So the exclusion was quite comfortable.
> 
> It's quite unlikely, though.  Don't forget that they actually reclaim
> in between, I just can't see them line up perfectly and race to the
> iterator at the same time repeatedly.  It's more likely to happen at
> the higher priority levels where less reclaim happens, and then it's
> not a big deal anyway.  With lower priority levels, when the glitches
> would be more problematic, they also become even less likely.

Fair enough, I will drop that patch in the next version.
 
> > > But as you said in the changelog that introduced the lock, it's never
> > > actually been a practical problem.
> > 
> > That is true but those bugs would be subtle though so I wouldn't be
> > opposed to prevent from them before we get burnt. But if you think that
> > we should keep the previous semantic I can drop that patch.
> 
> I just think that the problem is unlikely and not that big of a deal.
> 
> > > You just need to put the wmb back in place, so that we never see the
> > > dead_count give the green light while the cached position is stale, or
> > > we'll tryget random memory.
> > > 
> > > > > mem_cgroup_iter:
> > > > > rcu_read_lock()
> > > > > if atomic_read(&root->dead_count) == iter->dead_count:
> > > > >   smp_rmb()
> > > > >   if tryget(iter->position):
> > > > >     position = iter->position
> > > > > memcg = find_next(postion)
> > > > > css_put(position)
> > > > > iter->position = memcg
> > > > > smp_wmb() /* Write position cache BEFORE marking it uptodate */
> > > > > iter->dead_count = atomic_read(&root->dead_count)
> > > > > rcu_read_unlock()
> > > > 
> > > > Updated patch bellow:
> > > 
> > > Cool, thanks.  I hope you don't find it too ugly anymore :-)
> > 
> > It's getting trick and you know how people love when you have to play
> > and rely on atomics with memory barriers...
> 
> My bumper sticker reads "I don't believe in mutual exclusion" (the
> kernel hacker's version of smile for the red light camera).

Ohh, those easy riders.
 
> I mean, you were the one complaining about the lock...
> 
> > > That way, if the dead count gives the go-ahead, you KNOW that the
> > > position cache is valid, because it has been updated first.
> > 
> > OK, you are right. We can live without css_tryget because dead_count is
> > either OK which means that css would be alive at least this rcu period
> > (and RCU walk would be safe as well) or it is incremented which means
> > that we have started css_offline already and then css is dead already.
> > So css_tryget can be dropped.
> 
> Not quite :)
> 
> The dead_count check is for completed destructions,

Not quite :P. dead_count is incremented in css_offline callback which is
called before the cgroup core releases its last reference and unlinks
the group from the siblinks. css_tryget would already fail at this stage
because CSS_DEACT_BIAS is in place at that time but this doesn't break
RCU walk. So I think we are safe even without css_get.

Or am I missing something?
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
