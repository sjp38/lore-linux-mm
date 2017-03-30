Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3446B039F
	for <linux-mm@kvack.org>; Thu, 30 Mar 2017 06:26:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id x125so41040415pgb.5
        for <linux-mm@kvack.org>; Thu, 30 Mar 2017 03:26:17 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0095.outbound.protection.outlook.com. [104.47.2.95])
        by mx.google.com with ESMTPS id t8si1756743pfg.364.2017.03.30.03.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Mar 2017 03:26:16 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 2/4] x86/ldt: use vfree() instead of vfree_atomic()
Date: Thu, 30 Mar 2017 13:27:17 +0300
Message-ID: <20170330102719.13119-2-aryabinin@virtuozzo.com>
In-Reply-To: <20170330102719.13119-1-aryabinin@virtuozzo.com>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, mhocko@kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de

vfree() can be used in any atomic context now, thus there is no point
in vfree_atomic().
This reverts commit 8d5341a6260a ("x86/ldt: use vfree_atomic()
to free ldt entries")

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 arch/x86/kernel/ldt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index d4a1583..f09df2f 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -93,7 +93,7 @@ static void free_ldt_struct(struct ldt_struct *ldt)
 
 	paravirt_free_ldt(ldt->entries, ldt->size);
 	if (ldt->size * LDT_ENTRY_SIZE > PAGE_SIZE)
-		vfree_atomic(ldt->entries);
+		vfree(ldt->entries);
 	else
 		free_page((unsigned long)ldt->entries);
 	kfree(ldt);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
