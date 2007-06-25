Date: Mon, 25 Jun 2007 22:05:09 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 2.6.22-rc5-yesterdaygit with VM debug: BUG in mm/rmap.c:66:
 anon_vma_link ?
In-Reply-To: <467F6882.9000800@vmware.com>
Message-ID: <Pine.LNX.4.64.0706252129430.22492@blonde.wat.veritas.com>
References: <467F6882.9000800@vmware.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Petr Vandrovec <petr@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jun 2007, Petr Vandrovec wrote:
> Hello,
>   to catch some memory corruption bug in our code I've modified malloc to do
> mmap + mprotect - which has unfortunate effect that it creates thousands and
> thousands of VMAs.  Everything works (though rather slowly on kernel with
> CONFIG_VM_DEBUG) until application does fork() - kernel crashes on fork()
> because copy_process()'s anon_vma_link complains that it could not find anon
> vma after walking through 100000 elements of anon list - which seems strange,
> as I did not touch system wide limit (which is 65536 vmas), and mprotect()s
> started failing after creating 65536 vmas, as expected.
> 
> Full output of test program and full kernel dmesg are at
> http://buk.vc.cvut.cz/linux/rmap.

Thanks for finding that, Petr.  Patch below just solves the problem
by removing validate_anon_vma; but in the past both Nick and Andrea
have been less eager to delete old debug code than I am, so it would
be rude to put this patch in without an Ack from at least one of them
- they may prefer to tinker with the limit instead, but removing the
whole function is my preference.

You were puzzled by the numbers.  What happens is that the parent
builds up to 65536 vmas, and from that point on is not allowed to
split vmas any more, so the mprotects fail as you expected and
observed.  But further mmaps succeed, up to your own 131072 limit,
because each added area can simply extend the last vma.

All the vmas of interest here (i.e. not the executable, libs, stack
etc.), for better or worse, share the same anon_vma: so that if
mprotect were later used to undo the difference between neighbouring
vmas, they could be merged together - assigning different anon_vmas
would obstruct that merge (but yes, we've a guessed tradeoff there).

So the parent has around 65500 vmas all linked to the same anon_vma;
and in the course of its fork, links the child's dup vmas one by one
to that same anon_vma, until it hits the validate_anon_vma's 100000
BUG_ON.  It's very much the nature of the anon_vma, to be shared
between parent and child: anon pages may be shared between both.

If we raised the 100000 limit to 2*sysctl_max_map_count, then your
program would be safe (setting aside changes to that max_map_count),
but another program in which the child also forked would then BUG.



[PATCH] kill validate_anon_vma to avoid mapcount BUG

validate_anon_vma gave a useful check on the integrity of the anon_vma list
when Andrea was developing obj rmap; but it was not enabled in SLES9 itself,
nor in mainline, until Nick changed commented-out RMAP_DEBUG to configurable
CONFIG_DEBUG_VM in 2.6.17.  Now Petr Vandrovec reports that its
BUG_ON(mapcount > 100000) can easily crash a CONFIG_DEBUG_VM=y system.

That limit was just an arbitrary number to protect against an infinite loop.
We could raise it to something enormous (depending on sizeof struct vma and
size of memory?); but I rather think validate_anon_vma has outlived its
usefulness, and is better just removed - which gives a magnificent
performance boost to anything like Petr's test program ;)

Of course, a very long anon_vma list is bad news for preemption latency,
and I believe there has been one recent report of such: let's not forget
that, but validate_anon_vma only makes it worse not better.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/rmap.c |   24 +-----------------------
 1 file changed, 1 insertion(+), 23 deletions(-)

--- 2.6.22-rc6/mm/rmap.c	2007-05-19 07:36:34.000000000 +0100
+++ linux/mm/rmap.c	2007-06-25 21:01:01.000000000 +0100
@@ -53,24 +53,6 @@
 
 struct kmem_cache *anon_vma_cachep;
 
-static inline void validate_anon_vma(struct vm_area_struct *find_vma)
-{
-#ifdef CONFIG_DEBUG_VM
-	struct anon_vma *anon_vma = find_vma->anon_vma;
-	struct vm_area_struct *vma;
-	unsigned int mapcount = 0;
-	int found = 0;
-
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		mapcount++;
-		BUG_ON(mapcount > 100000);
-		if (vma == find_vma)
-			found = 1;
-	}
-	BUG_ON(!found);
-#endif
-}
-
 /* This must be called under the mmap_sem. */
 int anon_vma_prepare(struct vm_area_struct *vma)
 {
@@ -121,10 +103,8 @@ void __anon_vma_link(struct vm_area_stru
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 
-	if (anon_vma) {
+	if (anon_vma)
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
-		validate_anon_vma(vma);
-	}
 }
 
 void anon_vma_link(struct vm_area_struct *vma)
@@ -134,7 +114,6 @@ void anon_vma_link(struct vm_area_struct
 	if (anon_vma) {
 		spin_lock(&anon_vma->lock);
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
-		validate_anon_vma(vma);
 		spin_unlock(&anon_vma->lock);
 	}
 }
@@ -148,7 +127,6 @@ void anon_vma_unlink(struct vm_area_stru
 		return;
 
 	spin_lock(&anon_vma->lock);
-	validate_anon_vma(vma);
 	list_del(&vma->anon_vma_node);
 
 	/* We must garbage collect the anon_vma if it's empty */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
