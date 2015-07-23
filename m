Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCDE6B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 18:54:48 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so3189656pdb.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 15:54:47 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id af12si15325612pac.137.2015.07.23.15.54.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 15:54:47 -0700 (PDT)
Received: by pabkd10 with SMTP id kd10so3285469pab.2
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 15:54:46 -0700 (PDT)
Date: Thu, 23 Jul 2015 15:54:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
In-Reply-To: <20150723223651.GH24876@Sligo.logfs.org>
Message-ID: <alpine.DEB.2.10.1507231550390.7871@chino.kir.corp.google.com>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com> <alpine.DEB.2.10.1507231506050.6965@chino.kir.corp.google.com> <20150723223651.GH24876@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-215516084-1437692085=:7871"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>
Cc: Spencer Baugh <sbaugh@catern.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-215516084-1437692085=:7871
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 23 Jul 2015, Jorn Engel wrote:

> > This is wrong, you'd want to do any cond_resched() before the page 
> > allocation to avoid racing with an update to h->nr_huge_pages or 
> > h->surplus_huge_pages while hugetlb_lock was dropped that would result in 
> > the page having been uselessly allocated.
> 
> There are three options.  Either
> 	/* some allocation */
> 	cond_resched();
> or
> 	cond_resched();
> 	/* some allocation */
> or
> 	if (cond_resched()) {
> 		spin_lock(&hugetlb_lock);
> 		continue;
> 	}
> 	/* some allocation */
> 
> I think you want the second option instead of the first.  That way we
> have a little less memory allocation for the time we are scheduled out.
> Sure, we can do that.  It probably doesn't make a big difference either
> way, but why not.
> 

The loop is dropping the lock simply to do the allocation and it needs to 
compare with the user-written number of hugepages to allocate.

What we don't want is to allocate, reschedule, and check if we really 
needed to allocate.  That's what your patch does because it races with 
persistent_huge_page().  It's probably the worst place to do it.

Rather, what you want to do is check if you need to allocate, reschedule 
if needed (and if so, recheck), and then allocate.

> If you are asking for the third option, I would rather avoid that.  It
> makes the code more complex and doesn't change the fact that we have a
> race and better be able to handle the race.  The code size growth will
> likely cost us more performance that we would ever gain.  nr_huge_pages
> tends to get updated once per system boot.
> 

Your third option is nonsensical, you didn't save the state of whether you 
locked the lock so you can't reliably unlock it, and you cannot hold a 
spinlock while allocating in this context.
--397176738-215516084-1437692085=:7871--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
