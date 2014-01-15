Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7193E6B0035
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 03:21:40 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so273249eaj.21
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 00:21:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si6338340eeg.30.2014.01.15.00.21.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 15 Jan 2014 00:21:39 -0800 (PST)
Date: Wed, 15 Jan 2014 09:21:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] mm/memcg: iteration skip memcgs not yet fully
 initialized
Message-ID: <20140115082138.GB8782@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
 <alpine.LSU.2.11.1401131752360.2229@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401131752360.2229@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 13-01-14 17:54:04, Hugh Dickins wrote:
> It is surprising that the mem_cgroup iterator can return memcgs which
> have not yet been fully initialized.  By accident (or trial and error?)
> this appears not to present an actual problem; but it may be better to
> prevent such surprises, by skipping memcgs not yet online.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

This makes a perfect sense now after Tejun pointed out that I was wrong
assuming css_online is called before cgroup is made visible.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> Decide for yourself whether to take this or not.  I spent quite a while
> digging into a mysterious "trying to register non-static key" issue from
> lockdep, which originated from the iterator returning a vmalloc'ed memcg
> a moment before the res_counter_init()s had done their spin_lock_init()s.
> But the backtrace was an odd one of our own mis-devising, not a charge or
> reclaim or stats trace, so probably it's never been a problem for vanilla.
> 
>  mm/memcontrol.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> --- mmotm/mm/memcontrol.c	2014-01-10 18:25:02.236448954 -0800
> +++ linux/mm/memcontrol.c	2014-01-12 22:21:10.700570471 -0800
> @@ -1119,10 +1119,8 @@ skip_node:
>  	 * protected by css_get and the tree walk is rcu safe.
>  	 */
>  	if (next_css) {
> -		struct mem_cgroup *mem = mem_cgroup_from_css(next_css);
> -
> -		if (css_tryget(&mem->css))
> -			return mem;
> +		if ((next_css->flags & CSS_ONLINE) && css_tryget(next_css))
> +			return mem_cgroup_from_css(next_css);
>  		else {
>  			prev_css = next_css;
>  			goto skip_node;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
