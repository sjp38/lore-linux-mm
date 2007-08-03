Date: Fri, 3 Aug 2007 02:57:00 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] balance-on-fork NUMA placement
Message-ID: <20070803005700.GD14775@wotan.suse.de>
References: <20070731054142.GB11306@wotan.suse.de> <200707311114.09284.ak@suse.de> <Pine.LNX.4.64.0707311639450.31337@schroedinger.engr.sgi.com> <20070802034201.GA32631@wotan.suse.de> <Pine.LNX.4.64.0708021254160.8527@schroedinger.engr.sgi.com> <20070803002639.GC14775@wotan.suse.de> <Pine.LNX.4.64.0708021748110.13312@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708021748110.13312@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 02, 2007 at 05:52:28PM -0700, Christoph Lameter wrote:
> On Fri, 3 Aug 2007, Nick Piggin wrote:
> 
> > > Add a (slow) kmalloc_policy? Strict Object round robin for interleave 
> > > right? It probably needs its own RR counter otherwise it disturbs the per 
> > > task page RR.
> > 
> > I guess interleave could be nice for other things, but for this, I
> > just want MPOL_BIND to work. The problem is that the pagetable copying
> > etc codepaths cover a lot of code and some of it (eg pagetable allocation)
> > is used for other paths as well.. so I was just hoping to do something
> > less intrusive for now if possible.
> 
> Ok. So MPOL_BIND on a single node. We would have to save the current 
> memory policy on the stack and then restore it later. Then you would need 
> a special call anyways.

Well the memory policy will already be set to MPOL_BIND at this point.
The slab allocator I think would just have to honour the node at the
object level.


 
> Or is there some way to execute the code on the target cpu? That may be 
> the easiest solution.

It isn't so easy... we'd have to migrate the parent process to the new
node to perform the setup, and then migrate it back again afterwards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
