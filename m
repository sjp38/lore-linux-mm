Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 546226B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 01:39:34 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so6737207pde.29
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 22:39:34 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id x3si458534pdm.53.2014.12.08.22.39.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 22:39:31 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 9 Dec 2014 14:39:23 +0800
Subject: [PATCH V3] fix build error for vm tools
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313FF@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313FC@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E688B313FD@CNBJMBX05.corpusers.net>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313FD@CNBJMBX05.corpusers.net>
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
 tools/lib/api/Makefile |  2 +-
 tools/vm/Makefile      | 14 +++++++++-----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/tools/lib/api/Makefile b/tools/lib/api/Makefile
index 36c08b1..a1c598d 100644
--- a/tools/lib/api/Makefile
+++ b/tools/lib/api/Makefile
@@ -44,6 +44,6 @@ $(OUTPUT)%.o: %.S libapi_dirs
 	$(QUIET_CC)$(CC) -o $@ -c $(ALL_CFLAGS) $<
=20
 clean:
-	$(call QUIET_CLEAN, libapi) $(RM) $(LIB_OBJS) $(LIBFILE)
+	$(call QUIET_CLEAN, libapi) $(RM) $(LIB_OBJS) $(OUTPUT)$(LIBFILE)
=20
 .PHONY: clean
diff --git a/tools/vm/Makefile b/tools/vm/Makefile
index 3d907da..7e3fc9f 100644
--- a/tools/vm/Makefile
+++ b/tools/vm/Makefile
@@ -1,22 +1,26 @@
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
-	make -C $(LIB_DIR) clean
+	$(RM) $(OUTPUT)page-types $(OUTPUT)slabinfo
+	$(call descend,../lib/api clean)
+
+.PHONY: all clean
--=20
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
