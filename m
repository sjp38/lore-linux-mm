Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA28863
	for <linux-mm@kvack.org>; Fri, 1 Nov 2002 15:23:53 -0800 (PST)
Message-ID: <3DC30CD6.D92D0F9F@digeo.com>
Date: Fri, 01 Nov 2002 15:23:02 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Huge TLB pages always physically continious?
References: <20021101235620.A5263@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:
> 
> Hi there,
> 
> are huge TLB pages always physically continous in memory?

Yes.

> What does follow_hugetlb_page do exactly? I simply don't
> understand what the code does.

It allows get_user_pages() to work correctly across hugepage
regions.  It walks a chunk of memory which is covered by
hugepages and installs (at *pages) the list of 4k-pages which
are covered by the hugepage.  So

 |--------------------------------------------------|  <- hugepage
 |--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|--|  <- 4k pages

 get_user_pages(   ^here                   ^to here)

 will install the spanned 4k pages into the caller's pages[]
 array.
 
> I would like to build up a simplified get_user_pages_sgl() to
> build a scatter gather list from user space adresses.
> 
> If I want to coalesce physically continous pages (if they are
> also virtually continious) anyway, can I write up a simplified
> follow_hugetlb_page_sgl() function which handles the huge page
> really as only one page?

I suggest that you restructure get_user_pages thusly:

1: Write a simplified get_user_page().  Most callers of get_user_pages()
   only want a single page anyway, and don't need to concoct all those
   arguments.

2: Split get_user_pages up into a pagetable walker and a callback function.
   So it walks the pages, calling back to the caller's callback function
   for each page with

	(*callback)(struct page *page, <other stuff>, void *callerdata);

   You'll need to extend follow_hugetlb_page() to take the callback
   info and to perform the callbacks for its pages as well.

3: Reimplement the current get_user_pages() using the core engine from 2
   (ie: write the callback for it)

4: Implement your sg engine using the walker+callback arrangement.  This
   way, you can do your coalescing on-the-fly, and you only take one
   pass across the pages list and you do not need to know about hugepages
   at all.   Sure you'll do a *little* more work than you need to,  but
   not having that special case is nicer.

5: Fix up the ia64 follow_hugetlb_page too.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
