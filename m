Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB3DC6B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 09:46:43 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t204so33521693ywt.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 06:46:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f9si11356854ywa.79.2016.09.20.06.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 06:46:42 -0700 (PDT)
Date: Tue, 20 Sep 2016 15:46:38 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [xiaolong.ye@intel.com: [mm]  0331ab667f: kernel BUG at
 mm/mmap.c:327!]
Message-ID: <20160920134638.GJ4716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org

Hello Michel,

I altered the vma_adjust code and it's triggering what looks like to
be a false positive in vma_rb_erase->validate_mm_rb with
CONFIG_DEBUG_VM_RB=y.

So what happens is normally remove_next == 1 or == 2, and set
vma->vm_end to next->vm_end and then call validate_mm_rb(next) and it
passes and then unlink "next" (removed from vm_next/prev and rbtree).

I introduced a new case to fix a bug remove_next == 3 that actually
removes "vma" and sets next->vm_start = vma->vm_start.

So the old code was always doing:

   vma->vm_end = next->vm_end
   vma_rb_erase(next) // in __vma_unlink
   vma->vm_next = next->vm_next // in __vma_unlink
   next = vma->vm_next
   vma_gap_update(next)

The new code still does the above for remove_next == 1 and 2, but for
remove_next ==3 it has been changed and it does:

   next->vm_start = vma->vm_start
   vma_rb_erase(vma) // in __vma_unlink
   vma_gap_update(next)

However it bugs out in vma_rb_erase(vma) because next->vm_start was
reduced. However I tend to think what I'm executing is correct.

It's pointless to call vma_gap_update before I can call vm_rb_erase
anyway so certainly I can't fix it that way. I'm forced to remove
"vma" from the rbtree before I can call vma_gap_update(next).

So I did other tests:

diff --git a/mm/mmap.c b/mm/mmap.c
index 27f0509..a38c8a0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -400,15 +400,9 @@ static inline void vma_rb_insert(struct vm_area_struct *vma,
 	rb_insert_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
 }
 
-static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
+static void __vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
 {
 	/*
-	 * All rb_subtree_gap values must be consistent prior to erase,
-	 * with the possible exception of the vma being erased.
-	 */
-	validate_mm_rb(root, vma);
-
-	/*
 	 * Note rb_erase_augmented is a fairly large inline function,
 	 * so make sure we instantiate it only once with our desired
 	 * augmented rbtree callbacks.
@@ -416,6 +410,18 @@ static void vma_rb_erase(struct vm_area_struct *vma, struct rb_root *root)
 	rb_erase_augmented(&vma->vm_rb, root, &vma_gap_callbacks);
 }
 
+static __always_inline void vma_rb_erase(struct vm_area_struct *vma,
+					 struct rb_root *root)
+{
+	/*
+	 * All rb_subtree_gap values must be consistent prior to erase,
+	 * with the possible exception of the vma being erased.
+	 */
+	validate_mm_rb(root, vma);
+
+	__vma_rb_erase(vma, root);
+}
+
 /*
  * vma has some anon_vma assigned, and is already inserted on that
  * anon_vma's interval trees.
@@ -606,7 +612,10 @@ static __always_inline void __vma_unlink_common(struct mm_struct *mm,
 {
 	struct vm_area_struct *next;
 
-	vma_rb_erase(vma, &mm->mm_rb);
+	if (has_prev)
+		vma_rb_erase(vma, &mm->mm_rb);
+	else
+		__vma_rb_erase(vma, &mm->mm_rb);
 	next = vma->vm_next;
 	if (has_prev)
 		prev->vm_next = next;
@@ -892,9 +901,11 @@ again:
 			end = next->vm_end;
 			goto again;
 		}
-		else if (next)
+		else if (next) {
 			vma_gap_update(next);
-		else
+			if (remove_next == 3)
+				validate_mm_rb(&mm->mm_rb, next);
+		} else
 			mm->highest_vm_end = end;
 	}
 	if (insert && file)


The above shifts the validate_mm_rb(next) for the remove_next == 3
case from before the rb_removal of "vma" to after vma_gap_update is
called on "next". This works fine.

So if you agree this is a false positive of CONFIG_DEBUG_MM_RB and
there was no actual bug, I just suggest to shut off the warning by
telling validate_mm_rb not to ignore the vma that is being removed but
the next one, if the next->vm_start was reduced to overlap over the
vma that is being removed.

This shut off the warning just fine for me and it leaves the
validation in place and always enabled. Just it skips the check on the
next vma that was updated instead of the one that is being removed if
it was the next one that had next->vm_start reduced.

On a side note I also noticed "mm->highest_vm_end = end" is erroneous,
it should be VM_WARN_ON(mm->highest_vm_end != end) but that's
offtopic.

So this would be the patch I'd suggest to shut off the false positive,
it's a noop when CONFIG_DEBUG_VM_RB=n.
