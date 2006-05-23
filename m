Date: Tue, 23 May 2006 09:24:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: tracking dirty pages patches
In-Reply-To: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0605230917390.9731@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 May 2006, Hugh Dickins wrote:

> The other worries are in page_wrprotect_one's block
> 	entry = pte_mkclean(pte_wrprotect(*pte));
> 	ptep_establish(vma, address, pte, entry);
> 	update_mmu_cache(vma, address, entry);
> 	lazy_mmu_prot_update(entry);
> ptep_establish, update_mmu_cache and lazy_mmu_prot_update are tricky
> arch-dependent functions which have hitherto only been used on the
> current task mm, whereas you're now using them from (perhaps) another.

Page migration is also doing that in the version slated for 2.6.18 
in Andrew's tree.
 
> Well, no, I'm wrong: ptrace's get_user_pages has been using them
> from another process; but that's not so common a case as to reassure
> me there won't be issues on some architectures there.

> Quite likely ptep_establish and update_mmu_cache are okay for use in
> that way (needs careful checking of arches), at least they take a vma
> argument from which the mm can be found.  Whereas lazy_mmu_prot_update
> looks likely to be wrong, but only does something on ia64: you need
> to consult ia64 mm gurus to check what's needed there.  Maybe it'll
> just be a suboptimal issue (but more important now than in ptrace
> to make it optimal).

On ia64 lazy_mmu_prot_update deals with the aliasing issues between the 
icache and the dcache. For an executable page we need to flush the icache.

> Is there a problem with page_wrprotect on VM_LOCKED vmas?  I'm not
> sure: usually VM_LOCKED guarantees no faulting, you abandon that.

mlock guarantees that the page is not swapped out. We already modify
the dirty bit and the protections on the VMLOCKED ptes via mprotect.

> (Why does follow_pages set_page_dirty at all?  I _think_ it's in case
> the get_user_pages caller forgets to set_page_dirty when releasing.
> But that's not how we usually write kernel code, to hide mistakes most
> of the time, and your mods may change the balance there.  Andrew will
> remember better whether that set_page_dirty has stronger justification.)

follow_page() transfers the dirty bit from the pte to the page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
