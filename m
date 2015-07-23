Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 73D496B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 19:09:32 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so3428425pac.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 16:09:32 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id ev9si15463537pad.47.2015.07.23.16.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 16:09:31 -0700 (PDT)
Received: by pdjr16 with SMTP id r16so3343716pdj.3
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 16:09:31 -0700 (PDT)
Date: Thu, 23 Jul 2015 16:09:28 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
Message-ID: <20150723230928.GI24876@Sligo.logfs.org>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com>
 <alpine.DEB.2.10.1507231506050.6965@chino.kir.corp.google.com>
 <20150723223651.GH24876@Sligo.logfs.org>
 <alpine.DEB.2.10.1507231550390.7871@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1507231550390.7871@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Spencer Baugh <sbaugh@catern.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

On Thu, Jul 23, 2015 at 03:54:43PM -0700, David Rientjes wrote:
> On Thu, 23 Jul 2015, Jorn Engel wrote:
> 
> > > This is wrong, you'd want to do any cond_resched() before the page 
> > > allocation to avoid racing with an update to h->nr_huge_pages or 
> > > h->surplus_huge_pages while hugetlb_lock was dropped that would result in 
> > > the page having been uselessly allocated.
> > 
> > There are three options.  Either
> > 	/* some allocation */
> > 	cond_resched();
> > or
> > 	cond_resched();
> > 	/* some allocation */
> > or
> > 	if (cond_resched()) {
> > 		spin_lock(&hugetlb_lock);
> > 		continue;
> > 	}
> > 	/* some allocation */
> > 
> > I think you want the second option instead of the first.  That way we
> > have a little less memory allocation for the time we are scheduled out.
> > Sure, we can do that.  It probably doesn't make a big difference either
> > way, but why not.
> > 
> 
> The loop is dropping the lock simply to do the allocation and it needs to 
> compare with the user-written number of hugepages to allocate.

And at this point the existing code is racy.  Page allocation might
block for minutes trying to free some memory.  A cond_resched doesn't
change that - it only increases the odds of hitting the race window.

> What we don't want is to allocate, reschedule, and check if we really 
> needed to allocate.  That's what your patch does because it races with 
> persistent_huge_page().  It's probably the worst place to do it.
> 
> Rather, what you want to do is check if you need to allocate, reschedule 
> if needed (and if so, recheck), and then allocate.
> 
> > If you are asking for the third option, I would rather avoid that.  It
> > makes the code more complex and doesn't change the fact that we have a
> > race and better be able to handle the race.  The code size growth will
> > likely cost us more performance that we would ever gain.  nr_huge_pages
> > tends to get updated once per system boot.
> 
> Your third option is nonsensical, you didn't save the state of whether you 
> locked the lock so you can't reliably unlock it, and you cannot hold a 
> spinlock while allocating in this context.

Are we looking at the same code?  Mine looks like this:
	while (count > persistent_huge_pages(h)) {
		/*
		 * If this allocation races such that we no longer need the
		 * page, free_huge_page will handle it by freeing the page
		 * and reducing the surplus.
		 */
		spin_unlock(&hugetlb_lock);
		if (hstate_is_gigantic(h))
			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
		else
			ret = alloc_fresh_huge_page(h, nodes_allowed);
		spin_lock(&hugetlb_lock);
		if (!ret)
			goto out;

		/* Bail for signals. Probably ctrl-c from user */
		if (signal_pending(current))
			goto out;
	}

What state is there to save?  We just called spin_unlock, we did a
schedule and if we want to continue without doing page allocation we
better take the lock again.  Or do you want to go even more complex and
check for signals as well?

The case you are concerned about is rare.  It is so rare that it doesn't
matter from a performance point of view, only for correctness.  And if
we hit the rare case, the worst harm would be an unnecessary allocation
that we return back to the system.  How much complexity do you think it
is worth to avoid this allocation?  How much runtime will the bigger
text size cost you in the common cases?

What matters to me is the scheduler latency.  That is real and happens
reliably once per boot.

Jorn

--
Chance favors only the prepared mind.
-- Louis Pasteur

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
