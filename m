Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 34FC4900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:24:34 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3CF3JMW029643
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:03:31 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 75EF438C803C
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:24:22 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3CFOSSC1118282
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 11:24:29 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3CFORuL005691
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 12:24:28 -0300
Subject: Re: [PATCH 3/3] reuse __free_pages_exact() in __alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <op.vttl33xz3l0zgt@mnazarewicz-glaptop>
References: <20110411220345.9B95067C@kernel>
	 <20110411220348.D0280E4D@kernel>  <op.vttl33xz3l0zgt@mnazarewicz-glaptop>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 12 Apr 2011 08:24:24 -0700
Message-ID: <1302621864.8321.1856.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Tue, 2011-04-12 at 12:29 +0200, Michal Nazarewicz wrote:
> On Tue, 12 Apr 2011 00:03:48 +0200, Dave Hansen <dave@linux.vnet.ibm.com>  
> wrote:
> > diff -puN mm/page_alloc.c~reuse-free-exact mm/page_alloc.c
> > --- linux-2.6.git/mm/page_alloc.c~reuse-free-exact	2011-04-11  
> > 15:01:17.701822598 -0700
> > +++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-11 15:01:17.713822594  
> > -0700
> > @@ -2338,14 +2338,11 @@ struct page *__alloc_pages_exact(gfp_t g
> > 	page = alloc_pages(gfp_mask, order);
> >  	if (page) {
> > -		struct page *alloc_end = page + (1 << order);
> > -		struct page *used = page + nr_pages;
> > +		struct page *unused_start = page + nr_pages;
> > +		int nr_unused = (1 << order) - nr_pages;
> 
> How about unsigned long?

Personally, I'd rather leave this up to the poor sucker that tries to
set MAX_ORDER to 33.  If someone did that, we'd end up with kernels that
couldn't even boot on systems with less than 16GB of RAM since the
(required) flatmem mem_map[] would take up ~14.3GB.  They couldn't
handle memory holes and couldn't be NUMA-aware, either. 

So, if someone had a system like that, fixed up all the other spots
where we store numbers of pages in ints, and then did an 8TB+4k
allocation, yes, this would matter.  I'd rather save the 10 bytes of
source code and 4 bytes of stack than account for such an impossibly
improbable system.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
