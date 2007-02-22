Subject: Re: [PATCH 08/29] mm: kmem_cache_objs_to_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <84144f020702210747t50d7d92ei1a2f5da8bf117d40@mail.gmail.com>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144842.299190000@taijtu.programming.kicks-ass.net>
	 <84144f020702210747t50d7d92ei1a2f5da8bf117d40@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 22 Feb 2007 10:28:28 +0100
Message-Id: <1172136508.6374.41.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-02-21 at 17:47 +0200, Pekka Enberg wrote:
> Hi Peter,
> 
> On 2/21/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > Provide a method to calculate the number of pages needed to store a given
> > number of slab objects (upper bound when considering possible partial and
> > free slabs).
> 
> So how does this work? You ask the slab allocator how many pages you
> need for a given number of objects and then those pages are available
> to it via the page allocator? Can other users also dip into those
> reserves?

Everybody (ab)using PF_MEMALLOC or the new __GFP_EMERGENCY.

> I would prefer we simply have an API for telling the slab allocator to
> keep certain number of pages in a reserve for a cache rather than
> exposing internals such as object size to rest of the world.

Keeping the free pages in the page allocator is good for the buddy
system. Although you could probably implement a reserve interface
without actually claiming the pages.

However, doing it like so separates the making of the reserve from the
actual kmem_cache object, I can just carry a sum of pages around instead
of a list of kmem_cache pointers.

I calculate a potential reserve, I might never actually commit to making
(and using) the reserve.

Also, I don't see what internals are exposed, kmem_cache is still
private to slab.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
