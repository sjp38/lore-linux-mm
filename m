From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
Date: Mon, 6 Aug 2007 16:16:46 -0700
References: <20070806102922.907530000@chello.nl> <Pine.LNX.4.64.0708061315510.7603@schroedinger.engr.sgi.com> <20070806132747.4b9cea80.akpm@linux-foundation.org>
In-Reply-To: <20070806132747.4b9cea80.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061616.46611.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2007 13:27, Andrew Morton wrote:
> On Mon, 6 Aug 2007 13:19:26 -0700 (PDT) Christoph Lameter wrote:
> > The solution may be as simple as configuring the reserves right and
> > avoid the unbounded memory allocations. That is possible if one
> > would make sure that the network layer triggers reclaim once in a
> > while.
>
> Such a simple fix would be attractive.  Some of the net drivers now
> have remarkably large rx and tx queues.  One wonders if this is
> playing a part in the problem and whether reducing the queue sizes
> would help.

There is nothing wrong with having huge rx and tx queues, except when 
they lie in the vm writeout path.  In that case, we do indeed throttle 
them to reasonable numbers.

See:

   http://zumastor.googlecode.com/svn/trunk/ddsnap/kernel/dm-ddsnap.c
   down(&info->throttle_sem);

The only way we have ever gotten ddsnap to run reliably under heavy load 
without deadlocking is with Peter's patch set (a distant descendant of 
mine from two years or so ago) and we did put a lot of effort into 
trying to make congestion_wait and friends do the job instead.

To be sure, it is a small subset of Peter's full patch set that actually 
does the job that congestion_wait cannot be made to do, which is to 
guarantee that socket->write() is always able to get enough memory to 
send out the vm traffic without recursing.  What Peter's patches do is 
make it _nice_ to fix these problems.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
