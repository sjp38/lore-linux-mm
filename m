Date: Tue, 21 Nov 2006 13:14:10 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: build error: sparsemem + SLOB
Message-ID: <20061121191410.GL4797@waste.org>
References: <Pine.LNX.4.64.0611201724340.23537@blonde.wat.veritas.com> <20061120183632.GD4797@waste.org> <20061121143253.51B5.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061121143253.51B5.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 21, 2006 at 02:57:23PM +0900, Yasunori Goto wrote:
> > On Mon, Nov 20, 2006 at 05:28:24PM +0000, Hugh Dickins wrote:
> > > On Mon, 20 Nov 2006, Christoph Lameter wrote:
> > > > 
> > > > As far as I can tell SLOB is fundamentally racy since it does not support 
> > > > SLAB_DESTROY_BY_RCU correctly. F.e. The constructor for the anon_vma will 
> > > > be called on alloc without regard for RCU, we free an item and reuse it 
> > > > without regard to RCU. This can potentially mess up the anon_vma locking 
> > > > state while we access it.
> > > 
> > > Good find!
> > > 
> > > > Is SLOB used at all or have we been lucky so far?
> > >
> > > Lucky so far.  Well, we'd actually have to be quite unlucky to ever
> > > see what page_lock_anon_vma/SLAB_DESTROY_BY_RCU are guarding against.
> > >
> > > But you're absolutely right that users should not be exposed to such
> > > unsafety.  I'd say SLOB should be disallowed if SMP.
> > 
> > SLOB is an O(N) allocator and is pretty poorly suited to running on
> > anything like a modern desktop. Disallowing if SMP is probably
> > reasonable, as even machines with multicore ARM or MIPS will probably
> > have enough memory to make SLOB a bit painful.
> 
> Ok. It's simple. This is fix.

Are there any implications for preemptible kernels here?

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
