Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 878516B0044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 09:53:25 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so3360968vbk.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2012 06:53:24 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 27 Jul 2012 21:53:24 +0800
Message-ID: <CAJd=RBDQ1J9UTWOK1x6XNYunFz36RsMnr1Om9HsQQ_Kp8P7RKQ@mail.gmail.com>
Subject: [RFC patch] vm: clear swap entry before copying pte
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

If swap entry is cleared, we can see the reason that copying pte is
interrupted. If due to page table lock held long enough, no need to
increase swap count.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/memory.c	Fri Jul 27 21:33:32 2012
+++ b/mm/memory.c	Fri Jul 27 21:35:24 2012
@@ -971,6 +971,7 @@ again:
 		if (add_swap_count_continuation(entry, GFP_KERNEL) < 0)
 			return -ENOMEM;
 		progress = 0;
+		entry.val = 0;
 	}
 	if (addr != end)
 		goto again;
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
