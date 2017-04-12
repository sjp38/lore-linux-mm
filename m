Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 05F8C6B039F
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 08:49:31 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h64so20298595oia.7
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 05:49:31 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00136.outbound.protection.outlook.com. [40.107.0.136])
        by mx.google.com with ESMTPS id i14si9427724ote.14.2017.04.12.05.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Apr 2017 05:49:30 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 3/5] kernel/fork: use vfree() instead of vfree_atomic() to free thread stack
Date: Wed, 12 Apr 2017 15:49:03 +0300
Message-ID: <20170412124905.25443-4-aryabinin@virtuozzo.com>
In-Reply-To: <20170412124905.25443-1-aryabinin@virtuozzo.com>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <20170412124905.25443-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, penguin-kernel@I-love.SAKURA.ne.jp, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, thellstrom@vmware.com

vfree() can be used in any atomic context now, thus there is no point
in using vfree_atomic().
This reverts commit 0f110a9b956c ("kernel/fork: use vfree_atomic()
to free thread stack")

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 kernel/fork.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 81347bd..e4baa21 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -259,7 +259,7 @@ static inline void free_thread_stack(struct task_struct *tsk)
 		}
 		local_irq_restore(flags);
 
-		vfree_atomic(tsk->stack);
+		vfree(tsk->stack);
 		return;
 	}
 #endif
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
