Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [RFC][PATCH] dcache and rmap
Date: Tue, 7 May 2002 07:41:52 -0400
References: <200205052117.16268.tomlins@cam.org> <20020507014414.GL15756@holomorphy.com>
In-Reply-To: <20020507014414.GL15756@holomorphy.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200205070741.52896.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 6, 2002 09:44 pm, William Lee Irwin III wrote

stuff omitted

> Well, I think there are three major design issues. The first is the
> magic number of 32 pages. This (compile-time!) tunable is almost
> guaranteed not to work for everyone. The second is that in order to

Yes.  I figured I would keep it simple for now.   This could be made a
proc tuneable or kswapd could be modifed to autotune this.

> address the issue you're actually concerned about, it seems you would
> have to present some method for caches to know their allocation requests
> would require evicting other useful data to satisfy; for instance,

This is an interesting idea.  Might be as simple as hooking into the slab.c
code and checking if the number of freepages is to small.  Then we could
increment a counter/flag (which counter/flag set at cache create time, 
associated with a 'driver'.  See below).  If this works it would be generic
too...

> evicting pagecache holding useful (but clean) user data to allocate
> dcache. Third, the distinguished position of the dcache is suspicious
> to me; I feel that a greater degree of generality is in order.

In two years I have never seen any cache other than the dcache/icache
cause the problem.  I short, yes its suspicious, but warented (here) by 
experience.

> In short, I don't think you went far enough. How do you feel about
> GFP_SPECULATIVE (a.k.a. GFP_DONT_TRY_TOO_HARD), cache priorities and
> cache shrinking drivers?

Think I will sprinkle slab.c with a printk or two to see if we detect when
it's allocations are eating other caches.  If this works we should be able to
let the vm know when to shrink the slab cache and to let it know which
caches need shrinking (ie shrink_caches becomes a 'driver' to shrink the
dcache/icache family.  kmem_cache_reap being the generic 'driver')

Thanks for the feedback and interesting idea,

Ed Tomlinson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
