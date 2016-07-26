Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF546B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:14:15 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y134so445630753pfg.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:14:15 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 140si36747747pfx.153.2016.07.25.20.14.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 20:14:14 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] kexec: add restriction on kexec_load() segment sizes
Date: Tue, 26 Jul 2016 11:03:39 +0800
Message-ID: <1469502219-24140-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, ebiederm@xmission.com
Cc: linux-mm@kvack.org, mm-commits@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

I hit the following issue when run trinity in my system.  The kernel is
3.4 version, but mainline has the same issue.

The root cause is that the segment size is too large so the kerenl spends
too long trying to allocate a page.  Other cases will block until the test
case quits.  Also, OOM conditions will occur.

Call Trace:
 [<ffffffff81106eac>] __alloc_pages_nodemask+0x14c/0x8f0
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8124c2be>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff8113e5ef>] alloc_pages_current+0xaf/0x120
 [<ffffffff810a0da0>] kimage_alloc_pages+0x10/0x60
 [<ffffffff810a15ad>] kimage_alloc_control_pages+0x5d/0x270
 [<ffffffff81027e85>] machine_kexec_prepare+0xe5/0x6c0
 [<ffffffff810a0d52>] ? kimage_free_page_list+0x52/0x70
 [<ffffffff810a1921>] sys_kexec_load+0x141/0x600
 [<ffffffff8115e6b0>] ? vfs_write+0x100/0x180
 [<ffffffff8145fbd9>] system_call_fastpath+0x16/0x1b

The patch changes sanity_check_segment_list() to verify that no segment is
larger than half of memory.

Suggested-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 kernel/kexec_core.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 56b3ed0..536550f 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -140,6 +140,7 @@ int kexec_should_crash(struct task_struct *p)
  * allocating pages whose destination address we do not care about.
  */
 #define KIMAGE_NO_DEST	(-1UL)
+#define PAGE_COUNT(x)	(((x) + PAGE_SIZE - 1) >> PAGE_SHIFT)
 
 static struct page *kimage_alloc_page(struct kimage *image,
 				       gfp_t gfp_mask,
@@ -149,6 +150,7 @@ int sanity_check_segment_list(struct kimage *image)
 {
 	int result, i;
 	unsigned long nr_segments = image->nr_segments;
+	unsigned long total_segments = 0;
 
 	/*
 	 * Verify we have good destination addresses.  The caller is
@@ -210,6 +212,23 @@ int sanity_check_segment_list(struct kimage *image)
 	}

+	/*
+	 * Verify that no segment is larger than half of memory.
+	 * If a segment from userspace is too large, a large amount
+	 * of time will be wasted allocating pages, which can cause
+	 * a soft lockup.
+	 */
+	for (i = 0; i < nr_segments; i++) {
+		if (PAGE_COUNT(image->segment[i].memsz) > totalram_pages / 2
+				|| PAGE_COUNT(total_segments) > totalram_pages / 2)
+			return result;
+
+		total_segments += image->segment[i].memsz;
+	}
+
+	if (PAGE_COUNT(total_segments) > totalram_pages / 2)
+		return result;
+
	/*
 	 * Verify we have good destination addresses.  Normally
 	 * the caller is responsible for making certain we don't
 	 * attempt to load the new image into invalid or reserved
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
