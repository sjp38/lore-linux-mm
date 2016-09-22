Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F66A6B0275
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 11:28:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so74780556wmg.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 08:28:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q14si36625345wmb.133.2016.09.22.08.28.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Sep 2016 08:28:47 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] fs/select: add vmalloc fallback for select(2)
Date: Thu, 22 Sep 2016 17:28:31 +0200
Message-Id: <20160922152831.24165-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>

The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
with the number of fds passed. We had a customer report page allocation
failures of order-4 for this allocation. This is a costly order, so it might
easily fail, as the VM expects such allocation to have a lower-order fallback.

Such trivial fallback is vmalloc(), as the memory doesn't have to be
physically contiguous. Also the allocation is temporary for the duration of the
syscall, so it's unlikely to stress vmalloc too much.

Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
it doesn't need this kind of fallback.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 fs/select.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index 8ed9da50896a..8fe5bddbe99b 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -29,6 +29,7 @@
 #include <linux/sched/rt.h>
 #include <linux/freezer.h>
 #include <net/busy_poll.h>
+#include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
 
@@ -558,6 +559,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 	struct fdtable *fdt;
 	/* Allocate small arguments on the stack to save memory and be faster */
 	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
+	unsigned long alloc_size;
 
 	ret = -EINVAL;
 	if (n < 0)
@@ -580,10 +582,15 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 	bits = stack_fds;
 	if (size > sizeof(stack_fds) / 6) {
 		/* Not enough space in on-stack array; must use kmalloc */
+		alloc_size = 6 * size;
 		ret = -ENOMEM;
-		bits = kmalloc(6 * size, GFP_KERNEL);
-		if (!bits)
-			goto out_nofds;
+		bits = kmalloc(alloc_size, GFP_KERNEL|__GFP_NOWARN);
+		if (!bits && alloc_size > PAGE_SIZE) {
+			bits = vmalloc(alloc_size);
+
+			if (!bits)
+				goto out_nofds;
+		}
 	}
 	fds.in      = bits;
 	fds.out     = bits +   size;
@@ -618,7 +625,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 
 out:
 	if (bits != stack_fds)
-		kfree(bits);
+		kvfree(bits);
 out_nofds:
 	return ret;
 }
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
