Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 474229000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 05:32:47 -0400 (EDT)
Date: Fri, 30 Sep 2011 11:32:31 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 00/10] memcg naturalization -rc4
Message-ID: <20110930093231.GE30857@redhat.com>
References: <1317330064-28893-1-git-send-email-jweiner@redhat.com>
 <20110930170510.4695b8f0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110930170510.4695b8f0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 30, 2011 at 05:05:10PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 29 Sep 2011 23:00:54 +0200
> Johannes Weiner <jweiner@redhat.com> wrote:
> 
> > Hi,
> > 
> > this is the fourth revision of the memory cgroup naturalization
> > series.
> > 
> > The changes from v3 have mostly been documentation, changelog, and
> > naming fixes based on review feedback:
> > 
> >     o drop conversion of no longer existing zone-wide unevictable
> >       page rescue scanner
> >     o fix return value of mem_cgroup_hierarchical_reclaim() in
> >       limit-shrinking mode (Michal)
> >     o rename @remember to @reclaim in mem_cgroup_iter()
> >     o convert vm_swappiness to global_reclaim() in the
> >       correct patch (Michal)
> >     o rename
> >       struct mem_cgroup_iter_state -> struct mem_cgroup_reclaim_iter
> >       and
> >       struct mem_cgroup_iter -> struct mem_cgroup_reclaim_cookie
> >       (Michal)
> >     o added/amended comments and changelogs based on feedback (Michal, Kame)
> > 
> > Thanks for the review and feedback, guys, it's much appreciated!
> > 
> 
> Thank you for your work. Now, I'm ok this series to be tested in -mm.
> Ack. to all.

Thanks!

> Do you have any plan, concerns ?

I would really like to get them into 3.2.  While it's quite intrusive,
I stress-tested various scenarios for quite some time - tests that
revealed more bugs in the existing memcg code than in my changes - so
I don't expect too big surprises.  AFAICS, Google uses these patches
internally already and their bug reports early on also helped iron out
the most obvious problems.

What I am concerned about is the scalability on setups with thousands
of tiny memcgs that go into global reclaim, as this would try to scan
pages from all existing memcgs.  There is a mitigating factor in that
concurrent reclaimers divide the memcgs to scan among themselves (the
shared mem_cgroup_reclaim_iter), and with hundreds or thousands of
memcgs, I expect several threads to go into reclaim upon global memory
pressure at the same time in the common case.  I don't have the means
to test this and I also don't know if such setups exist or are within
the realm of sanity that we would like to support, anyway.  If this
shows up, I think the fix would be as easy as bailing out early from
the hierarchy walk, but I would like to cross that bridge when we come
to it.

Other than that, I see no reason to hold it off.  Traditional reclaim
without memcgs except root_mem_cgroup - what most people care about -
is mostly unaffected.  There is a real interest in the series, and
maintaining it out-of-tree is a major pain and quite error prone.

What do you think?

Thanks,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
