Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id B65F06B007B
	for <linux-mm@kvack.org>; Thu,  7 May 2015 00:12:33 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so15375739qge.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 21:12:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a78si856574qka.120.2015.05.06.21.12.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 21:12:33 -0700 (PDT)
Subject: [PATCH 10/10] bnx2x,
 tg3: Replace put_page(virt_to_head_page()) with skb_free_frag()
From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 06 May 2015 21:12:31 -0700
Message-ID: <20150507041231.1873.76848.stgit@ahduyck-vm-fedora22>
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/ethernet/broadcom/tg3.c             |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a8bb8f664d3d..b10d1744e5ae 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -662,7 +662,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 static void bnx2x_frag_free(const struct bnx2x_fastpath *fp, void *data)
 {
 	if (fp->rx_frag_size)
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 	else
 		kfree(data);
 }
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 069952fa5d64..73c934cf6c61 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6618,7 +6618,7 @@ static void tg3_tx(struct tg3_napi *tnapi)
 static void tg3_frag_free(bool is_frag, void *data)
 {
 	if (is_frag)
-		put_page(virt_to_head_page(data));
+		skb_free_frag(data);
 	else
 		kfree(data);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
