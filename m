Date: Thu, 10 Apr 2008 10:24:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: git-slub crashes on the t16p
Message-Id: <20080410102454.8248e0ae.akpm@linux-foundation.org>
In-Reply-To: <47FE41EE.8040402@cs.helsinki.fi>
References: <20080410015958.bc2fd041.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804101327190.15828@sbz-30.cs.Helsinki.FI>
	<47FE37D0.5030004@cs.helsinki.fi>
	<47FE41EE.8040402@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Thu, 10 Apr 2008 19:35:58 +0300 Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> Pekka Enberg wrote:
> >>> It's the tree I pulled about 12 hours ago.  Quite early in boot.
> >>>
> >>> crash: http://userweb.kernel.org/~akpm/p4105087.jpg
> >>> config: http://userweb.kernel.org/~akpm/config-t61p.txt
> >>> git-slub.patch: 
> >>> http://userweb.kernel.org/~akpm/mmotm/broken-out/git-slub.patch
> >>>
> >>> A t61p is a dual-core x86_64.
> >>>
> >>> I was testing with all of the -mm series up to and including 
> >>> git-slub.patch
> >>> applied.
> > 
> > On Thu, 10 Apr 2008, Andrew Morton wrote:
> >> Does the following patch fix it?
> > 
> > Okay, forget the patch. Looking at disassembly of the oops:
> > 
> > 0000000000000000 <.text>:
> >    0:   eb ce                   jmp    0xffffffffffffffd0
> >    2:   48 89 de                mov    %rbx,%rsi
> >    5:   4c 89 e7                mov    %r12,%rdi
> >    8:   e8 38 fe ff ff          callq  0xfffffffffffffe45
> >    d:   b8 01 00 00 00          mov    $0x1,%eax
> >   12:   5b                      pop    %rbx
> >   13:   41 5c                   pop    %r12
> >   15:   c9                      leaveq
> >   16:   c3                      retq
> >   17:   c3                      retq
> >   18:   48 63 f6                movslq %esi,%rsi
> >   1b:   55                      push   %rbp
> >   1c:   48 8b 8c f7 20 01 00    mov    0x120(%rdi,%rsi,8),%rcx
> >   23:   00
> >   24:   48 89 e5                mov    %rsp,%rbp
> >   27:   48 85 c9                test   %rcx,%rcx
> >   2a:   74 0d                   je     0x39
> >   2c:   f0 48 ff 41 50          lock incq 0x50(%rcx) # %rcx == 0x64
> >   31:   48 63 c2                movslq %edx,%rax
> >   34:   f0 48 01 41 58          lock add %rax,0x58(%rcx)
> >   39:   c9                      leaveq
> >   3a:   c3                      retq
> >   3b:   48 8b 07                mov    (%rdi),%rax
> >   3e:   55                      push   %rbp
> >   3f:   48                      rex.W
> >   40:   89                      .byte 0x89
> > 
> > Somehow s->node[node] gets to be 0x64 which makes no sense. I checked my 
> > logs and I hit the exact same problem but it went away with "make 
> > clean". Andrew, can you please try that as well?
> 
> I can't reproduce this on my 2-way with CONFIG_NUMA with or without 
> numa=fake enabled and Mel Gorman tells me my tree boots on their monster 
> numa boxen so I'm a wee bit at of a loss here.... Hmm

I retested with just origin.patch and git-slub.patch.  Did a `make mproper'
first.  Similar crash happens: http://userweb.kernel.org/~akpm/p4105088.jpg

That's within the call to atomic64_inc(), from the inc_slabs_node() here:

0xffffffff8109c348 is in new_slab (mm/slub.c:1159).
1154                    flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
1155            if (!page)
1156                    goto out;
1157    
1158            inc_slabs_node(s, node, page->objects);
1159            page->slab = s;
1160            page->flags |= 1 << PG_slab;
1161            if (s->flags & (SLAB_DEBUG_FREE | SLAB_RED_ZONE | SLAB_POISON |
1162                            SLAB_STORE_USER | SLAB_TRACE))
1163                    SetSlabDebug(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
