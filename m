Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B108A6B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 02:53:36 -0500 (EST)
Date: Tue, 16 Feb 2010 18:53:30 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem allocations
Message-ID: <20100216075330.GJ5723@laptop>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com>
 <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
 <20100216064402.GC5723@laptop>
 <alpine.DEB.2.00.1002152334260.7470@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002152334260.7470@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 15, 2010 at 11:41:49PM -0800, David Rientjes wrote:
> On Tue, 16 Feb 2010, Nick Piggin wrote:
> 
> > > As I already explained when you first brought this up, the possibility of 
> > > not invoking the oom killer is not unique to GFP_DMA, it is also possible 
> > > for GFP_NOFS.  Since __GFP_NOFAIL is deprecated and there are no current 
> > > users of GFP_DMA | __GFP_NOFAIL, that warning is completely unnecessary.  
> > > We're not adding any additional __GFP_NOFAIL allocations.
> > 
> > Completely agree with this request. Actually, I think even better you
> > should just add && !(gfp_mask & __GFP_NOFAIL). Deprecated doesn't mean
> > it is OK to break the API (callers *will* oops or corrupt memory if
> > __GFP_NOFAIL returns NULL).
> > 
> 
> ... unless it's used with GFP_ATOMIC, which we've always returned NULL 
> for when even ALLOC_HARDER can't find pages, right?

Ye, it's never worked with GFP_ATOMIC.


> I'm wondering where this strong argument in favor of continuing to support 
> __GFP_NOFAIL was when I insisted we call the oom killer for them even for 
> allocations over PAGE_ALLOC_COSTLY_ORDER when __alloc_pages_nodemask() was 
> refactored back in 2.6.31.  The argument was that nobody is allocating 
> that high of orders of __GFP_NOFAIL pages so we don't need to free memory 
> for them and that's where the deprecation of the modifier happened in the 
> first place.  Ultimately, we did invoke the oom killer for those 
> allocations because there's no chance of forward progress otherwise and, 
> unlike __GFP_DMA, GFP_KERNEL | __GFP_NOFAIL actually is popular.  

I don't know. IMO we should never just randomly weaken or break such
flag as the page allocator API.

> 
> I'll add this check to __alloc_pages_may_oom() for the !(gfp_mask & 
> __GFP_NOFAIL) path since we're all content with endlessly looping.

Thanks. Yes endlessly looping is far preferable to randomly oopsing
or corrupting memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
