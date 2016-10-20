Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 594636B0265
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 19:32:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u84so37785368pfj.6
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 16:32:46 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t27si29865312pfk.177.2016.10.20.16.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 16:32:45 -0700 (PDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v2 8/8] mm/swap: Enable swap slots cache usage
Date: Thu, 20 Oct 2016 16:31:47 -0700
Message-Id: <24619a5b1749f6fb62de70d9def6d20d25229a65.1477004978.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1477004978.git.tim.c.chen@linux.intel.com>
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1477004978.git.tim.c.chen@linux.intel.com>
References: <cover.1477004978.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

Initialize swap slots cache and enable it on swap on.
Drain swap slots on swap off.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/swapfile.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index caf9fe6..e98c725 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2132,7 +2132,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	struct address_space *mapping;
 	struct inode *inode;
 	struct filename *pathname;
-	int err, found = 0;
+	int err, found = 0, has_swap = 0;
 	unsigned int old_block_size;
 
 	if (!capable(CAP_SYS_ADMIN))
@@ -2144,6 +2144,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	if (IS_ERR(pathname))
 		return PTR_ERR(pathname);
 
+	disable_swap_slots_cache();
 	victim = file_open_name(pathname, O_RDWR|O_LARGEFILE, 0);
 	err = PTR_ERR(victim);
 	if (IS_ERR(victim))
@@ -2153,10 +2154,13 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	spin_lock(&swap_lock);
 	plist_for_each_entry(p, &swap_active_head, list) {
 		if (p->flags & SWP_WRITEOK) {
-			if (p->swap_file->f_mapping == mapping) {
+			if (p->swap_file->f_mapping == mapping)
 				found = 1;
+			else
+				++has_swap;
+			/* there is another swap device left? */
+			if (found && has_swap)
 				break;
-			}
 		}
 	}
 	if (!found) {
@@ -2275,6 +2279,8 @@ out_dput:
 	filp_close(victim, NULL);
 out:
 	putname(pathname);
+	if (has_swap)
+		reenable_swap_slots_cache();
 	return err;
 }
 
@@ -2692,6 +2698,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
+	enable_swap_slot_caches();
 	p = alloc_swap_info();
 	if (IS_ERR(p))
 		return PTR_ERR(p);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
