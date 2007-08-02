Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l72GuSVQ012281
	for <linux-mm@kvack.org>; Thu, 2 Aug 2007 12:56:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l72I0xCF505478
	for <linux-mm@kvack.org>; Thu, 2 Aug 2007 14:00:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l72I0wr6020877
	for <linux-mm@kvack.org>; Thu, 2 Aug 2007 14:00:59 -0400
Subject: Re: [PATCH 4/4] vmemmap ppc64: convert VMM_* macros to a
	real	function
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <46B216ED.9090404@shadowen.org>
References: <exportbomb.1186045945@pinky>
	 <E1IGWwO-0002Yc-8h@hellhawk.shadowen.org>
	 <1186072295.18414.257.camel@localhost>  <46B216ED.9090404@shadowen.org>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 11:00:56 -0700
Message-Id: <1186077656.18414.267.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 18:39 +0100, Andy Whitcroft wrote:
> Dave Hansen wrote:
> > On Thu, 2007-08-02 at 10:25 +0100, Andy Whitcroft wrote:
> >> +unsigned long __meminit vmemmap_section_start(struct page *page)
> >> +{
> >> +       unsigned long offset = ((unsigned long)page) -
> >> +                                               ((unsigned long)(vmemmap)); 
> > 
> > Isn't this basically page_to_pfn()?  Can we use it here?
> 
> No, as that does direct subtraction of the two pointers.  Our 'page'
> here is not guarenteed to be aligned even to a struct page boundary.

Are you saying that it isn't PAGE_MASK (((unsigned long)page)&PAGE_MASK
== page) aligned.  Or, that it isn't sizeof(struct page) aligned?

> +unsigned long __meminit vmemmap_section_start(struct page *page)
...
> @@ -204,7 +209,7 @@ int __meminit vmemmap_populated(unsigned long start, int page_size)
>         unsigned long end = start + page_size;
> 
>         for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
> -               if (pfn_valid(VMM_SECTION_PAGE(start)))
> +               if (pfn_valid(vmemmap_section_start(start)))
>                         return 1;

If "start" is an "unsigned long", why is it being passed into a function
that takes a "struct page"?

I think the types are confusing me a bit.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
