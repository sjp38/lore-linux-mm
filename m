Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCC982F6F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 05:24:57 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so156050063wic.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 02:24:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce1si10619668wjc.199.2015.10.06.02.24.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 02:24:52 -0700 (PDT)
From: Jan Kara <jack@suse.com>
Subject: [PATCH 2/7] ia64: Use get_user_pages_fast() in err_inject.c
Date: Tue,  6 Oct 2015 11:24:25 +0200
Message-Id: <1444123470-4932-3-git-send-email-jack@suse.com>
In-Reply-To: <1444123470-4932-1-git-send-email-jack@suse.com>
References: <1444123470-4932-1-git-send-email-jack@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Jan Kara <jack@suse.cz>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

From: Jan Kara <jack@suse.cz>

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
index 0c161ed6d18e..1fc8995bd8b8 100644
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
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
