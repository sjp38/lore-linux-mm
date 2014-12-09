Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5A92F6B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 00:23:47 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lj1so6696838pab.4
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 21:23:47 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id pm2si75435pac.169.2014.12.08.21.23.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 21:23:45 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 9 Dec 2014 13:23:27 +0800
Subject: [PATCH V2] fix build error for vm tools
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313FD@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313FC@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313FC@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'acme@redhat.com'" <acme@redhat.com>, "'bp@suse.de'" <bp@suse.de>, "'mingo@kernel.org'" <mingo@kernel.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

This patch fix the build error when make like this:
make O=3D/xx/x vm

use $(OUTPUT) to generate to the right place.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 tools/vm/Makefile | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/vm/Makefile b/tools/vm/Makefile
index 3d907da..2847345 100644
--- a/tools/vm/Makefile
+++ b/tools/vm/Makefile
@@ -1,22 +1,24 @@
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
 LDFLAGS =3D $(LIBS)
=20
+all: $(TARGETS)
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
