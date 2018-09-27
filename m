Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 02E738E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 16:27:23 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id g133-v6so4160870ioa.12
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:27:22 -0700 (PDT)
Received: from sonic316-21.consmr.mail.ne1.yahoo.com (sonic316-21.consmr.mail.ne1.yahoo.com. [66.163.187.147])
        by mx.google.com with ESMTPS id u26-v6si1632830iog.121.2018.09.27.13.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 13:27:21 -0700 (PDT)
Date: Thu, 27 Sep 2018 16:27:12 -0400
From: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
Subject: [PATCH] mm: fix z3fold warnings on CONFIG_SMP=n
Message-Id: <1538079759.qxp8zh3nwh.astroid@alex-archsus.none>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: ddstreet@ieee.org

Spinlocks are always lockable on UP systems, even if they were just
locked.

Cc: Dan Streetman <ddstreet@ieee.org>
Signed-off-by: Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
---
 mm/z3fold.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 4b366d181..4e6ad2de4 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -202,6 +202,13 @@ static inline void z3fold_page_lock(struct z3fold_head=
er *zhdr)
 	spin_lock(&zhdr->page_lock);
 }
=20
+static inline void z3fold_page_ensure_locked(struct z3fold_header *zhdr)
+{
+#ifdef CONFIG_SMP
+	WARN_ON(z3fold_page_trylock(zhdr));
+#endif
+}
+
 /* Try to lock a z3fold page */
 static inline int z3fold_page_trylock(struct z3fold_header *zhdr)
 {
@@ -277,7 +284,7 @@ static void release_z3fold_page_locked(struct kref *ref=
)
 {
 	struct z3fold_header *zhdr =3D container_of(ref, struct z3fold_header,
 						refcount);
-	WARN_ON(z3fold_page_trylock(zhdr));
+	z3fold_page_ensure_locked(zhdr);
 	__release_z3fold_page(zhdr, true);
 }
=20
@@ -289,7 +296,7 @@ static void release_z3fold_page_locked_list(struct kref=
 *ref)
 	list_del_init(&zhdr->buddy);
 	spin_unlock(&zhdr->pool->lock);
=20
-	WARN_ON(z3fold_page_trylock(zhdr));
+	z3fold_page_ensure_locked(zhdr);
 	__release_z3fold_page(zhdr, true);
 }
=20
@@ -403,7 +410,7 @@ static void do_compact_page(struct z3fold_header *zhdr,=
 bool locked)
=20
 	page =3D virt_to_page(zhdr);
 	if (locked)
-		WARN_ON(z3fold_page_trylock(zhdr));
+		z3fold_page_ensure_locked(zhdr);
 	else
 		z3fold_page_lock(zhdr);
 	if (WARN_ON(!test_and_clear_bit(NEEDS_COMPACTING, &page->private))) {
--=20
2.19.0

=
