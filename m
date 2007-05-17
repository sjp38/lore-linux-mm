Date: Thu, 17 May 2007 12:53:27 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 0/5] make slab gfp fair
Message-ID: <20070517175327.GX11115@waste.org>
References: <20070514131904.440041502@chello.nl> <Pine.LNX.4.64.0705161957440.13458@schroedinger.engr.sgi.com> <1179385718.27354.17.camel@twins> <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705171027390.17245@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2007 at 10:29:06AM -0700, Christoph Lameter wrote:
> On Thu, 17 May 2007, Peter Zijlstra wrote:
> 
> > I'm really not seeing why you're making such a fuzz about it; normally
> > when you push the system this hard we're failing allocations left right
> > and center too. Its just that the block IO path has some mempools which
> > allow it to write out some (swap) pages and slowly get back to sanity.
> 
> I am weirdly confused by these patches. Among other things you told me 
> that the performance does not matter since its never (or rarely) being 
> used (why do it then?).

Because it's a failsafe.

Simply stated, the problem is sometimes it's impossible to free memory
without allocating more memory. Thus we must keep enough protected
reserve that we can guarantee progress. This is what mempools are for
in the regular I/O stack. Unfortunately, mempools are a bad match for
network I/O.

It's absolutely correct that performance doesn't matter in the case
this patch is addressing. All that matters is digging ourselves out of
OOM. The box either survives the crisis or it doesn't.

It's also correct that we should hardly ever get into a situation
where we trigger this problem. But such cases are still fairly easy to
trigger in some workloads. Swap over network is an excellent example,
because we typically don't start swapping heavily until we're quite
low on freeable memory.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
