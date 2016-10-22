Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C70D66B0261
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 11:17:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r16so79707291pfg.4
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 08:17:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id qj8si6126311pac.114.2016.10.22.08.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Oct 2016 08:17:35 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 4/7] mm: defer vmalloc from atomic context
Date: Sat, 22 Oct 2016 17:17:17 +0200
Message-Id: <1477149440-12478-5-git-send-email-hch@lst.de>
In-Reply-To: <1477149440-12478-1-git-send-email-hch@lst.de>
References: <1477149440-12478-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

We want to be able to use a sleeping lock for freeing vmap to keep
latency down.  For this we need to use the deferred vfree mechanisms
no only from interrupt, but from any atomic context.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a4e2cec..bcc1a64 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1509,7 +1509,7 @@ void vfree(const void *addr)
 
 	if (!addr)
 		return;
-	if (unlikely(in_interrupt())) {
+	if (unlikely(in_atomic())) {
 		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
 		if (llist_add((struct llist_node *)addr, &p->list))
 			schedule_work(&p->wq);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
