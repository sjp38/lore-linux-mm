Date: Sat, 6 Nov 2004 02:20:18 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages / all_unreclaimable braindamage
Message-ID: <20041106012018.GT8229@dualathlon.random>
References: <20041105200118.GA20321@logos.cnet> <200411051532.51150.jbarnes@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200411051532.51150.jbarnes@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Barnes <jbarnes@sgi.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 05, 2004 at 03:32:50PM -0800, Jesse Barnes wrote:
> On Friday, November 05, 2004 12:01 pm, Marcelo Tosatti wrote:
> > In my opinion the correct approach is to trigger the OOM killer
> > when kswapd is unable to free pages. Once that is done, the number
> > of tasks inside page reclaim is irrelevant.
> 
> That makes sense.

I don't like it, kswapd may fail balancing because there's a GFP_DMA
allocation that eat the last dma page, but we should not kill tasks if
we fail to balance in kswapd, we should kill tasks only when no fail
path exists (i.e. only during page faults, everything else in the kernel
has a fail path and it should never trigger oom).

If you move it in kswapd there's no way to prevent oom-killing from a
syscall allocation (I guess even right now it would go wrong in this
sense, but at least right now it's more fixable). I want to move the oom
kill outside the alloc_page paths. The oom killing is all about the page
faults not having a fail path, and in turn the oom killing should be
moved in the page fault code, not in the allocator. Everything else
should keep returning -ENOMEM to the caller.

So to me moving the oom killer into kswapd looks a regression.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
