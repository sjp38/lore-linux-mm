Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id CFEF86B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 07:52:07 -0500 (EST)
Date: Wed, 23 Jan 2013 13:52:02 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 0/7] rework mem_cgroup iterator
Message-ID: <20130123125202.GA13319@dhcp22.suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

Are there any comments? Ying, Johannes?
I would be happy if this could go into 3.9.

On Thu 03-01-13 18:54:14, Michal Hocko wrote:
> Hi all,
> this is a third version of the patchset previously posted here:
> https://lkml.org/lkml/2012/11/26/616
> 
> The patch set tries to make mem_cgroup_iter saner in the way how it
> walks hierarchies. css->id based traversal is far from being ideal as it
> is not deterministic because it depends on the creation ordering.
> 
> Diffstat doesn't look that promising as in previous versions anymore but
> I think it is worth the resulting outcome (and the sanity ;)).
> 
> The first patch fixes a potential misbehaving which I haven't seen but
> the fix is needed for the later patches anyway. We could take it alone
> as well but I do not have any bug report to base the fix on. The second
> one is also preparatory and it is new to the series.
> 
> The third patch is the core of the patchset and it replaces css_get_next
> based on css_id by the generic cgroup pre-order iterator which
> means that css_id is no longer used by memcg. This brings some
> chalanges for the last visited group caching during the reclaim
> (mem_cgroup_per_zone::reclaim_iter). We have to use memcg pointers
> directly now which means that we have to keep a reference to those
> groups' css to keep them alive.
> 
> The next patch fixups an unbounded cgroup removal holdoff caused by
> the elevated css refcount and does the clean up on the group removal.
> Thanks to Ying who spotted this during testing of the previous version
> of the patchset.
> I could have folded it into the previous patch but I felt it would be
> too big to review but if people feel it would be better that way, I have
> no problems to squash them together.
> 
> The fourth and fifth patches are an attempt for simplification of the
> mem_cgroup_iter. css juggling is removed and the iteration logic is
> moved to a helper so that the reference counting and iteration are
> separated.
> 
> The last patch just removes css_get_next as there is no user for it any
> longer.
> 
> I am also thinking that leaf-to-root iteration makes more sense but this
> patch is not included in the series yet because I have to think some
> more about the justification.
> 
> Same as with the previous version I have tested with a quite simple
> hierarchy:
>         A (limit = 280M, use_hierarchy=true)
>       / | \
>      B  C  D (all have 100M limit)
> 
> And a separate kernel build in the each leaf group. This triggers
> both children only and hierarchical reclaim which is parallel so the
> iter_reclaim caching is active a lot. I will hammer it some more but the
> series should be in quite a good shape already. 
> 
> Michal Hocko (7):
>       memcg: synchronize per-zone iterator access by a spinlock
>       memcg: keep prev's css alive for the whole mem_cgroup_iter
>       memcg: rework mem_cgroup_iter to use cgroup iterators
>       memcg: remove memcg from the reclaim iterators
>       memcg: simplify mem_cgroup_iter
>       memcg: further simplify mem_cgroup_iter
>       cgroup: remove css_get_next
> 
> And the diffstat says:
>  include/linux/cgroup.h |    7 --
>  kernel/cgroup.c        |   49 ------------
>  mm/memcontrol.c        |  199 ++++++++++++++++++++++++++++++++++++++++++------
>  3 files changed, 175 insertions(+), 80 deletions(-)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
