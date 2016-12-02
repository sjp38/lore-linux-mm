Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFEDD6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 00:09:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so382787212pfy.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 21:09:49 -0800 (PST)
Received: from mgwkm02.jp.fujitsu.com (mgwkm02.jp.fujitsu.com. [202.219.69.169])
        by mx.google.com with ESMTPS id b61si3453936plc.299.2016.12.01.21.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 21:09:49 -0800 (PST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 61897AC01A5
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 14:09:40 +0900 (JST)
Message-ID: <584101D2.4090200@jp.fujitsu.com>
Date: Fri, 2 Dec 2016 14:08:34 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2] block: avoid incorrect bdi_unregiter call
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-mm@kvack.org, linux-block@vger.kernel.org

bdi_unregister() should be called after bdi_register() is called,
so we should check whether WB_registered flag is set.

For example of the situation, error path in device driver may call
blk_cleanup_queue() before the driver calls bdi_register().

Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
---
 mm/backing-dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 8fde443..f8b07d4 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -853,6 +853,9 @@ static void bdi_remove_from_list(struct backing_dev_info *bdi)
 
 void bdi_unregister(struct backing_dev_info *bdi)
 {
+	if (!test_bit(WB_registered, &bdi->wb.state))
+		return;
+
 	/* make sure nobody finds us on the bdi_list anymore */
 	bdi_remove_from_list(bdi);
 	wb_shutdown(&bdi->wb);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
