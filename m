Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4B16B0037
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:04:13 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so5733560pab.2
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:04:13 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id fl7si10722748pad.316.2014.01.27.02.04.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:04:09 -0800 (PST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0200FN81AO9950@mailout4.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:04:00 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 8/8] mm/frontswap: add missing handle on a dup-store failure
Date: Mon, 27 Jan 2014 18:03:04 +0800
Message-id: <000701cf1b47$19c56ab0$4d504010$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Heesub Shin' <heesub.shin@samsung.com>, mquzik@redhat.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, xfishcoder@gmail.com

If a frontswap dup-store failed, it should invalidate the old page in
backend and return failure.

This patch add this missing handle. According to the comments of
__frontswap_store(), it should have been there.

Reported-by: changkun.li <xfishcoder@gmail.com>
Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/frontswap.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/frontswap.c b/mm/frontswap.c
index df067f1..171c6c0 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -245,8 +245,10 @@ int __frontswap_store(struct page *page)
 		  the (older) page from frontswap
 		 */
 		inc_frontswap_failed_stores();
-		if (dup)
+		if (dup) {
 			__frontswap_clear(sis, offset);
+			frontswap_ops->invalidate_page(type, offset);
+		}
 	}
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
