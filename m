Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 39AA26B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 05:08:07 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id ty20so1298014lab.3
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 02:08:06 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id v20si3727609laz.80.2014.06.19.02.08.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jun 2014 02:08:04 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 3/3] fork: copy mm's vm usage counters under mmap_sem
Date: Thu, 19 Jun 2014 13:07:48 +0400
Message-ID: <8efb9247108e3b327a321853025a09774cdaf032.1403168346.git.vdavydov@parallels.com>
In-Reply-To: <fa98629155872c1b97ba4dcd00d509a1e467c1c3.1403168346.git.vdavydov@parallels.com>
References: <fa98629155872c1b97ba4dcd00d509a1e467c1c3.1403168346.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: oleg@redhat.com, rientjes@google.com, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If a forking process has a thread calling (un)mmap (silly but still),
the child process may have some of its mm's vm usage counters (total_vm
and friends) screwed up, because currently they are copied from oldmm
w/o holding any locks (memcpy in dup_mm).

This patch moves the counters initialization to dup_mmap() to be called
under oldmm->mmap_sem, which eliminates any possibility of race.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 kernel/fork.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/fork.c b/kernel/fork.c
index 938707e108db..5002b1188554 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -365,6 +365,11 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	 */
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
+	mm->total_vm = oldmm->total_vm;
+	mm->shared_vm = oldmm->shared_vm;
+	mm->exec_vm = oldmm->exec_vm;
+	mm->stack_vm = oldmm->stack_vm;
+
 	rb_link = &mm->mm_rb.rb_node;
 	rb_parent = NULL;
 	pprev = &mm->mmap;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
