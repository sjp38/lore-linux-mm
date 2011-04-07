Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 832428D003B
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 18:18:30 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p37LqhM7004469
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 17:52:43 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id A757D38C8038
	for <linux-mm@kvack.org>; Thu,  7 Apr 2011 18:18:19 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p37MHkwL193000
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 18:17:59 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p37MHjVB031435
	for <linux-mm@kvack.org>; Thu, 7 Apr 2011 16:17:46 -0600
Subject: Re: [PATCH 2/2] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104071452070.14967@chino.kir.corp.google.com>
References: <20110407172104.1F8B7329@kernel>
	 <20110407172105.831B9A0A@kernel>
	 <alpine.DEB.2.00.1104071452070.14967@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 07 Apr 2011 15:17:43 -0700
Message-ID: <1302214663.8184.4164.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 2011-04-07 at 15:03 -0700, David Rientjes wrote:
> On Thu, 7 Apr 2011, Dave Hansen wrote:
> > What I really wanted in the end was a highmem-capable alloc_pages_exact(),
> > so here it is.
> 
> Perhaps expand upon how the new alloc_pages_exact() works and what it will 
> be used for instead of only talking about how it's named?

Will do.

> > +/* 'struct page' version */
> > +struct page *__alloc_pages_exact(gfp_t, size_t);
> > +void __free_pages_exact(struct page *, size_t);
> 
> They're not required, but these should have the names of the arguments 
> like the other prototypes in this file.

Fair enough.

> > -	addr = __get_free_pages(gfp_mask, order);
> > -	if (addr) {
> > -		unsigned long alloc_end = addr + (PAGE_SIZE << order);
> > -		unsigned long used = addr + PAGE_ALIGN(size);
> > +	page = alloc_pages(gfp_mask, order);
> > +	if (page) {
> > +		struct page *alloc_end = page + (1 << order);
> > +		struct page *used = page + PAGE_ALIGN(size)/PAGE_SIZE;
> 
> Wouldn't it better to call this "unused" rather than "used" since it 
> represents a cursor over pages that we want to free?

Yeah, agreed.  I think I screwed this up once when coding this because I
misread it.  I'll change it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
