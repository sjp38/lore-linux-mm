Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 7588A6B0062
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 20:55:13 -0500 (EST)
Date: Fri, 9 Dec 2011 02:55:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111209015506.GE15343@redhat.com>
References: <alpine.LSU.2.00.1111041856530.22199@sister.anvils>
 <1320512782-12209-1-git-send-email-aarcange@redhat.com>
 <20111208160856.9e4ebebf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111208160856.9e4ebebf.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org, Nai Xia <nai.xia@gmail.com>

On Thu, Dec 08, 2011 at 04:08:56PM -0800, Andrew Morton wrote:
> It's not obvious to me that the patch which I merged is the one which
> we want to merge, given the amount of subsequent discussion.  Please
> check this.

That's not the last version.

> I'm thinking we merge this into 3.3-rc1, tagged for backporting into
> 3.2.x.  To give us additional time to think about it and test it.
> 
> Or perhaps the bug just isn't serious enough to bother fixing it in 3.2
> or earlier?

Probably not serious enough, I'm not aware of anybody reproducing it.

Then we've also to think what to do about the i_mmap_mutex, if to
remove it from mremap it too, or if to add it to fork too.

The problem of the i_mmap_mutex is that the prio tree, being a tree,
has no way for us to ensure ordering of the range "walk" is related to
the order of "insertion". So a solution like below can't work for
prio tree (it only works for the anon_vma_chain _list_).

Either we loop twice in the rmap_walk (adding a third loop to
vmtruncate) or we add i_mmap_mutex to fork (where it looks missing and
probably the page_mapped check in __delete_from_page_cache can fire if
such a race triggers, otherwise it looks fairly innocent race but
clearly the implications aren't obvious or there would be no BUG_ON in
__delete_from_page_cache).

For file mappings the only rmap walk that has to be exact and not to
miss any pte, is the vmtruncate path. That's why only vmtruncate would
need a third loop (third because we need a first loop before the
pagecache truncation, and two more loops to catch all ptes, or a
temporary, but only temporary pte, can still be mapped and fire the
bug-on in __delete_from_page_cache).

For anon pages it's only split_huge_page and remove_migration_ptes
that shouldn't miss ptes/hugepmds.

===
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mremap: enforce rmap src/dst vma ordering in case of vma_merge succeeding in copy_vma

migrate was doing a rmap_walk with speculative lock-less access on
pagetables. That could lead it to not serialize properly against
mremap PT locks. But a second problem remains in the order of vmas in
the same_anon_vma list used by the rmap_walk.

If vma_merge would succeed in copy_vma, the src vma could be placed
after the dst vma in the same_anon_vma list. That could still lead
migrate to miss some pte.

This patch adds a anon_vma_moveto_tail() function to force the dst vma
at the end of the list before mremap starts to solve the problem.

If the mremap is very large and there are a lots of parents or childs
sharing the anon_vma root lock, this should still scale better than
taking the anon_vma root lock around every pte copy practically for
the whole duration of mremap.

Update: Hugh noticed special care is needed in the error path where
move_page_tables goes in the reverse direction, a second
anon_vma_moveto_tail() call is needed in the error path.

This program exercises the anon_vma_moveto_tail:

===

int main()
{
	static struct timeval oldstamp, newstamp;
	long diffsec;
	char *p, *p2, *p3, *p4;
	if (posix_memalign((void **)&p, 2*1024*1024, SIZE))
		perror("memalign"), exit(1);
	if (posix_memalign((void **)&p2, 2*1024*1024, SIZE))
		perror("memalign"), exit(1);
	if (posix_memalign((void **)&p3, 2*1024*1024, SIZE))
		perror("memalign"), exit(1);

	memset(p, 0xff, SIZE);
	printf("%p\n", p);
	memset(p2, 0xff, SIZE);
	memset(p3, 0x77, 4096);
	if (memcmp(p, p2, SIZE))
		printf("error\n");
	p4 = mremap(p+SIZE/2, SIZE/2, SIZE/2, MREMAP_FIXED|MREMAP_MAYMOVE, p3);
	if (p4 != p3)
		perror("mremap"), exit(1);
	p4 = mremap(p4, SIZE/2, SIZE/2, MREMAP_FIXED|MREMAP_MAYMOVE, p+SIZE/2);
	if (p4 != p+SIZE/2)
		perror("mremap"), exit(1);
	if (memcmp(p, p2, SIZE))
		printf("error\n");
	printf("ok\n");

	return 0;
}
===

$ perf probe -a anon_vma_moveto_tail
Add new event:
  probe:anon_vma_moveto_tail (on anon_vma_moveto_tail)

You can now use it on all perf tools, such as:

        perf record -e probe:anon_vma_moveto_tail -aR sleep 1

$ perf record -e probe:anon_vma_moveto_tail -aR ./anon_vma_moveto_tail
0x7f2ca2800000
ok
[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.043 MB perf.data (~1860 samples) ]
$ perf report --stdio
   100.00%  anon_vma_moveto  [kernel.kallsyms]  [k] anon_vma_moveto_tail

Reported-by: Nai Xia <nai.xia@gmail.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/rmap.h |    1 +
 mm/mmap.c            |   24 +++++++++++++++++++++---
 mm/mremap.c          |    9 +++++++++
 mm/rmap.c            |   45 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 76 insertions(+), 3 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 2148b12..1afb995 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -120,6 +120,7 @@ void anon_vma_init(void);	/* create anon_vma_cachep */
 int  anon_vma_prepare(struct vm_area_struct *);
 void unlink_anon_vmas(struct vm_area_struct *);
 int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
+void anon_vma_moveto_tail(struct vm_area_struct *);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index eae90af..adea3b8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2322,13 +2322,16 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	struct vm_area_struct *new_vma, *prev;
 	struct rb_node **rb_link, *rb_parent;
 	struct mempolicy *pol;
+	bool faulted_in_anon_vma = true;
 
 	/*
 	 * If anonymous vma has not yet been faulted, update new pgoff
 	 * to match new location, to increase its chance of merging.
 	 */
-	if (!vma->vm_file && !vma->anon_vma)
+	if (unlikely(!vma->vm_file && !vma->anon_vma)) {
 		pgoff = addr >> PAGE_SHIFT;
+		faulted_in_anon_vma = false;
+	}
 
 	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
@@ -2337,9 +2340,24 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		/*
 		 * Source vma may have been merged into new_vma
 		 */
-		if (vma_start >= new_vma->vm_start &&
-		    vma_start < new_vma->vm_end)
+		if (unlikely(vma_start >= new_vma->vm_start &&
+			     vma_start < new_vma->vm_end)) {
+			/*
+			 * The only way we can get a vma_merge with
+			 * self during an mremap is if the vma hasn't
+			 * been faulted in yet and we were allowed to
+			 * reset the dst vma->vm_pgoff to the
+			 * destination address of the mremap to allow
+			 * the merge to happen. mremap must change the
+			 * vm_pgoff linearity between src and dst vmas
+			 * (in turn preventing a vma_merge) to be
+			 * safe. It is only safe to keep the vm_pgoff
+			 * linear if there are no pages mapped yet.
+			 */
+			VM_BUG_ON(faulted_in_anon_vma);
 			*vmap = new_vma;
+		} else
+			anon_vma_moveto_tail(new_vma);
 	} else {
 		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 		if (new_vma) {
diff --git a/mm/mremap.c b/mm/mremap.c
index d6959cb..87bb839 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -221,6 +221,15 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len);
 	if (moved_len < old_len) {
 		/*
+		 * Before moving the page tables from the new vma to
+		 * the old vma, we need to be sure the old vma is
+		 * queued after new vma in the same_anon_vma list to
+		 * prevent SMP races with rmap_walk (that could lead
+		 * rmap_walk to miss some page table).
+		 */
+		anon_vma_moveto_tail(vma);
+
+		/*
 		 * On error, move entries back from new area to old,
 		 * which will succeed since page tables still there,
 		 * and then proceed to unmap new area instead of old.
diff --git a/mm/rmap.c b/mm/rmap.c
index a4fd368..a2e5ce1 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -272,6 +272,51 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 }
 
 /*
+ * Some rmap walk that needs to find all ptes/hugepmds without false
+ * negatives (like migrate and split_huge_page) running concurrent
+ * with operations that copy or move pagetables (like mremap() and
+ * fork()) to be safe. They depend on the anon_vma "same_anon_vma"
+ * list to be in a certain order: the dst_vma must be placed after the
+ * src_vma in the list. This is always guaranteed by fork() but
+ * mremap() needs to call this function to enforce it in case the
+ * dst_vma isn't newly allocated and chained with the anon_vma_clone()
+ * function but just an extension of a pre-existing vma through
+ * vma_merge.
+ *
+ * NOTE: the same_anon_vma list can still be changed by other
+ * processes while mremap runs because mremap doesn't hold the
+ * anon_vma mutex to prevent modifications to the list while it
+ * runs. All we need to enforce is that the relative order of this
+ * process vmas isn't changing (we don't care about other vmas
+ * order). Each vma corresponds to an anon_vma_chain structure so
+ * there's no risk that other processes calling anon_vma_moveto_tail()
+ * and changing the same_anon_vma list under mremap() will screw with
+ * the relative order of this process vmas in the list, because we
+ * they can't alter the order of any vma that belongs to this
+ * process. And there can't be another anon_vma_moveto_tail() running
+ * concurrently with mremap() coming from this process because we hold
+ * the mmap_sem for the whole mremap(). fork() ordering dependency
+ * also shouldn't be affected because fork() only cares that the
+ * parent vmas are placed in the list before the child vmas and
+ * anon_vma_moveto_tail() won't reorder vmas from either the fork()
+ * parent or child.
+ */
+void anon_vma_moveto_tail(struct vm_area_struct *dst)
+{
+	struct anon_vma_chain *pavc;
+	struct anon_vma *root = NULL;
+
+	list_for_each_entry_reverse(pavc, &dst->anon_vma_chain, same_vma) {
+		struct anon_vma *anon_vma = pavc->anon_vma;
+		VM_BUG_ON(pavc->vma != dst);
+		root = lock_anon_vma_root(root, anon_vma);
+		list_del(&pavc->same_anon_vma);
+		list_add_tail(&pavc->same_anon_vma, &anon_vma->head);
+	}
+	unlock_anon_vma_root(root);
+}
+
+/*
  * Attach vma to its own anon_vma, as well as to the anon_vmas that
  * the corresponding VMA in the parent process is attached to.
  * Returns 0 on success, non-zero on failure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
