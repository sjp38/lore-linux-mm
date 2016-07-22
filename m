Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB5DD6B025E
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 01:49:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id p126so225628945qke.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 22:49:30 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id u4si6744263qkf.228.2016.07.21.22.49.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 22:49:30 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH v2] kexec: add resriction on the kexec_load
Date: Fri, 22 Jul 2016 13:36:22 +0800
Message-ID: <1469165782-13193-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ebiederm@xmission.com, akpm@linux-foundation.org
Cc: kexec@lists.infradead.org, linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

I hit the following question when run trinity in my system. The
kernel is 3.4 version. but the mainline have same question to be
solved. The root cause is the segment size is too large, it can
expand the most of the area or the whole memory, therefore, it
may waste an amount of time to abtain a useable page. and other
cases will block until the test case quit. at the some time,
OOM will come up.

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

The patch just add condition on sanity_check_segment_list to
restriction the segment size.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 kernel/kexec_core.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 56b3ed0..1f58824 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -148,6 +148,7 @@ static struct page *kimage_alloc_page(struct kimage *image,
 int sanity_check_segment_list(struct kimage *image)
 {
 	int result, i;
+	unsigned long total_segments = 0;
 	unsigned long nr_segments = image->nr_segments;
 
 	/*
@@ -209,6 +210,21 @@ int sanity_check_segment_list(struct kimage *image)
 			return result;
 	}
 
+	/* Verity all segment size donnot exceed the specified size.
+	 * if segment size from user space is too large,  a large
+	 * amount of time will be wasted when allocating page. so,
+	 * softlockup may be come up.
+	 */
+	for (i = 0; i < nr_segments; i++) {
+		if (image->segment[i].memsz > (totalram_pages / 2))
+			return result;
+
+		total_segments += image->segment[i].memsz;
+	}
+
+	if (total_segments > (totalram_pages / 2))
+		return result;
+
 	/*
 	 * Verify we have good destination addresses.  Normally
 	 * the caller is responsible for making certain we don't
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
