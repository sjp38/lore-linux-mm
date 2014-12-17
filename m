Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id B169A6B0032
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 21:13:07 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id l18so19009082wgh.12
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 18:13:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cm1si5720752wib.51.2014.12.16.18.13.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 18:13:06 -0800 (PST)
Date: Tue, 16 Dec 2014 21:13:02 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Stalled MM patches for review
Message-ID: <20141217021302.GA14148@phnom.home.cmpxchg.org>
References: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org>
 <548F7541.8040407@jp.fujitsu.com>
 <20141216030658.GA18569@phnom.home.cmpxchg.org>
 <alpine.DEB.2.10.1412161650540.19867@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1412161650540.19867@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Dec 16, 2014 at 05:07:16PM -0800, David Rientjes wrote:
> On Mon, 15 Dec 2014, Johannes Weiner wrote:
> >  	/* Check if we should retry the allocation */
> >  	pages_reclaimed += did_some_progress;
> >  	if (should_alloc_retry(gfp_mask, order, did_some_progress,
> >  						pages_reclaimed)) {
> > +		/*
> > +		 * If we fail to make progress by freeing individual
> > +		 * pages, but the allocation wants us to keep going,
> > +		 * start OOM killing tasks.
> > +		 */
> > +		if (!did_some_progress) {
> > +			page = __alloc_pages_may_oom(gfp_mask, order, zonelist,
> > +						high_zoneidx, nodemask,
> > +						preferred_zone, classzone_idx,
> > +						migratetype,&did_some_progress);
> 
> Missing a space.

That was because of the 80 character limit, it seemed preferrable over
a linewrap.

> > +			if (page)
> > +				goto got_pg;
> > +			if (!did_some_progress)
> > +				goto nopage;
> > +		}
> >  		/* Wait for some write requests to complete then retry */
> >  		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
> >  		goto rebalance;
> 
> This is broken because it does not recall gfp_to_alloc_flags().  If 
> current is the oom kill victim, then ALLOC_NO_WATERMARKS never gets set 
> properly and the slowpath will end up looping forever.  The "restart" 
> label which was removed in this patch needs to be reintroduced, and it can 
> probably be moved to directly before gfp_to_alloc_flags().

Thanks for catching this.  gfp_to_alloc_flags()'s name doesn't exactly
imply such side effects...  Here is a fixlet on top:

---
