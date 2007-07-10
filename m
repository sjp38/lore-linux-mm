Received: from krystal.dyndns.org ([76.65.100.197])
          by tomts16-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20070710051616.CSZJ1673.tomts16-srv.bellnexxia.net@krystal.dyndns.org>
          for <linux-mm@kvack.org>; Tue, 10 Jul 2007 01:16:16 -0400
Date: Tue, 10 Jul 2007 01:16:16 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [PATCH] x86_64 - Use non locked version for local_cmpxchg()
Message-ID: <20070710051616.GB16148@Krystal>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de> <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com> <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com> <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal> <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com> <20070709225817.GA5111@Krystal> <Pine.LNX.4.64.0707091605380.20282@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707091605380.20282@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

You are completely right: on x86_64, a bit got lost in the move to
cmpxchg.h, here is the fix. It applies on 2.6.22-rc6-mm1.

x86_64 - Use non locked version for local_cmpxchg()

local_cmpxchg() should not use any LOCK prefix. This change probably got lost in
the move to cmpxchg.h.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
---
 include/asm-x86_64/cmpxchg.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-lttng/include/asm-x86_64/cmpxchg.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-x86_64/cmpxchg.h	2007-07-10 01:10:10.000000000 -0400
+++ linux-2.6-lttng/include/asm-x86_64/cmpxchg.h	2007-07-10 01:11:03.000000000 -0400
@@ -128,7 +128,7 @@
 	((__typeof__(*(ptr)))__cmpxchg((ptr),(unsigned long)(o),\
 					(unsigned long)(n),sizeof(*(ptr))))
 #define cmpxchg_local(ptr,o,n)\
-	((__typeof__(*(ptr)))__cmpxchg((ptr),(unsigned long)(o),\
+	((__typeof__(*(ptr)))__cmpxchg_local((ptr),(unsigned long)(o),\
 					(unsigned long)(n),sizeof(*(ptr))))
 
 #endif


* Christoph Lameter (clameter@sgi.com) wrote:
> On Mon, 9 Jul 2007, Mathieu Desnoyers wrote:
> 
> > > > Yep, I volountarily used the variant without lock prefix because the
> > > > data is per cpu and I disable preemption.
> > > 
> > > local_cmpxchg generates this?
> > > 
> > 
> > Yes.
> 
> Does not work here. If I use
> 
> static void __always_inline *slab_alloc(struct kmem_cache *s,
>                 gfp_t gfpflags, int node, void *addr)
> {
>         void **object;
>         struct kmem_cache_cpu *c;
> 
>         preempt_disable();
>         c = get_cpu_slab(s, smp_processor_id());
> redo:
>         object = c->freelist;
>         if (unlikely(!object || !node_match(c, node)))
>                 return __slab_alloc(s, gfpflags, node, addr, c);
> 
>         if (cmpxchg_local(&c->freelist, object, object[c->offset]) != object)
>                 goto redo;
> 
>         preempt_enable();
>         if (unlikely((gfpflags & __GFP_ZERO)))
>                 memset(object, 0, c->objsize);
> 
>         return object;
> }
> 
> Then the code will include a lock prefix:
> 
>     3270:       48 8b 1a                mov    (%rdx),%rbx
>     3273:       48 85 db                test   %rbx,%rbx




>     3276:       74 23                   je     329b <kmem_cache_alloc+0x4b>
>     3278:       8b 42 14                mov    0x14(%rdx),%eax
>     327b:       4c 8b 0c c3             mov    (%rbx,%rax,8),%r9
>     327f:       48 89 d8                mov    %rbx,%rax
>     3282:       f0 4c 0f b1 0a          lock cmpxchg %r9,(%rdx)
>     3287:       48 39 c3                cmp    %rax,%rbx
>     328a:       75 e4                   jne    3270 <kmem_cache_alloc+0x20>
>     328c:       66 85 f6                test   %si,%si
>     328f:       78 19                   js     32aa <kmem_cache_alloc+0x5a>
>     3291:       48 89 d8                mov    %rbx,%rax
>     3294:       48 83 c4 08             add    $0x8,%rsp
>     3298:       5b                      pop    %rbx
>     3299:       c9                      leaveq
>     329a:       c3                      retq
> 
> 
> > What applies to local_inc, given as example in the local_ops.txt
> > document, applies integrally to local_cmpxchg. And I would say that
> > local_cmpxchg is by far the cheapest locking mechanism I have found, and
> > use today, for my kernel tracer. The idea emerged from my need to trace
> > every execution context, including NMIs, while still providing good
> > performances. local_cmpxchg was the perfect fit; that's why I deployed
> > it in local.h in each and every architecture.
> 
> Great idea. The SLUB allocator may be able to use your idea to improve 
> both the alloc and free path.
> 

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
