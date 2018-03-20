Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DF9EF6B000C
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 17:32:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y19so1480931pgv.18
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 14:32:32 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id e9-v6si2377206pln.439.2018.03.20.14.32.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 14:32:31 -0700 (PDT)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [RFC PATCH 6/8] fs: proc/vmcore: pass atomic parameter to do_munmap()
Date: Wed, 21 Mar 2018 05:31:24 +0800
Message-Id: <1521581486-99134-7-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1521581486-99134-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Just pass "true" here since vmcore map is not a hot path there is not
too much gain to release mmap_sem in the middle.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 fs/proc/vmcore.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index a45f0af..02683eb 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -388,7 +388,7 @@ static int remap_oldmem_pfn_checked(struct vm_area_struct *vma,
 	}
 	return 0;
 fail:
-	do_munmap(vma->vm_mm, from, len, NULL);
+	do_munmap(vma->vm_mm, from, len, NULL, true);
 	return -EAGAIN;
 }
 
@@ -481,7 +481,7 @@ static int mmap_vmcore(struct file *file, struct vm_area_struct *vma)
 
 	return 0;
 fail:
-	do_munmap(vma->vm_mm, vma->vm_start, len, NULL);
+	do_munmap(vma->vm_mm, vma->vm_start, len, NULL, true);
 	return -EAGAIN;
 }
 #else
-- 
1.8.3.1
