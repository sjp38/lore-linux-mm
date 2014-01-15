Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f48.google.com (mail-qe0-f48.google.com [209.85.128.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9069C6B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 16:25:10 -0500 (EST)
Received: by mail-qe0-f48.google.com with SMTP id k5so1687173qej.21
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 13:25:10 -0800 (PST)
Received: from mail-pb0-x236.google.com (mail-pb0-x236.google.com [2607:f8b0:400e:c01::236])
        by mx.google.com with ESMTPS id t7si6984214qar.91.2014.01.15.13.25.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 13:25:09 -0800 (PST)
Received: by mail-pb0-f54.google.com with SMTP id un15so1687149pbc.41
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 13:25:08 -0800 (PST)
Date: Wed, 15 Jan 2014 13:24:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
In-Reply-To: <20140115121728.GJ8782@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1401151241280.9004@eggly.anvils>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils> <alpine.LSU.2.11.1401131751080.2229@eggly.anvils> <20140114132727.GB32227@dhcp22.suse.cz> <20140114142610.GF32227@dhcp22.suse.cz> <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
 <20140115095829.GI8782@dhcp22.suse.cz> <20140115121728.GJ8782@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 15 Jan 2014, Michal Hocko wrote:
> On Wed 15-01-14 10:58:29, Michal Hocko wrote:
> > On Tue 14-01-14 12:42:28, Hugh Dickins wrote:
> > > On Tue, 14 Jan 2014, Michal Hocko wrote:
> [...]
> > > > Ouch. And thinking about this shows that out_css_put is broken as well
> > > > for subtree walks (those that do not start at root_mem_cgroup level). We
> > > > need something like the the snippet bellow.
> > > 
> > > It's the out_css_put precedent that I was following in not incrementing
> > > for the root.  I think that's been discussed in the past, and rightly or
> > > wrongly we've concluded that the caller of mem_cgroup_iter() always has
> > > some hold on the root, which makes it safe to skip get/put on it here.
> > > No doubt one of those many short cuts to avoid memcg overhead when
> > > there's no memcg other than the root_mem_cgroup.
> > 
> > That might be true but I guess it makes sense to get rid of some subtle
> > assumptions. Especially now that we have an effective per-cpu ref.
> > counting for css.
> 
> OK, I finally found some time to think about this some more and it seems
> that the issue you have reported and the above issue are in fact
> identical. css reference counting optimization in fact also prevent from
> the endless loop you are seeing here because we simply didn't call
> css_tryget on the root...

Wow.  I don't see them as the same issue, but yes, one fix for both.
I completely missed that: so we've been leaking a "struct mem_cgroup"
and its attached stuff, for any memcg on which reclaim or other iteration
had been done, from v3.10 onwards?

Or am I confused and overstating it?  I'd have sworn I've checked for
memcg leaks myself after doing tests, and not realized this; but now I
put in a count of those allocated, yes, I see it going up and up (with
my half-fix in to proceed beyond the hang) without your fix, but staying
steady with your fix in (which also gets around my hang).

> 
> Therefore I guess we should reintroduce the optimization. What do you

It's not a question of reintroducing an optimization, but of either
fixing the broken end of the optimization, or ripping the other end out.
At this point I'm for simply fixing what we know is broken; then later
one of us audit the other iterators to check the original assumption
behind the optimization is still valid (that callers of mem_cgroup_iter
have some kind of hold on the root they call it for).

Ah.  But perhaps the unfreeable memcg has been protecting us from
nasties which can now emerge.  Hmm: I like your fix, but it's not
something to rush into mainline and stable immediately.  We'll have
to give it some exposure first.

And given the confusion, and progressive little modifications in
just these few lines of code, I wonder if it won't be easier for
stable to combine the CSS_ONLINE one into this to make a single
patch.  It is a separate issue, but similar, and now it's clear
that it's what you intended originally, I don't think it would be
inappropriate to make a single patch correcting those few lines,
with log comment listing the three issues.


> think about the following? This is on top of the current mmotm but it
> certainly needs backporting to the stable kernels.
> ---
> From 560924e86059947ab9418732cb329ad149dd8f6a Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 15 Jan 2014 11:52:09 +0100
> Subject: [PATCH] memcg: fix css reference leak from mem_cgroup_iter
> 
> 19f39402864e (memcg: simplify mem_cgroup_iter) has introduced a css
> refrence leak (thus memory leak) because mem_cgroup_iter makes sure it
> doesn't put a css reference on the root of the tree walk. The mentioned
> commit however dropped the root check when the css reference is taken
> while it keept the css_put optimization fora the root in place.
> 
> This means that css_put is not called and so css along with mem_cgroup
> and other cgroup internal object tied by css lifetime are never freed.
> 
> Fix the issue by reintroducing root check in __mem_cgroup_iter_next.
> 
> This patch also fixes issue reported by Hugh Dickins when
> mem_cgroup_iter might end up in an endless loop because a group which is
> under hard limit reclaim is removed in parallel with iteration.
> __mem_cgroup_iter_next would always return NULL because css_tryget on
> the root (reclaimed memcg) would fail and there are no other memcg in
> the hierarchy. prev == NULL in mem_cgroup_iter would prevent break out
> from the root and so the while (!memcg) loop would never terminate.
> as css_tryget is no longer called for the root of the tree walk this
> doesn't happen anymore.
> 
> Cc: stable@vger.kernel.org # 3.10+
> Reported-and-debugged-by: Hugh Dickins <hughd@google.com>

Definitely not debugged by me!  Debugged and understood by you.

> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f016d26adfd3..dd3974c9f08d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1078,7 +1078,8 @@ skip_node:
>  	 * protected by css_get and the tree walk is rcu safe.
>  	 */
>  	if (next_css) {
> -		if ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))
> +		if ((next_css->flags & CSS_ONLINE) &&
> +				(next_css == root || css_tryget(next_css)))

Not quite: next_css points to one thing and root to another.
>  			return mem_cgroup_from_css(next_css);
>  		else {
>  			prev_css = next_css;
> -- 

This is how I've re-written that block, and started testing on it;
the unnecessary "else {" part was looking increasingly ugly to me
(though let loose on it, I might change it all around more...)

	if (next_css) {
		if ((next_css->flags & CSS_ONLINE) &&
		    (next_css == &root->css || css_tryget(next_css)))
			return mem_cgroup_from_css(next_css);
		prev_css = next_css;
		goto skip_node;
	}

Sorry for being so slow to respond, by the way: for a couple of hours
I couldn't test at all, and thought I was going mad - one day I send
you that "cg" script, the next day it starts to break, it couldn't
"mkdir -p /cg/cg", claiming it already existed, wha???  Turns out the
fix for that has gone into yesterday's mmotm (though I've not had time
to move on to that yet): uninitialized ret in memcg_propagate_kmem().

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
