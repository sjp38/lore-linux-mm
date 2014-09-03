Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id F0B326B0037
	for <linux-mm@kvack.org>; Wed,  3 Sep 2014 01:55:37 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id r2so8521579igi.0
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 22:55:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l12si10635016icm.84.2014.09.02.22.55.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 22:55:37 -0700 (PDT)
From: Junxiao Bi <junxiao.bi@oracle.com>
Subject: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
Date: Wed,  3 Sep 2014 13:54:54 +0800
Message-Id: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, akpm@linux-foundation.org
Cc: xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

commit 21caf2fc1931 ("mm: teach mm by current context info to not do I/O during memory allocation")
introduces PF_MEMALLOC_NOIO flag to avoid doing I/O inside memory allocation, __GFP_IO is cleared
when this flag is set, but __GFP_FS implies __GFP_IO, it should also be cleared. Or it may still
run into I/O, like in superblock shrinker.

Signed-off-by: Junxiao Bi <junxiao.bi@oracle.com>
Cc: joyce.xue <xuejiufei@huawei.com>
Cc: Ming Lei <ming.lei@canonical.com>
---
 include/linux/sched.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5c2c885..2fb2c47 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1936,11 +1936,13 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define tsk_used_math(p) ((p)->flags & PF_USED_MATH)
 #define used_math() tsk_used_math(current)
 
-/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags */
+/* __GFP_IO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags
+ * __GFP_FS is also cleared as it implies __GFP_IO.
+ */
 static inline gfp_t memalloc_noio_flags(gfp_t flags)
 {
 	if (unlikely(current->flags & PF_MEMALLOC_NOIO))
-		flags &= ~__GFP_IO;
+		flags &= ~(__GFP_IO | __GFP_FS);
 	return flags;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
