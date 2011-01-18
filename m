Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D8A568D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 03:40:22 -0500 (EST)
Date: Tue, 18 Jan 2011 09:40:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-ID: <20110118084013.GK2212@cmpxchg.org>
References: <20110117191359.GI2212@cmpxchg.org>
 <20110118101057.51d20ed7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110118101057.51d20ed7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Michel Lespinasse <walken@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 10:10:57AM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 17 Jan 2011 20:14:00 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Hello,
> > 
> > on the MM summit, I would like to talk about the current state of
> > memory control groups, the features and extensions that are currently
> > being developed for it, and what their status is.
> > 
> > I am especially interested in talking about the current runtime memory
> > overhead memcg comes with (1% of ram) and what we can do to shrink it.
> > 
> > In comparison to how efficiently struct page is packed, and given that
> > distro kernels come with memcg enabled per default, I think we should
> > put a bit more thought into how struct page_cgroup (which exists for
> > every page in the system as well) is organized.
> > 
> > I have a patch series that removes the page backpointer from struct
> > page_cgroup by storing a node ID (or section ID, depending on whether
> > sparsemem is configured) in the free bits of pc->flags.
> > 
> > I also plan on replacing the pc->mem_cgroup pointer with an ID
> > (KAMEZAWA-san has patches for that), and move it to pc->flags too.
> > Every flag not used means doubling the amount of possible control
> > groups, so I have patches that get rid of some flags currently
> > allocated, including PCG_CACHE, PCG_ACCT_LRU, and PCG_MIGRATION.
> > 
> > [ I meant to send those out much earlier already, but a bug in the
> > migration rework was not responding to my yelling 'Marco', and now my
> > changes collide horribly with THP, so it will take another rebase. ]
> > 
> > The per-memcg dirty accounting work e.g. allocates a bunch of new bits
> > in pc->flags and I'd like to hash out if this leaves enough room for
> > the structure packing I described, or whether we can come up with a
> > different way of tracking state.
> > 
> 
> I see that there are requests for shrinking page_cgroup. And yes, I think
> we should do so. I think there are trade-off between performance v.s.
> memory usage. So, could you show the numbers when we discuss it ?

Yep, I will prepare them anyway for submission.

> BTW, I think we can...
> 
> - PCG_ACCT_LRU bit can be dropped.(I think list_empty(&pc->lru) can be used.
>                 ROOT cgroup will not be problem.)

Yes, that's what I did.  Should be protected by the lru lock and root
cgroup pages can easily be marked so that list_empty() works on them.

> - pc->mem_cgroup can be replaced with ID.
>   But move it into flags field seems difficult because of races.
> - pc->page can be replaced with some lookup routine.
>   But Section bit encoding may be something mysterious and look up cost
>   will be problem.

Why is that?

The lookup is actually straight-forward, like lookup_page_cgroup().
And we only need it when coming from the per-cgroup LRU, i.e. in
reclaim and force_empty.

> - PCG_CACHE bit is a duplicate of information of 'page'. So, we can use PageAnon()

I did that, too.  But for this to work, we need to make sure that
pages are always rmapped when they are charged and uncharged.  This is
one point where I collide with THP.  It's also why I complained that
migration clears page->mapping of replaced anonymous pages :)

> - I'm not sure PCG_MIGRATION. It's for avoiding races.

That's also a scary patch...  Yeah, it's to prevent uncharging of
oldpage in case migration fails and it has to be reused.  I changed
the migration sequence for memcg a bit so that we don't have to do
that anymore.  It survived basic testing.

> Note: we'll need to use 16bits for blkio tracking.
> 
> Another idea is dynamic allocation of page_cgroup. It may be able to be a help
> for THP enviroment but will not work well (just adds overhead) against file cache
> workload.
> 
> Anwyay, my priority of development for memcg this year is:
> 
>  1. dirty ratio support.
>  2. Backgound reclaim (kswapd)
>  3. blkio tracking.
> 
> Diet of page_cgroup should be done in step by step. We've seen many level down
> when some new feature comes to memory cgroup.

Yes, and that's what I'm afraid of.  We would never be able to add a
side-feature that makes struct page increase in arbitrary size.

If the feature is sufficiently important and there is no other way, it
should of course be an option.  But it should not be done careless.

E.g. I have a suspicion that we might be able to do dirty accounting
without all the flags (we have them in the page anyway!) but use
proportionals instead.  It's not page-accurate, but I think the
fundamental problem is solved: when the dirty ratio is exceeded,
throttle the cgroup with the biggest dirty share.

But yes, that's sort of what I want to discuss :)

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
