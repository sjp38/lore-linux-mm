Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB476B025E
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e70so84618wmc.6
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r64si3674280wma.131.2017.11.30.14.15.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:14 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:11 -0800
From: akpm@linux-foundation.org
Subject: [patch 01/15] mm: skip HWPoisoned pages when onlining pages
Message-ID: <5a2082ef.O5KuTYIgAA5wXBLf%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, ldufour@linux.vnet.ibm.com, avagin@openvz.org, bsingharora@gmail.com, glommer@openvz.org, n-horiguchi@ah.jp.nec.com, vdavydov.dev@gmail.com

From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: mm: skip HWPoisoned pages when onlining pages

b023f46813cd ("memory-hotplug: skip HWPoisoned page when offlining pages")
skipped the HWPoisoned pages when offlining pages, but this should be
skipped when onlining the pages too.

n-horiguchi@ah.jp.nec.com said:

: If I read correctly, to "skip HWPoiosned page" in commit b023f46813cd
: means that we skip the page status check for hwpoisoned pages *not* to
: prevent memory offlining for memblocks with hwpoisoned pages.  That
: means that hwpoisoned pages can be offlined.
: 
: And another reason to clear PageReserved is that we could reuse the
: hwpoisoned page after onlining back with replacing the broken DIMM.  In
: this usecase, we first do unpoisoning to clear PageHWPoison, but it
: doesn't work if PageReserved is set.  My simple testing shows the BUG
: below in unpoisoning (without the ClearPageReserved):
: 
:   Unpoison: Software-unpoisoned page 0x18000
:   BUG: Bad page state in process page-types  pfn:18000
:   page:ffffda5440600000 count:0 mapcount:0 mapping:          (null) index:0x70006b599
:   flags: 0x1fffc00004081a(error|uptodate|dirty|reserved|swapbacked)
:   raw: 001fffc00004081a 0000000000000000 000000070006b599 00000000ffffffff
:   raw: dead000000000100 dead000000000200 0000000000000000 0000000000000000
:   page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
:   bad because of flags: 0x800(reserved)

Link: http://lkml.kernel.org/r/1493130472-22843-3-git-send-email-ldufour@linux.vnet.ibm.com
Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrey Vagin <avagin@openvz.org>
Cc: Glauber Costa <glommer@openvz.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/memory_hotplug.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN mm/memory_hotplug.c~mm-skip-hwpoisoned-pages-when-onlining-pages mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~mm-skip-hwpoisoned-pages-when-onlining-pages
+++ a/mm/memory_hotplug.c
@@ -696,6 +696,10 @@ static int online_pages_range(unsigned l
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
+			if (PageHWPoison(page)) {
+				ClearPageReserved(page);
+				continue;
+			}
 			(*online_page_callback)(page);
 			onlined_pages++;
 		}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
