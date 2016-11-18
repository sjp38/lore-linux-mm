Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 907706B041C
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e9so251355854pgc.5
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id t15si8202610pgn.14.2016.11.18.05.04.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:29 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/10] mm: warn about vfree from atomic context
Date: Fri, 18 Nov 2016 14:03:53 +0100
Message-Id: <1479474236-4139-8-git-send-email-hch@lst.de>
In-Reply-To: <1479474236-4139-1-git-send-email-hch@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

We can't handle vfree itself from atomic context, but callers
can explicitly use vfree_atomic instead, which defers the actual
vfree to a workqueue.  Unfortunately in_atomic does not work
on non-preemptible kernels, so we can't just do the right thing
by default.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/vmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 80f3fae..e2030b4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1530,6 +1530,7 @@ void vfree_atomic(const void *addr)
 void vfree(const void *addr)
 {
 	BUG_ON(in_nmi());
+	WARN_ON_ONCE(in_atomic());
 
 	kmemleak_free(addr);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
