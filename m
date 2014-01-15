Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 078F56B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 04:58:31 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id e53so734736eek.25
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 01:58:31 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r41si6827694eem.17.2014.01.15.01.58.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 01:58:30 -0800 (PST)
Date: Wed, 15 Jan 2014 10:58:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
Message-ID: <20140115095829.GI8782@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
 <alpine.LSU.2.11.1401131751080.2229@eggly.anvils>
 <20140114132727.GB32227@dhcp22.suse.cz>
 <20140114142610.GF32227@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 14-01-14 12:42:28, Hugh Dickins wrote:
> On Tue, 14 Jan 2014, Michal Hocko wrote:
> > On Tue 14-01-14 14:27:27, Michal Hocko wrote:
> > > On Mon 13-01-14 17:52:30, Hugh Dickins wrote:
> > > > On one home machine I can easily reproduce (by rmdir of memcgdir during
> > > > reclaim) multiple processes stuck looping forever in mem_cgroup_iter():
> > > > __mem_cgroup_iter_next() keeps selecting the memcg being destroyed, fails
> > > > to tryget it, returns NULL to mem_cgroup_iter(), which goes around again.
> > > 
> > > So you had a single memcg (without any children) and a limit-reclaim
> > > on it when you removed it, right?
> > 
> > Hmm, thinking about this once more how can this happen? There must be a
> > task to trigger the limit reclaim so the cgroup cannot go away (or is
> > this somehow related to kmem accounting?). Only if the taks was migrated
> > after the reclaim was initiated but before we started iterating?
> 
> Yes, I believe that's how it comes about (but no kmem accounting:
> it's configured in but I'm not setting limits).

OK, then it makes more sense now.

> The "cg" script I run for testing appended below.  Normally I just run
> it as "cg 2" to set up two memcgs, then my dual-tmpfs-kbuild script runs
> one kbuild on tmpfs in cg 1, and another kbuild on ext4 on loop on tmpfs
> in cg 2, mainly to test swapping.  But for this bug I run it as "cg m",
> to repeatedly create new memcg, move running tasks from old to new, and
> remove old.

thanks I will play with it.

> Sometimes I'm doing swapoff and swapon in the background too, but
> that's not needed to see this bug.  And although we're accustomed to
> move_charge_at_immigrate being a beast, for this bug it's much quicker
> to have that turned off.

yes, that makes sense becuase the task doesn't take its memory with it
and the reclaim contains even without any task in the group.

> (Until a couple of months ago, I was working in /cg/1 and /cg/2; but
> have now pushed down a level to /cg/cg/1 and /cg/cg/2 after realizing
> that working at the root would miss some important issues - in particular
> the mem_cgroup_reparent_charges wrong-usage hang; but in fact I have
> *never* caught that here, just know that it still exists from some
> Google watchdog dumps, but we've still not identified the cause -
> seen even without MEMCG_SWAP and with Hannes's extra reparent_charges.)

Interesting. There is another user seeing hangs with the reparent
workaround as well. I still didn't get to his test case because of other
interal work that is due.

> > I am confused now and have to rush shortly so I will think about it
> > tomorrow some more.
> 
> Thanks, yes, I knew it's one you'd want to think about first: no rush.
> 
> > 
> > > This is nasty because __mem_cgroup_iter_next will try to skip it but
> > > there is nothing else so it returns NULL. We update iter->generation++
> > > but that doesn't help us as prev = NULL as this is the first iteration
> > > so
> > > 		if (prev && reclaim->generation != iter->generation)
> > > 
> > > break out will not help us.
> > 
> > > You patch will surely help I am just not sure it is the right thing to
> > > do. Let me think about this.
> > 
> > The patch is actually not correct after all. You are returning root
> > memcg without taking a reference. So there is a risk that memcg will
> > disappear. Although, it is true that the race with removal is not that
> > probable because mem_cgroup_css_offline (resp. css_free) will see some
> > pages on LRUs and they will reclaim as well.
> > 
> > Ouch. And thinking about this shows that out_css_put is broken as well
> > for subtree walks (those that do not start at root_mem_cgroup level). We
> > need something like the the snippet bellow.
> 
> It's the out_css_put precedent that I was following in not incrementing
> for the root.  I think that's been discussed in the past, and rightly or
> wrongly we've concluded that the caller of mem_cgroup_iter() always has
> some hold on the root, which makes it safe to skip get/put on it here.
> No doubt one of those many short cuts to avoid memcg overhead when
> there's no memcg other than the root_mem_cgroup.

That might be true but I guess it makes sense to get rid of some subtle
assumptions. Especially now that we have an effective per-cpu ref.
counting for css.

> I've not given enough thought to whether that is still a good assumption.
> The try_charge route does a css_tryget, and that will be the hold on the
> root in the reclaim case, won't it?

Yes, that is what I realized when looked at the code yesterday and tried
to handle by the snippet. I will post it as a separate patch.

> And its css_tryget succeeding does not guarantee that a css_tryget a
> moment later will also succeed, which is what happens in this bug.

Once the tryget succeeds then we get the memcg so another tryget won't
be needed. Or am I missing something? What I tried to tell is that you
should do css_get(root) in your escape path.

> But I have not attempted to audit other uses of mem_cgroup_iter() and
> for_each_mem_cgroup_tree().  I've not hit any problems from them, but
> may not have exercised those paths at all.  And the question of
> whether there's a good hold on the root is a separate issue, really.
> 
> Hugh
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
