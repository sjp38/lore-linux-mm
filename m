Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA31313
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 03:03:37 -0400
Received: from mirkwood.dummy.home (root@anx1p6.phys.uu.nl [131.211.33.95])
	by max.phys.uu.nl (8.8.7/8.8.7/hjm) with ESMTP id JAA23949
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 09:03:30 +0200 (MET DST)
Received: from localhost (riel@localhost) by mirkwood.dummy.home (8.9.0/8.8.3) with SMTP id HAA02911 for <linux-mm@kvack.org>; Fri, 26 Jun 1998 07:34:11 +0200
Date: Fri, 26 Jun 1998 07:34:10 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Linux wppage patch (fwd)
Message-ID: <Pine.LNX.3.96.980626073357.2529L-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


---------- Forwarded message ----------
Date: Thu, 25 Jun 1998 21:10:00 -0700 (PDT)
From: Jason Crawford <jasonc@cacr.caltech.edu>
To: h.h.vanriel@phys.uu.nl
Subject: Linux wppage patch

Greetings. I am currently working at the Center for Advanced Computing
Research at Caltech, doing research related to the Beowulf parallel Linux
project. I am writing a distributed shared memory system for Beowulf
parallel workstations.

As part of my project, I need to make some minor changes to the Linux
fault handlers. Basically, I need to do two things:

1. Add a hook for custom wppage routines. In the VM operations struct,
there is an entry for a custom nopage routine and a custom wppage
routine. The do_no_page function in memory.c checks to see if the VMA has
a nopage routine, and if so, it calls that instead of running the default
code. The do_wp_page function, however, does not check for a custom
wppage routine. In fact, I searched through the entire Linux source tree,
and the wppage field of the VM operations struct is never accessed! I
guess since nothing uses it, nobody noticed that it was missing. I need
it for my project, however.

2. Make a slight change to the way the custom nopage routine is called.
The third argument to nopage is declared as "write_access" in the
definition of the VM operations struct in mm.h. But when it's called, it
is actually "no_share", computed as:

	(vma->vm_flags & VM_SHARED) ? 0 : write_access

My code, however, needs to know whether the access was a write even
though it is shared memory, so I would like to change this argument to
just "write_access". Since the VMA is passed in to the routine anyway,
the VM flags will be available, and any routine which wants to calculate
"no_share" can do so. Again, I searched the Linux source tree, and only
the generic filemap_nopage routine uses the no_share argument. It can
easily be changed to accept "write_access" instead of "no_share" and
calculate "no_share" before it does any work.

I was also thinking of adding an "rppage" hook to the VM operations
struct, analagous to the nopage and wppage routines. This would be a
routine that is called when a present but read-protected page is faulted
on. (In my code, this is a signal that a page is invalid and needs to be
updated.) Currently, all that happens is the process receives a seg fault
(this happens directly from the architecture-specific fault handler in
some cases). I was talking to Don Becker from CESDIS about these changes,
though, and he said, "Linus will think the rppage hook is silly -- he
would say, 'If you can't read it or write to it, there's no reason to
have a PTE for it.'" So I think I will just make the 'rppage' handler of
my system a special case of the nopage handler (the code is very similar
anyway). Don thought the rest of the changes were reasonable, though. He
said that he was pretty sure the wppage hook *was* implemented in an
earlier kernel version, and suggested I look in version 2.0.0, but it
wasn't there either.

Anyway, I've come up with a preliminary patch. I haven't tested it very
much yet, but I thought I'd let you take a look at it, just so you can
see what I'm up to. The patch is against kernel version 2.1.103. (I'm
sending this to you because you have the Linux MM homepage; if there is
someone else who should see this, feel free to forward this email.)

                                  -Jason Crawford
                                   jasonc@cacr.caltech.edu
                                   Center for Advanced Computing Research
                                   California Institute of Technology


diff -ruN linux-2.1.103.orig/mm/filemap.c linux/mm/filemap.c
--- linux-2.1.103.orig/mm/filemap.c	Thu Mar 26 12:56:36 1998
+++ linux/mm/filemap.c	Thu Jun 25 16:14:15 1998
@@ -783,8 +783,11 @@
  *
  * WSH 06/04/97: fixed a memory leak and moved the allocation of new_page
  * ahead of the wait if we're sure to need it.
+ *
+ * JRC 25 Jun 1998: changed "no_share" argument to "write_access", to reflect
+ * change in mm/memory.c.
  */
-static unsigned long filemap_nopage(struct vm_area_struct * area, unsigned long address, int no_share)
+static unsigned long filemap_nopage(struct vm_area_struct * area, unsigned long address, int write_access)
 {
 	struct file * file = area->vm_file;
 	struct dentry * dentry = file->f_dentry;
@@ -792,6 +795,7 @@
 	unsigned long offset;
 	struct page * page, **hash;
 	unsigned long old_page, new_page;
+	int no_share = (area->vm_flags & VM_SHARED) ? 0 : write_access;
 
 	new_page = 0;
 	offset = (address & PAGE_MASK) - area->vm_start + area->vm_offset;
diff -ruN linux-2.1.103.orig/mm/memory.c linux/mm/memory.c
--- linux-2.1.103.orig/mm/memory.c	Mon Feb 23 15:24:32 1998
+++ linux/mm/memory.c	Thu Jun 25 16:03:54 1998
@@ -615,10 +615,17 @@
 	unsigned long address, int write_access, pte_t *page_table)
 {
 	pte_t pte;
-	unsigned long old_page, new_page;
+	unsigned long old_page, new_page = 0;
 	struct page * page_map;
 	
 	pte = *page_table;
+	old_page = pte_page(pte);
+	if (MAP_NR(old_page) >= max_mapnr)
+		goto bad_wp_page;
+
+	if (vma->vm_ops && vma->vm_ops->wppage)
+		goto special_wp_page;
+
 	new_page = __get_free_page(GFP_KERNEL);
 	/* Did someone else copy this page for us while we slept? */
 	if (pte_val(*page_table) != pte_val(pte))
@@ -627,9 +634,6 @@
 		goto end_wp_page;
 	if (pte_write(pte))
 		goto end_wp_page;
-	old_page = pte_page(pte);
-	if (MAP_NR(old_page) >= max_mapnr)
-		goto bad_wp_page;
 	tsk->min_flt++;
 	page_map = mem_map + MAP_NR(old_page);
 	
@@ -664,6 +668,27 @@
 	if (new_page)
 		free_page(new_page);
 	return;
+
+special_wp_page:
+	new_page = vma->vm_ops->wppage(vma, address, old_page);
+	if (!new_page)
+		goto bad_wp_page;
+
+	tsk->min_flt++;
+	if (new_page == old_page) {
+		flush_page_to_ram(old_page);
+		flush_cache_page(vma, address);
+		set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
+		flush_tlb_page(vma, address);
+		return;
+	}
+	flush_page_to_ram(old_page);
+	flush_page_to_ram(new_page);
+	flush_cache_page(vma, address);
+	set_pte(page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
+	flush_tlb_page(vma, address);
+	return;
+
 bad_wp_page:
 	printk("do_wp_page: bogus page at address %08lx (%08lx)\n",address,old_page);
 	send_sig(SIGKILL, tsk, 1);
@@ -805,12 +830,15 @@
 	if (!vma->vm_ops || !vma->vm_ops->nopage)
 		goto anonymous_page;
 	/*
-	 * The third argument is "no_share", which tells the low-level code
-	 * to copy, not share the page even if sharing is possible.  It's
-	 * essentially an early COW detection 
+	 * The third argument here *used* to be "no_share", which was equal to
+	 * write_access unless the VM_SHARED flag was set, in which case it
+	 * was 0. It was basically another early COW. I changed it to just
+	 * "write_access", because some code actually wants that instead of
+	 * "no_share", and any code which wants "no_share" can just compute it
+	 * by itself. (The only code that actually uses it is filemap_nopage,
+	 * anyway.)	-JRC
 	 */
-	page = vma->vm_ops->nopage(vma, address, 
-		(vma->vm_flags & VM_SHARED)?0:write_access);
+	page = vma->vm_ops->nopage(vma, address, write_access);
 	if (!page)
 		goto sigbus;
 	++tsk->maj_flt;
