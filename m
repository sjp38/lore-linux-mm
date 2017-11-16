Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 684EE6B0292
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 12:44:41 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 5so372949wmk.8
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 09:44:41 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o3si5550edi.217.2017.11.16.09.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 Nov 2017 09:44:39 -0800 (PST)
Date: Thu, 16 Nov 2017 12:44:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171116174422.GC26475@cmpxchg.org>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115005602.GB23810@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171115005602.GB23810@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 15, 2017 at 09:56:02AM +0900, Minchan Kim wrote:
> @@ -498,6 +498,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>  			sc.nid = 0;
>  
>  		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> +		/*
> +		 * bail out if someone want to register a new shrinker to prevent
> +		 * long time stall by parallel ongoing shrinking.
> +		 */
> +		if (rwsem_is_contended(&shrinker_rwsem)) {
> +			freed = 1;
> +			break;
> +		}
>  	}

When you send the formal version, please include

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
