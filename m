Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFC36B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:44:15 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id vb8so7229083obc.32
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 13:44:14 -0800 (PST)
Received: from g1t0026.austin.hp.com (g1t0026.austin.hp.com. [15.216.28.33])
        by mx.google.com with ESMTPS id f4si5938583oel.92.2014.01.27.13.44.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jan 2014 13:44:13 -0800 (PST)
Message-ID: <1390859042.27421.4.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 3/8] mm, hugetlb: fix race in region tracking
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 27 Jan 2014 13:44:02 -0800
In-Reply-To: <1390856576-ud1qp3fm-mutt-n-horiguchi@ah.jp.nec.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
	 <1390794746-16755-4-git-send-email-davidlohr@hp.com>
	 <1390856576-ud1qp3fm-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-01-27 at 16:02 -0500, Naoya Horiguchi wrote:
> On Sun, Jan 26, 2014 at 07:52:21PM -0800, Davidlohr Bueso wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > There is a race condition if we map a same file on different processes.
> > Region tracking is protected by mmap_sem and hugetlb_instantiation_mutex.
> > When we do mmap, we don't grab a hugetlb_instantiation_mutex, but only the,
> > mmap_sem (exclusively). This doesn't prevent other tasks from modifying the
> > region structure, so it can be modified by two processes concurrently.
> > 
> > To solve this, introduce a spinlock to resv_map and make region manipulation
> > function grab it before they do actual work.
> > 
> > Acked-by: David Gibson <david@gibson.dropbear.id.au>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > [Updated changelog]
> > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > ---
> ...
> > @@ -203,15 +200,23 @@ static long region_chg(struct resv_map *resv, long f, long t)
> >  	 * Subtle, allocate a new region at the position but make it zero
> >  	 * size such that we can guarantee to record the reservation. */
> >  	if (&rg->link == head || t < rg->from) {
> > -		nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> > -		if (!nrg)
> > -			return -ENOMEM;
> > +		if (!nrg) {
> > +			spin_unlock(&resv->lock);
> 
> I think that doing kmalloc() inside the lock is simpler.
> Why do you unlock and retry here?

This is a spinlock, no can do -- we've previously debated this and since
the critical region is quite small, a non blocking lock is better suited
here. We do the retry so we don't race once the new region is allocated
after the lock is dropped.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
