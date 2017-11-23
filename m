Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDD6D6B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 18:46:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q187so3833271pga.6
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 15:46:28 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id m39si17361960plg.464.2017.11.23.15.46.26
        for <linux-mm@kvack.org>;
        Thu, 23 Nov 2017 15:46:27 -0800 (PST)
Date: Fri, 24 Nov 2017 08:46:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Message-ID: <20171123234626.GA19756@bbox>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115005602.GB23810@bbox>
 <20171116174422.GC26475@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171116174422.GC26475@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 16, 2017 at 12:44:22PM -0500, Johannes Weiner wrote:
> On Wed, Nov 15, 2017 at 09:56:02AM +0900, Minchan Kim wrote:
> > @@ -498,6 +498,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
> >  			sc.nid = 0;
> >  
> >  		freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> > +		/*
> > +		 * bail out if someone want to register a new shrinker to prevent
> > +		 * long time stall by parallel ongoing shrinking.
> > +		 */
> > +		if (rwsem_is_contended(&shrinker_rwsem)) {
> > +			freed = 1;
> > +			break;
> > +		}
> >  	}
> 
> When you send the formal version, please include
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks for the review, Johannes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
