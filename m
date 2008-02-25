Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PNBpmt015239
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 18:11:51 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PNBpH6286654
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 18:11:51 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PNBp2t002587
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 18:11:51 -0500
Subject: Re: [PATCH 1/3] hugetlb: Correct page count for surplus huge pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1203980580.3837.30.camel@localhost.localdomain>
References: <20080225220119.23627.33676.stgit@kernel>
	 <20080225220129.23627.5152.stgit@kernel>
	 <1203978363.11846.10.camel@nimitz.home.sr71.net>
	 <1203980580.3837.30.camel@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 25 Feb 2008 15:11:49 -0800
Message-Id: <1203981109.11846.22.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-25 at 17:03 -0600, Adam Litke wrote:
> > It also seems a bit goofy to me to zero the refcount here, then reset it
> > to one later on in update_and_free_page().
> 
> Yeah, it is a special case -- and commented accordingly.  Do you have
> any ideas how to avoid it without the wasted time of an
> enqueue_huge_page()/dequeue_huge_page() cycle?

There are a couple of steps here, right?

1. alloc from the buddy list
2. initialize to set ->dtor, page->_count, etc...
3. enqueue_huge_page()
4. somebody does dequeue_huge_page() and gets it

I wonder if it might get simpler if you just make the pages on the
freelists "virgin buddy pages".  Basically don't touch pages much until
after they're dequeued.  Flip flop (a la John Kerry) the order around a
bit:

1. alloc from the buddy list
2. enqueue_huge_page()
3. somebody does dequeue_huge_page() and before it returns, we:
4. initialize to set ->dtor, page->_count, etc...

This has the disadvantage of shifting some work from a "once per alloc
from the buddy list" to "once per en/dequeue".  Basically, just try and
re-think when you turn pages from plain buddy pages into
hugetlb-flavored pages.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
