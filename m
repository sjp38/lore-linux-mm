Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 968316B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 23:55:39 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id g14so174870148ioj.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 20:55:39 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id j130si15186991oib.244.2016.07.29.20.55.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jul 2016 20:55:38 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: =?UTF-8?q?=5BPATCH=5D=20fs=3A=20fix=20a=20bug=20when=20new=5Finsert=5Fkey=20is=20not=20initialization?=
Date: Sat, 30 Jul 2016 11:51:09 +0800
Message-ID: <1469850669-64815-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

when compile the kenrel code, I happens to the following warn.
fs/reiserfs/ibalance.c:1156:2: warning: a??new_insert_keya?? may be used
uninitialized in this function.
memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);

The patch fix it by check the new_insert_ptr. if new_insert_ptr is not
NULL, we ensure that new_insert_key is assigned. therefore, memcpy will
saftly exec the operatetion.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 fs/reiserfs/ibalance.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/reiserfs/ibalance.c b/fs/reiserfs/ibalance.c
index b751eea..2c46829 100644
--- a/fs/reiserfs/ibalance.c
+++ b/fs/reiserfs/ibalance.c
@@ -1153,8 +1153,10 @@ int balance_internal(struct tree_balance *tb,
 				       insert_ptr);
 	}
 
-	memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
-	insert_ptr[0] = new_insert_ptr;
+	if (new_insert_ptr) {
+		memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
+		insert_ptr[0] = new_insert_ptr;
+	}
 
 	return order;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
