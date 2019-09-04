Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B256C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AB6722CF5
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:51:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AB6722CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABCAA6B0003; Wed,  4 Sep 2019 02:51:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A47496B0006; Wed,  4 Sep 2019 02:51:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9348D6B0007; Wed,  4 Sep 2019 02:51:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0021.hostedemail.com [216.40.44.21])
	by kanga.kvack.org (Postfix) with ESMTP id 6CEBB6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:51:46 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 172B3824CA3F
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:51:46 +0000 (UTC)
X-FDA: 75896317812.05.flock68_83a4457826e0e
X-HE-Tag: flock68_83a4457826e0e
X-Filterd-Recvd-Size: 5021
Received: from mailgw02.mediatek.com (unknown [210.61.82.184])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:51:44 +0000 (UTC)
X-UUID: d6949eddd6d848458f0e91f382beab44-20190904
X-UUID: d6949eddd6d848458f0e91f382beab44-20190904
Received: from mtkexhb02.mediatek.inc [(172.21.101.103)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0809 with TLS)
	with ESMTP id 4046662; Wed, 04 Sep 2019 14:51:38 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs08n2.mediatek.inc (172.21.101.56) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Wed, 4 Sep 2019 14:51:35 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Wed, 4 Sep 2019 14:51:35 +0800
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>
CC: <kasan-dev@googlegroups.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>, Walter Wu
	<walter-zh.wu@mediatek.com>
Subject: [PATCH 1/2] mm/kasan: dump alloc/free stack for page allocator
Date: Wed, 4 Sep 2019 14:51:33 +0800
Message-ID: <20190904065133.20268-1-walter-zh.wu@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-TM-SNTS-SMTP:
	E693BB34C42D4B73B3B2B12EEB54C8F30BF059021EA46B52BEF177F393CF9F522000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is KASAN report adds the alloc/free stacks for page allocator
in order to help programmer to see memory corruption caused by page.

By default, KASAN doesn't record alloc/free stack for page allocator.
It is difficult to fix up page use-after-free issue.

This feature depends on page owner to record the last stack of pages.
It is very helpful for solving the page use-after-free or out-of-bound.

KASAN report will show the last stack of page, it may be:
a) If page is in-use state, then it prints alloc stack.
   It is useful to fix up page out-of-bound issue.

BUG: KASAN: slab-out-of-bounds in kmalloc_pagealloc_oob_right+0x88/0x90
Write of size 1 at addr ffffffc0d64ea00a by task cat/115
...
Allocation stack of page:
 prep_new_page+0x1a0/0x1d8
 get_page_from_freelist+0xd78/0x2748
 __alloc_pages_nodemask+0x1d4/0x1978
 kmalloc_order+0x28/0x58
 kmalloc_order_trace+0x28/0xe0
 kmalloc_pagealloc_oob_right+0x2c/0x90

b) If page is freed state, then it prints free stack.
   It is useful to fix up page use-after-free issue.

BUG: KASAN: use-after-free in kmalloc_pagealloc_uaf+0x70/0x80
Write of size 1 at addr ffffffc0d651c000 by task cat/115
...
Free stack of page:
 kasan_free_pages+0x68/0x70
 __free_pages_ok+0x3c0/0x1328
 __free_pages+0x50/0x78
 kfree+0x1c4/0x250
 kmalloc_pagealloc_uaf+0x38/0x80


This has been discussed, please refer below link.
https://bugzilla.kernel.org/show_bug.cgi?id=203967

Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
---
 lib/Kconfig.kasan | 9 +++++++++
 mm/kasan/common.c | 6 ++++++
 2 files changed, 15 insertions(+)

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 4fafba1a923b..ba17f706b5f8 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -135,6 +135,15 @@ config KASAN_S390_4_LEVEL_PAGING
 	  to 3TB of RAM with KASan enabled). This options allows to force
 	  4-level paging instead.
 
+config KASAN_DUMP_PAGE
+	bool "Dump the page last stack information"
+	depends on KASAN && PAGE_OWNER
+	help
+	  By default, KASAN doesn't record alloc/free stack for page allocator.
+	  It is difficult to fix up page use-after-free issue.
+	  This feature depends on page owner to record the last stack of page.
+	  It is very helpful for solving the page use-after-free or out-of-bound.
+
 config TEST_KASAN
 	tristate "Module for testing KASAN for bug detection"
 	depends on m && KASAN
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 2277b82902d8..2a32474efa74 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -35,6 +35,7 @@
 #include <linux/vmalloc.h>
 #include <linux/bug.h>
 #include <linux/uaccess.h>
+#include <linux/page_owner.h>
 
 #include "kasan.h"
 #include "../slab.h"
@@ -227,6 +228,11 @@ void kasan_alloc_pages(struct page *page, unsigned int order)
 
 void kasan_free_pages(struct page *page, unsigned int order)
 {
+#ifdef CONFIG_KASAN_DUMP_PAGE
+	gfp_t gfp_flags = GFP_KERNEL;
+
+	set_page_owner(page, order, gfp_flags);
+#endif
 	if (likely(!PageHighMem(page)))
 		kasan_poison_shadow(page_address(page),
 				PAGE_SIZE << order,
-- 
2.18.0


