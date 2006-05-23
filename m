Subject: Re: tracking dirty pages patches
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Wed, 24 May 2006 01:07:07 +0200
Message-Id: <1148425627.10561.32.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-05-22 at 20:31 +0100, Hugh Dickins wrote:
> Belated observations on your "tracking dirty pages" patches.

Thanks for the thorough examination, I always suspected there was
something I'd overlooked, this being my first foray into these parts of
the code.

> page_wrprotect is a nice use of rmap, but I see a couple of problems.
> One is in the lock ordering (there's info on mm lock ordering at the
> top of filemap.c, but I find the list at the top of rmap.c easier).
> 
> set_page_dirty has always (awkwardly) been liable to be called from
> very low in the hierarchy; whereas you're assuming clear_page_dirty
> is called from much higher up.  And in most cases there's no problem
> (please cross-check to confirm that); but try_to_free_buffers in fs/
> buffer.c calls it while holding mapping->private_lock - page_wrprotect
> called from test_clear_page_dirty then violates the order.
> 
> If we're lucky and that is indeed the only violation, maybe Andrew
> can recommend a change to try_to_free_buffers to avoid it: I have
> no appreciation of the issues at that end myself.

Not really familiar with the code myself either, but from some
inspection it seems safe to do so. ->private_lock seems to serialise
access to the page buffers, not the page state.

Will be in the next version.

> The other worries are in page_wrprotect_one's block
> 	entry = pte_mkclean(pte_wrprotect(*pte));
> 	ptep_establish(vma, address, pte, entry);
> 	update_mmu_cache(vma, address, entry);
> 	lazy_mmu_prot_update(entry);
> ptep_establish, update_mmu_cache and lazy_mmu_prot_update are tricky
> arch-dependent functions which have hitherto only been used on the
> current task mm, whereas you're now using them from (perhaps) another.
> 
> Well, no, I'm wrong: ptrace's get_user_pages has been using them
> from another process; but that's not so common a case as to reassure
> me there won't be issues on some architectures there.

Christoph Lameter has cleared up the waters here, thanks!

> Quite likely ptep_establish and update_mmu_cache are okay for use in
> that way (needs careful checking of arches), at least they take a vma
> argument from which the mm can be found.  Whereas lazy_mmu_prot_update
> looks likely to be wrong, but only does something on ia64: you need
> to consult ia64 mm gurus to check what's needed there.  Maybe it'll
> just be a suboptimal issue (but more important now than in ptrace
> to make it optimal).

Not much here, except to say: thanks for the discussions, they were very
educative.

> Is there a problem with page_wrprotect on VM_LOCKED vmas?  I'm not
> sure: usually VM_LOCKED guarantees no faulting, you abandon that.

Also cleared up by Christoph, he is my hero for today ;-)

> Like others, I don't care for "VM_SharedWritable": you followed the
> VM_ReadHint macros, but this isn't a read hint, and those are weird.
> 
> Personally, I much prefer the explicit
> 	((vma->vm_flags & (VM_SHARED|VM_WRITE)) == (VM_SHARED|VM_WRITE))
> which is the usual style for vm_flags tests throughout mm (except for
> the hugetlb test designed to melt away without HUGETLB).  But I may be
> in a minority on that, Linus did put an is_cow_mapping() in memory.c
> recently, so maybe you'd follow that and say is_shared_writable().

OK, done, is_shared_writable() is it.

> There's a clash and overlap between your "tracking dirty pages" patches
> and David Howell's "add notification of page becoming writable" patch.
> The merge of the two in 2.6.17-rc4-mm1 was wrong: your handle_pte_fault
> change meant it never reached David's page_mkwrite call in do_wp_page.

...

> Please take a look at that patch (David reposted it on linux-kernel
> last Friday, as 08/14 of FS-Cache try #10): I went over it with him
> many months ago, and it fills in at least one gap you're missing...
> 
> mprotect: we all forget mprotect, but mprotect(,,PROT_READ)
> followed by mprotect(,,PROT_WRITE) will give write permission to all
> those ptes you've carefully taken write permission from.  In the
> page_mkwrite patch, we found that was most easily fixed by using
> the !VM_SHARED vm_page_prot in place of the VM_SHARED one.  I
> expect you can simplify your patch a little by doing the same.

Whee, this took me a while to understand, but I think I've got it.
If I do what you propose to do, would there be any remaining users of
the MAP_SHARED part of protection_map left?

I shall try this approach tomorrow if I find some time.

> msync: I rather think that with your changes, if they're to stay,
> then all the page table walking code can be removed from msync -
> since it already skipped vmas which were not VM_SHARED, and there's
> nothing to gain from syncing the !mapping_cap_account_dirty ones.
> I think MS_ASYNC becomes a no-op, and sys_msync so small it won't
> deserve its own msync.c (madvise.c wouldn't be a bad place for it).
> Or am I missing something?

I vaguely remember some discussions on the semantics of these things.
I'll reread and examine the code.

> I'm not convinced that optimize-follow_pages is a worthwhile optimization
> (in some cases you're adding an atomic inc and dec), and it's irrelevant
> to your tracking of dirty pages, but I don't feel strongly about it.
> Except, if it stays then it needs fixing: the flags 0 case is doing
> a put_page without having done a get_page.

Not sure on the benefit either, I just did it to educate myself on the
subject (and blotched it on my way). Christoph kindly fixed the
offending condition.

I guess this patch could really do with some numbers if found that the
set_page_dirty() is needed at all.

> Though currently it seems only some powerpc #ifdef __DEBUG code is using
> follow_pages in that way: since that's not the common case, I think you'd
> best just remove the "if (flags & (FOLL_GET | FOLL_TOUCH))" condition
> from before the get_page.
> 
> (Why does follow_pages set_page_dirty at all?  I _think_ it's in case
> the get_user_pages caller forgets to set_page_dirty when releasing.
> But that's not how we usually write kernel code, to hide mistakes most
> of the time, and your mods may change the balance there.  Andrew will
> remember better whether that set_page_dirty has stronger justification.)
> 
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
