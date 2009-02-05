Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AB4EB6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 12:23:07 -0500 (EST)
Date: Thu, 5 Feb 2009 11:23:03 -0600
From: Robin Holt <holt@sgi.com>
Subject: [Patch] mmu_notifiers destroyed by __mmu_notifier_release() retain
	extra mm_count.
Message-ID: <20090205172303.GB8559@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


An application relying upon mmu_notifier_release for teardown of the
mmu_notifiers will leak mm_structs.  At the do_mmu_notifier_register
increments mm_count, but __mmu_notifier_release() does not decrement it.

Signed-off-by: Robin Holt <holt@sgi.com>
CC: Stable kernel maintainers <stable@vger.kernel.org>

---

I detected this while running a 2.6.27 kernel.  Could this get added to
the stable trees when accepted as well?  It does cause a denial of
service with OOM.

 mm/mmu_notifier.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.27/mm/mmu_notifier.c
===================================================================
--- linux-2.6.27.orig/mm/mmu_notifier.c	2008-10-09 17:13:53.000000000 -0500
+++ linux-2.6.27/mm/mmu_notifier.c	2009-02-05 10:55:07.076561592 -0600
@@ -61,6 +61,7 @@ void __mmu_notifier_release(struct mm_st
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
 		rcu_read_unlock();
+		mmdrop(mm);	/* matches do_mmu_notifier_register's inc */
 		spin_lock(&mm->mmu_notifier_mm->lock);
 	}
 	spin_unlock(&mm->mmu_notifier_mm->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
