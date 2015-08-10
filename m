Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0BAF76B0255
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 07:56:25 -0400 (EDT)
Received: by oihn130 with SMTP id n130so86525587oih.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 04:56:24 -0700 (PDT)
Received: from BLU004-OMC1S27.hotmail.com (blu004-omc1s27.hotmail.com. [65.55.116.38])
        by mx.google.com with ESMTPS id n124si14213369oib.96.2015.08.10.04.56.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 10 Aug 2015 04:56:24 -0700 (PDT)
Message-ID: <BLU436-SMTP127FE35D7513403A2EF15BC80700@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH v2 4/5] mm/hwpoison: fix refcount of THP head page in no-injection case
Date: Mon, 10 Aug 2015 19:28:22 +0800
In-Reply-To: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
References: <1439206103-86829-1-git-send-email-wanpeng.li@hotmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <wanpeng.li@hotmail.com>

Hwpoison injection takes a refcount of target page and another refcount
of head page of THP if the target page is the tail page of a THP. However,
current code doesn't release the refcount of head page if the THP is not 
supported to be injected wrt hwpoison filter. 

Fix it by reducing the refcount of head page if the target page is the tail 
page of a THP and it is not supported to be injected.

Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
---
 mm/hwpoison-inject.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index 5015679..9d26fd9 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -55,7 +55,7 @@ inject:
 	pr_info("Injecting memory failure at pfn %#lx\n", pfn);
 	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
 put_out:
-	put_page(p);
+	put_hwpoison_page(p);
 	return 0;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
