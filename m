Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1416E6B04A8
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 17:43:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p69so2447013pfk.10
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:58 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id o66si956132pfg.500.2017.08.28.14.43.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 14:43:57 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id h75so4746271pfh.1
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 14:43:56 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v2 25/30] fork: Define usercopy region in thread_stack slab caches
Date: Mon, 28 Aug 2017 14:35:06 -0700
Message-Id: <1503956111-36652-26-git-send-email-keescook@chromium.org>
In-Reply-To: <1503956111-36652-1-git-send-email-keescook@chromium.org>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, David Windsor <dave@nullcore.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

From: David Windsor <dave@nullcore.net>

In support of usercopy hardening, this patch defines a region in the
thread_stack slab caches in which userspace copy operations are allowed.
Since the entire thread_stack needs to be available to userspace, the
entire slab contents are whitelisted. Note that the slab-based thread
stack is only present on systems with THREAD_SIZE < PAGE_SIZE and
!CONFIG_VMAP_STACK.

cache object allocation:
    kernel/fork.c:
        alloc_thread_stack_node(...):
            return kmem_cache_alloc_node(thread_stack_cache, ...)

        dup_task_struct(...):
            ...
            stack = alloc_thread_stack_node(...)
            ...
            tsk->stack = stack;

        copy_process(...):
            ...
            dup_task_struct(...)

        _do_fork(...):
            ...
            copy_process(...)

This region is known as the slab cache's usercopy region. Slab caches
can now check that each copy operation involving cache-managed memory
falls entirely within the slab's usercopy region.

This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log, split patch, provide usage trace]
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 kernel/fork.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index d8ebf755a47b..0f33fb1aabbf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -276,8 +276,9 @@ static void free_thread_stack(struct task_struct *tsk)
 
 void thread_stack_cache_init(void)
 {
-	thread_stack_cache = kmem_cache_create("thread_stack", THREAD_SIZE,
-					      THREAD_SIZE, 0, NULL);
+	thread_stack_cache = kmem_cache_create_usercopy("thread_stack",
+					THREAD_SIZE, THREAD_SIZE, 0, 0,
+					THREAD_SIZE, NULL);
 	BUG_ON(thread_stack_cache == NULL);
 }
 # endif
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
