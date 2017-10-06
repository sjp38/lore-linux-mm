Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B12B86B025F
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 07:38:25 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 90so2463571lfs.12
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 04:38:25 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [2a02:6b8:0:1a72::290])
        by mx.google.com with ESMTPS id d26si632086ljf.361.2017.10.06.04.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 04:38:24 -0700 (PDT)
Subject: [PATCH] kmemleak: clear stale pointers from task stacks
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 06 Oct 2017 14:38:21 +0300
Message-ID: <150728990124.744199.8403409836394318684.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>
Cc: Andy Lutomirski <luto@kernel.org>

Kmemleak considers any pointers as task stacks as references.
This patch clears newly allocated and reused vmap stacks.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/thread_info.h |    2 +-
 kernel/fork.c               |    4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index 905d769d8ddc..5f7eeab990fe 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -42,7 +42,7 @@ enum {
 #define THREAD_ALIGN	THREAD_SIZE
 #endif
 
-#ifdef CONFIG_DEBUG_STACK_USAGE
+#if IS_ENABLED(CONFIG_DEBUG_STACK_USAGE) || IS_ENABLED(CONFIG_DEBUG_KMEMLEAK)
 # define THREADINFO_GFP		(GFP_KERNEL_ACCOUNT | __GFP_NOTRACK | \
 				 __GFP_ZERO)
 #else
diff --git a/kernel/fork.c b/kernel/fork.c
index c4ff0303b7c5..53e3b6f8a3bf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -213,6 +213,10 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 		if (!s)
 			continue;
 
+#ifdef CONFIG_DEBUG_KMEMLEAK
+		/* Clear stale pointers from reused stack. */
+		memset(s->addr, 0, THREAD_SIZE);
+#endif
 		tsk->stack_vm_area = s;
 		return s->addr;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
