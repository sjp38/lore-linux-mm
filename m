Date: Thu, 11 Nov 2004 19:21:01 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [Fwd: Page allocator doubt]
Message-ID: <20041111212101.GA18822@logos.cnet>
References: <41937940.9070001@tteng.com.br> <1100200247.932.1145.camel@localhost> <4193BD07.5010100@tteng.com.br> <1100201816.7883.22.camel@localhost> <4193CA1B.1090409@tteng.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4193CA1B.1090409@tteng.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luciano A. Stertz" <luciano@tteng.com.br>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2004 at 06:22:51PM -0200, Luciano A. Stertz wrote:
> Dave Hansen wrote:
> >On Thu, 2004-11-11 at 11:27, Luciano A. Stertz wrote:
> >
> >>	But... are they allocated to me, even with page_count zeroed? Do I 
> >>	need to do get_page on the them? Sorry if it's a too lame question, but I 
> >>still didn't understand and found no place to read about this.
> >
> >
> >Do you see anywhere in the page allocator where it does a loop like
> >yours?
> >
> >        for (i = 1; i< 1<<order; i++)
> >		get_page(page + i);
> 	Actually this loop isn't mine. It's part of the page allocator, but 
> it's only executed on systems without a MMU.
> 
> >When you do a multi-order allocation, the first page represents the
> >whole group and they're treated as a whole.  As you've noticed, breaking
> >them up requires a little work.
> >
> >Why don't you post all of the code that you're using so that we can tell
> >what you're doing?  There might be a better way.  Drivers probably
> >shouldn't be putting stuff in the page cache all by themselves.  
> 	Unhappily I can't post any code yet, but I'll try to give an insight 
> 	of what we're trying to do.
> 	It's not a driver. We're doing an implementation to allow the kernel 
> 	to execute compressed files, decompressing pages on demand.
> 	These files will usually be compressed in small blocks, typically 
> 	4kb. But if they got compressed in blocks bigger then a page (say 8kb 
> blocks on a 4kb page system), the kernel will have more than one 
> decompressed page each time a block have to be decompressed; and I'd like 
> to add them both to the page cache.
> 	So, seems I would have to break multi-order allocated pages. Is this 
> possible / viable? If not, maybe I'll have to work only with small 
> blocks, but I wouldn't like to...

Why do you need the pages to be physically contiguous?

I dont see any reason for that requirement - you can use discontiguous physical
pages which are virtually contiguous (so your decompression code wont need to 
care about non adjacent pieces of memory).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
