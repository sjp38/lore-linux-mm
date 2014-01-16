Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id DE9546B0037
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 14:16:13 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id i7so356694yha.0
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 11:16:13 -0800 (PST)
Received: from mail-pb0-x232.google.com (mail-pb0-x232.google.com [2607:f8b0:400e:c01::232])
        by mx.google.com with ESMTPS id t28si7672220yhd.111.2014.01.16.11.16.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 11:16:12 -0800 (PST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so3051279pbb.23
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 11:16:11 -0800 (PST)
Date: Thu, 16 Jan 2014 11:15:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/3] mm/memcg: fix endless iteration in reclaim
In-Reply-To: <20140116152259.GG28157@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1401161011110.1321@eggly.anvils>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils> <alpine.LSU.2.11.1401131751080.2229@eggly.anvils> <20140114132727.GB32227@dhcp22.suse.cz> <20140114142610.GF32227@dhcp22.suse.cz> <alpine.LSU.2.11.1401141201120.3762@eggly.anvils>
 <20140115095829.GI8782@dhcp22.suse.cz> <20140115121728.GJ8782@dhcp22.suse.cz> <alpine.LSU.2.11.1401151241280.9004@eggly.anvils> <20140116081738.GA28157@dhcp22.suse.cz> <20140116152259.GG28157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 16 Jan 2014, Michal Hocko wrote:
> From 543df5c82f6eec622f669ea322ba6ff03924fded Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 16 Jan 2014 16:17:13 +0100
> Subject: [PATCH] memcg: fix css reference leak from mem_cgroup_iter
> 
> 19f39402864e (memcg: simplify mem_cgroup_iter) has introduced a css
> refrence leak (thus memory leak) because mem_cgroup_iter makes sure it
> doesn't put a css reference on the root of the tree walk. The mentioned
> commit however dropped the root check when the css reference is taken
> while it keept the css_put optimization fora the root in place.

I don't think that's quite right, actually - and I think it's all
so confusing that we do need to be pedantic and set it down right.

I spent quite a while yesterday trying out my "cg m" on 3.10, 3.11,
3.12 and 3.13-rc8 on this laptop: first just counting mem_cgroup_allocs
and frees (if I could get that far without hanging or crashing), then
also with your patch in (on 3.12 and 3.13-rc8) or the completely
different patch appended at the bottom (on 3.10 and 3.11), checking
for leftover mem_cgroups afterwards.

I saw no evidence of mem_cgroup leakage on 3.10 and 3.11, which had
	/*
	 * Root is not visited by cgroup iterators so it needs an
	 * explicit visit.
	 */
	if (!last_visited)
		return root;
at the head of __mem_cgroup_iter_next(), removed around the same
time as changeover from prev_cgroup etc to prev_css etc in 3.12.

I don't believe 19f39402864e was responsible for a reference leak,
that came later.  But I think it was responsible for the original
endless iteration (shrink_zone going around and around getting root
again and again from mem_cgroup_iter).

But beware of my conclusion, please check for yourself: with my
separate kbuilds in separate /cg/cg/? memcgs, what "cg m" is doing
is very simple and segregated, can hardly be called testing reclaim
iteration, so I hope you have something better to check it.  Plus
I was testing on 3.10 and 3.11 vanilla, not latest stable versions.

(If I'm very honest, I'll admit that I still did not see that hang
on 3.11 vanilla: what I hit was a crash in kfree instead, but the
same patch got rid of that too.  Of course I ought to investigate
further, but at some point I just have to give up and move on,
there's just too much breakage to chase all over the kernel...)

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
> [hughd@google.com: Fixed root vs. root->css fix]
> [hughd@google.com: Get rid of else branch because it is ugly]

Thanks for your courtesy!  But let's not clutter it with those two.

> <Hugh's-selection>-by: Hugh Dickins <hughd@google.com>

You already credited me above, but "Reported-by:" here if you insist.

> Cc: stable@vger.kernel.org # 3.10+

Well, I'm okay with that, if we use that as a way to shoehorn in the
patch at the bottom instead for 3.10 and 3.11 stables.  Whether that's
an abuse of the stable system... I think not, the patch at the bottom
(though it could be written in a variety of other ways) is what we're
relying on for 3.11 at Google, and the iteration hang it fixes is
equivalent to the one you're fixing here (but a hang repeatedly
calling mem_cgroup_iter morphed into a tighter hang repeatedly
calling __mem_cgroup_iter_next with the 3.12 rewrite, plus leakage).

Or, if you're uncomfortable with the misrepresentation, you could
just say 3.12+; but I think we serve other users of 3.10 and 3.11
best by saying 3.10+ there as you have it.

> Signed-off-by: Michal Hocko <mhocko@suse.cz>

No quarrels with that!

> ---
>  mm/memcontrol.c | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f016d26adfd3..969f14d32b30 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1076,14 +1076,22 @@ skip_node:
>  	 * skipped and we should continue the tree walk.
>  	 * last_visited css is safe to use because it is
>  	 * protected by css_get and the tree walk is rcu safe.
> +	 *
> +	 * We do not take a reference on the root of the tree walk
> +	 * because we might race with the root removal when it would
> +	 * be the only node in the iterated hierarchy and mem_cgroup_iter
> +	 * would end up in an endless loop because it expects that at
> +	 * least one valid node will be returned. Root cannot disappear
> +	 * because caller of the iterator should hold it already so
> +	 * skipping css reference should be safe.
>  	 */
>  	if (next_css) {
> -		if ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))
> +		if ((next_css->flags & CSS_ONLINE) &&

Well, okay.  It's fine by me to keep the CSS_ONLINE one separate if you
prefer, but since we're not intending that one for -stable (or are we?),
basing this on top of that means that this patch will not apply to stable
and gregkh will ask us to craft a separate version for each release.
That's okay, I just preferred not to revisit this later (any more than
will anyway be necessary for 3.10 and 3.11).

> +				(next_css == root->css || css_tryget(next_css)))
>  			return mem_cgroup_from_css(next_css);
> -		else {
> -			prev_css = next_css;
> -			goto skip_node;
> -		}
> +

Yes, thanks, it's better with the blank line.

> +		prev_css = next_css;
> +		goto skip_node;
>  	}
>  
>  	return NULL;
> -- 
> 1.8.5.2
> 
> -- 
> Michal Hocko
> SUSE Labs

"Equivalent" patch for 3.10 or 3.11: fixing similar hangs but no leakage.

Signed-off-by: Hugh Dickins <hughd@google.com>

--- v3.10/mm/memcontrol.c	2013-06-30 15:13:29.000000000 -0700
+++ linux/mm/memcontrol.c	2014-01-15 18:18:24.476566659 -0800
@@ -1226,7 +1226,8 @@ struct mem_cgroup *mem_cgroup_iter(struc
 			}
 		}
 
-		memcg = __mem_cgroup_iter_next(root, last_visited);
+		if (!prev || last_visited)
+			memcg = __mem_cgroup_iter_next(root, last_visited);
 
 		if (reclaim) {
 			if (last_visited)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
