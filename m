Subject: Re: [PATCH 0/5] make slab gfp fair
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070514124451.c868c4c0.akpm@linux-foundation.org>
References: <20070514131904.440041502@chello.nl>
	 <Pine.LNX.4.64.0705140852150.10442@schroedinger.engr.sgi.com>
	 <20070514161224.GC11115@waste.org>
	 <20070514124451.c868c4c0.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 14 May 2007 22:05:29 +0200
Message-Id: <1179173129.2942.52.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-05-14 at 12:44 -0700, Andrew Morton wrote:
> On Mon, 14 May 2007 11:12:24 -0500
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > If I understand this correctly:
> > 
> > privileged thread                      unprivileged greedy process
> > kmem_cache_alloc(...)
> >    adds new slab page from lowmem pool
> > do_io()
> >                                        kmem_cache_alloc(...)
> >                                        kmem_cache_alloc(...)
> >                                        kmem_cache_alloc(...)
> >                                        kmem_cache_alloc(...)
> >                                        kmem_cache_alloc(...)
> >                                        ...
> >                                           eats it all
> > kmem_cache_alloc(...) -> ENOMEM
> >    who ate my donuts?!
> 
> Yes, that's my understanding also.
> 
> I can see why it's a problem in theory, but I don't think Peter has yet
> revealed to us why it's a problem in practice.  I got all excited when
> Christoph asked "I am not sure what the point of all of this is.", but
> Peter cunningly avoided answering that ;)
> 
> What observed problem is being fixed here?

I'm moving towards swapping over networked storage. Admittedly a new
feature.

Like with pretty much all other swap solutions; there is the fundamental
vm deadlock: freeing memory requires memory. Current block devices get
around that by using mempools. This works well.

However with network traffic mempools are not easily usable; the network
stack uses kmalloc. By using reserve based allocation we can keep
operating in a similar matter.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
