Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 78C996B006C
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 18:53:39 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5807973pbb.14
        for <linux-mm@kvack.org>; Sun, 10 Jun 2012 15:53:38 -0700 (PDT)
Date: Sun, 10 Jun 2012 15:53:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] memcg: fix use_hierarchy css_is_ancestor oops
 regression
In-Reply-To: <20120610221516.GJ1761@cmpxchg.org>
Message-ID: <alpine.LSU.2.00.1206101547390.16184@eggly.anvils>
References: <alpine.LSU.2.00.1206101150230.4239@eggly.anvils> <20120610221516.GJ1761@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 11 Jun 2012, Johannes Weiner wrote:
> On Sun, Jun 10, 2012 at 11:54:47AM -0700, Hugh Dickins wrote:
> > If use_hierarchy is set, reclaim testing soon oopses in css_is_ancestor()
> > called from __mem_cgroup_same_or_subtree() called from page_referenced():
> > when processes are exiting, it's easy for mm_match_cgroup() to pass along
> > a NULL memcg coming from a NULL mm->owner.
> > 
> > Check for that in __mem_cgroup_same_or_subtree().  Return true or false?
> > False because we cannot know if it was in the hierarchy, but also false
> > because it's better not to count a reference from an exiting process.
> > 
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> Looks like an older version of the patch that introduced it slipped
> into the tree, Konstantin noted this problem during review.  The final
> version did
> 
> 	match = memcg && __mem_cgroup_same_or_subtree(root, memcg);
> 
> in the caller because of it.
> 
> Do you think it would be cleaner this way, since this is also the
> place where that memcg is looked up, and so the "can return NULL"
> handling after mem_cgroup_from_task() would be in the same place?

I don't mind, either way.

It depends on whether we add more such uses which could receive a NULL
memcg.  I tend to prefer dealing with rare conditions (which this is)
inside the callee, but common conditions before calling from the caller.

But let's let others decide.

> 
> But either way,
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Thanks, Hugh!

And thank you, Hannes!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
