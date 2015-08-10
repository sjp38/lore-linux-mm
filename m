Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7A31E6B0254
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 07:56:13 -0400 (EDT)
Received: by oip136 with SMTP id 136so84282499oip.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:56:13 -0700 (PDT)
Received: from BLU004-OMC1S14.hotmail.com (blu004-omc1s14.hotmail.com. [65.55.116.25])
        by mx.google.com with ESMTPS id mw13si14209619obb.86.2015.08.10.04.56.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Aug 2015 04:56:12 -0700 (PDT)
Message-ID: <BLU436-SMTP127DCA3FEE328C95FE71B3280700@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH v2 2/5] mm/hwpoison: fix PageHWPoison test/set race
Date: Mon, 10 Aug 2015 19:28:20 +0800
In-Reply-To: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <wanpeng.li@hotmail.com>

There is a race between madvise_hwpoison path and memory_failure:

 CPU0					CPU1

madvise_hwpoison
get_user_pages_fast
PageHWPoison check (false)
					memory_failure
					TestSetPageHWPoison
soft_offline_page
PageHWPoison check (true)
return -EBUSY (without put_page)

Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
---
 mm/memory-failure.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 56b8a71..e0eb7ab 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1704,6 +1704,8 @@ int soft_offline_page(struct page *page, int flags)
 
 	if (PageHWPoison(page)) {
 		pr_info("soft offline: %#lx page already poisoned\n", pfn);
+		if (flags & MF_COUNT_INCREASED)
+			put_page(page);
 		return -EBUSY;
 	}
 	if (!PageHuge(page) && PageTransHuge(hpage)) {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
