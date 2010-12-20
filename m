Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 47D666B008C
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 12:03:22 -0500 (EST)
Received: from business-088-079-120-127.static.arcor-ip.net ([::ffff:88.79.120.127] HELO eb-work1.ma.silicon-software.de) (auth=eike@sf-mail.de)
	by mail.sf-mail.de (Qsmtpd 0.16) with (DHE-RSA-AES256-SHA encrypted) ESMTPSA
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 18:03:09 +0100
From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Take lock only once in dma_pool_free()
Date: Mon, 20 Dec 2010 18:03:06 +0100
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201012201803.06873.eike-kernel@sf-tec.de>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

=46rom 0db01c2ea9476609c399de3e9fdf7861df07d2f1 Mon Sep 17 00:00:00 2001
=46rom: Rolf Eike Beer <eike-kernel@sf-tec.de>
Date: Mon, 20 Dec 2010 17:29:33 +0100
Subject: [PATCH] Speed up dma_pool_free()

dma_pool_free() scans for the page to free in the pool list holding the pool
lock. Then it releases the lock basically to acquire it immediately again.
Modify the code to only take the lock once.

This will do some additional loops and computations with the lock held in i=
f=20
memory debugging is activated. If it is not activated the only new operatio=
ns=20
with this lock is one if and one substraction.

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
=2D--
 mm/dmapool.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 4df2de7..a2f6295 100644
=2D-- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -355,20 +355,15 @@ EXPORT_SYMBOL(dma_pool_alloc);
=20
 static struct dma_page *pool_find_page(struct dma_pool *pool, dma_addr_t d=
ma)
 {
=2D	unsigned long flags;
 	struct dma_page *page;
=20
=2D	spin_lock_irqsave(&pool->lock, flags);
 	list_for_each_entry(page, &pool->page_list, page_list) {
 		if (dma < page->dma)
 			continue;
 		if (dma < (page->dma + pool->allocation))
=2D			goto done;
+			return page;
 	}
=2D	page =3D NULL;
=2D done:
=2D	spin_unlock_irqrestore(&pool->lock, flags);
=2D	return page;
+	return NULL;
 }
=20
 /**
@@ -386,8 +381,10 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr,=
=20
dma_addr_t dma)
 	unsigned long flags;
 	unsigned int offset;
=20
+	spin_lock_irqsave(&pool->lock, flags);
 	page =3D pool_find_page(pool, dma);
 	if (!page) {
+		spin_unlock_irqrestore(&pool->lock, flags);
 		if (pool->dev)
 			dev_err(pool->dev,
 				"dma_pool_free %s, %p/%lx (bad dma)\n",
@@ -401,6 +398,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr,=
=20
dma_addr_t dma)
 	offset =3D vaddr - page->vaddr;
 #ifdef	DMAPOOL_DEBUG
 	if ((dma - page->dma) !=3D offset) {
+		spin_unlock_irqrestore(&pool->lock, flags);
 		if (pool->dev)
 			dev_err(pool->dev,
 				"dma_pool_free %s, %p (bad vaddr)/%Lx\n",
@@ -418,6 +416,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr,=
=20
dma_addr_t dma)
 				chain =3D *(int *)(page->vaddr + chain);
 				continue;
 			}
+			spin_unlock_irqrestore(&pool->lock, flags);
 			if (pool->dev)
 				dev_err(pool->dev, "dma_pool_free %s, dma %Lx "
 					"already free\n", pool->name,
@@ -432,7 +431,6 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr,=
=20
dma_addr_t dma)
 	memset(vaddr, POOL_POISON_FREED, pool->size);
 #endif
=20
=2D	spin_lock_irqsave(&pool->lock, flags);
 	page->in_use--;
 	*(int *)vaddr =3D page->offset;
 	page->offset =3D offset;
=2D-=20
1.6.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
