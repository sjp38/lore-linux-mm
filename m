Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f41.google.com (mail-qe0-f41.google.com [209.85.128.41])
	by kanga.kvack.org (Postfix) with ESMTP id E45D46B00C4
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:36:30 -0500 (EST)
Received: by mail-qe0-f41.google.com with SMTP id gh4so3102203qeb.0
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:36:30 -0800 (PST)
Received: from g5t0006.atlanta.hp.com (g5t0006.atlanta.hp.com. [15.192.0.43])
        by mx.google.com with ESMTPS id l7si192353qat.113.2013.12.09.08.36.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 08:36:29 -0800 (PST)
Message-ID: <1386606983.2723.2.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v2 19/20] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 09 Dec 2013 08:36:23 -0800
In-Reply-To: <20130930074744.GA15351@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <1376040398-11212-20-git-send-email-iamjoonsoo.kim@lge.com>
	 <20130905011553.GA10158@voom.redhat.com> <20130905054357.GA23597@lge.com>
	 <20130916120909.GA2706@voom.fritz.box> <20130930074744.GA15351@lge.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: David Gibson <david@gibson.dropbear.id.au>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Mon, 2013-09-30 at 16:47 +0900, Joonsoo Kim wrote:
> On Mon, Sep 16, 2013 at 10:09:09PM +1000, David Gibson wrote:
> > > > 
> > > > > +		*do_dequeue = false;
> > > > >  		spin_unlock(&hugetlb_lock);
> > > > >  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> > > > >  		if (!page) {
> > > > 
> > > > I think the counter also needs to be incremented in the case where we
> > > > call alloc_buddy_huge_page() from alloc_huge_page().  Even though it's
> > > > new, it gets added to the hugepage pool at this point and could still
> > > > be a contended page for the last allocation, unless I'm missing
> > > > something.
> > > 
> > > Your comment has reasonable point to me, but I have a different opinion.
> > > 
> > > As I already mentioned, the point is that we want to avoid the race
> > > which kill the legitimate users of hugepages by out of resources.
> > > I increase 'h->nr_dequeue_users' when the hugepage allocated by
> > > administrator is dequeued. It is because what the hugepage I want to
> > > protect from the race is the one allocated by administrator via
> > > kernel param or /proc interface. Administrator may already know how many
> > > hugepages are needed for their application so that he may set nr_hugepage
> > > to reasonable value. I want to guarantee that these hugepages can be used
> > > for his application without any race, since he assume that the application
> > > would work fine with these hugepages.
> > > 
> > > To protect hugepages returned from alloc_buddy_huge_page() from the race
> > > is different for me. Although it will be added to the hugepage pool, this
> > > doesn't guarantee certain application's success more. If certain
> > > application's success depends on the race of this new hugepage, it's death
> > > by the race doesn't matter, since nobody assume that it works fine.
> > 
> > Hrm.  I still think this path should be included.  Although I'll agree
> > that failing in this case is less bad.
> > 
> > However, it can still lead to a situation where with two processes or
> > threads, faulting on exactly the same shared page we have one succeed
> > and the other fail.  That's a strange behaviour and I think we want to
> > avoid it in this case too.
> 
> Hello, David.
> 
> I don't think it is a strange behaviour. Similar situation can occur
> even though we use the mutex. Hugepage allocation can be failed when
> the first process try to allocate the hugepage while second process is blocked
> by the mutex. And then, second process will go into the fault handler. And
> at this time, it can succeed. So result is that we have one succeed and
> the other fail.
> 
> It is slightly different from the case you mentioned, but I think that
> effect for user is same. We cannot avoid this kind of race completely and
> I think that avoiding the race for administrator managed hugepage pool is
> good enough to use.

What was the final decision on this issue? Is Joonsoo's approach to
removing this mutex viable, or are we stuck with it?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
