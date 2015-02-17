Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 754FD6B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 09:50:55 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id k14so26332852wgh.3
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 06:50:55 -0800 (PST)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id ew8si29418822wic.29.2015.02.17.06.50.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Feb 2015 06:50:54 -0800 (PST)
Received: by mail-wi0-f170.google.com with SMTP id hi2so32423834wib.1
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 06:50:53 -0800 (PST)
Date: Tue, 17 Feb 2015 15:50:51 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150217145051.GD32017@dhcp22.suse.cz>
References: <201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
 <20141229181937.GE32618@dhcp22.suse.cz>
 <201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
 <20141230112158.GA15546@dhcp22.suse.cz>
 <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp>
 <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp>
 <20150210151934.GA11212@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150210151934.GA11212@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On Tue 10-02-15 10:19:34, Johannes Weiner wrote:
[...]
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8e20f9c2fa5a..f77c58ebbcfa 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2382,8 +2382,15 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		if (high_zoneidx < ZONE_NORMAL)
>  			goto out;
>  		/* The OOM killer does not compensate for light reclaim */
> -		if (!(gfp_mask & __GFP_FS))
> +		if (!(gfp_mask & __GFP_FS)) {
> +			/*
> +			 * XXX: Page reclaim didn't yield anything,
> +			 * and the OOM killer can't be invoked, but
> +			 * keep looping as per should_alloc_retry().
> +			 */
> +			*did_some_progress = 1;
>  			goto out;
> +		}
>  		/*
>  		 * GFP_THISNODE contains __GFP_NORETRY and we never hit this.
>  		 * Sanity check for bare calls of __GFP_THISNODE, not real OOM.

Although the side effect of 9879de7373fc (mm: page_alloc: embed OOM
killing naturally into allocation slowpath) is subtle and it would be
much better if it was documented in the changelog (I have missed that
too during review otherwise I would ask for that) I do not think this is
a change in a good direction. Hopelessly retrying at the time when the
reclaimm didn't help and OOM is not available is simply a bad(tm)
choice.

Besides that __GFP_WAIT callers should be prepared for the allocation
failure and should better cope with it. So no, I really hate something
like the above.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
