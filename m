Date: Mon, 10 Sep 2007 13:17:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <1189454122.21778.47.camel@twins>
Message-ID: <Pine.LNX.4.64.0709101315020.25407@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>  <200709050220.53801.phillips@phunq.net>
  <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
 <20070905114242.GA19938@wotan.suse.de>  <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
  <20070905121937.GA9246@wotan.suse.de>  <Pine.LNX.4.64.0709101225350.24735@schroedinger.engr.sgi.com>
  <1189453031.21778.28.camel@twins>  <Pine.LNX.4.64.0709101238510.24941@schroedinger.engr.sgi.com>
 <1189454122.21778.47.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Sep 2007, Peter Zijlstra wrote:

> > Allright maybe you can get the kernel to be stable in the face of having 
> > no memory and debug all the fallback paths in the kernel when an OOM 
> > condition occurs.
> > 
> > But system calls will fail? Like fork/exec? etc? There may be daemons 
> > running that are essential for the system to survive and that cannot 
> > easily take an OOM condition? Various reclaim paths also need memory and 
> > if the allocation fails then reclaim cannot continue.
> 
> I'm not making any of these paths significantly more likely to occur
> than they already are. Lots and lots of users run swap heavy loads day
> in day out - they don't get funny systems (well sometimes they do, and
> theoretically we can easily run out of the PF_MEMALLOC reserves -
> HOWEVER in practise it seems to work quite reliably).
> 

The patchset increases these failures significantly since there will be a 
longer time period where these allocations can fail.

The swap loads are fine as long as we do not exhaust the reserve pools.

IMHO the right solution is to throttle the networking layer to not do 
unbounded allocations. You can likely do this by checking certain VM 
counters like SLAB_UNRECLAIMABLE. If need be we can add a new category of 
SLAB_TEMPORARY for temporary allocs and track these. If they get too large 
then throttle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
