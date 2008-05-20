Date: Tue, 20 May 2008 18:59:35 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] nommu: Push kobjsize() slab-specific logic down to ksize().
Message-ID: <20080520095935.GB18633@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>, David Howells <dhowells@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently SLUB and SLOB both blow up in different ways on shnommu:

SLOB:

Freeing unused kernel memory: 620k freed
------------[ cut here ]------------
kernel BUG at mm/nommu.c:119!
Kernel BUG: 003e [#1]
Modules linked in:

Pid : 1, Comm:                 init
PC is at kobjsize+0x5c/0x8c
PC  : 0c04000c SP  : 0c20dd08 SR  : 40000001                   Not tainted
R0  : 00000000 R1  : 0000000a R2  : 001b8334 R3  : 0c180000
R4  : 00000840 R5  : 0c3a507c R6  : 000110e2 R7  : 00000020
R8  : 0c1e5334 R9  : 0c3a5210 R10 : 0c3a5210 R11 : 0c180000
R12 : 0c3a5250 R13 : 00000000 R14 : 0c20dd08
MACH: 00000221 MACL: 001b8334 GBR : 00000000 PR  : 0c03fff4

Call trace:
[<0c0409ca>] do_mmap_pgoff+0x5ea/0x7f0
[<0c07046a>] load_flat_file+0x326/0x77c
[<0c07090a>] load_flat_binary+0x4a/0x2c8
...


SLUB:

Freeing unused kernel memory: 624k freed
Unable to allocate RAM for process text/data, errno 12
Failed to execute /init
Unable to allocate RAM for process text/data, errno 12
Unable to allocate RAM for process text/data, errno 12
Kernel panic - not syncing: No init found.  Try passing init= option to kernel.
...

In both cases this is due to kobjsize() failures. By checking PageSlab()
before calling in to ksize(), SLAB manages to work ok, as it aggressively
sets these bits across compounds.

In situations where we are setting up private mappings or shared
anonymous mappings (via do_mmap_private()) and the vm_file mmap() fop
hands back an -ENOSYS, a new allocation is made and the file contents
copied over. SLOB's page->index at the time of hitting the above BUG_ON()
is the value of the non-page-aligned address returned by kmalloc() +
the read size. page->index itself is otherwise sane when the object to be
copied is larger than a page in size and aligned.

Both SLOB and SLUB presently have methods to determine whether an object
passed in to their respective ksize() implementations are their own slab
pages, or part of a compound page (heavily used by nommu for anonymous
mappings), leaving only SLAB as the odd one out. The rationale here seems
to be that SLAB's ksize() will trigger a BUG_ON() if !PageSlab(), and so
the page->index shift is defaulted to instead for non-slab pages.

Moving the existing logic in to SLAB's ksize() and simply wrapping in to
ksize() directly seems to do the right thing in all cases, and allows me
to boot with any of the slab allocators enabled, rather than simply SLAB
by itself.

I've done the same !PageSlab() test in SLAB as SLUB does in its ksize(),
which also seems to produce the correct results. Hopefully someone more
familiar with the history of kobjsize()/ksize() interaction can scream if
this is the wrong thing to do. :-)

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

---

 mm/nommu.c |    8 +-------
 mm/slab.c  |    6 ++++++
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index ef8c62c..3e11814 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -112,13 +112,7 @@ unsigned int kobjsize(const void *objp)
 	if (!objp || (unsigned long)objp >= memory_end || !((page = virt_to_page(objp))))
 		return 0;
 
-	if (PageSlab(page))
-		return ksize(objp);
-
-	BUG_ON(page->index < 0);
-	BUG_ON(page->index >= MAX_ORDER);
-
-	return (PAGE_SIZE << page->index);
+	return ksize(objp);
 }
 
 /*
diff --git a/mm/slab.c b/mm/slab.c
index 06236e4..7a012bb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4472,10 +4472,16 @@ const struct seq_operations slabstats_op = {
  */
 size_t ksize(const void *objp)
 {
+	struct page *page;
+
 	BUG_ON(!objp);
 	if (unlikely(objp == ZERO_SIZE_PTR))
 		return 0;
 
+	page = virt_to_head_page(objp);
+	if (unlikely(!PageSlab(page)))
+		return PAGE_SIZE << compound_order(page);
+
 	return obj_size(virt_to_cache(objp));
 }
 EXPORT_SYMBOL(ksize);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
