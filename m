Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C26B86B0032
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 22:36:28 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so6458467pdj.28
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 19:36:28 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id fo10si62810068pad.106.2014.12.08.19.36.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 19:36:27 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 9 Dec 2014 11:36:17 +0800
Subject: [PATCH] fix build error for vm tools
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313FC@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'acme@redhat.com'" <acme@redhat.com>, "'bp@suse.de'" <bp@suse.de>, "'mingo@kernel.org'" <mingo@kernel.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

This patch fix the build error when make like this:
make O=3D/xx/x vm

use $(OUTPUT) to generate to the right place.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 tools/vm/Makefile | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/tools/vm/Makefile b/tools/vm/Makefile
index 3d907da..28d4bd9 100644
--- a/tools/vm/Makefile
+++ b/tools/vm/Makefile
@@ -1,9 +1,10 @@
 # Makefile for vm tools
 #
+include ../scripts/Makefile.include
 TARGETS=3Dpage-types slabinfo
=20
 LIB_DIR =3D ../lib/api
-LIBS =3D $(LIB_DIR)/libapikfs.a
+LIBS =3D $(OUTPUT)../lib/api/libapikfs.a
=20
 CC =3D $(CROSS_COMPILE)gcc
 CFLAGS =3D -Wall -Wextra -I../lib/
@@ -12,11 +13,11 @@ LDFLAGS =3D $(LIBS)
 $(TARGETS): $(LIBS)
=20
 $(LIBS):
-	make -C $(LIB_DIR)
+	$(call descend,../lib/api libapikfs.a)
=20
 %: %.c
-	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)
+	$(CC) $(CFLAGS) -o $(OUTPUT)$@ $< $(LDFLAGS)
=20
 clean:
-	$(RM) page-types slabinfo
+	$(RM) $(OUTPUT)page-types $(OUTPUT)slabinfo
 	make -C $(LIB_DIR) clean
--=20
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
