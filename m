Date: Sat, 25 Feb 2006 21:26:31 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0602252120150.29251@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 26 Feb 2006, Hugh Dickins wrote:

> I still believe the page_mapped test is essential for the correctness
> of the original page_referenced_anon and try_to_unmap_anon cases (but
> please don't ask me to reproduce the case it's guarding against!).

Well if it is essential then we should have some comment there explaining 
the purpose of that check.

> But disastrous for the remove_from_swap case you've added -
> how does that work at all with the page_mapped test in?

It doesnt right now. Thats what I am trying to fix. It is not essential
for page migration that the swap ptes be removed. If they are left then we 
need additional page faults to convert the swap ptes to regular one. So it 
currently slows things down and unnecessarily consume swap entries.

> But I think you can avoid it.  It looks to me like the mmap_sem of
> an mm containing the pages is held across migrate_pages?  That should

Currently yes, but the hotplug folks may need to use the page 
migration functions without holding mmap_sem. So we would like to see the 
page migration code in vmscan.c not depend on mmap_sem.

> be enough to guarantee that the anon_vmas involved cannot be freed

The page is locked. Isnt that enough to guarantee that the page cannot be 
removed from the anon vma?

> behind your back (whereas page_referenced and try_to_unmap are called
> without any mmap_sem held).  So you'd want to add a new flag to
> page_lock_anon_vma, to condition whether page_mapped is checked.

Is that really necessary? Can we check for page mapped or page locked?

> Though I'm not yet certain that that won't have races of its own:
> please examine it sceptically.  And is it actually guaranteed that
> a relevant mmap_sem is held here?  Why on earth does vmscan.c contain
> EXPORT_SYMBOLs of migrate_page_remove_references, migrate_page_copy,
> migrate_page?

This is so that filesystems can generate their own migration functions. 
Filesystem may mantain structures with additional references to the pages 
being moved and we cannot move pages with buffers without filesystem 
cooperation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
