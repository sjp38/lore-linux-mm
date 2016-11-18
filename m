Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4506B0416
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p66so253360958pga.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:22 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id n1si8185530pgc.121.2016.11.18.05.04.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:21 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 05/10] kernel/fork: use vfree_atomic() to free thread stack
Date: Fri, 18 Nov 2016 14:03:51 +0100
Message-Id: <1479474236-4139-6-git-send-email-hch@lst.de>
In-Reply-To: <1479474236-4139-1-git-send-email-hch@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

From: Andrey Ryabinin <aryabinin@virtuozzo.com>

vfree() is going to use sleeping lock. Thread stack freed in atomic
context, therefore we must use vfree_atomic() here.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 kernel/fork.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 997ac1d..cfee5ec 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -229,7 +229,7 @@ static inline void free_thread_stack(struct task_struct *tsk)
 		}
 		local_irq_restore(flags);
 
-		vfree(tsk->stack);
+		vfree_atomic(tsk->stack);
 		return;
 	}
 #endif
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
