Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C1F196B041A
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:24 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f188so248522946pgc.1
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:24 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id u75si8198979pfa.86.2016.11.18.05.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:24 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 06/10] x86/ldt: use vfree_atomic() to free ldt entries
Date: Fri, 18 Nov 2016 14:03:52 +0100
Message-Id: <1479474236-4139-7-git-send-email-hch@lst.de>
In-Reply-To: <1479474236-4139-1-git-send-email-hch@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

From: Andrey Ryabinin <aryabinin@virtuozzo.com>

vfree() is going to use sleeping lock. free_ldt_struct()
may be called with disabled preemption, therefore we must
use vfree_atomic() here.

E.g. call trace:
	vfree()
	free_ldt_struct()
	destroy_context_ldt()
	__mmdrop()
	finish_task_switch()
	schedule_tail()
	ret_from_fork()

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 arch/x86/kernel/ldt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kernel/ldt.c b/arch/x86/kernel/ldt.c
index 6707039..4d12cdf 100644
--- a/arch/x86/kernel/ldt.c
+++ b/arch/x86/kernel/ldt.c
@@ -93,7 +93,7 @@ static void free_ldt_struct(struct ldt_struct *ldt)
 
 	paravirt_free_ldt(ldt->entries, ldt->size);
 	if (ldt->size * LDT_ENTRY_SIZE > PAGE_SIZE)
-		vfree(ldt->entries);
+		vfree_atomic(ldt->entries);
 	else
 		free_page((unsigned long)ldt->entries);
 	kfree(ldt);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
