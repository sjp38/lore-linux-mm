Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 30A9F6B0036
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 16:16:29 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id w61so2658483wes.40
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 13:16:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ur6si2979036wjc.38.2014.02.07.13.16.26
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 13:16:27 -0800 (PST)
Date: Fri, 07 Feb 2014 16:16:04 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <52f54d2b.26ecc20a.61cb.2eccSMTPIN_ADDED_BROKEN@mx.google.com>
Subject: [PATCH] mm/memory-failure.c: move refcount only in
 !MF_COUNT_INCREASED
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

# Resending due to sending failure. Sorry if you received twice.
---
mce-test detected a test failure when injecting error to a thp tail page.
This is because we take page refcount of the tail page in madvise_hwpoison()
while the fix in commit a3e0f9e47d5e ("mm/memory-failure.c: transfer page
count from head page to tail page after split thp") assumes that we always
take refcount on the head page.

When a real memory error happens we take refcount on the head page where
memory_failure() is called without MF_COUNT_INCREASED set, so it seems to me
that testing memory error on thp tail page using madvise makes little sense.

This patch cancels moving refcount in !MF_COUNT_INCREASED for valid testing.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # 3.9+: a3e0f9e47d5e
---
 mm/memory-failure.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git v3.14-rc1.orig/mm/memory-failure.c v3.14-rc1/mm/memory-failure.c
index ab55d489eb05..16886ddb6ab4 100644
--- v3.14-rc1.orig/mm/memory-failure.c
+++ v3.14-rc1/mm/memory-failure.c
@@ -1042,8 +1042,10 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 			 * to it. Similarly, page lock is shifted.
 			 */
 			if (hpage != p) {
-				put_page(hpage);
-				get_page(p);
+				if (!(flags && MF_COUNT_INCREASED)) {
+					put_page(hpage);
+					get_page(p);
+				}
 				lock_page(p);
 				unlock_page(hpage);
 				*hpagep = p;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
