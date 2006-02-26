Date: Sun, 26 Feb 2006 15:58:30 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.64.0602252120150.29251@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0602261535350.13368@goblin.wat.veritas.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252120150.29251@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Feb 2006, Christoph Lameter wrote:
> On Sun, 26 Feb 2006, Hugh Dickins wrote:
> 
> > But I think you can avoid it.  It looks to me like the mmap_sem of
> > an mm containing the pages is held across migrate_pages?  That should
> 
> Currently yes, but the hotplug folks may need to use the page 
> migration functions without holding mmap_sem. So we would like to see the 
> page migration code in vmscan.c not depend on mmap_sem.

I'm afraid you'll have to think up some other way to stabilize the
anon_vma in that future extension then.  For now mmap_sem covers it.
Wish I could dream up a BUG_ON to warn against those future changes.

> > be enough to guarantee that the anon_vmas involved cannot be freed
> 
> The page is locked. Isnt that enough to guarantee that the page cannot be 
> removed from the anon vma?

Not at all.  We don't have to take page lock when munmapping or exiting
mm (though when it's a swap page, we do trylock).  Nor would wish to.

> > behind your back (whereas page_referenced and try_to_unmap are called
> > without any mmap_sem held).  So you'd want to add a new flag to
> > page_lock_anon_vma, to condition whether page_mapped is checked.
> 
> Is that really necessary? Can we check for page mapped or page locked?

Yes.  No.

> > Though I'm not yet certain that that won't have races of its own:
> > please examine it sceptically.  And is it actually guaranteed that
> > a relevant mmap_sem is held here?  Why on earth does vmscan.c contain
> > EXPORT_SYMBOLs of migrate_page_remove_references, migrate_page_copy,
> > migrate_page?
> 
> This is so that filesystems can generate their own migration functions. 
> Filesystem may mantain structures with additional references to the pages 
> being moved and we cannot move pages with buffers without filesystem 
> cooperation.

Hmm.  I'd be happier about them if there were some example in the tree
of how they should be used from a filesystem: kill the EXPORTs until
then?  probably too late now, to make that change in 2.6.16.

So long as the filesystem only tries to migrate its own pagecache
pages, it should be okay (the locking for file pages is not problematic
as it is for anonymous - probably because we do insist on locking pages
before truncating or clearing the cache).  But if it were to try to
migrate the anonymous pages COWed into a private file-based vma,
without any mmap_sem, then it would be unsafe.  Unlikely mistake.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
