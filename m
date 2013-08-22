Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id DC8AD6B0033
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:59:12 -0400 (EDT)
Date: Thu, 22 Aug 2013 15:59:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 09/20] mm, hugetlb: protect region tracking via newly
 introduced resv_map lock
Message-ID: <20130822065919.GE13415@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-10-git-send-email-iamjoonsoo.kim@lge.com>
 <87eh9ngxmg.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87eh9ngxmg.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Wed, Aug 21, 2013 at 03:43:27PM +0530, Aneesh Kumar K.V wrote:

> >  static long region_chg(struct resv_map *resv, long f, long t)
> >  {
> >  	struct list_head *head = &resv->regions;
> > -	struct file_region *rg, *nrg;
> > +	struct file_region *rg, *nrg = NULL;
> >  	long chg = 0;
> >
> > +retry:
> > +	spin_lock(&resv->lock);
> >  	/* Locate the region we are before or in. */
> >  	list_for_each_entry(rg, head, link)
> >  		if (f <= rg->to)
> > @@ -202,15 +199,27 @@ static long region_chg(struct resv_map *resv, long f, long t)
> >  	 * Subtle, allocate a new region at the position but make it zero
> >  	 * size such that we can guarantee to record the reservation. */
> >  	if (&rg->link == head || t < rg->from) {
> > -		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> > -		if (!nrg)
> > -			return -ENOMEM;
> > +		if (!nrg) {
> > +			nrg = kmalloc(sizeof(*nrg), GFP_NOWAIT);
> 
> Do we really need to have the GFP_NOWAIT allocation attempt. Why can't we simply say
> allocate and retry ? Or should resv->lock be a mutex ?
> 

Yes, your proposal that simply allocate and retry looks good to me.
I will change it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
