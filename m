Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AD28B6B0007
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:57:01 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 35-v6so1471462pla.18
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:57:01 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id z24si1503785pgn.55.2018.04.18.11.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 11:57:00 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH -mmotm] prctl: add comment about mmap_sem and arg_lock
Date: Thu, 19 Apr 2018 02:56:39 +0800
Message-Id: <1524077799-80690-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, gorcunov@gmail.com, akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add comment to elaborate why mmap_sem for is used by prctl.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
akpm: this patch can be foled into:
mm-introduce-arg_lock-to-protect-arg_startend-and-env_startend-in-mm_struct.patch

 kernel/sys.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/kernel/sys.c b/kernel/sys.c
index 0cc5a1c..943fdc5 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -2011,6 +2011,10 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
 			return error;
 	}
 
+	/*
+	 * arg_lock protects concurent updates but we still need mmap_sem for
+	 * read to exclude races with sys_brk.
+	 */
 	down_read(&mm->mmap_sem);
 
 	/*
-- 
1.8.3.1
