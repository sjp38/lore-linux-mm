Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B496C6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 06:48:15 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id f59-v6so1029230plb.7
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 03:48:15 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id n12-v6si12730441pls.292.2018.03.07.03.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 03:48:14 -0800 (PST)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH] slub: Fix misleading 'age' in verbose slub prints
Date: Wed,  7 Mar 2018 17:17:46 +0530
Message-Id: <1520423266-28830-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>

When SLUB_DEBUG catches the some issues, it prints
all the required debug info being verbose. However,
in few cases where allocation and free of the object
has have happened in a very short time, 'age' might
mislead. See the example below,

[ 6044.137581] =============================================================================
[ 6044.145863] BUG kmalloc-256 (Tainted: G        W  O   ): Poison overwritten
[ 6044.152889] -----------------------------------------------------------------------------
[ 6044.152889]
[ 6044.162618] INFO: 0xfffffff14956a878-0xfffffff14956a878. First byte 0x67 instead of 0x6b
[ 6044.170804] INFO: Allocated in binder_transaction+0x4b0/0x2448 age=731 cpu=3 pid=5314
[ 6044.178711] __slab_alloc.isra.68.constprop.71+0x58/0x98
[ 6044.184070] kmem_cache_alloc_trace+0x198/0x2c4
[ 6044.188642] binder_transaction+0x4b0/0x2448
[ 6044.192953] binder_thread_write+0x998/0x1410
[ 6044.197350] binder_ioctl_write_read+0x130/0x370
[ 6044.202016] binder_ioctl+0x550/0x7dc
[ 6044.205726] do_vfs_ioctl+0xcc/0x888
[ 6044.209510] SyS_ioctl+0x90/0xa4
[ 6044.212821] __sys_trace_return+0x0/0x4
[ 6044.216696] INFO: Freed in binder_free_transaction+0x2c/0x58 age=735 cpu=6 pid=2079
[ 6044.224415] kfree+0x28c/0x290
[ 6044.227505] binder_free_transaction+0x2c/0x58
[ 6044.231991] binder_transaction+0x1f78/0x2448
[ 6044.236392] binder_thread_write+0x998/0x1410
[ 6044.240789] binder_ioctl_write_read+0x130/0x370
[ 6044.245455] binder_ioctl+0x550/0x7dc
[ 6044.249152] do_vfs_ioctl+0xcc/0x888
[ 6044.252772] SyS_ioctl+0x90/0xa4
[ 6044.256041] __sys_trace_return+0x0/0x4
[ 6044.259924] INFO: Slab 0xffffffbfc5255a00 objects=21 used=20 fp=0xfffffff14956a480 flags=0x4080
[ 6044.268695] INFO: Object 0xfffffff14956a780 @offset=10112 fp=0xfffffff149568680
...
[ 6044.494293] Object fffffff14956a870: 6b 6b 6b 6b 6b 6b 6b 6b 67 6b 6b 6b 6b 6b 6b a5  kkkkkkkkgkkkkkk.

In this case, object got freed later but 'age' shows
otherwise. This could be because, while printing
this info, we print allocation traces first and
free traces thereafter. In between, if we get schedule
out, (jiffies - t->when) could become meaningless.

So, simply print when the object was allocated/freed.

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---
 mm/slub.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index e381728..b173f85 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -603,8 +603,8 @@ static void print_track(const char *s, struct track *t)
 	if (!t->addr)
 		return;
 
-	pr_err("INFO: %s in %pS age=%lu cpu=%u pid=%d\n",
-	       s, (void *)t->addr, jiffies - t->when, t->cpu, t->pid);
+	pr_err("INFO: %s in %pS when=%lu cpu=%u pid=%d\n",
+	       s, (void *)t->addr, t->when, t->cpu, t->pid);
 #ifdef CONFIG_STACKTRACE
 	{
 		int i;
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation
Center, Inc., is a member of Code Aurora Forum, a Linux Foundation
Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
