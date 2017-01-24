Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 357436B0033
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 07:41:00 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t18so26589584wmt.7
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 04:41:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si18157688wmf.115.2017.01.24.04.40.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 04:40:58 -0800 (PST)
Date: Tue, 24 Jan 2017 13:40:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20170124124048.GE6867@dhcp22.suse.cz>
References: <20161220134904.21023-1-mhocko@kernel.org>
 <20161220134904.21023-3-mhocko@kernel.org>
 <001f01d272f7$e53acbd0$afb06370$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <001f01d272f7$e53acbd0$afb06370$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'David Rientjes' <rientjes@google.com>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>

On Fri 20-01-17 16:33:36, Hillf Danton wrote:
> 
> On Tuesday, December 20, 2016 9:49 PM Michal Hocko wrote: 
> > 
> > @@ -1013,7 +1013,7 @@ bool out_of_memory(struct oom_control *oc)
> >  	 * make sure exclude 0 mask - all other users should have at least
> >  	 * ___GFP_DIRECT_RECLAIM to get here.
> >  	 */
> > -	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
> > +	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
> >  		return true;
> > 
> As to GFP_NOFS|__GFP_NOFAIL request, can we check gfp mask
> one bit after another?
> 
> 	if (oc->gfp_mask) {
> 		if (!(oc->gfp_mask & __GFP_FS))
> 			return false;
> 
> 		/* No service for request that can handle fail result itself */
> 		if (!(oc->gfp_mask & __GFP_NOFAIL))
> 			return false;
> 	}

I really do not understand this request. This patch is removing the
__GFP_NOFAIL part... Besides that why should they return false?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
