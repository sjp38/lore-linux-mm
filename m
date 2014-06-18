Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 087256B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 09:33:35 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id q8so512635lbi.6
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 06:33:35 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id na5si3096237lbb.7.2014.06.18.06.33.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jun 2014 06:33:34 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] fork: dup_mm: init vm stat counters under mmap_sem
Date: Wed, 18 Jun 2014 17:33:11 +0400
Message-ID: <1403098391-24546-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: oleg@redhat.com, rientjes@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If a forking process has a thread calling (un)mmap (silly but still),
the child process may have some of its mm's vm stats (total_vm and
friends) screwed up, because currently they are copied from oldmm w/o
holding any locks (see dup_mm).

This patch moves the stats initialization to dup_mmap to be called under
oldmm->mmap_sem, which eliminates any possibility of race.

Also, mm->pinned_vm is not reset on fork. Let's fix it.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 kernel/fork.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/fork.c b/kernel/fork.c
index d2799d1fc952..eaacc75da4f7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -365,7 +365,12 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	 */
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
+	mm->total_vm = oldmm->total_vm;
 	mm->locked_vm = 0;
+	mm->pinned_vm = 0;
+	mm->shared_vm = oldmm->shared_vm;
+	mm->exec_vm = oldmm->exec_vm;
+	mm->stack_vm = oldmm->stack_vm;
 	mm->mmap = NULL;
 	mm->vmacache_seqnum = 0;
 	mm->map_count = 0;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
