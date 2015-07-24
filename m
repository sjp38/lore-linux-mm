Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 577DF6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 15:49:17 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so18969354pab.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:49:17 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id nu16si22907095pdb.199.2015.07.24.12.49.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 12:49:16 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so18938619pac.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:49:15 -0700 (PDT)
Date: Fri, 24 Jul 2015 12:49:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] hugetlb: cond_resched for set_max_huge_pages and
 follow_hugetlb_page
In-Reply-To: <20150723230928.GI24876@Sligo.logfs.org>
Message-ID: <alpine.DEB.2.10.1507241237420.5215@chino.kir.corp.google.com>
References: <1437688476-3399-1-git-send-email-sbaugh@catern.com> <alpine.DEB.2.10.1507231506050.6965@chino.kir.corp.google.com> <20150723223651.GH24876@Sligo.logfs.org> <alpine.DEB.2.10.1507231550390.7871@chino.kir.corp.google.com>
 <20150723230928.GI24876@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397176738-21862817-1437767156=:5215"
Content-ID: <alpine.DEB.2.10.1507241245590.5215@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>
Cc: Spencer Baugh <sbaugh@catern.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Mike Kravetz <mike.kravetz@oracle.com>, Luiz Capitulino <lcapitulino@redhat.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>, Spencer Baugh <Spencer.baugh@purestorage.com>, Joern Engel <joern@logfs.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397176738-21862817-1437767156=:5215
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.10.1507241245591.5215@chino.kir.corp.google.com>

On Thu, 23 Jul 2015, JA?rn Engel wrote:

> > The loop is dropping the lock simply to do the allocation and it needs to 
> > compare with the user-written number of hugepages to allocate.
> 
> And at this point the existing code is racy.  Page allocation might
> block for minutes trying to free some memory.  A cond_resched doesn't
> change that - it only increases the odds of hitting the race window.
> 

The existing code has always been racy, it explicitly admits this, the 
problem is that your patch is making the race window larger.

> Are we looking at the same code?  Mine looks like this:
> 	while (count > persistent_huge_pages(h)) {
> 		/*
> 		 * If this allocation races such that we no longer need the
> 		 * page, free_huge_page will handle it by freeing the page
> 		 * and reducing the surplus.
> 		 */
> 		spin_unlock(&hugetlb_lock);
> 		if (hstate_is_gigantic(h))
> 			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
> 		else
> 			ret = alloc_fresh_huge_page(h, nodes_allowed);
> 		spin_lock(&hugetlb_lock);
> 		if (!ret)
> 			goto out;
> 
> 		/* Bail for signals. Probably ctrl-c from user */
> 		if (signal_pending(current))
> 			goto out;
> 	}
> 

I don't see the cond_resched() you propose to add, but the need for it is 
obvious with a large user-written nr_hugepages in the above loop.

The suggestion is to check the conditional, reschedule if needed (and if 
so, recheck the conditional), and then allocate.

Your third option looks fine and the best place to do the cond_resched().  
I was looking at your second option when I responded and compared it to 
the first.  We don't want to do cond_resched() immediately before or after 
the allocation, the net result is the same: we may be pointlessly 
allocating the hugepage and each hugepage allocation can be very 
heavyweight.

So I agree with your third option from the previous email.

You may also want to include the actual text of the warning from the 
kernel log in your commit message.  When people encounter this, then will 
probably grep in the kernel logs for some keywords to see if it was 
already fixed and I fear your current commit message may allow it to be 
missed.
--397176738-21862817-1437767156=:5215--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
