Date: Thu, 11 Nov 2004 22:50:43 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] fix spurious OOM kills
Message-ID: <20041111215043.GC5138@x30.random>
References: <20041111112922.GA15948@logos.cnet> <20041111154238.GD18365@x30.random> <20041111123850.GA16349@logos.cnet> <20041111165050.GA5822@x30.random> <318860000.1100194936@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <318860000.1100194936@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <piggin@cyberone.com.au>, Rik van Riel <riel@redhat.com>, Martin MOKREJ? <mmokrejs@ribosome.natur.cuni.cz>, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2004 at 09:42:17AM -0800, Martin J. Bligh wrote:
> >> > I disagree about the design of killing anything from kswapd. kswapd is
> >> > an async helper like pdflush and it has no knowledge on the caller (it
> >> > cannot know if the caller is ok with the memory currently available in
> >> > the freelists, before triggering the oom). 
> >> 
> >> If zone_dma / zone_normal are below pages_min no caller is "OK with
> >> memory currently available" except GFP_ATOMIC/realtime callers.
> > 
> > If the GFP_DMA zone is filled, and nobody allocates with GFP_DMA,
> > nothing should be killed and everything should run fine, how can you
> > get this right from kswapd?
> 
> Technically, that seems correct, but does it really matter much? We're 
> talking about 
> 
> "it's full of unreclaimable stuff" vs
> "it's full of unreclaimable stuff and someone tried to allocate a page".

exactly, that's the difference.

> So the difference is only ever one page, right? Doesn't really seem 

there's not a single page of difference.

> worth worrying about - we'll burn that in code space for the algorithms
> to do this ;-)

are you kidding? burnt space in the algorithm? the burnt space is to
move the thing in kswapd, period. that global variable and message
passing protocol between the task context and kswapd is the total waste.
There's no waste at all in moving the oom killer up the stack to
alloc_pages and in the future up outside alloc_pages with some more
higher level API.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
