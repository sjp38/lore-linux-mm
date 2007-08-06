Date: Mon, 6 Aug 2007 13:19:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
In-Reply-To: <20070806201257.GG11115@waste.org>
Message-ID: <Pine.LNX.4.64.0708061315510.7603@schroedinger.engr.sgi.com>
References: <20070806102922.907530000@chello.nl> <200708061121.50351.phillips@phunq.net>
 <Pine.LNX.4.64.0708061141511.3152@schroedinger.engr.sgi.com>
 <200708061148.43870.phillips@phunq.net> <Pine.LNX.4.64.0708061150270.7603@schroedinger.engr.sgi.com>
 <20070806201257.GG11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Matt Mackall wrote:

> > > Because a block device may have deadlocked here, leaving the system 
> > > unable to clean dirty memory, or unable to load executables over the 
> > > network for example.
> > 
> > So this is a locking problem that has not been taken care of?
> 
> No.
> 
> It's very simple:
> 
> 1) memory becomes full

We do have limits to avoid memory getting too full.

> 2) we try to free memory by paging or swapping
> 3) I/O requires a memory allocation which fails because memory is full
> 4) box dies because it's unable to dig itself out of OOM
> 
> Most I/O paths can deal with this by having a mempool for their I/O
> needs. For network I/O, this turns out to be prohibitively hard due to
> the complexity of the stack.

The common solution is to have a reserve (min_free_kbytes). The problem 
with the network stack seems to be that the amount of reserve needed 
cannot be predicted accurately.

The solution may be as simple as configuring the reserves right and 
avoid the unbounded memory allocations. That is possible if one 
would make sure that the network layer triggers reclaim once in a 
while.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
