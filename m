Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 792E4C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 13:02:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4579A206A1
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 13:02:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4579A206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D18B16B0006; Wed, 11 Sep 2019 09:02:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC82F6B0008; Wed, 11 Sep 2019 09:02:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB8A66B000A; Wed, 11 Sep 2019 09:02:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0102.hostedemail.com [216.40.44.102])
	by kanga.kvack.org (Postfix) with ESMTP id 998686B0006
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 09:02:31 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E146EA2A7
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 13:02:30 +0000 (UTC)
X-FDA: 75922653660.28.8112565
Received: from filter.hostedemail.com (10.5.16.251.rfc1918.com [10.5.16.251])
	by smtpin28.hostedemail.com (Postfix) with ESMTP id 7F44221245
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 13:02:08 +0000 (UTC)
X-HE-Tag: drop27_86daf2f4fad0b
X-Filterd-Recvd-Size: 5112
Received: from mailgw01.mediatek.com (unknown [210.61.82.183])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 13:02:06 +0000 (UTC)
X-UUID: e7bb7d6d9123418ab85de4128f4f1d7a-20190911
X-UUID: e7bb7d6d9123418ab85de4128f4f1d7a-20190911
Received: from mtkcas07.mediatek.inc [(172.21.101.84)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0809 with TLS)
	with ESMTP id 1948053234; Wed, 11 Sep 2019 21:02:00 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Wed, 11 Sep 2019 21:01:58 +0800
Received: from mtksdccf07.mediatek.inc (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Wed, 11 Sep 2019 21:01:58 +0800
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko
	<glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Matthias Brugger
	<matthias.bgg@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Andrey Konovalov
	<andreyknvl@google.com>, Qian Cai <cai@lca.pw>, Vlastimil Babka
	<vbabka@suse.cz>, Arnd Bergmann <arnd@arndb.de>
CC: <linux-kernel@vger.kernel.org>, <kasan-dev@googlegroups.com>,
	<linux-mm@kvack.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>, Walter Wu
	<walter-zh.wu@mediatek.com>
Subject: [PATCH v4] mm/kasan: dump alloc and free stack for page allocator
Date: Wed, 11 Sep 2019 21:01:56 +0800
Message-ID: <20190911130156.12628-1-walter-zh.wu@mediatek.com>
X-Mailer: git-send-email 2.18.0
MIME-Version: 1.0
Content-Type: text/plain
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is KASAN's report adds the alloc/free stack for page allocator
in order to help programmer to see memory corruption caused by the page.

By default, KASAN doesn't record alloc or free stack for page allocator.
It is difficult to fix up the page use-after-free or double-free issue.

We add the following changing:
1) KASAN enable PAGE_OWNER by default to get the alloc stack of the page.
2) Add new feature option to get the free stack of the page.

The new feature KASAN_DUMP_PAGE depends on DEBUG_PAGEALLOC, it will help
to record free stack of the page, it is very helpful for solving the page
use-after-free or double-free issue.

When KASAN_DUMP_PAGE is enabled then KASAN's report will show the last
alloc and free stack of the page, it should be:

BUG: KASAN: use-after-free in kmalloc_pagealloc_uaf+0x70/0x80
Write of size 1 at addr ffffffc0d60e4000 by task cat/115
...
 prep_new_page+0x1c8/0x218
 get_page_from_freelist+0x1ba0/0x28d0
 __alloc_pages_nodemask+0x1d4/0x1978
 kmalloc_order+0x28/0x58
 kmalloc_order_trace+0x28/0xe0
 kmalloc_pagealloc_uaf+0x2c/0x80
page last free stack trace:
 __free_pages_ok+0x116c/0x1630
 __free_pages+0x50/0x78
 kfree+0x1c4/0x250
 kmalloc_pagealloc_uaf+0x38/0x80

Changes since v1:
- slim page_owner and move it into kasan
- enable the feature by default

Changes since v2:
- enable PAGE_OWNER by default
- use DEBUG_PAGEALLOC to get page information

Changes since v3:
- correct typo

cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
cc: Vlastimil Babka <vbabka@suse.cz>
cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Walter Wu <walter-zh.wu@mediatek.com>
---
 lib/Kconfig.kasan | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 4fafba1a923b..a3683e952b10 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -41,6 +41,7 @@ config KASAN_GENERIC
 	select SLUB_DEBUG if SLUB
 	select CONSTRUCTORS
 	select STACKDEPOT
+	select PAGE_OWNER
 	help
 	  Enables generic KASAN mode.
 	  Supported in both GCC and Clang. With GCC it requires version 4.9.2
@@ -63,6 +64,7 @@ config KASAN_SW_TAGS
 	select SLUB_DEBUG if SLUB
 	select CONSTRUCTORS
 	select STACKDEPOT
+	select PAGE_OWNER
 	help
 	  Enables software tag-based KASAN mode.
 	  This mode requires Top Byte Ignore support by the CPU and therefore
@@ -135,6 +137,19 @@ config KASAN_S390_4_LEVEL_PAGING
 	  to 3TB of RAM with KASan enabled). This options allows to force
 	  4-level paging instead.
 
+config KASAN_DUMP_PAGE
+	bool "Dump the last allocation and freeing stack of the page"
+	depends on KASAN
+	select DEBUG_PAGEALLOC
+	help
+	  By default, KASAN enable PAGE_OWNER only to record alloc stack
+	  for page allocator. It is difficult to fix up page use-after-free
+	  or double-free issue.
+	  The feature depends on DEBUG_PAGEALLOC, it will extra record
+	  free stack of the page. It is very helpful for solving the page
+	  use-after-free or double-free issue.
+	  The feature will have a small memory overhead.
+
 config TEST_KASAN
 	tristate "Module for testing KASAN for bug detection"
 	depends on m && KASAN
-- 
2.18.0


