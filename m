Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE9C6B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 16:05:23 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id md12so3477410pbc.17
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:05:23 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id ew3si11058583pbb.184.2014.06.20.13.05.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 13:05:22 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so3495915pab.3
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 13:05:21 -0700 (PDT)
Date: Fri, 20 Jun 2014 13:03:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at /src/linux-dev/mm/mempolicy.c:1738! on v3.16-rc1
In-Reply-To: <20140620194639.GA30729@nhori.bos.redhat.com>
Message-ID: <alpine.LSU.2.11.1406201257370.8123@eggly.anvils>
References: <20140619215641.GA9792@nhori.bos.redhat.com> <alpine.DEB.2.11.1406200923220.10271@gentwo.org> <20140620194639.GA30729@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@gentwo.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 20 Jun 2014, Naoya Horiguchi wrote:
> On Fri, Jun 20, 2014 at 09:24:36AM -0500, Christoph Lameter wrote:
> > On Thu, 19 Jun 2014, Naoya Horiguchi wrote:
> >
> > > I'm suspecting that mbind_range() do something wrong around vma handling,
> > > but I don't have enough luck yet. Anyone has an idea?
> >
> > Well memory policy data corrupted. This looks like you were trying to do
> > page migration via mbind()?
> 
> Right.
> 
> > Could we get some more details as to what is
> > going on here? Specifically the parameters passed to mbind would be
> > interesting.
> 
> My view about the kernel behavior was in another email a few hours ago.
> And as for what userspace did, I attach the reproducer below. It's simply
> doing mbind(mode=MPOL_BIND, flags=MPOL_MF_MOVE_ALL) on random address/length/node.

Thanks for the additional information earlier.  ext4, so no shmem
shared mempolicy involved: that cuts down the bugspace considerably.

I agree from what you said that it looked like corrupt vm_area_struct
and hence corrupt policy.

Here's an obvious patch to try, entirely untested - thanks for the
reproducer, but I'd rather leave the testing to you.  Sounds like
you have a useful fuzzer there: good catch.


[PATCH] mm: fix crashes from mbind() merging vmas

v2.6.34's 9d8cebd4bcd7 ("mm: fix mbind vma merge problem") introduced
vma merging to mbind(), but it should have also changed the convention
of passing start vma from queue_pages_range() (formerly check_range())
to new_vma_page(): vma merging may have already freed that structure,
resulting in BUG at mm/mempolicy.c:1738 and probably worse crashes.

Fixes: 9d8cebd4bcd7 ("mm: fix mbind vma merge problem")
Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org # 2.6.34+
---

 mm/mempolicy.c |   46 ++++++++++++++++++++--------------------------
 1 file changed, 20 insertions(+), 26 deletions(-)

--- 3.16-rc1/mm/mempolicy.c	2014-06-16 00:28:55.116076530 -0700
+++ linux/mm/mempolicy.c	2014-06-20 12:40:00.000204558 -0700
@@ -656,19 +656,18 @@ static unsigned long change_prot_numa(st
  * @nodes and @flags,) it's isolated and queued to the pagelist which is
  * passed via @private.)
  */
-static struct vm_area_struct *
+static int
 queue_pages_range(struct mm_struct *mm, unsigned long start, unsigned long end,
 		const nodemask_t *nodes, unsigned long flags, void *private)
 {
-	int err;
-	struct vm_area_struct *first, *vma, *prev;
-
+	int err = 0;
+	struct vm_area_struct *vma, *prev;
 
-	first = find_vma(mm, start);
-	if (!first)
-		return ERR_PTR(-EFAULT);
+	vma = find_vma(mm, start);
+	if (!vma)
+		return -EFAULT;
 	prev = NULL;
-	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
+	for (; vma && vma->vm_start < end; vma = vma->vm_next) {
 		unsigned long endvma = vma->vm_end;
 
 		if (endvma > end)
@@ -678,9 +677,9 @@ queue_pages_range(struct mm_struct *mm,
 
 		if (!(flags & MPOL_MF_DISCONTIG_OK)) {
 			if (!vma->vm_next && vma->vm_end < end)
-				return ERR_PTR(-EFAULT);
+				return -EFAULT;
 			if (prev && prev->vm_end < vma->vm_start)
-				return ERR_PTR(-EFAULT);
+				return -EFAULT;
 		}
 
 		if (flags & MPOL_MF_LAZY) {
@@ -694,15 +693,13 @@ queue_pages_range(struct mm_struct *mm,
 
 			err = queue_pages_pgd_range(vma, start, endvma, nodes,
 						flags, private);
-			if (err) {
-				first = ERR_PTR(err);
+			if (err)
 				break;
-			}
 		}
 next:
 		prev = vma;
 	}
-	return first;
+	return err;
 }
 
 /*
@@ -1156,16 +1153,17 @@ out:
 
 /*
  * Allocate a new page for page migration based on vma policy.
- * Start assuming that page is mapped by vma pointed to by @private.
+ * Start by assuming the page is mapped by the same vma as contains @start.
  * Search forward from there, if not.  N.B., this assumes that the
  * list of pages handed to migrate_pages()--which is how we get here--
  * is in virtual address order.
  */
-static struct page *new_vma_page(struct page *page, unsigned long private, int **x)
+static struct page *new_page(struct page *page, unsigned long start, int **x)
 {
-	struct vm_area_struct *vma = (struct vm_area_struct *)private;
+	struct vm_area_struct *vma;
 	unsigned long uninitialized_var(address);
 
+	vma = find_vma(current->mm, start);
 	while (vma) {
 		address = page_address_in_vma(page, vma);
 		if (address != -EFAULT)
@@ -1195,7 +1193,7 @@ int do_migrate_pages(struct mm_struct *m
 	return -ENOSYS;
 }
 
-static struct page *new_vma_page(struct page *page, unsigned long private, int **x)
+static struct page *new_page(struct page *page, unsigned long start, int **x)
 {
 	return NULL;
 }
@@ -1205,7 +1203,6 @@ static long do_mbind(unsigned long start
 		     unsigned short mode, unsigned short mode_flags,
 		     nodemask_t *nmask, unsigned long flags)
 {
-	struct vm_area_struct *vma;
 	struct mm_struct *mm = current->mm;
 	struct mempolicy *new;
 	unsigned long end;
@@ -1271,11 +1268,9 @@ static long do_mbind(unsigned long start
 	if (err)
 		goto mpol_out;
 
-	vma = queue_pages_range(mm, start, end, nmask,
+	err = queue_pages_range(mm, start, end, nmask,
 			  flags | MPOL_MF_INVERT, &pagelist);
-
-	err = PTR_ERR(vma);	/* maybe ... */
-	if (!IS_ERR(vma))
+	if (!err)
 		err = mbind_range(mm, start, end, new);
 
 	if (!err) {
@@ -1283,9 +1278,8 @@ static long do_mbind(unsigned long start
 
 		if (!list_empty(&pagelist)) {
 			WARN_ON_ONCE(flags & MPOL_MF_LAZY);
-			nr_failed = migrate_pages(&pagelist, new_vma_page,
-					NULL, (unsigned long)vma,
-					MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
+			nr_failed = migrate_pages(&pagelist, new_page, NULL,
+				start, MIGRATE_SYNC, MR_MEMPOLICY_MBIND);
 			if (nr_failed)
 				putback_movable_pages(&pagelist);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
