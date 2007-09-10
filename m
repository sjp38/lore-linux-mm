Date: Mon, 10 Sep 2007 13:22:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <1189454145.21778.48.camel@twins>
Message-ID: <Pine.LNX.4.64.0709101318160.25407@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com>  <200709050220.53801.phillips@phunq.net>
  <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
 <200709050916.04477.phillips@phunq.net>  <Pine.LNX.4.64.0709101220001.24735@schroedinger.engr.sgi.com>
 <1189454145.21778.48.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Sep 2007, Peter Zijlstra wrote:

> On Mon, 2007-09-10 at 12:25 -0700, Christoph Lameter wrote:
> 
> > Of course boundless allocations from interrupt / reclaim context will 
> > ultimately crash the system. To fix that you need to stop the networking 
> > layer from performing these.
> 
> Trouble is, I don't only need a network layer to not endlessly consume
> memory, I need it to 'fully' function so that we can receive the
> writeout completion.

You need to drop packets after having inspected them right? Why wont 
dropping packets after a certain amount of memory has been allocated work? 
What is so difficult about that?

> or
> 
>   - have a global reserve and selectively serves sockets
>     (what I've been doing)

That is a scalability problem on large systems! Global means global 
serialization, cacheline bouncing and possibly livelocks. If we get into 
this global shortage then all cpus may end up taking the same locks 
cycling thought the same allocation paths.

> So, if you will, you can view my approach as a reserve per socket, where
> most sockets get a reserve of 0 and a few (those serving the VM) !0.

Well it looks like you know how to do it. Why not implement it?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
