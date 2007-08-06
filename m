Date: Mon, 6 Aug 2007 15:12:57 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
Message-ID: <20070806201257.GG11115@waste.org>
References: <20070806102922.907530000@chello.nl> <200708061121.50351.phillips@phunq.net> <Pine.LNX.4.64.0708061141511.3152@schroedinger.engr.sgi.com> <200708061148.43870.phillips@phunq.net> <Pine.LNX.4.64.0708061150270.7603@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708061150270.7603@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Daniel Phillips <phillips@phunq.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 06, 2007 at 11:51:45AM -0700, Christoph Lameter wrote:
> On Mon, 6 Aug 2007, Daniel Phillips wrote:
> 
> > On Monday 06 August 2007 11:42, Christoph Lameter wrote:
> > > On Mon, 6 Aug 2007, Daniel Phillips wrote:
> > > > Currently your system likely would have died here, so ending up
> > > > with a reserve page temporarily on the wrong node is already an
> > > > improvement.
> > >
> > > The system would have died? Why?
> > 
> > Because a block device may have deadlocked here, leaving the system 
> > unable to clean dirty memory, or unable to load executables over the 
> > network for example.
> 
> So this is a locking problem that has not been taken care of?

No.

It's very simple:

1) memory becomes full
2) we try to free memory by paging or swapping
3) I/O requires a memory allocation which fails because memory is full
4) box dies because it's unable to dig itself out of OOM

Most I/O paths can deal with this by having a mempool for their I/O
needs. For network I/O, this turns out to be prohibitively hard due to
the complexity of the stack.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
