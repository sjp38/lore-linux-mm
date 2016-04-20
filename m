Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E83D6B026E
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 06:53:43 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id wy10so7888805lbb.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 03:53:43 -0700 (PDT)
Received: from fnsib-smtp07.srv.cat (fnsib-smtp07.srv.cat. [46.16.61.67])
        by mx.google.com with ESMTPS id w2si9372091wma.29.2016.04.20.03.53.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 03:53:41 -0700 (PDT)
Received: from vostok.local (cliente152.wlan.uam.es [150.244.199.152])
	by fnsib-smtp07.srv.cat (Postfix) with ESMTPA id 3FC34811F
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 12:53:39 +0200 (CEST)
Date: Wed, 20 Apr 2016 12:53:33 +0200
From: =?utf-8?Q?Guillermo_Juli=C3=A1n_Moreno?=
 <guillermo.julian@naudit.es>
Message-ID: <etPan.57175fb3.7a271c6b.2bd@naudit.es>
Subject: [PATCH] mm: fix overflow in vm_map_ram
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


When remapping pages accounting for 4G or more memory space, the
operation 'count << PAGE=5FSHI=46T' overflows as it is performed on an
integer. Solution: cast before doing the bitshift.

Signed-off-by: Guillermo Juli=C3=A1n <guillermo.julian=40naudit.es>
---
mm/vmalloc.c =7C 4 ++--
1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c =20
index ae7d20b..97257e4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
=40=40 -1114,7 +1114,7 =40=40 EXPORT=5FSYMBOL(vm=5Funmap=5Fram);
*/
void *vm=5Fmap=5Fram(struct page **pages, unsigned int count, int node, p=
gprot=5Ft prot)
=7B
- unsigned long size =3D count << PAGE=5FSHI=46T;
+ unsigned long size =3D ((unsigned long) count) << PAGE=5FSHI=46T;
unsigned long addr;
void *mem;

=40=40 -1484,7 +1484,7 =40=40 static void =5F=5Fvunmap(const void *addr, =
int deallocate=5Fpages) =20
kfree(area);
return;
=7D
-
+
/**
* vfree - release memory allocated by vmalloc()
* =40addr: memory base address
--
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
