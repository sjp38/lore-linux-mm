Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 628B36B027B
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c20so131982354pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:28 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id n4si4760234pfj.132.2016.04.14.07.37.27
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:27 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 01/19] drivers/hwspinlock: Use correct radix tree API
Date: Thu, 14 Apr 2016 10:37:04 -0400
Message-Id: <1460644642-30642-2-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

radix_tree_is_indirect_ptr() is an internal API.  The correct call to use
is radix_tree_deref_retry() which has the appropriate unlikely() annotation.

Fixes: c6400ba7e13a ("drivers/hwspinlock: fix race between radix tree insertion and lookup")
Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 drivers/hwspinlock/hwspinlock_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/hwspinlock/hwspinlock_core.c b/drivers/hwspinlock/hwspinlock_core.c
index d50c701..4074441 100644
--- a/drivers/hwspinlock/hwspinlock_core.c
+++ b/drivers/hwspinlock/hwspinlock_core.c
@@ -313,7 +313,7 @@ int of_hwspin_lock_get_id(struct device_node *np, int index)
 		hwlock = radix_tree_deref_slot(slot);
 		if (unlikely(!hwlock))
 			continue;
-		if (radix_tree_is_indirect_ptr(hwlock)) {
+		if (radix_tree_deref_retry(hwlock)) {
 			slot = radix_tree_iter_retry(&iter);
 			continue;
 		}
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
