Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4642A8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 17:15:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g23-v6so2457702qtq.13
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 14:15:36 -0700 (PDT)
Received: from sonic308-3.consmr.mail.bf2.yahoo.com (sonic308-3.consmr.mail.bf2.yahoo.com. [74.6.130.42])
        by mx.google.com with ESMTPS id x194-v6si2006585qkb.211.2018.09.27.14.15.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 14:15:35 -0700 (PDT)
Date: Thu, 27 Sep 2018 17:15:27 -0400
From: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
Subject: [PATCH v2] mm: fix z3fold warnings on CONFIG_SMP=n
References: <1538079759.qxp8zh3nwh.astroid@alex-archsus.none>
	<CALZtONA9r6=gnK-5a++tjaReqEnRzrBb3hzYMTFNXZ13z+UOWQ@mail.gmail.com>
	<153808275043.724.15980761008814866300@pink.alxu.ca>
In-Reply-To: <153808275043.724.15980761008814866300@pink.alxu.ca>
Message-Id: <1538082779.246sm0vb2p.astroid@alex-archsus.none>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Spinlocks are always lockable on UP systems, even if they were just
locked.

Cc: Dan Streetman <ddstreet@ieee.org>
Signed-off-by: Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
---
 mm/z3fold.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 4b366d181..2e8d268ac 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -277,7 +277,7 @@ static void release_z3fold_page_locked(struct kref *ref=
)
 {
 	struct z3fold_header *zhdr =3D container_of(ref, struct z3fold_header,
 						refcount);
-	WARN_ON(z3fold_page_trylock(zhdr));
+	WARN_ON_SMP(z3fold_page_trylock(zhdr));
 	__release_z3fold_page(zhdr, true);
 }
=20
@@ -289,7 +289,7 @@ static void release_z3fold_page_locked_list(struct kref=
 *ref)
 	list_del_init(&zhdr->buddy);
 	spin_unlock(&zhdr->pool->lock);
=20
-	WARN_ON(z3fold_page_trylock(zhdr));
+	WARN_ON_SMP(z3fold_page_trylock(zhdr));
 	__release_z3fold_page(zhdr, true);
 }
=20
@@ -403,7 +403,7 @@ static void do_compact_page(struct z3fold_header *zhdr,=
 bool locked)
=20
 	page =3D virt_to_page(zhdr);
 	if (locked)
-		WARN_ON(z3fold_page_trylock(zhdr));
+		WARN_ON_SMP(z3fold_page_trylock(zhdr));
 	else
 		z3fold_page_lock(zhdr);
 	if (WARN_ON(!test_and_clear_bit(NEEDS_COMPACTING, &page->private))) {
--=20
2.19.0

=
