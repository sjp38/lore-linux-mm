From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
Date: Mon, 6 Aug 2007 15:47:30 -0700
References: <20070806102922.907530000@chello.nl> <20070806201257.GG11115@waste.org> <Pine.LNX.4.64.0708061315510.7603@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708061315510.7603@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061547.30681.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

(What Peter already wrote, but in different words)

On Monday 06 August 2007 13:19, Christoph Lameter wrote:
> The solution may be as simple as configuring the reserves right and
> avoid the unbounded memory allocations.

Exactly.  That is what this patch set is about.  This is the part that 
provides some hooks to extend the traditional reserves to be able to 
handle some of the more difficult situations.

> That is possible if one 
> would make sure that the network layer triggers reclaim once in a
> while.

No.  It does no good at all for network to do a bunch of work 
reclaiming, then have some other random task (for example, a heavy 
writer) swoop in and grab the reclaimed memory before net can use it.  
Also, net allocates memory in interrupt context where shrink_caches is 
not possible.  The correct solution is to _reserve_ the memory net 
needs for vm writeout, which is in Peter's next patch set coming down 
the pipe.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
