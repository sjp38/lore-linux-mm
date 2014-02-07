Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 587FA6B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 09:37:43 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id x55so2331449wes.4
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 06:37:42 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cq8si1555100wib.56.2014.02.07.06.37.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 06:37:41 -0800 (PST)
Date: Fri, 7 Feb 2014 15:37:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] cgroup: use an ordered workqueue for cgroup destruction
Message-ID: <20140207143740.GD5121@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
 <20140207140402.GA3304@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207140402.GA3304@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 07-02-14 09:04:02, Tejun Heo wrote:
> Hello, Hugh.
> 
> On Thu, Feb 06, 2014 at 03:56:01PM -0800, Hugh Dickins wrote:
> > Sometimes the cleanup after memcg hierarchy testing gets stuck in
> > mem_cgroup_reparent_charges(), unable to bring non-kmem usage down to 0.
> > 
> > There may turn out to be several causes, but a major cause is this: the
> > workitem to offline parent can get run before workitem to offline child;
> > parent's mem_cgroup_reparent_charges() circles around waiting for the
> > child's pages to be reparented to its lrus, but it's holding cgroup_mutex
> > which prevents the child from reaching its mem_cgroup_reparent_charges().
> > 
> > Just use an ordered workqueue for cgroup_destroy_wq.
> 
> Hmmm... I'm not really comfortable with this.  This would seal shut
> any possiblity of increasing concurrency in that path, which is okay
> now but I find the combination of such long term commitment and the
> non-obviousness (it's not apparent from looking at memcg code why it
> wouldn't deadlock) very unappealing.  Besides, the only reason
> offline() is currently called under cgroup_mutex is history.  We can
> move it out of cgroup_mutex right now.
> 
> But even with offline being called outside cgroup_mutex, IIRC, the
> described problem would still be able to deadlock as long as the tree
> depth is deeper than max concurrency level of the destruction
> workqueue.  Sure, we can give it large enough number but it's
> generally nasty.
> 
> One thing I don't get is why memcg has such reverse dependency at all.
> Why does the parent wait for its descendants to do something during
> offline?

Because the parent sees charges of its children but it doesn't see pages
as they are on the LRU of those children. So it cannot reach 0 charges.
We are are assuming that the offlining memcg doesn't have any children
which sounds like a reasonable expectation to me.

> Shouldn't it be able to just bail and let whatever
> descendant which is stil busy propagate things upwards?  That's a
> usual pattern we use to tree shutdowns anyway.  Would that be nasty to
> implement in memcg?

Hmm, this is a bit tricky. We cannot use memcg iterators to reach
children because css_tryget would fail on them. We can use cgroup
iterators instead, alright, and reparent pages from leafs but this all
sounds like a lot of complications.

Another option would be weakening css_offline reparenting and do not
insist on having 0 charges. We want to get rid of as many charges as
possible but do not need to have all of them gone
(http://marc.info/?l=linux-kernel&m=139161412932193&w=2). The last part
would be reparenting to the upmost parent which is still online.

I guess this is implementable but I would prefer Hugh's fix for now and
for stable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
