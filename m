Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 773AD6B00EE
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 22:40:34 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so11917635pab.24
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:40:34 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id tr9si21667744pac.159.2014.11.11.19.40.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 11 Nov 2014 19:40:33 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NEW00G9QQ7GW3C0@mailout2.samsung.com> for
 linux-mm@kvack.org; Wed, 12 Nov 2014 12:40:28 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH] mm: mincore: add hwpoison page handle
Date: Wed, 12 Nov 2014 11:39:29 +0800
Message-id: <000001cffe2a$66a95a50$33fc0ef0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

When encounter pte is a swap entry, the current code handles two cases:
migration and normal swapentry, but we have a third case: hwpoison page.

This patch adds hwpoison page handle, consider hwpoison page incore as
same as migration.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/mincore.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 725c809..3545f13 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -137,8 +137,8 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		} else { /* pte is a swap entry */
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
-			if (is_migration_entry(entry)) {
-				/* migration entries are always uptodate */
+			if (non_swap_entry(entry)) {
+			/* migration or hwpoison entries are always uptodate */
 				*vec = 1;
 			} else {
 #ifdef CONFIG_SWAP
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
