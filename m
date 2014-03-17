Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9024F6B005A
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 00:09:28 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so5202346pad.15
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 21:09:28 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id hj8si3601418pac.285.2014.03.16.21.09.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Mar 2014 21:09:21 -0700 (PDT)
Message-ID: <53267520.4030503@huawei.com>
Date: Mon, 17 Mar 2014 12:08:00 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v2 2/3] kmemleak: remove redundant code
References: <5326750E.1000004@huawei.com>
In-Reply-To: <5326750E.1000004@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

- remove kmemleak_padding().
- remove kmemleak_release().

Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 include/linux/kmemleak.h | 2 --
 mm/kmemleak.c            | 7 +------
 2 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index 2a5e554..5bb4246 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -30,8 +30,6 @@ extern void kmemleak_alloc_percpu(const void __percpu *ptr, size_t size) __ref;
 extern void kmemleak_free(const void *ptr) __ref;
 extern void kmemleak_free_part(const void *ptr, size_t size) __ref;
 extern void kmemleak_free_percpu(const void __percpu *ptr) __ref;
-extern void kmemleak_padding(const void *ptr, unsigned long offset,
-			     size_t size) __ref;
 extern void kmemleak_not_leak(const void *ptr) __ref;
 extern void kmemleak_ignore(const void *ptr) __ref;
 extern void kmemleak_scan_area(const void *ptr, size_t size, gfp_t gfp) __ref;
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 7fc030e..54270f2 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1545,11 +1545,6 @@ static int kmemleak_open(struct inode *inode, struct file *file)
 	return seq_open(file, &kmemleak_seq_ops);
 }
 
-static int kmemleak_release(struct inode *inode, struct file *file)
-{
-	return seq_release(inode, file);
-}
-
 static int dump_str_object_info(const char *str)
 {
 	unsigned long flags;
@@ -1680,7 +1675,7 @@ static const struct file_operations kmemleak_fops = {
 	.read		= seq_read,
 	.write		= kmemleak_write,
 	.llseek		= seq_lseek,
-	.release	= kmemleak_release,
+	.release	= seq_release,
 };
 
 /*
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
