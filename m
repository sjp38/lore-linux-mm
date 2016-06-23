Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9284828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:19:58 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a4so50228519lfa.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 02:19:58 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id c9si6009504wju.177.2016.06.23.02.19.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Jun 2016 02:19:57 -0700 (PDT)
From: <chenjie6@huawei.com>
Subject: [PATCH] memory:bugxfix panic on cat or write /dev/kmem
Date: Fri, 24 Jun 2016 01:30:10 +0800
Message-ID: <1466703010-32242-1-git-send-email-chenjie6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David.Woodhouse@intel.com, zhihui.gao@huawei.com, panxuesong@huawei.com
Cc: akpm@linux-foundation.org, chenjie <chenjie6@huawei.com>

From: chenjie <chenjie6@huawei.com>

cat /dev/kmem and echo > /dev/kmem will lead panic

Signed-off-by: chenjie <chenjie6@huawei.com>
---
 drivers/char/mem.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 71025c2..4bdde28 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -412,6 +412,8 @@ static ssize_t read_kmem(struct file *file, char __user *buf,
 			 * by the kernel or data corruption may occur
 			 */
 			kbuf = xlate_dev_kmem_ptr((void *)p);
+			if (!kbuf)
+				return -EFAULT;
 
 			if (copy_to_user(buf, kbuf, sz))
 				return -EFAULT;
@@ -482,6 +484,11 @@ static ssize_t do_write_kmem(unsigned long p, const char __user *buf,
 		 * corruption may occur.
 		 */
 		ptr = xlate_dev_kmem_ptr((void *)p);
+		if (!ptr) {
+			if (written)
+				break;
+			return -EFAULT;
+		}
 
 		copied = copy_from_user(ptr, buf, sz);
 		if (copied) {
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
