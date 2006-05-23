Date: Tue, 23 May 2006 12:31:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: tracking dirty pages patches
In-Reply-To: <Pine.LNX.4.64.0605231937410.14985@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0605231223360.10836@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605230917390.9731@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605231937410.14985@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2006, Hugh Dickins wrote:

> > On ia64 lazy_mmu_prot_update deals with the aliasing issues between the 
> > icache and the dcache. For an executable page we need to flush the icache.
> 
> And looking more closely, I now see it operates on the underlying struct
> page and its kernel page_address(), nothing to do with userspace mm.
> 
> Okay, but it's pointless for Peter to call it from page_wrprotect_one
> (which is making no change to executability), isn't that so?

That is true for ia64. However, the name "lazy_mmu_prot_update" suggests
that the intended scope is to cover protection updates in general. 
And we definitely change the protections of the page.

Maybe we could rename lazy_mmu_prot_update? What does icache/dcache 
aliasing have to do with page protection?

> You're right, silly of me not to look it up: yes, "memory-resident" is
> the critical issue, so VM_LOCKED presents no problem to Peter's patch.

Page migration currently also assumes that VM_LOCKED means do not move the 
page. At some point we may want to have a separate flag that guarantees
that a page should not be moved. This would enable the moving of VM_LOCKED 
pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
