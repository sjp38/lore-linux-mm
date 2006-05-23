Date: Tue, 23 May 2006 21:34:11 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: tracking dirty pages patches
In-Reply-To: <Pine.LNX.4.64.0605231223360.10836@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0605232131560.19019@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605230917390.9731@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605231937410.14985@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605231223360.10836@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, Rohit Seth <rohitseth@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2006, Christoph Lameter wrote:
> On Tue, 23 May 2006, Hugh Dickins wrote:
> 
> > > On ia64 lazy_mmu_prot_update deals with the aliasing issues between the 
> > > icache and the dcache. For an executable page we need to flush the icache.
> > 
> > And looking more closely, I now see it operates on the underlying struct
> > page and its kernel page_address(), nothing to do with userspace mm.
> > 
> > Okay, but it's pointless for Peter to call it from page_wrprotect_one
> > (which is making no change to executability), isn't that so?
> 
> That is true for ia64. However, the name "lazy_mmu_prot_update" suggests
> that the intended scope is to cover protection updates in general. 
> And we definitely change the protections of the page.

True, and I now see Documentation/cachetlb.txt documents it that way.
Yet nothing but ia64 has any use for it.

> Maybe we could rename lazy_mmu_prot_update? What does icache/dcache 
> aliasing have to do with page protection?

I'd strongly agree with you that it should be renamed: for a start,
why does it say "lazy"?  That's an architectural implementation detail.

Except that, instead of agreeing it should be renamed, I say it should
be deleted entirely.  It seems to represent that ia64 has an empty
update_mmu_cache, and someone decided to add a new interface instead
of giving ia64 that work to do in its update_mmu_cache.

That someone being Rohit, CC'ed.

I can make no sense of it from its callsites.  It seems to be called
immediately after any update_mmu_cache, unless the source file is
called mm/fremap.c, in which case it's left out.

> > You're right, silly of me not to look it up: yes, "memory-resident" is
> > the critical issue, so VM_LOCKED presents no problem to Peter's patch.
> 
> Page migration currently also assumes that VM_LOCKED means do not move the 
> page. At some point we may want to have a separate flag that guarantees
> that a page should not be moved. This would enable the moving of VM_LOCKED 
> pages.

Oh yes, I'd noticed that subject going by, and meant to speak up
sometime.  I feel pretty strongly, and have so declared in the past,
that VM_LOCKED should _not_ guarantee that the same physical page is
used forever: get_user_pages is what's used to pin a physical page
for that effect.  I remember Arjan sharing this opinion.

You might discover a problem or two in letting page migration go that
way, I'm not saying there cannot be a problem; but I'd much rather
you try without adding a new flag unless it's proved necessary.
And I know Linus prefers not to go overboard with extra flags.

You mentioned in one of the mails that went past that you'd seen
drivers enforcing VM_LOCKED in vm_flags: aren't those just drivers
copying other drivers which did so, but achieving nothing thereby,
to be cleaned up in due course?  (The pages aren't even on LRU.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
