Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id BC7FD6B0255
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 16:18:05 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id cy9so10749156pac.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:18:05 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 78si11759567pfr.69.2016.01.27.13.18.00
        for <linux-mm@kvack.org>;
        Wed, 27 Jan 2016 13:18:00 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 2/5] hwspinlock: Fix race between radix tree insertion and lookup
Date: Wed, 27 Jan 2016 16:17:49 -0500
Message-Id: <1453929472-25566-3-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Ohad Ben-Cohen <ohad@wizery.com>
Cc: Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

From: Matthew Wilcox <willy@linux.intel.com>

of_hwspin_lock_get_id() is protected by the RCU lock, which means that
insertions can occur simultaneously with the lookup.  If the radix tree
transitions from a height of 0, we can see a slot with the indirect_ptr
bit set, which will cause us to at least read random memory, and could
cause other havoc.

Fix this by using the newly introduced radix_tree_iter_retry().

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Cc: stable@vger.kernel.org
---
 drivers/hwspinlock/hwspinlock_core.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/hwspinlock/hwspinlock_core.c b/drivers/hwspinlock/hwspinlock_core.c
index 52f708bcf77f..d50c701b19d6 100644
--- a/drivers/hwspinlock/hwspinlock_core.c
+++ b/drivers/hwspinlock/hwspinlock_core.c
@@ -313,6 +313,10 @@ int of_hwspin_lock_get_id(struct device_node *np, int index)
 		hwlock = radix_tree_deref_slot(slot);
 		if (unlikely(!hwlock))
 			continue;
+		if (radix_tree_is_indirect_ptr(hwlock)) {
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
 
 		if (hwlock->bank->dev->of_node == args.np) {
 			ret = 0;
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
