Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8HK7m9B021378
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 16:07:48 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HK7iZT458646
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 14:07:45 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HK7hMH004329
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 14:07:44 -0600
Subject: Re: [PATCH 3/4] hugetlb: Try to grow hugetlb pool for MAP_SHARED
	mappings
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <46EECAA0.9080300@kolumbus.fi>
References: <20070917163935.32557.50840.stgit@kernel>
	 <20070917164009.32557.4348.stgit@kernel>  <46EEB7C1.70806@kolumbus.fi>
	 <1190050936.15024.89.camel@localhost.localdomain>
	 <46EECAA0.9080300@kolumbus.fi>
Content-Type: text/plain; charset=ISO-8859-15
Date: Mon, 17 Sep 2007 15:07:42 -0500
Message-Id: <1190059662.15024.103.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-17 at 21:42 +0300, Mika Penttila wrote:
> Adam Litke wrote:
> > On Mon, 2007-09-17 at 20:22 +0300, Mika Penttila wrote:
> >   
> >>> +void return_unused_surplus_pages(void)
> >>> +{
> >>> +	static int nid = -1;
> >>> +	int delta;
> >>> +	struct page *page;
> >>> +
> >>> +	delta = unused_surplus_pages - resv_huge_pages;
> >>> +
> >>> +	while (delta) {
> >>>   
> >>>       
> >> Shouldn't this be while (delta >= 0) ?
> >>     
> >
> > unused_surplus_pages is always >= resv_huge_pages so delta cannot go
> > negative.  But for clarity it makes sense to apply the change you
> > suggest.  Thanks for responding.
> >
> >   
> I think unused_surplus_pages accounting isn't quite right. It gets 
> always decremented in dequeue_huge_page() but incremented only if we 
> haven't enough free pages at reserve time.

Ahh yes, good catch.  The solution is to only decrement
unused_surplus_pages in dequeue_huge_page() until it becomes zero.  Once
that condition is true we know that return_unused_surplus_pages() will
have no work to do.  Thank you for your careful review.  I am now
testing this case specifically.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
