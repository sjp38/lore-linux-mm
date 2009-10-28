Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2FA986B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:56:38 -0400 (EDT)
Subject: [PATCH 2/2] Fix debug_kmap_atomic() to also handle KM_IRQ_PTE, KM_NMI, and KM_NMI_PTE
References: <ye84opj9zgs.fsf@camel23.daimi.au.dk>
From: Soeren Sandmann <sandmann@daimi.au.dk>
Date: 28 Oct 2009 18:56:35 +0100
In-Reply-To: <ye84opj9zgs.fsf@camel23.daimi.au.dk>
Message-ID: <ye8vdhz8krw.fsf@camel23.daimi.au.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Previously calling debug_kmap_atomic() with these types would cause
spurious warnings.

Signed-off-by: S=C3=B8ren Sandmann Pedersen <sandmann@redhat.com>
---
 mm/highmem.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 33587de..9c1e627 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -432,10 +432,15 @@ void debug_kmap_atomic(enum km_type type)
 		return;
=20
 	if (unlikely(in_interrupt())) {
-		if (in_irq()) {
+		if (in_nmi()) {
+			if (type !=3D KM_NMI && type !=3D KM_NMI_PTE) {
+				WARN_ON(1);
+				warn_count--;
+			}
+		} else if (in_irq()) {
 			if (type !=3D KM_IRQ0 && type !=3D KM_IRQ1 &&
 			    type !=3D KM_BIO_SRC_IRQ && type !=3D KM_BIO_DST_IRQ &&
-			    type !=3D KM_BOUNCE_READ) {
+			    type !=3D KM_BOUNCE_READ && type !=3D KM_IRQ_PTE) {
 				WARN_ON(1);
 				warn_count--;
 			}
@@ -452,7 +457,9 @@ void debug_kmap_atomic(enum km_type type)
 	}
=20
 	if (type =3D=3D KM_IRQ0 || type =3D=3D KM_IRQ1 || type =3D=3D KM_BOUNCE_R=
EAD ||
-			type =3D=3D KM_BIO_SRC_IRQ || type =3D=3D KM_BIO_DST_IRQ) {
+			type =3D=3D KM_BIO_SRC_IRQ || type =3D=3D KM_BIO_DST_IRQ ||
+			type =3D=3D KM_IRQ_PTE || type =3D=3D KM_NMI ||
+			type =3D=3D KM_NMI_PTE ) {
 		if (!irqs_disabled()) {
 			WARN_ON(1);
 			warn_count--;
--=20
1.6.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
