Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B9A636B0256
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:16:01 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so16950811wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:16:01 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id t11si4317490wib.37.2015.09.25.05.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Sep 2015 05:15:57 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
Subject: [PATCH 3/4] dma-debug: Check nents in dma_sync_sg*
Date: Fri, 25 Sep 2015 13:15:45 +0100
Message-Id: <c725a1746c556d8aa532a53a5f30bb2005a9ddae.1443178314.git.robin.murphy@arm.com>
In-Reply-To: <cover.1443178314.git.robin.murphy@arm.com>
References: <cover.1443178314.git.robin.murphy@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Cc: arnd@arndb.de, m.szyprowski@samsung.com, sumit.semwal@linaro.org, sakari.ailus@iki.fi, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

Like dma_unmap_sg, dma_sync_sg* should be called with the original
number of entries passed to dma_map_sg, so do the same check in the sync
path as we do in the unmap path.

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---
 lib/dma-debug.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/lib/dma-debug.c b/lib/dma-debug.c
index dace71f..908fb35 100644
--- a/lib/dma-debug.c
+++ b/lib/dma-debug.c
@@ -1249,6 +1249,14 @@ static void check_sync(struct device *dev,
 =09=09=09=09dir2name[entry->direction],
 =09=09=09=09dir2name[ref->direction]);
=20
+=09if (ref->sg_call_ents && ref->type =3D=3D dma_debug_sg &&
+=09    ref->sg_call_ents !=3D entry->sg_call_ents) {
+=09=09err_printk(ref->dev, entry, "DMA-API: device driver syncs "
+=09=09=09   "DMA sg list with different entry count "
+=09=09=09   "[map count=3D%d] [sync count=3D%d]\n",
+=09=09=09   entry->sg_call_ents, ref->sg_call_ents);
+=09}
+
 out:
 =09put_hash_bucket(bucket, &flags);
 }
--=20
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
