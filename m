Subject: Re: [PATCH]: Clean up of __alloc_pages
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <4362DF80.3060802@yahoo.com.au>
References: <20051028183326.A28611@unix-os.sc.intel.com>
	 <4362DF80.3060802@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 31 Oct 2005 12:55:07 -0800
Message-Id: <1130792107.4853.24.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 2005-10-29 at 12:33 +1000, Nick Piggin wrote:

> Rohit, Seth wrote:
> > the only changes in this clean up are:
> > 
> 
> Looking good. I imagine it must be good for icache.
> Man, the page allocator somehow turned unreadable since I last
> looked at it! We will want this patch.
> 

Thanks for your comments.

> > 	1- remove the initial direct reclaim logic
> > 	2- GFP_HIGH pages are allowed to go little below low watermark sooner
> 
> I don't think #2 is any good. The reason we don't check GFP_HIGH on
> the first time round is because we simply want to kick kswapd at its
> normal watermark - ie. it doesn't matter what kind of allocation this
> is, kswapd should start at the same time no matter what.
> 
> If you don't do this, then a GFP_HIGH allocator can allocate right
> down to its limit before it kicks kswapd, then it either will fail or
> will have to do direct reclaim.
> 

You are right if there are only GFP_HIGH requests coming in then the
allocation will go down to (min - min/2) before kicking in kswapd.
Though if the requester is not ready to wait, there is another good shot
at allocation succeed before we get into direct reclaim (and this is
happening based on can_try_harder flag).

> >
> >  got_pg:
> > -	zone_statistics(zonelist, z);
> > +	zone_statistics(zonelist, page_zone(page));
> >  	return page;
> 
> How about moving the zone_statistics up into the 'if (page)'
> test of get_page_from_freelist? This way we don't have to
> evaluate page_zone().
> 

Let us keep this as is for now.  Will revisit once after the
pcp_prefer_allocation patches get in place. 

Thanks,
-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
