Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id E9AAE6B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 19:08:58 -0500 (EST)
Date: Thu, 8 Dec 2011 16:08:56 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-Id: <20111208160856.9e4ebebf.akpm@linux-foundation.org>
In-Reply-To: <1320512782-12209-1-git-send-email-aarcange@redhat.com>
References: <alpine.LSU.2.00.1111041856530.22199@sister.anvils>
	<1320512782-12209-1-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org, Nai Xia <nai.xia@gmail.com>

On Sat,  5 Nov 2011 18:06:22 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> This patch adds a anon_vma_moveto_tail() function to force the dst vma
> at the end of the list before mremap starts to solve the problem.

It's not obvious to me that the patch which I merged is the one which
we want to merge, given the amount of subsequent discussion.  Please
check this.

I'm thinking we merge this into 3.3-rc1, tagged for backporting into
3.2.x.  To give us additional time to think about it and test it.

Or perhaps the bug just isn't serious enough to bother fixing it in 3.2
or earlier?



From: Andrea Arcangeli <aarcange@redhat.com>
Subject: mremap: enforce rmap src/dst vma ordering in case of vma_merge() succeeding in copy_vma()

migrate was doing an rmap_walk with speculative lock-less access on
pagetables.  That could lead it to not serializing properly against mremap
PT locks.  But a second problem remains in the order of vmas in the
same_anon_vma list used by the rmap_walk.

If vma_merge succeeds in copy_vma, the src vma could be placed after the
dst vma in the same_anon_vma list.  That could still lead to migrate
missing some pte.

This patch adds an anon_vma_moveto_tail() function to force the dst vma at
the end of the list before mremap starts to solve the problem.

If the mremap is very large and there are a lots of parents or childs
sharing the anon_vma root lock, this should still scale better than taking
the anon_vma root lock around every pte copy practically for the whole
duration of mremap.

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

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Nai Xia <nai.xia@gmail.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Pawel Sikora <pluto@agmk.net
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/rmap.h |    1 
 mm/mmap.c            |   22 ++++++++++++++++++--
 mm/mremap.c          |    1 
 mm/rmap.c            |   45 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 2 deletions(-)

diff -puN include/linux/rmap.h~mremap-enforce-rmap-src-dst-vma-ordering-in-case-of-vma_merge-succeeding-in-copy_vma include/linux/rmap.h
--- a/include/linux/rmap.h~mremap-enforce-rmap-src-dst-vma-ordering-in-case-of-vma_merge-succeeding-in-copy_vma
+++ a/include/linux/rmap.h
@@ -120,6 +120,7 @@ void anon_vma_init(void);	/* create anon
 int  anon_vma_prepare(struct vm_area_struct *);
 void unlink_anon_vmas(struct vm_area_struct *);
 int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
+void anon_vma_moveto_tail(struct vm_area_struct *);
 int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
 void __anon_vma_link(struct vm_area_struct *);
 
diff -puN mm/mmap.c~mremap-enforce-rmap-src-dst-vma-ordering-in-case-of-vma_merge-succeeding-in-copy_vma mm/mmap.c
--- a/mm/mmap.c~mremap-enforce-rmap-src-dst-vma-ordering-in-case-of-vma_merge-succeeding-in-copy_vma
+++ a/mm/mmap.c
@@ -2349,13 +2349,16 @@ struct vm_area_struct *copy_vma(struct v
 	struct vm_area_struct *new_vma, *prev;
 	struct rb_node **rb_link, *rb_parent;
 	struct mempolicy *pol;
+	bool faulted_in_anon_vma = true;
 
 	/*
 	 * If anonymous vma has not yet been faulted, update new pgoff
 	 * to match new location, to increase its chance of merging.
 	 */
-	if (!vma->vm_file && !vma->anon_vma)
+	if (!vma->vm_file && !vma->anon_vma) {
 		pgoff = addr >> PAGE_SHIFT;
+		faulted_in_anon_vma = false;
+	}
 
 	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
@@ -2365,8 +2368,23 @@ struct vm_area_struct *copy_vma(struct v
 		 * Source vma may have been merged into new_vma
 		 */
 		if (vma_start >= new_vma->vm_start &&
-		    vma_start < new_vma->vm_end)
+		    vma_start < new_vma->vm_end) {
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
diff -puN mm/mremap.c~mremap-enforce-rmap-src-dst-vma-ordering-in-case-of-vma_merge-succeeding-in-copy_vma mm/mremap.c
--- a/mm/mremap.c~mremap-enforce-rmap-src-dst-vma-ordering-in-case-of-vma_merge-succeeding-in-copy_vma
+++ a/mm/mremap.c
@@ -225,6 +225,7 @@ static unsigned long move_vma(struct vm_
 		 * which will succeed since page tables still there,
 		 * and then proceed to unmap new area instead of old.
 		 */
+		anon_vma_moveto_tail(vma);
 		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len);
 		vma = new_vma;
 		old_len = new_len;
diff -puN mm/rmap.c~mremap-enforce-rmap-src-dst-vma-ordering-in-case-of-vma_merge-succeeding-in-copy_vma mm/rmap.c
--- a/mm/rmap.c~mremap-enforce-rmap-src-dst-vma-ordering-in-case-of-vma_merge-succeeding-in-copy_vma
+++ a/mm/rmap.c
@@ -272,6 +272,51 @@ int anon_vma_clone(struct vm_area_struct
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
