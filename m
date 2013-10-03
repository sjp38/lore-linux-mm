Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 980796B003C
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:08 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id q10so1656959pdj.20
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:08 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id v10so1664223pde.24
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:06 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 03/14] vrange: Clear volatility on new mmaps
Date: Wed,  2 Oct 2013 17:51:32 -0700
Message-Id: <1380761503-14509-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

At lsf-mm, the issue was brought up that there is a precedence with
interfaces like mlock, such that new mappings in a pre-existing range
do no inherit the mlock state.

This is mostly because mlock only modifies the existing vmas, and so
any new mmaps create new vmas, which won't be mlocked.

Since volatility is not stored in the vma (for good cause, specifically
as we'd have to have manage file volatility differently from anonymous
and we're likely to manage volatility on small chunks of memory, which
would cause lots of vma splitting and churn), this patch clears volitility
on new mappings, to ensure that we don't inherit volatility if memory in
an existing volatile range is unmapped and then re-mapped with something
else.

Thus, this patch forces any volatility to be cleared on mmap.

XXX: We expect this patch to be not well loved by mm folks, and are open
to alternative methods here. Its more of a place holder to address
the issue from lsf-mm and hopefully will spur some further discussion.

Minchan does have an alternative solution, but I'm not a big fan of it
yet, so this simpler approach is a placeholder for now.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/vrange.h | 2 ++
 mm/mmap.c              | 5 +++++
 mm/vrange.c            | 8 ++++++++
 3 files changed, 15 insertions(+)

diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 2b96ee1..ef153c8 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -36,6 +36,8 @@ static inline int vrange_type(struct vrange *vrange)
 	return vrange->owner->type;
 }
 
+extern int vrange_clear(struct vrange_root *vroot,
+				unsigned long start, unsigned long end);
 extern void vrange_root_cleanup(struct vrange_root *vroot);
 extern int vrange_fork(struct mm_struct *new,
 					struct mm_struct *old);
diff --git a/mm/mmap.c b/mm/mmap.c
index f9c97d1..ed7056f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -36,6 +36,7 @@
 #include <linux/sched/sysctl.h>
 #include <linux/notifier.h>
 #include <linux/memory.h>
+#include <linux/vrange.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1502,6 +1503,10 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	/* Clear old maps */
 	error = -ENOMEM;
 munmap_back:
+
+	/* zap any volatile ranges */
+	vrange_clear(&mm->vroot, addr, addr + len);
+
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent)) {
 		if (do_munmap(mm, addr, len))
 			return -ENOMEM;
diff --git a/mm/vrange.c b/mm/vrange.c
index 4ddcc3e9..f2d1588 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -166,6 +166,14 @@ static int vrange_remove(struct vrange_root *vroot,
 	return 0;
 }
 
+int vrange_clear(struct vrange_root *vroot,
+					unsigned long start, unsigned long end)
+{
+	int purged;
+
+	return vrange_remove(vroot, start, end - 1, &purged);
+}
+
 void vrange_root_cleanup(struct vrange_root *vroot)
 {
 	struct vrange *range;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
