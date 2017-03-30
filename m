Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E89D6B039F
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 06:26:19 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u3so40422121pgn.12
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:26:19 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0136.outbound.protection.outlook.com. [104.47.2.136])
        by mx.google.com with ESMTPS id x3si1757918pfk.290.2017.03.30.03.26.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 03:26:18 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 3/4] kernel/fork: use vfree() instead of vfree_atomic() to free thread stack
Date: Thu, 30 Mar 2017 13:27:18 +0300
Message-ID: <20170330102719.13119-3-aryabinin@virtuozzo.com>
In-Reply-To: <20170330102719.13119-1-aryabinin@virtuozzo.com>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de

vfree() can be used in any atomic context now, thus there is no point
in using vfree_atomic().
This reverts commit 0f110a9b956c ("kernel/fork: use vfree_atomic()
to free thread stack")

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 kernel/fork.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index a9f642d..084e6a4 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -241,7 +241,7 @@ static inline void free_thread_stack(struct task_struct *tsk)
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
