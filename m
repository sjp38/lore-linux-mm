Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D15AC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AED6120872
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 10:31:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gaM1Wphg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AED6120872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D8A46B0270; Tue, 10 Sep 2019 06:31:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5895F6B0271; Tue, 10 Sep 2019 06:31:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4511D6B0272; Tue, 10 Sep 2019 06:31:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0246.hostedemail.com [216.40.44.246])
	by kanga.kvack.org (Postfix) with ESMTP id 235986B0270
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 06:31:47 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 853A98243768
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:31:46 +0000 (UTC)
X-FDA: 75918645012.13.slip23_499ea27b85e45
X-HE-Tag: slip23_499ea27b85e45
X-Filterd-Recvd-Size: 8881
Received: from mail-lj1-f194.google.com (mail-lj1-f194.google.com [209.85.208.194])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 10:31:45 +0000 (UTC)
Received: by mail-lj1-f194.google.com with SMTP id a4so15856123ljk.8
        for <linux-mm@kvack.org>; Tue, 10 Sep 2019 03:31:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=x0YgKmdVtumN8tvDl4QalfpDpMB5gNsbs7jNvv+lUoo=;
        b=gaM1WphgA3BYhyQ3v2TEVs/84kZ3SRr/EFx6UBDMAK2XgnVFpWeEjEJ862aNXmdqX+
         dQUMj1mCe2LtTH/gsVlXkse22+SQO5olU/+1krJhRdIr3m0aYomsgIaAUYD8d0qe+47z
         W94Xx0kuTUV1dUo/HIOoaUMtKPIZBOeEfxQFkA+JFrnigXIzS88yC7viA2cNjUaaxbLu
         CSBl6IfY5g9k/ttH8CRbpqWgLMLTux6c/sp+7d3m3wIEQ8GeIc42d5BkhdzSv9p0v0qb
         /NNZJWLGK+CV9BOczlqpIH8edaw8bWg/Pt/GIpChdu3n6IUbt4l1prNwJHlUaW0vm7ha
         XQUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:mime-version
         :content-transfer-encoding;
        bh=x0YgKmdVtumN8tvDl4QalfpDpMB5gNsbs7jNvv+lUoo=;
        b=i5GNQq0i8qiee5VmKgkuDteGgnCzwqg7pmVc/m799EXfcRgirraS/u9xdgtTaTjWNE
         /PqJ9vLwWCW1TYnqeK+3sNc+poahAD1FM3r0xsdTjYKDHBNvQ+xuWtIpAi8L+6k2uV3D
         ifczZs7/zcN3ODIXHimJtK9e9NwsDhPyLEeYTUaCsP0SUjMB5mZwoleagJ0PmAoiYgdB
         GlI90o1bbmzVwNkGQD62tQgYcdUZnBnYMZ7j6y65J8nzdLtR1GFV3hl84TnHgn499WJh
         5k2Q2x6OrpnIRJqp7C/wu4TzeaRKSz8SnCR/Hiw59JID2l+P4zRVZyRYhX194v2sXBBy
         D/ow==
X-Gm-Message-State: APjAAAW0VHe1MzjY/GY1Oud9hU4DXkgwzSmItMo7//XPYzgJ68QPSorq
	x463l8CIBU0LZuKitLSMlcvcmHAkQ21d2A==
X-Google-Smtp-Source: APXvYqyE6++B1h1BdnFoXxDSPjLEOcnaW38D6HkTmwvK3nhegfJ4gTgtUvHdKO5Gg7mBbDMyrnPXdA==
X-Received: by 2002:a2e:86c5:: with SMTP id n5mr12600118ljj.153.1568111503915;
        Tue, 10 Sep 2019 03:31:43 -0700 (PDT)
Received: from seldlx21914.corpusers.net ([37.139.156.40])
        by smtp.gmail.com with ESMTPSA id q11sm244474ljc.27.2019.09.10.03.31.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Sep 2019 03:31:43 -0700 (PDT)
Date: Tue, 10 Sep 2019 12:31:42 +0200
From: Vitaly Wool <vitalywool@gmail.com>
To: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, =?ISO-8859-1?Q?Agust=EDn?=
 Dall'Alba <agustin@dallalba.com.ar>, Henry Burns
 <henrywolfeburns@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] Revert
 "mm/z3fold.c: fix race between migration and destruction"
Message-Id: <20190910123142.7a9c8d2de4d0acbc0977c602@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.30; x86_64-unknown-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With the original commit applied, z3fold_zpool_destroy() may
get blocked on wait_event() for indefinite time. Revert this
commit for the time being to get rid of this problem since the
issue the original commit addresses is less severe.

This reverts commit d776aaa9895eb6eb770908e899cb7f5bd5025b3c.

Reported-by: Agust=EDn Dall'Alba <agustin@dallalba.com.ar>
Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 90 -----------------------------------------------------
 1 file changed, 90 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 75b7962439ff..ed19d98c9dcd 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -41,7 +41,6 @@
 #include <linux/workqueue.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
-#include <linux/wait.h>
 #include <linux/zpool.h>
 #include <linux/magic.h>
=20
@@ -146,8 +145,6 @@ struct z3fold_header {
  * @release_wq:	workqueue for safe page release
  * @work:	work_struct for safe page release
  * @inode:	inode for z3fold pseudo filesystem
- * @destroying: bool to stop migration once we start destruction
- * @isolated: int to count the number of pages currently in isolation
  *
  * This structure is allocated at pool creation time and maintains metadata
  * pertaining to a particular z3fold pool.
@@ -166,11 +163,8 @@ struct z3fold_pool {
 	const struct zpool_ops *zpool_ops;
 	struct workqueue_struct *compact_wq;
 	struct workqueue_struct *release_wq;
-	struct wait_queue_head isolate_wait;
 	struct work_struct work;
 	struct inode *inode;
-	bool destroying;
-	int isolated;
 };
=20
 /*
@@ -775,7 +769,6 @@ static struct z3fold_pool *z3fold_create_pool(const cha=
r *name, gfp_t gfp,
 		goto out_c;
 	spin_lock_init(&pool->lock);
 	spin_lock_init(&pool->stale_lock);
-	init_waitqueue_head(&pool->isolate_wait);
 	pool->unbuddied =3D __alloc_percpu(sizeof(struct list_head)*NCHUNKS, 2);
 	if (!pool->unbuddied)
 		goto out_pool;
@@ -815,15 +808,6 @@ static struct z3fold_pool *z3fold_create_pool(const ch=
ar *name, gfp_t gfp,
 	return NULL;
 }
=20
-static bool pool_isolated_are_drained(struct z3fold_pool *pool)
-{
-	bool ret;
-
-	spin_lock(&pool->lock);
-	ret =3D pool->isolated =3D=3D 0;
-	spin_unlock(&pool->lock);
-	return ret;
-}
 /**
  * z3fold_destroy_pool() - destroys an existing z3fold pool
  * @pool:	the z3fold pool to be destroyed
@@ -833,22 +817,6 @@ static bool pool_isolated_are_drained(struct z3fold_po=
ol *pool)
 static void z3fold_destroy_pool(struct z3fold_pool *pool)
 {
 	kmem_cache_destroy(pool->c_handle);
-	/*
-	 * We set pool-> destroying under lock to ensure that
-	 * z3fold_page_isolate() sees any changes to destroying. This way we
-	 * avoid the need for any memory barriers.
-	 */
-
-	spin_lock(&pool->lock);
-	pool->destroying =3D true;
-	spin_unlock(&pool->lock);
-
-	/*
-	 * We need to ensure that no pages are being migrated while we destroy
-	 * these workqueues, as migration can queue work on either of the
-	 * workqueues.
-	 */
-	wait_event(pool->isolate_wait, !pool_isolated_are_drained(pool));
=20
 	/*
 	 * We need to destroy pool->compact_wq before pool->release_wq,
@@ -1339,28 +1307,6 @@ static u64 z3fold_get_pool_size(struct z3fold_pool *=
pool)
 	return atomic64_read(&pool->pages_nr);
 }
=20
-/*
- * z3fold_dec_isolated() expects to be called while pool->lock is held.
- */
-static void z3fold_dec_isolated(struct z3fold_pool *pool)
-{
-	assert_spin_locked(&pool->lock);
-	VM_BUG_ON(pool->isolated <=3D 0);
-	pool->isolated--;
-
-	/*
-	 * If we have no more isolated pages, we have to see if
-	 * z3fold_destroy_pool() is waiting for a signal.
-	 */
-	if (pool->isolated =3D=3D 0 && waitqueue_active(&pool->isolate_wait))
-		wake_up_all(&pool->isolate_wait);
-}
-
-static void z3fold_inc_isolated(struct z3fold_pool *pool)
-{
-	pool->isolated++;
-}
-
 static bool z3fold_page_isolate(struct page *page, isolate_mode_t mode)
 {
 	struct z3fold_header *zhdr;
@@ -1387,34 +1333,6 @@ static bool z3fold_page_isolate(struct page *page, i=
solate_mode_t mode)
 		spin_lock(&pool->lock);
 		if (!list_empty(&page->lru))
 			list_del(&page->lru);
-		/*
-		 * We need to check for destruction while holding pool->lock, as
-		 * otherwise destruction could see 0 isolated pages, and
-		 * proceed.
-		 */
-		if (unlikely(pool->destroying)) {
-			spin_unlock(&pool->lock);
-			/*
-			 * If this page isn't stale, somebody else holds a
-			 * reference to it. Let't drop our refcount so that they
-			 * can call the release logic.
-			 */
-			if (unlikely(kref_put(&zhdr->refcount,
-					      release_z3fold_page_locked))) {
-				/*
-				 * If we get here we have kref problems, so we
-				 * should freak out.
-				 */
-				WARN(1, "Z3fold is experiencing kref problems\n");
-				z3fold_page_unlock(zhdr);
-				return false;
-			}
-			z3fold_page_unlock(zhdr);
-			return false;
-		}
-
-
-		z3fold_inc_isolated(pool);
 		spin_unlock(&pool->lock);
 		z3fold_page_unlock(zhdr);
 		return true;
@@ -1483,10 +1401,6 @@ static int z3fold_page_migrate(struct address_space =
*mapping, struct page *newpa
=20
 	queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
=20
-	spin_lock(&pool->lock);
-	z3fold_dec_isolated(pool);
-	spin_unlock(&pool->lock);
-
 	page_mapcount_reset(page);
 	put_page(page);
 	return 0;
@@ -1506,14 +1420,10 @@ static void z3fold_page_putback(struct page *page)
 	INIT_LIST_HEAD(&page->lru);
 	if (kref_put(&zhdr->refcount, release_z3fold_page_locked)) {
 		atomic64_dec(&pool->pages_nr);
-		spin_lock(&pool->lock);
-		z3fold_dec_isolated(pool);
-		spin_unlock(&pool->lock);
 		return;
 	}
 	spin_lock(&pool->lock);
 	list_add(&page->lru, &pool->lru);
-	z3fold_dec_isolated(pool);
 	spin_unlock(&pool->lock);
 	z3fold_page_unlock(zhdr);
 }
--=20
2.17.1

