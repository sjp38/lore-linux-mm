From: Andi Kleen <ak@suse.de>
Subject: Re: [rfc] increase struct page size?!
Date: Fri, 18 May 2007 14:06:39 +0200
References: <20070518040854.GA15654@wotan.suse.de>
In-Reply-To: <20070518040854.GA15654@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705181406.39702.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>
> I'd say all up this is going to decrease overall cache footprint in
> fastpaths, both by reducing text and data footprint of page_address and
> related operations, and by reducing cacheline footprint of most batched
> operations on struct pages.

I suspect the cache line footprint is not the main problem here (talking about
only one other cache line), but the potential latency of fetching the other 
half. One possible alternative instead of increasing struct page would be to 
identify places that commonly touch a page first (e.g. using oprofile) and 
then always add a prefetch()  there to fetch the other half of the page 
early. 

prefetch on something that is already in cache should be cheap,
so for the structs that don't straddle cachelines it shouldn't be a big
overhead.

I don't think doing the ->virtual addition will buy very much,
because at least the 64bit architectures will probably move
towards vmemmap where pfn->virt is quite cheap.

Of course the real long term fix for struct page cache overhead
would be larger soft page size.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
