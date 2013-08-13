Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 33ABD6B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 03:45:31 -0400 (EDT)
Date: Tue, 13 Aug 2013 16:45:44 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 09/20] mm, hugetlb: protect region tracking via newly
 introduced resv_map lock
Message-ID: <20130813074544.GA22918@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-10-git-send-email-iamjoonsoo.kim@lge.com>
 <1376344985.13247.16.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376344985.13247.16.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

> > @@ -202,15 +199,27 @@ static long region_chg(struct resv_map *resv, long f, long t)
> >  	 * Subtle, allocate a new region at the position but make it zero
> >  	 * size such that we can guarantee to record the reservation. */
> >  	if (&rg->link == head || t < rg->from) {
> > -		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> > -		if (!nrg)
> > -			return -ENOMEM;
> > +		if (!nrg) {
> > +			nrg = kmalloc(sizeof(*nrg), GFP_NOWAIT);
> > +			if (!nrg) {
> > +				spin_unlock(&resv->lock);
> > +				nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> > +				if (!nrg) {
> > +					chg = -ENOMEM;
> > +					goto out;
> 
> Just return -ENOMEM here.

Okay. It looks better!

> 
> > +				}
> > +				goto retry;
> > +			}
> > +		}
> > +
> 
> You seem to be right, at least in my workloads, the hold times for the
> region lock is quite small, so a spinlock is better than a sleeping
> lock.
> 
> That said, this code is quite messy, but I cannot think of a
> better/cleaner approach right now.

Okay.

Thanks for review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
