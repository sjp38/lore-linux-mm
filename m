Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iABKYEJT541392
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 15:34:15 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iABKYE1p240234
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 13:34:14 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iABKYE0u030070
	for <linux-mm@kvack.org>; Thu, 11 Nov 2004 13:34:14 -0700
Subject: Re: [Fwd: Page allocator doubt]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <4193CA1B.1090409@tteng.com.br>
References: <41937940.9070001@tteng.com.br>
	 <1100200247.932.1145.camel@localhost>  <4193BD07.5010100@tteng.com.br>
	 <1100201816.7883.22.camel@localhost>  <4193CA1B.1090409@tteng.com.br>
Content-Type: text/plain
Message-Id: <1100205251.7883.90.camel@localhost>
Mime-Version: 1.0
Date: Thu, 11 Nov 2004 12:34:11 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luciano A. Stertz" <luciano@tteng.com.br>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-11-11 at 12:22, Luciano A. Stertz wrote:
> Dave Hansen wrote:
> > On Thu, 2004-11-11 at 11:27, Luciano A. Stertz wrote:
> > 
> >>	But... are they allocated to me, even with page_count zeroed? Do I need 
> >>to do get_page on the them? Sorry if it's a too lame question, but I 
> >>still didn't understand and found no place to read about this.
> > 
> > 
> > Do you see anywhere in the page allocator where it does a loop like
> > yours?
> > 
> >         for (i = 1; i< 1<<order; i++)
> > 		get_page(page + i);
> 	Actually this loop isn't mine. It's part of the page allocator, but 
> it's only executed on systems without a MMU.

Well, what does that tell you?  How can page_count(page[i]) be non-zero
unless someone goes and sets it like that for pages other than the first
(0th) one?

> 	Unhappily I can't post any code yet, but I'll try to give an insight of 
> what we're trying to do.
> 	It's not a driver. We're doing an implementation to allow the kernel to 
> execute compressed files, decompressing pages on demand.
> 	These files will usually be compressed in small blocks, typically 4kb. 
> But if they got compressed in blocks bigger then a page (say 8kb blocks 
> on a 4kb page system), the kernel will have more than one decompressed 
> page each time a block have to be decompressed; and I'd like to add them 
> both to the page cache.

 Why do 2 *uncompressed* blocks have to be physically contiguous?  If
you're decompressing and you need more than one page, just allocate
another one.  I understand that your algorithms may not be optimized for
this right now, but that's what you get for doing it in the kernel. :)

> 	So, seems I would have to break multi-order allocated pages. Is this 
> possible / viable? If not, maybe I'll have to work only with small 
> blocks, but I wouldn't like to...

It's possible, but you shouldn't do it.  Multi-order pages are a very
valuable commodity and should be reserved for things that *ABSOLUTELY*
need them, like DMA buffers.  If you ever get a system up for a while
and under a lot of memory pressure, those non-order-zero allocations are
going to start failing all over the place.

Make your code handle all order-0 pages now.  You'll need to do it
eventually.  

-- Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
