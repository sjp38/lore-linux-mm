Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 7F7CD6B005A
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 22:17:47 -0400 (EDT)
Received: by yenl1 with SMTP id l1so4722125yen.14
        for <linux-mm@kvack.org>; Mon, 13 Aug 2012 19:17:46 -0700 (PDT)
Date: Mon, 13 Aug 2012 19:17:01 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch] mmap: feed back correct prev vma when finding vma
In-Reply-To: <CAJd=RBDu5ebAAOuie5yNc8x7vkn7LPfDZZyGzRsCUFNRojWmwQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1208131900260.29738@eggly.anvils>
References: <CAJd=RBAjGaOXfQQ_NX+ax6=tJJ0eg7EXCFHz3rdvSR3j1K3qHA@mail.gmail.com> <alpine.LSU.2.00.1208091816240.9631@eggly.anvils> <CAJd=RBDu5ebAAOuie5yNc8x7vkn7LPfDZZyGzRsCUFNRojWmwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mikulas Patocka <mpatocka@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Benny Halevy <bhalevy@tonian.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, 10 Aug 2012, Hillf Danton wrote:
> On Fri, Aug 10, 2012 at 9:26 AM, Hugh Dickins <hughd@google.com> wrote:
> > On Thu, 9 Aug 2012, Hillf Danton wrote:
> >> After walking rb tree, if vma is determined, prev vma has to be determined
> >> based on vma; and rb_prev should be considered only if no vma determined.
> >
> > Why?  Because you think more code is better code?  I disagree.
> 
> s/more/correct/
> 
> Because feedback is incorrect if we return vma corresponding to
> the root node.

"feedback"?  "root node"?

I took another look, and a WARN_ON soon told me that you do have a point.
It stirred memories, and I found an earlier thread from 2008, responsible
for replacing the original "return vma" by a "break" in 2.6.27.

I agree that find_vma_prepare() is confusing, but your vm_prev patch is not
the right fix: let's un-confuse it this way, which barely needs comment.

Hugh

[PATCH] mm: replace find_vma_prepare by clearer find_vma_links

People get confused by find_vma_prepare(), because it doesn't care about
what it returns in its output args, when its callers won't be interested.

Clarify by passing in end-of-range address too, and returning failure if
any existing vma overlaps the new range: instead of returning an ambiguous
vma which most callers then must check.  find_vma_links() is a clearer name.

This does revert 2.6.27's dfe195fb79e88 ("mm: fix uninitialized variables
for find_vma_prepare callers"), but it looks like gcc 4.3.0 was one of
those releases too eager to shout about uninitialized variables: only
copy_vma() warns with 4.5.1 and 4.7.1, which a BUG on error silences.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Benny Halevy <bhalevy@tonian.com>
Cc: Hillf Danton <dhillf@gmail.com>
---

 mm/mmap.c |   45 +++++++++++++++++++++------------------------
 1 file changed, 21 insertions(+), 24 deletions(-)

--- 3.6-rc1/mm/mmap.c	2012-08-03 08:31:27.064842271 -0700
+++ linux/mm/mmap.c	2012-08-13 12:23:35.862895633 -0700
@@ -356,17 +356,14 @@ void validate_mm(struct mm_struct *mm)
 #define validate_mm(mm) do { } while (0)
 #endif
 
-static struct vm_area_struct *
-find_vma_prepare(struct mm_struct *mm, unsigned long addr,
-		struct vm_area_struct **pprev, struct rb_node ***rb_link,
-		struct rb_node ** rb_parent)
+static int find_vma_links(struct mm_struct *mm, unsigned long addr,
+		unsigned long end, struct vm_area_struct **pprev,
+		struct rb_node ***rb_link, struct rb_node **rb_parent)
 {
-	struct vm_area_struct * vma;
-	struct rb_node ** __rb_link, * __rb_parent, * rb_prev;
+	struct rb_node **__rb_link, *__rb_parent, *rb_prev;
 
 	__rb_link = &mm->mm_rb.rb_node;
 	rb_prev = __rb_parent = NULL;
-	vma = NULL;
 
 	while (*__rb_link) {
 		struct vm_area_struct *vma_tmp;
@@ -375,9 +372,9 @@ find_vma_prepare(struct mm_struct *mm, u
 		vma_tmp = rb_entry(__rb_parent, struct vm_area_struct, vm_rb);
 
 		if (vma_tmp->vm_end > addr) {
-			vma = vma_tmp;
-			if (vma_tmp->vm_start <= addr)
-				break;
+			/* Fail if an existing vma overlaps the area */
+			if (vma_tmp->vm_start < end)
+				return -ENOMEM;
 			__rb_link = &__rb_parent->rb_left;
 		} else {
 			rb_prev = __rb_parent;
@@ -390,7 +387,7 @@ find_vma_prepare(struct mm_struct *mm, u
 		*pprev = rb_entry(rb_prev, struct vm_area_struct, vm_rb);
 	*rb_link = __rb_link;
 	*rb_parent = __rb_parent;
-	return vma;
+	return 0;
 }
 
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -459,11 +456,12 @@ static void vma_link(struct mm_struct *m
  */
 static void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	struct vm_area_struct *__vma, *prev;
+	struct vm_area_struct *prev;
 	struct rb_node **rb_link, *rb_parent;
 
-	__vma = find_vma_prepare(mm, vma->vm_start,&prev, &rb_link, &rb_parent);
-	BUG_ON(__vma && __vma->vm_start < vma->vm_end);
+	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
+			   &prev, &rb_link, &rb_parent))
+		BUG();
 	__vma_link(mm, vma, prev, rb_link, rb_parent);
 	mm->map_count++;
 }
@@ -1229,8 +1227,7 @@ unsigned long mmap_region(struct file *f
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
-	vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
-	if (vma && vma->vm_start < addr + len) {
+	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
 		goto munmap_back;
@@ -2201,8 +2198,7 @@ static unsigned long do_brk(unsigned lon
 	 * Clear old maps.  this also does some error checking for us
 	 */
  munmap_back:
-	vma = find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
-	if (vma && vma->vm_start < addr + len) {
+	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
 		goto munmap_back;
@@ -2316,10 +2312,10 @@ void exit_mmap(struct mm_struct *mm)
  * and into the inode's i_mmap tree.  If vm_file is non-NULL
  * then i_mmap_mutex is taken here.
  */
-int insert_vm_struct(struct mm_struct * mm, struct vm_area_struct * vma)
+int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	struct vm_area_struct * __vma, * prev;
-	struct rb_node ** rb_link, * rb_parent;
+	struct vm_area_struct *prev;
+	struct rb_node **rb_link, *rb_parent;
 
 	/*
 	 * The vm_pgoff of a purely anonymous vma should be irrelevant
@@ -2337,8 +2333,8 @@ int insert_vm_struct(struct mm_struct *
 		BUG_ON(vma->anon_vma);
 		vma->vm_pgoff = vma->vm_start >> PAGE_SHIFT;
 	}
-	__vma = find_vma_prepare(mm,vma->vm_start,&prev,&rb_link,&rb_parent);
-	if (__vma && __vma->vm_start < vma->vm_end)
+	if (find_vma_links(mm, vma->vm_start, vma->vm_end,
+			   &prev, &rb_link, &rb_parent))
 		return -ENOMEM;
 	if ((vma->vm_flags & VM_ACCOUNT) &&
 	     security_vm_enough_memory_mm(mm, vma_pages(vma)))
@@ -2372,7 +2368,8 @@ struct vm_area_struct *copy_vma(struct v
 		faulted_in_anon_vma = false;
 	}
 
-	find_vma_prepare(mm, addr, &prev, &rb_link, &rb_parent);
+	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
+		BUG();
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
 			vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma));
 	if (new_vma) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
