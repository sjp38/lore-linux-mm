Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 38DA76B0044
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 12:51:47 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so11377267wes.21
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 09:51:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hk6si20626621wib.26.2014.07.02.09.51.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 09:51:15 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 03/10] mm: PT lock: export double_pt_lock/unlock
Date: Wed,  2 Jul 2014 18:50:09 +0200
Message-Id: <1404319816-30229-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Paolo Bonzini <pbonzini@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>, Mel Gorman <mgorman@suse.de>

Those two helpers are needed by remap_anon_pages.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h |  4 ++++
 mm/fremap.c        | 29 +++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00faeda..0a7f0e1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1401,6 +1401,10 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 }
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
 
+/* mm/fremap.c */
+extern void double_pt_lock(spinlock_t *ptl1, spinlock_t *ptl2);
+extern void double_pt_unlock(spinlock_t *ptl1, spinlock_t *ptl2);
+
 #if USE_SPLIT_PTE_PTLOCKS
 #if ALLOC_SPLIT_PTLOCKS
 void __init ptlock_cache_init(void);
diff --git a/mm/fremap.c b/mm/fremap.c
index 72b8fa3..1e509f7 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -281,3 +281,32 @@ out_freed:
 
 	return err;
 }
+
+void double_pt_lock(spinlock_t *ptl1,
+		    spinlock_t *ptl2)
+	__acquires(ptl1)
+	__acquires(ptl2)
+{
+	spinlock_t *ptl_tmp;
+
+	if (ptl1 > ptl2) {
+		/* exchange ptl1 and ptl2 */
+		ptl_tmp = ptl1;
+		ptl1 = ptl2;
+		ptl2 = ptl_tmp;
+	}
+	/* lock in virtual address order to avoid lock inversion */
+	spin_lock(ptl1);
+	if (ptl1 != ptl2)
+		spin_lock_nested(ptl2, SINGLE_DEPTH_NESTING);
+}
+
+void double_pt_unlock(spinlock_t *ptl1,
+		      spinlock_t *ptl2)
+	__releases(ptl1)
+	__releases(ptl2)
+{
+	spin_unlock(ptl1);
+	if (ptl1 != ptl2)
+		spin_unlock(ptl2);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
