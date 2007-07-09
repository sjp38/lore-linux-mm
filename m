Date: Mon, 9 Jul 2007 16:08:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/10] [RFC] SLUB patches for more functionality,
 performance and maintenance
In-Reply-To: <20070709225817.GA5111@Krystal>
Message-ID: <Pine.LNX.4.64.0707091605380.20282@schroedinger.engr.sgi.com>
References: <20070708034952.022985379@sgi.com> <p73y7hrywel.fsf@bingen.suse.de>
 <Pine.LNX.4.64.0707090845520.13792@schroedinger.engr.sgi.com>
 <46925B5D.8000507@google.com> <Pine.LNX.4.64.0707091055090.16207@schroedinger.engr.sgi.com>
 <4692A1D0.50308@mbligh.org> <20070709214426.GC1026@Krystal>
 <Pine.LNX.4.64.0707091451200.18780@schroedinger.engr.sgi.com>
 <20070709225817.GA5111@Krystal>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Martin Bligh <mbligh@mbligh.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Jul 2007, Mathieu Desnoyers wrote:

> > > Yep, I volountarily used the variant without lock prefix because the
> > > data is per cpu and I disable preemption.
> > 
> > local_cmpxchg generates this?
> > 
> 
> Yes.

Does not work here. If I use

static void __always_inline *slab_alloc(struct kmem_cache *s,
                gfp_t gfpflags, int node, void *addr)
{
        void **object;
        struct kmem_cache_cpu *c;

        preempt_disable();
        c = get_cpu_slab(s, smp_processor_id());
redo:
        object = c->freelist;
        if (unlikely(!object || !node_match(c, node)))
                return __slab_alloc(s, gfpflags, node, addr, c);

        if (cmpxchg_local(&c->freelist, object, object[c->offset]) != object)
                goto redo;

        preempt_enable();
        if (unlikely((gfpflags & __GFP_ZERO)))
                memset(object, 0, c->objsize);

        return object;
}

Then the code will include a lock prefix:

    3270:       48 8b 1a                mov    (%rdx),%rbx
    3273:       48 85 db                test   %rbx,%rbx
    3276:       74 23                   je     329b <kmem_cache_alloc+0x4b>
    3278:       8b 42 14                mov    0x14(%rdx),%eax
    327b:       4c 8b 0c c3             mov    (%rbx,%rax,8),%r9
    327f:       48 89 d8                mov    %rbx,%rax
    3282:       f0 4c 0f b1 0a          lock cmpxchg %r9,(%rdx)
    3287:       48 39 c3                cmp    %rax,%rbx
    328a:       75 e4                   jne    3270 <kmem_cache_alloc+0x20>
    328c:       66 85 f6                test   %si,%si
    328f:       78 19                   js     32aa <kmem_cache_alloc+0x5a>
    3291:       48 89 d8                mov    %rbx,%rax
    3294:       48 83 c4 08             add    $0x8,%rsp
    3298:       5b                      pop    %rbx
    3299:       c9                      leaveq
    329a:       c3                      retq


> What applies to local_inc, given as example in the local_ops.txt
> document, applies integrally to local_cmpxchg. And I would say that
> local_cmpxchg is by far the cheapest locking mechanism I have found, and
> use today, for my kernel tracer. The idea emerged from my need to trace
> every execution context, including NMIs, while still providing good
> performances. local_cmpxchg was the perfect fit; that's why I deployed
> it in local.h in each and every architecture.

Great idea. The SLUB allocator may be able to use your idea to improve 
both the alloc and free path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
