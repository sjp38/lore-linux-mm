Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 75C526B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 18:36:55 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so2973268pdr.2
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 15:36:55 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id y5si15271969pas.76.2015.07.23.15.36.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 15:36:54 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so2999134pdb.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 15:36:54 -0700 (PDT)
Date: Thu, 23 Jul 2015 15:36:51 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
Message-ID: <20150723223651.GH24876@Sligo.logfs.org>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
 <alpine.DEB.2.10.1507231506050.6965@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1507231506050.6965@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Spencer Baugh <sbaugh@catern.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

On Thu, Jul 23, 2015 at 03:08:58PM -0700, David Rientjes wrote:
> On Thu, 23 Jul 2015, Spencer Baugh wrote:
> > From: Joern Engel <joern@logfs.org>
> > 
> > ~150ms scheduler latency for both observed in the wild.
> > 
> > Signed-off-by: Joern Engel <joern@logfs.org>
> > Signed-off-by: Spencer Baugh <sbaugh@catern.com>
> > ---
> >  mm/hugetlb.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index a8c3087..2eb6919 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1836,6 +1836,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
> >  			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
> >  		else
> >  			ret = alloc_fresh_huge_page(h, nodes_allowed);
> > +		cond_resched();
> >  		spin_lock(&hugetlb_lock);
> >  		if (!ret)
> >  			goto out;
> 
> This is wrong, you'd want to do any cond_resched() before the page 
> allocation to avoid racing with an update to h->nr_huge_pages or 
> h->surplus_huge_pages while hugetlb_lock was dropped that would result in 
> the page having been uselessly allocated.

There are three options.  Either
	/* some allocation */
	cond_resched();
or
	cond_resched();
	/* some allocation */
or
	if (cond_resched()) {
		spin_lock(&hugetlb_lock);
		continue;
	}
	/* some allocation */

I think you want the second option instead of the first.  That way we
have a little less memory allocation for the time we are scheduled out.
Sure, we can do that.  It probably doesn't make a big difference either
way, but why not.

If you are asking for the third option, I would rather avoid that.  It
makes the code more complex and doesn't change the fact that we have a
race and better be able to handle the race.  The code size growth will
likely cost us more performance that we would ever gain.  nr_huge_pages
tends to get updated once per system boot.

> > @@ -3521,6 +3522,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  				spin_unlock(ptl);
> >  			ret = hugetlb_fault(mm, vma, vaddr,
> >  				(flags & FOLL_WRITE) ? FAULT_FLAG_WRITE : 0);
> > +			cond_resched();
> >  			if (!(ret & VM_FAULT_ERROR))
> >  				continue;
> >  
> 
> This is almost certainly the wrong placement as well since it's inserted 
> inside a conditional inside a while loop and there's no reason to 
> hugetlb_fault(), schedule, and then check the return value.  You need to 
> insert your cond_resched()'s in legitimate places.

I assume you want the second option here as well.  Am I right?

Jorn

--
Sometimes it pays to stay in bed on Monday, rather than spending the rest
of the week debugging Monday's code.
-- Christopher Thompson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
