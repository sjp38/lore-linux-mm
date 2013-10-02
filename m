Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id D6D4A6B0037
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 10:29:00 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so949850pbc.35
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 07:29:00 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 02/26] ia64: Use get_user_pages_fast() in err_inject.c
Date: Wed,  2 Oct 2013 16:27:43 +0200
Message-Id: <1380724087-13927-3-git-send-email-jack@suse.cz>
In-Reply-To: <1380724087-13927-1-git-send-email-jack@suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Convert get_user_pages() call to get_user_pages_fast(). This actually
fixes an apparent bug where get_user_pages() has been called without
mmap_sem for an arbitrary user-provided address.

CC: Tony Luck <tony.luck@intel.com>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Jan Kara <jack@suse.cz>
---
 arch/ia64/kernel/err_inject.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index f59c0b844e88..75d35906a86b 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -142,8 +142,7 @@ store_virtual_to_phys(struct device *dev, struct device_attribute *attr,
 	u64 virt_addr=simple_strtoull(buf, NULL, 16);
 	int ret;
 
-        ret = get_user_pages(current, current->mm, virt_addr,
-                        1, VM_READ, 0, NULL, NULL);
+	ret = get_user_pages_fast(virt_addr, 1, VM_READ, NULL);
 	if (ret<=0) {
 #ifdef ERR_INJ_DEBUG
 		printk("Virtual address %lx is not existing.\n",virt_addr);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
