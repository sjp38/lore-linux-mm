Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4CC156B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:55:38 -0400 (EDT)
Subject: [PATCH 1/2] Fix race in debug_kmap_atomic() which could cause warn_count to underflow
References: <ye84opj9zgs.fsf@camel23.daimi.au.dk>
From: Soeren Sandmann <sandmann@daimi.au.dk>
Date: 28 Oct 2009 18:55:36 +0100
In-Reply-To: <ye84opj9zgs.fsf@camel23.daimi.au.dk>
Message-ID: <ye8zl7b8ktj.fsf@camel23.daimi.au.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

debug_kmap_atomic() tries to prevent ever printing more than 10
warnings, but it does so by testing whether an unsigned integer is
equal to 0. However, if the warning is caused by a nested IRQ, then
this counter may underflow and the stream of warnings will never end.

Fix that by using a signed integer instead.

Signed-off-by: S=C3=B8ren Sandmann Pedersen <sandmann@redhat.com>
---
 mm/highmem.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 25878cc..33587de 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -426,9 +426,9 @@ void __init page_address_init(void)
=20
 void debug_kmap_atomic(enum km_type type)
 {
-	static unsigned warn_count =3D 10;
+	static int warn_count =3D 10;
=20
-	if (unlikely(warn_count =3D=3D 0))
+	if (unlikely(warn_count < 0))
 		return;
=20
 	if (unlikely(in_interrupt())) {
--=20
1.6.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
