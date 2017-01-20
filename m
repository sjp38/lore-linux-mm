Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BB5316B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 03:33:58 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 204so87500678pge.5
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 00:33:58 -0800 (PST)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id v75si1276596pfj.50.2017.01.20.00.33.56
        for <linux-mm@kvack.org>;
        Fri, 20 Jan 2017 00:33:57 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161220134904.21023-1-mhocko@kernel.org> <20161220134904.21023-3-mhocko@kernel.org>
In-Reply-To: <20161220134904.21023-3-mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
Date: Fri, 20 Jan 2017 16:33:36 +0800
Message-ID: <001f01d272f7$e53acbd0$afb06370$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'David Rientjes' <rientjes@google.com>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>


On Tuesday, December 20, 2016 9:49 PM Michal Hocko wrote: 
> 
> @@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
>  	 * make sure exclude 0 mask - all other users should have at least
>  	 * ___GFP_DIRECT_RECLAIM to get here.
>  	 */
> -	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
>  		return true;
> 
As to GFP_NOFS|__GFP_NOFAIL request, can we check gfp mask
one bit after another?

	if (oc->gfp_mask) {
		if (!(oc->gfp_mask & __GFP_FS))
			return false;

		/* No service for request that can handle fail result itself */
		if (!(oc->gfp_mask & __GFP_NOFAIL))
			return false;
	}

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
