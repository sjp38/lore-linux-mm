From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only pte and _count=2?
Date: Fri, 20 Jun 2008 19:23:11 +1000
References: <20080618164158.GC10062@sgi.com> <Pine.LNX.4.64.0806182209320.16252@blonde.site> <20080619163258.GD10062@sgi.com>
In-Reply-To: <20080619163258.GD10062@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806201923.11914.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 20 June 2008 02:32, Robin Holt wrote:
> On Wed, Jun 18, 2008 at 10:46:09PM +0100, Hugh Dickins wrote:
> > On Wed, 18 Jun 2008, Robin Holt wrote:
> > > On Wed, Jun 18, 2008 at 08:01:48PM +0100, Hugh Dickins wrote:
> >
> > --- 2.6.26-rc6/mm/memory.c	2008-05-26 20:00:39.000000000 +0100
> > +++ linux/mm/memory.c	2008-06-18 22:06:46.000000000 +0100
> > @@ -1152,9 +1152,15 @@ int get_user_pages(struct task_struct *t
> >  				 * do_wp_page has broken COW when necessary,
> >  				 * even if maybe_mkwrite decided not to set
> >  				 * pte_write. We can thus safely do subsequent
> > -				 * page lookups as if they were reads.
> > +				 * page lookups as if they were reads. But only
> > +				 * do so when looping for pte_write is futile:
> > +				 * in some cases userspace may also be wanting
> > +				 * to write to the gotten user page, which a
> > +				 * read fault here might prevent (a readonly
> > +				 * page would get reCOWed by userspace write).
> >  				 */
> > -				if (ret & VM_FAULT_WRITE)
> > +				if ((ret & VM_FAULT_WRITE) &&
> > +				    !(vma->vm_flags & VM_WRITE))
> >  					foll_flags &= ~FOLL_WRITE;
> >
> >  				cond_resched();
>
> I applied the equivalent of this to the sles10 kernel and still saw the
> problem.

If you were able to test my hypothesis, that might help while Hugh
comes up with a more efficient solution (this adds 3 atomic ops in
the do_wp_page path for anonymous)...

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c  2008-06-20 19:16:20.000000000 +1000
+++ linux-2.6/mm/memory.c       2008-06-20 19:19:08.000000000 +1000
@@ -1677,10 +1677,15 @@
         * not dirty accountable.
         */
        if (PageAnon(old_page)) {
-               if (!TestSetPageLocked(old_page)) {
-                       reuse = can_share_swap_page(old_page);
-                       unlock_page(old_page);
-               }
+               page_cache_get(old_page);
+               pte_unmap_unlock(page_table, ptl);
+               lock_page(old_page);
+               reuse = can_share_swap_page(old_page);
+               unlock_page(old_page);
+               page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+               page_cache_release(old_page);
+               if (!pte_same(*page_table, orig_pte))
+                       goto unlock;
        } else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
                                        (VM_WRITE|VM_SHARED))) {
                /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
