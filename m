Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3E939828DF
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:09:03 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id a140so7989134wma.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:09:03 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h128si17830001wmf.4.2016.04.11.04.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:08:39 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id l6so20397534wml.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:39 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 18/19] crypto: get rid of superfluous __GFP_REPEAT
Date: Mon, 11 Apr 2016 13:08:11 +0200
Message-Id: <1460372892-8157-19-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
References: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations.

lzo_init uses __GFP_REPEAT to allocate LZO1X_MEM_COMPRESS 16K. This is
order 3 allocation request and __GFP_REPEAT is ignored for this size
as well as all <= PAGE_ALLOC_COSTLY requests.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 crypto/lzo.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/lzo.c b/crypto/lzo.c
index 4b3e92525dac..c3f3dd9a28c5 100644
--- a/crypto/lzo.c
+++ b/crypto/lzo.c
@@ -32,7 +32,7 @@ static int lzo_init(struct crypto_tfm *tfm)
 	struct lzo_ctx *ctx = crypto_tfm_ctx(tfm);
 
 	ctx->lzo_comp_mem = kmalloc(LZO1X_MEM_COMPRESS,
-				    GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+				    GFP_KERNEL | __GFP_NOWARN);
 	if (!ctx->lzo_comp_mem)
 		ctx->lzo_comp_mem = vmalloc(LZO1X_MEM_COMPRESS);
 	if (!ctx->lzo_comp_mem)
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
