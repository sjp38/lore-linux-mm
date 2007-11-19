Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJLJrW6027755
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 16:19:53 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAJLJjkv040330
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:19:48 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJLJj7i016648
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:19:45 -0700
Subject: Re: [PATCH] Cast page_to_pfn to unsigned long in CONFIG_SPARSEMEM
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071119130801.bd7b7021.akpm@linux-foundation.org>
References: <20071113194025.150641834@polymtl.ca>
	 <1195160783.7078.203.camel@localhost> <20071115215142.GA7825@Krystal>
	 <1195164977.27759.10.camel@localhost> <20071116144742.GA17255@Krystal>
	 <1195495626.27759.119.camel@localhost> <20071119185258.GA998@Krystal>
	 <1195501381.27759.127.camel@localhost> <20071119195257.GA3440@Krystal>
	 <1195502983.27759.134.camel@localhost> <20071119202023.GA5086@Krystal>
	 <20071119130801.bd7b7021.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 19 Nov 2007 13:19:43 -0800
Message-Id: <1195507183.27759.150.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-11-19 at 13:08 -0800, Andrew Morton wrote:
> 
> >  #else
> > -#define page_to_pfn __page_to_pfn
> > +#define page_to_pfn ((unsigned long)__page_to_pfn)
> >  #define pfn_to_page __pfn_to_page
> >  #endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
> 
> I'd have thought that __pfn_to_page() was the place to fix this: the
> lower-level point.  Because someone might later start using
> __pfn_to_page()
> for something.
> 
> Heaven knows why though - why does __pfn_to_page() even exist?

I think it's this stuff:
        
        #ifdef CONFIG_OUT_OF_LINE_PFN_TO_PAGE
        struct page *pfn_to_page(unsigned long pfn)
        {
                return __pfn_to_page(pfn);
        }
        unsigned long page_to_pfn(struct page *page)
        {
                return __page_to_pfn(page);
        }
        EXPORT_SYMBOL(pfn_to_page);
        EXPORT_SYMBOL(page_to_pfn);
        #endif /* CONFIG_OUT_OF_LINE_PFN_TO_PAGE */
        
Which comes from:
        
        config OUT_OF_LINE_PFN_TO_PAGE
                def_bool X86_64
                depends on DISCONTIGMEM
        
and only on x86_64.  Perhaps it can go away with the
discontig->sparsemem-vmemmap conversion.

-- Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
