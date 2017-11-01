Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F31DF6B0038
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 17:38:57 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t10so3644690pgo.20
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 14:38:57 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id 73si599630ple.592.2017.11.01.14.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 14:38:56 -0700 (PDT)
From: "Yang Shi" <yang.s@alibaba-inc.com>
Subject: [PATCH] mm: use in_atomic() in print_vma_addr()
Date: Thu, 02 Nov 2017 05:38:33 +0800
Message-Id: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

commit 3e51f3c4004c9b01f66da03214a3e206f5ed627b
("sched/preempt: Remove PREEMPT_ACTIVE unmasking off in_atomic()") makes
in_atomic() just check the preempt count, so it is not necessary to use
preempt_count() in print_vma_addr() any more. Replace preempt_count() to
in_atomic() which is a generic API for checking atomic context.

Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index a728bed..19b684e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4460,7 +4460,7 @@ void print_vma_addr(char *prefix, unsigned long ip)
 	 * Do not print if we are in atomic
 	 * contexts (in exception stacks, etc.):
 	 */
-	if (preempt_count())
+	if (in_atomic())
 		return;
 
 	down_read(&mm->mmap_sem);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
