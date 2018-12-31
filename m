Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE508E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 22:03:11 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id b16so33205423qtc.22
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 19:03:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n30sor35877443qvd.24.2018.12.30.19.03.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 19:03:10 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH] usercopy: no check page span for stack objects
Date: Sun, 30 Dec 2018 22:02:54 -0500
Message-Id: <20181231030254.99441-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: keescook@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

It is easy to trigger this with CONFIG_HARDENED_USERCOPY_PAGESPAN=y,

usercopy: Kernel memory overwrite attempt detected to spans multiple
pages (offset 0, size 23)!
kernel BUG at mm/usercopy.c:102!

For example,

print_worker_info
char name[WQ_NAME_LEN] = { };
char desc[WORKER_DESC_LEN] = { };
  probe_kernel_read(name, wq->name, sizeof(name) - 1);
  probe_kernel_read(desc, worker->desc, sizeof(desc) - 1);
    __copy_from_user_inatomic
      check_object_size
        check_heap_object
          check_page_span

This is because on-stack variables could cross PAGE_SIZE boundary, and
failed this check,

if (likely(((unsigned long)ptr & (unsigned long)PAGE_MASK) ==
	   ((unsigned long)end & (unsigned long)PAGE_MASK)))

ptr = FFFF889007D7EFF8
end = FFFF889007D7F00E

Hence, fix it by checking if it is a stack object first.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/usercopy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index 852eb4e53f06..a1f58beaa246 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -262,9 +262,6 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 	/* Check for invalid addresses. */
 	check_bogus_address((const unsigned long)ptr, n, to_user);
 
-	/* Check for bad heap object. */
-	check_heap_object(ptr, n, to_user);
-
 	/* Check for bad stack object. */
 	switch (check_stack_object(ptr, n)) {
 	case NOT_STACK:
@@ -282,6 +279,9 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 		usercopy_abort("process stack", NULL, to_user, 0, n);
 	}
 
+	/* Check for bad heap object. */
+	check_heap_object(ptr, n, to_user);
+
 	/* Check for object in kernel to avoid text exposure. */
 	check_kernel_text_object((const unsigned long)ptr, n, to_user);
 }
-- 
2.17.2 (Apple Git-113)
