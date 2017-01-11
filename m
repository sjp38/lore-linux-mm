Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 577F36B026A
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 12:55:53 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so64433810pfb.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 09:55:53 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m13si6442061pga.262.2017.01.11.09.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 09:55:52 -0800 (PST)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v5 8/9] mm/swap: Enable swap slots cache usage
Date: Wed, 11 Jan 2017 09:55:18 -0800
Message-Id: <07cbc94882fa95d4ac3cfc50b8dce0b1ec231b93.1484082593.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1484082593.git.tim.c.chen@linux.intel.com>
References: <cover.1484082593.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ying Huang <ying.huang@intel.com>, dave.hansen@intel.com, ak@linux.intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Jonathan Corbet <corbet@lwn.net>

Initialize swap slots cache and enable it on swap on.
Drain all swap slots on swap off.

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 mm/swapfile.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index e6c30ed..14d9ea2 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2181,6 +2181,8 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	spin_unlock(&p->lock);
 	spin_unlock(&swap_lock);
 
+	disable_swap_slots_cache_lock();
+
 	set_current_oom_origin();
 	err = try_to_unuse(p->type, false, 0); /* force unuse all pages */
 	clear_current_oom_origin();
@@ -2188,9 +2190,12 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	if (err) {
 		/* re-insert swap space back into swap_list */
 		reinsert_swap_info(p);
+		reenable_swap_slots_cache_unlock();
 		goto out_dput;
 	}
 
+	reenable_swap_slots_cache_unlock();
+
 	flush_work(&p->discard_work);
 
 	destroy_swap_extents(p);
@@ -2868,6 +2873,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		putname(name);
 	if (inode && S_ISREG(inode->i_mode))
 		inode_unlock(inode);
+	if (!error)
+		enable_swap_slots_cache();
 	return error;
 }
 
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
