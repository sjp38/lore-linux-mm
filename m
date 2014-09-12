Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id D1F576B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 06:12:18 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so938158pad.7
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 03:12:18 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id j3si7046129pbw.2.2014.09.12.03.12.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 03:12:17 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 12 Sep 2014 18:05:04 +0800
Subject: [PATCH] arm:free_initrd_mem should also free the memblock
Message-ID: <35FD53F367049845BC99AC72306C23D103CDBFBFB028@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>, "'linux@arm.linux.org.uk'" <linux@arm.linux.org.uk>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>

this patch fix the memblock statics for memblock
in file /sys/kernel/debug/memblock/reserved
if we don't call memblock_free the initrd will still
be marked as reserved, even they are freed.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 arch/arm/mm/init.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 659c75d..7bc8e5b 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -638,6 +638,7 @@ void free_initrd_mem(unsigned long start, unsigned long=
 end)
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
 		free_reserved_area((void *)start, (void *)end, -1, "initrd");
+		memblock_free(__pa(start), end - start);
 	}
 }
=20
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
