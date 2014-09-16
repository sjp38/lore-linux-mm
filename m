Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 25F3B6B0038
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 21:38:13 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so7650843pab.33
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:38:12 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id o2si26415146pdh.86.2014.09.15.18.38.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 18:38:12 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 16 Sep 2014 09:34:49 +0800
Subject: [RFC v3] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB49160A@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>

this patch extend the start and end address of initrd to be page aligned,
so that we can free all memory including the un-page aligned head or tail
page of initrd, if the start or end address of initrd are not page
aligned, the page can't be freed by free_initrd_mem() function.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 arch/arm/mm/init.c   | 5 +++++
 arch/arm64/mm/init.c | 8 +++++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 659c75d..9221645 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -636,6 +636,11 @@ static int keep_initrd;
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
+		if (start =3D=3D initrd_start)
+			start =3D round_down(start, PAGE_SIZE);
+		if (end =3D=3D initrd_end)
+			end =3D round_up(end, PAGE_SIZE);
+
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
 		free_reserved_area((void *)start, (void *)end, -1, "initrd");
 	}
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 5472c24..c5512f6 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -334,8 +334,14 @@ static int keep_initrd;
=20
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	if (!keep_initrd)
+	if (!keep_initrd) {
+		if (start =3D=3D initrd_start)
+			start =3D round_down(start, PAGE_SIZE);
+		if (end =3D=3D initrd_end)
+			end =3D round_up(end, PAGE_SIZE);
+
 		free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	}
 }
=20
 static int __init keepinitrd_setup(char *__unused)
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
