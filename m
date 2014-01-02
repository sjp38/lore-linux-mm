Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 27C416B0037
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:13 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fb1so14273752pad.32
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:12 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gm1si15344151pac.100.2014.01.01.23.13.10
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:11 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 02/16] vrange: Clear volatility on new mmaps
Date: Thu,  2 Jan 2014 16:12:10 +0900
Message-Id: <1388646744-15608-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

From: John Stultz <john.stultz@linaro.org>

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

Minchan does have an alternative solution[1], but I'm not a big fan of it
yet, so this simpler approach is a placeholder for now.

[1] https://git.kernel.org/cgit/linux/kernel/git/minchan/linux.git/commit/?h=vrange-working&id=821f58333b381fd88ee7f37fd9c472949756c74e

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
[minchan: add link alternative solution]
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/vrange.h |    2 ++
 mm/mmap.c              |    5 +++++
 mm/vrange.c            |    8 ++++++++
 3 files changed, 15 insertions(+)

diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 2b96ee1ee75b..ef153c8a88d1 100644
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
index 9d548512ff8a..b8e2c1e57336 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -36,6 +36,7 @@
 #include <linux/sched/sysctl.h>
 #include <linux/notifier.h>
 #include <linux/memory.h>
+#include <linux/vrange.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -1503,6 +1504,10 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
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
index 57dad4d72b04..444da8794dbf 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -167,6 +167,14 @@ static int vrange_remove(struct vrange_root *vroot,
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
