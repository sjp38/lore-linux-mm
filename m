Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A44476B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 01:18:23 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so8178147pab.41
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 22:18:23 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id sn3si27148405pab.106.2014.09.15.22.18.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 22:18:22 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 16 Sep 2014 13:14:05 +0800
Subject: [RFC resend] arm:change keep_initrd and free_initrd_mem into .init
 section
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB49160F@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Jiang Liu' <jiang.liu@huawei.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Will Deacon' <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

this patch change keep_initrd to __initdata section,
and free_initrd_mem to __init section so that they can be freed by
free_initmem, free_initrd_mem is only called by free_initrd function,
so it's safe to free it after use.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 arch/arm/mm/init.c   | 4 ++--
 arch/arm64/mm/init.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 659c75d..907dee1 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -631,9 +631,9 @@ void free_initmem(void)
=20
 #ifdef CONFIG_BLK_DEV_INITRD
=20
-static int keep_initrd;
+static int __initdata keep_initrd;
=20
-void free_initrd_mem(unsigned long start, unsigned long end)
+void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 5472c24..7268d57 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -330,9 +330,9 @@ void free_initmem(void)
=20
 #ifdef CONFIG_BLK_DEV_INITRD
=20
-static int keep_initrd;
+static int __initdata keep_initrd;
=20
-void free_initrd_mem(unsigned long start, unsigned long end)
+void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd)
 		free_reserved_area((void *)start, (void *)end, 0, "initrd");
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
