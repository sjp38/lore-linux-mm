Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 99FEA6B0035
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 09:23:57 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id q59so7401592wes.6
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 06:23:57 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15si1569723wiv.10.2014.02.13.06.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 06:23:55 -0800 (PST)
Date: Thu, 13 Feb 2014 15:23:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: fix endless loop in __mem_cgroup_iter_next
Message-ID: <20140213142355.GB11986@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1402121717420.5917@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402121717420.5917@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 12-02-14 17:26:46, Hugh Dickins wrote:
> Commit 0eef615665ed ("memcg: fix css reference leak and endless loop in
> mem_cgroup_iter") got the interaction with the commit a few before it
> d8ad30559715 ("mm/memcg: iteration skip memcgs not yet fully initialized")
> slightly wrong, and we didn't notice at the time.
> 
> It's elusive, and harder to get than the original, but for a couple of
> days before rc1, I several times saw a endless loop similar to that
> supposedly being fixed.
> 
> This time it was a tighter loop in __mem_cgroup_iter_next(): because we
> can get here when our root has already been offlined, and the ordering
> of conditions was such that we then just cycled around forever.
> 
> Fixes: 0eef615665ed ("memcg: fix css reference leak and endless loop in mem_cgroup_iter")
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: stable@vger.kernel.org # 3.12+

You are right of course. This is really embarrassing. I should have
noticed this when porting my original patch on top of yours.

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
> Of course I'd have preferred to send this before that commit went through
> to -stable, but priorities kept preempting; I did wonder whether to ask
> GregKH to delay it, but decided it's not serious enough to trouble him,
> just go with the flow of stable fixing stable.
> 
>  mm/memcontrol.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> --- 3.14-rc2/mm/memcontrol.c	2014-02-02 18:49:07.897302115 -0800
> +++ linux/mm/memcontrol.c	2014-02-12 11:55:02.836035004 -0800
> @@ -1127,8 +1127,8 @@ skip_node:
>  	 * skipping css reference should be safe.
>  	 */
>  	if (next_css) {
> -		if ((next_css->flags & CSS_ONLINE) &&
> -				(next_css == &root->css || css_tryget(next_css)))
> +		if ((next_css == &root->css) ||
> +		    ((next_css->flags & CSS_ONLINE) && css_tryget(next_css)))
>  			return mem_cgroup_from_css(next_css);
>  
>  		prev_css = next_css;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
