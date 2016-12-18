Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 256766B0038
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 07:33:12 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id 3so87773050uaz.2
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 04:33:12 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r4si1113046uaf.22.2016.12.18.04.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 04:33:11 -0800 (PST)
From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH 4/4] mm: clarify mm_struct.mm_{users,count} documentation
Date: Sun, 18 Dec 2016 13:32:29 +0100
Message-Id: <20161218123229.22952-4-vegard.nossum@oracle.com>
In-Reply-To: <20161218123229.22952-1-vegard.nossum@oracle.com>
References: <20161218123229.22952-1-vegard.nossum@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org
Cc: Peter Zijlstra <peterz@infradead.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>

Clarify documentation relating to mm_users and mm_count, and switch to
kernel-doc syntax.

Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
---
 include/linux/mm_types.h | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 08d947fc4c59..316c3e1fc226 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -407,8 +407,27 @@ struct mm_struct {
 	unsigned long task_size;		/* size of task vm space */
 	unsigned long highest_vm_end;		/* highest vma end address */
 	pgd_t * pgd;
-	atomic_t mm_users;			/* How many users with user space? */
-	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
+
+	/**
+	 * @mm_users: The number of users including userspace.
+	 *
+	 * Use mmget()/mmget_not_zero()/mmput() to modify. When this drops
+	 * to 0 (i.e. when the task exits and there are no other temporary
+	 * reference holders), we also release a reference on @mm_count
+	 * (which may then free the &struct mm_struct if @mm_count also
+	 * drops to 0).
+	 */
+	atomic_t mm_users;
+
+	/**
+	 * @mm_count: The number of references to &struct mm_struct
+	 * (@mm_users count as 1).
+	 *
+	 * Use mmgrab()/mmdrop() to modify. When this drops to 0, the
+	 * &struct mm_struct is freed.
+	 */
+	atomic_t mm_count;
+
 	atomic_long_t nr_ptes;			/* PTE page table pages */
 #if CONFIG_PGTABLE_LEVELS > 2
 	atomic_long_t nr_pmds;			/* PMD page table pages */
-- 
2.11.0.1.gaa10c3f

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
