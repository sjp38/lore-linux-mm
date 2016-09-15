Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 504256B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 15:30:40 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id t204so79203031ywt.2
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 12:30:40 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id r4si3410587qkd.42.2016.09.15.12.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 12:30:39 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id g192so3371927ywh.0
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 12:30:39 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/7] slab, workqueue: remove keventd_up() usage
Date: Thu, 15 Sep 2016 15:30:19 -0400
Message-Id: <1473967821-24363-6-git-send-email-tj@kernel.org>
In-Reply-To: <1473967821-24363-1-git-send-email-tj@kernel.org>
References: <1473967821-24363-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, jiangshanlai@gmail.com, akpm@linux-foundation.org, kernel-team@fb.com, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org

Now that workqueue can handle work item queueing from very early
during boot, there is no need to gate schedule_delayed_work_on() while
!keventd_up().  Remove it.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
---
Hello,

This change depends on an earlier workqueue patch and is followed by a
patch to remove keventd_up().  It'd be great if it can be routed
through the wq/for-4.9 branch.

Thanks.

 mm/slab.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b672710..dc69b6b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -550,12 +550,7 @@ static void start_cpu_timer(int cpu)
 {
 	struct delayed_work *reap_work = &per_cpu(slab_reap_work, cpu);
 
-	/*
-	 * When this gets called from do_initcalls via cpucache_init(),
-	 * init_workqueues() has already run, so keventd will be setup
-	 * at that time.
-	 */
-	if (keventd_up() && reap_work->work.func == NULL) {
+	if (reap_work->work.func == NULL) {
 		init_reap_node(cpu);
 		INIT_DEFERRABLE_WORK(reap_work, cache_reap);
 		schedule_delayed_work_on(cpu, reap_work,
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
