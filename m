Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD4CB280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 06:05:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 136so1776734wmm.15
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 03:05:58 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id o26si1254343edf.332.2017.08.23.03.05.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 03:05:57 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id l19so12010321wmi.1
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 03:05:57 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kcov: support compat processes
Date: Wed, 23 Aug 2017 12:05:53 +0200
Message-Id: <20170823100553.55812-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, syzkaller@googlegroups.com, linux-mm@kvack.org

Support compat processes in KCOV by providing compat_ioctl callback.
Compat mode uses the same ioctl callback: we have 2 commands that
do not use the argument and 1 that already checks that the arg does
not overflow INT_MAX.
This allows to use KCOV-guided fuzzing in compat processes.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: syzkaller@googlegroups.com
Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 kernel/kcov.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/kcov.c b/kernel/kcov.c
index cd771993f96f..3f693a0f6f3e 100644
--- a/kernel/kcov.c
+++ b/kernel/kcov.c
@@ -270,6 +270,7 @@ static long kcov_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
 static const struct file_operations kcov_fops = {
 	.open		= kcov_open,
 	.unlocked_ioctl	= kcov_ioctl,
+	.compat_ioctl	= kcov_ioctl,
 	.mmap		= kcov_mmap,
 	.release        = kcov_close,
 };
-- 
2.14.1.342.g6490525c54-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
