Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 52A5D6B0259
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 04:34:34 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l68so53073622wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 01:34:34 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id y91si19393128wmh.107.2016.02.29.01.34.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 01:34:33 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] crypto/async_pq: use __free_page() instead of put_page()
Date: Mon, 29 Feb 2016 10:33:58 +0100
Message-Id: <1456738445-876239-1-git-send-email-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-arm-kernel@lists.infradead.org, Michal Nazarewicz <mina86@mina86.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, "David S. Miller" <davem@davemloft.net>, NeilBrown <neilb@suse.com>, Markus Stockhausen <stockhausen@collogia.de>, Vinod Koul <vinod.koul@intel.com>, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org

The addition of tracepoints to the page reference tracking had an
unfortunate side-effect in at least one driver that calls put_page
from its exit function, resulting in a link error:

`.exit.text' referenced in section `__jump_table' of crypto/built-in.o: defined in discarded section `.exit.text' of crypto/built-in.o

>From a cursory look at that this driver, it seems that it may be
doing the wrong thing here anyway, as the page gets allocated
using 'alloc_page()', and should be freed using '__free_page()'
rather than 'put_page()'.

With this patch, I no longer get any other build errors from the
page_ref patch, so hopefully we can assume that it's always wrong
to call any of those functions from __exit code, and that no other
driver does it.

Fixes: 0f80830dd044 ("mm/page_ref: add tracepoint to track down page reference manipulation")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 crypto/async_tx/async_pq.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/async_tx/async_pq.c b/crypto/async_tx/async_pq.c
index c0748bbd4c08..08b3ac68952b 100644
--- a/crypto/async_tx/async_pq.c
+++ b/crypto/async_tx/async_pq.c
@@ -444,7 +444,7 @@ static int __init async_pq_init(void)
 
 static void __exit async_pq_exit(void)
 {
-	put_page(pq_scribble_page);
+	__free_page(pq_scribble_page);
 }
 
 module_init(async_pq_init);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
