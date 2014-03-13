Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id D5F526B0036
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 02:48:12 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so672462pbb.15
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 23:48:12 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id p2si1229789pbn.213.2014.03.12.23.48.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 23:48:12 -0700 (PDT)
Message-ID: <532154A1.3060002@huawei.com>
Date: Thu, 13 Mar 2014 14:48:01 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] kmemleak: remove redundant code
References: <53215492.40701@huawei.com>
In-Reply-To: <53215492.40701@huawei.com>
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
index c7d4b94..9e102ce 100644
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
@@ -1685,7 +1680,7 @@ static const struct file_operations kmemleak_fops = {
 	.read		= seq_read,
 	.write		= kmemleak_write,
 	.llseek		= seq_lseek,
-	.release	= kmemleak_release,
+	.release	= seq_release,
 };
 
 static void __kmemleak_do_cleanup(void)
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
