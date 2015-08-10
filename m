Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 103D86B0254
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:50:03 -0400 (EDT)
Received: by obbfr1 with SMTP id fr1so80343315obb.1
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 23:50:02 -0700 (PDT)
Received: from BLU004-OMC1S6.hotmail.com (blu004-omc1s6.hotmail.com. [65.55.116.17])
        by mx.google.com with ESMTPS id oq12si13663214oeb.82.2015.08.09.23.50.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 09 Aug 2015 23:50:02 -0700 (PDT)
Message-ID: <BLU436-SMTP1881EF02196F4DFB4A0882B80700@phx.gbl>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH 2/2] mm/hwpoison: fix refcount of THP head page in no-injection case
Date: Mon, 10 Aug 2015 14:32:31 +0800
In-Reply-To: <1439188351-24292-1-git-send-email-wanpeng.li@hotmail.com>
References: <1439188351-24292-1-git-send-email-wanpeng.li@hotmail.com>
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
 mm/hwpoison-inject.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index 5015679..c343a45 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -56,6 +56,8 @@ inject:
 	return memory_failure(pfn, 18, MF_COUNT_INCREASED);
 put_out:
 	put_page(p);
+	if (p != hpage)
+		put_page(hpage);
 	return 0;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
