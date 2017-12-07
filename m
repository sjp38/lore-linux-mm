Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25F356B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 04:58:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a45so3756255wra.14
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 01:58:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l19si3723958wrf.26.2017.12.07.01.58.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 01:58:36 -0800 (PST)
Date: Thu, 7 Dec 2017 10:58:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: terminate shrink_slab loop if signal is pending
Message-ID: <20171207095835.GE20234@dhcp22.suse.cz>
References: <20171206192026.25133-1-surenb@google.com>
 <20171207095223.GB574@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171207095223.GB574@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Suren Baghdasaryan <surenb@google.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, timmurray@google.com, tkjos@google.com

On Thu 07-12-17 18:52:23, Sergey Senozhatsky wrote:
> On (12/06/17 11:20), Suren Baghdasaryan wrote:
> > Slab shrinkers can be quite time consuming and when signal
> > is pending they can delay handling of the signal. If fatal
> > signal is pending there is no point in shrinking that process
> > since it will be killed anyway. This change checks for pending
> > fatal signals inside shrink_slab loop and if one is detected
> > terminates this loop early.
> > 
> > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > ---
> >  mm/vmscan.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index c02c850ea349..69296528ff33 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -486,6 +486,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
> >  			.memcg = memcg,
> >  		};
> >  
> > +		/*
> > +		 * We are about to die and free our memory.
> > +		 * Stop shrinking which might delay signal handling.
> > +		 */
> > +		if (unlikely(fatal_signal_pending(current))
> 
> -               if (unlikely(fatal_signal_pending(current))
> +               if (unlikely(fatal_signal_pending(current)))

Heh, well, spotted. This begs a question how this has been tested, if at
all?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
