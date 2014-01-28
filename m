Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9E96B0038
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 20:54:02 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id ii20so8216475qab.5
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:54:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id fg9si4424754qcb.105.2014.01.27.17.54.00
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 17:54:01 -0800 (PST)
Date: Mon, 27 Jan 2014 20:53:41 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390874021-48f5mo0m-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1390859042.27421.4.camel@buesod1.americas.hpqcorp.net>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
 <1390794746-16755-4-git-send-email-davidlohr@hp.com>
 <1390856576-ud1qp3fm-mutt-n-horiguchi@ah.jp.nec.com>
 <1390859042.27421.4.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 3/8] mm, hugetlb: fix race in region tracking
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Davidlohr,

On Mon, Jan 27, 2014 at 01:44:02PM -0800, Davidlohr Bueso wrote:
> On Mon, 2014-01-27 at 16:02 -0500, Naoya Horiguchi wrote:
> > On Sun, Jan 26, 2014 at 07:52:21PM -0800, Davidlohr Bueso wrote:
> > > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > 
> > > There is a race condition if we map a same file on different processes.
> > > Region tracking is protected by mmap_sem and hugetlb_instantiation_mutex.
> > > When we do mmap, we don't grab a hugetlb_instantiation_mutex, but only the,
> > > mmap_sem (exclusively). This doesn't prevent other tasks from modifying the
> > > region structure, so it can be modified by two processes concurrently.
> > > 
> > > To solve this, introduce a spinlock to resv_map and make region manipulation
> > > function grab it before they do actual work.
> > > 
> > > Acked-by: David Gibson <david@gibson.dropbear.id.au>
> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > > [Updated changelog]
> > > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > > ---
> > ...
> > > @@ -203,15 +200,23 @@ static long region_chg(struct resv_map *resv, long f, long t)
> > >  	 * Subtle, allocate a new region at the position but make it zero
> > >  	 * size such that we can guarantee to record the reservation. */
> > >  	if (&rg->link == head || t < rg->from) {
> > > -		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> > > -		if (!nrg)
> > > -			return -ENOMEM;
> > > +		if (!nrg) {
> > > +			spin_unlock(&resv->lock);
> > 
> > I think that doing kmalloc() inside the lock is simpler.
> > Why do you unlock and retry here?
> 
> This is a spinlock, no can do -- we've previously debated this and since
> the critical region is quite small, a non blocking lock is better suited
> here. We do the retry so we don't race once the new region is allocated
> after the lock is dropped.

Using spinlock instead of rw_sem makes sense.
But I'm not sure how the retry is essential to fix the race.
(Sorry I can't find the discussion log about this.)
As you did in your ver.1 (https://lkml.org/lkml/2013/7/26/296),
simply doing like below seems to be fine to me, is it right?

        if (&rg->link == head || t < rg->from) {
		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
		if (!nrg) {
			chg = -ENOMEM;
			goto out_locked;
		}
		nrg->from = f;
		...
	}

In the current version nrg is initialized to NULL, so we always do retry
once when adding new file_region. That's not optimal to me.

If this retry is really essential for the fix, please comment the reason
both in patch description and inline comment. It's very important for
future code maintenance.

And I noticed another point. I don't think the name of new goto label
'out_locked' is a good one. 'out_unlock' or 'unlock' is better.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
