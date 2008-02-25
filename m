Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1PMQ7f2012035
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:26:07 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1PMQ680281934
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:26:06 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1PMQ67H024297
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 17:26:06 -0500
Subject: Re: [PATCH 1/3] hugetlb: Correct page count for surplus huge pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20080225220129.23627.5152.stgit@kernel>
References: <20080225220119.23627.33676.stgit@kernel>
	 <20080225220129.23627.5152.stgit@kernel>
Content-Type: text/plain
Date: Mon, 25 Feb 2008 14:26:03 -0800
Message-Id: <1203978363.11846.10.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

Mon, 2008-02-25 at 14:01 -0800, Adam Litke wrote:
> 
>         spin_lock(&hugetlb_lock);
>         if (page) {
> +               /*
> +                * This page is now managed by the hugetlb allocator and has
> +                * no current users -- reset its reference count.
> +                */
> +               set_page_count(page, 0);

So, they come out of the allocator and have a refcount of 1, and you
want them to be consistent with the other huge pages that have a count
of 0?

I'd feel a lot better about this if you did a __put_page() then a
atomic_read() or equivalent to double-check what's going on.  (I
basically suggested the same thing to Jon Tollefson on the ginormous
page stuff).  It just forces the thing to be more consistent.

It also seems a bit goofy to me to zero the refcount here, then reset it
to one later on in update_and_free_page().

I dunno.  It just seems like every time something in here gets touched,
three other things break.  Makes me nervous. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
