Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 28C7028024E
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:19:12 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id cg13so35465851pac.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:19:12 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l5si3513280pay.57.2016.09.27.10.19.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 10:19:11 -0700 (PDT)
Date: Tue, 27 Sep 2016 10:19:10 -0700
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH 8/8] mm/swap: Enable swap slots cache usage
Message-ID: <20160927171909.GA17961@linux.intel.com>
Reply-To: tim.c.chen@linux.intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

Initialize swap slots cache and enable it on swap on.
Drain swap slots on swap off.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/swapfile.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index fa6935f..985215b 100644
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
@@ -2152,6 +2153,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	mapping = victim->f_mapping;
 	spin_lock(&swap_lock);
 	plist_for_each_entry(p, &swap_active_head, list) {
+		has_swap = 1;
 		if (p->flags & SWP_WRITEOK) {
 			if (p->swap_file->f_mapping == mapping) {
 				found = 1;
@@ -2275,6 +2277,8 @@ out_dput:
 	filp_close(victim, NULL);
 out:
 	putname(pathname);
+	if (has_swap)
+		reenable_swap_slots_cache();
 	return err;
 }
 
@@ -2692,6 +2696,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
+	init_swap_slot_caches();
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
