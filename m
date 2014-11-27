Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1708A6B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 05:25:50 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id bs8so17844024wib.3
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 02:25:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si26612605wia.0.2014.11.27.02.25.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 02:25:48 -0800 (PST)
Date: Thu, 27 Nov 2014 11:25:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, oom: remove gfp helper function
Message-ID: <20141127102547.GA18833@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1411261416480.13014@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Qiang Huang <h.huangqiang@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 26-11-14 14:17:32, David Rientjes wrote:
> Commit b9921ecdee66 ("mm: add a helper function to check may oom
> condition") was added because the gfp criteria for oom killing was
> checked in both the page allocator and memcg.
> 
> That was true for about nine months, but then commit 0029e19ebf84 ("mm:
> memcontrol: remove explicit OOM parameter in charge path") removed the
> memcg usecase.
> 
> Fold the implementation into its only caller.

I don't care much whether the check is open coded or hidden behind the
helper but I would really appreciate a comment explaining why we care
about these two particular gfp flags. The code is like that since ages
- excavation work would lead us back to 2002 resp. 2003. Let's save
other others people time and do not repeat the same exercise again.

What about a comment like the following?

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/oom.h | 5 -----
>  mm/page_alloc.c     | 2 +-
>  2 files changed, 1 insertion(+), 6 deletions(-)
> 
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2706,7 +2706,7 @@ rebalance:
>  	 * running out of options and have to consider going OOM
>  	 */
>  	if (!did_some_progress) {
> -		if (oom_gfp_allowed(gfp_mask)) {
		/*
		 * Do not attempt to trigger OOM killer for !__GFP_FS
		 * allocations because it would be premature to kill
		 * anything just because the reclaim is stuck on
		 * dirty/writeback pages.
		 * __GFP_NORETRY allocations might fail and so the OOM
		 * would be more harmful than useful.
		 */
> +		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
>  			if (oom_killer_disabled)
>  				goto nopage;
>  			/* Coredumps can quickly deplete all memory reserves */

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
