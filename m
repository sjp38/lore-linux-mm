Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PMvcDp022157
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:57:38 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PMtfh0247414
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:55:41 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PMte4q001735
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:55:41 -0500
Subject: Re: [PATCH 1/3] hugetlb: Correct page count for surplus huge pages
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1203978363.11846.10.camel@nimitz.home.sr71.net>
References: <20080225220119.23627.33676.stgit@kernel>
	 <20080225220129.23627.5152.stgit@kernel>
	 <1203978363.11846.10.camel@nimitz.home.sr71.net>
Content-Type: text/plain
Date: Mon, 25 Feb 2008 17:03:00 -0600
Message-Id: <1203980580.3837.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-25 at 14:26 -0800, Dave Hansen wrote:
> Mon, 2008-02-25 at 14:01 -0800, Adam Litke wrote:
> > 
> >         spin_lock(&hugetlb_lock);
> >         if (page) {
> > +               /*
> > +                * This page is now managed by the hugetlb allocator and has
> > +                * no current users -- reset its reference count.
> > +                */
> > +               set_page_count(page, 0);
> 
> So, they come out of the allocator and have a refcount of 1, and you
> want them to be consistent with the other huge pages that have a count
> of 0?

Yep all pages come out of the buddy allocator in this state.  What is
different in this case is that we are choosing not to enqueue it into
the hugetlb pool right away since it might be immediately needed by the
caller.

> I'd feel a lot better about this if you did a __put_page() then a
> atomic_read() or equivalent to double-check what's going on.  (I
> basically suggested the same thing to Jon Tollefson on the ginormous
> page stuff).  It just forces the thing to be more consistent.

I could agree to this.

> It also seems a bit goofy to me to zero the refcount here, then reset it
> to one later on in update_and_free_page().

Yeah, it is a special case -- and commented accordingly.  Do you have
any ideas how to avoid it without the wasted time of an
enqueue_huge_page()/dequeue_huge_page() cycle?

> I dunno.  It just seems like every time something in here gets touched,
> three other things break.  Makes me nervous. :(

Now c'mon, that's not fair.  I'd expect that sort of statement from the
Hillary Clinton campaign, not you Dave :)

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
