Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CBA66B02FD
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:43:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s74so111861178pfe.10
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 13:43:13 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id b2si9036629pgc.211.2017.06.19.13.43.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 13:43:12 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id l89so59077795pfi.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 13:43:12 -0700 (PDT)
Date: Mon, 19 Jun 2017 13:43:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-4.12] mm, thp: remove cond_resched from
 __collapse_huge_page_copy
Message-ID: <alpine.DEB.2.10.1706191341550.97821@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Larry Finger <Larry.Finger@lwfinger.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

This is a partial revert of commit 338a16ba1549 ("mm, thp: copying user
pages must schedule on collapse") which added a cond_resched() to
__collapse_huge_page_copy().

On x86 with CONFIG_HIGHPTE, __collapse_huge_page_copy is called in atomic
context and thus scheduling is not possible.  This is only a possible
config on arm and i386.

Although need_resched has been shown to be set for over 100 jiffies while
doing the iteration in __collapse_huge_page_copy, this is better than
doing

	if (in_atomic())
		cond_resched()

to cover only non-CONFIG_HIGHPTE configs.

Reported-by: Larry Finger <Larry.Finger@lwfinger.net>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Note: Larry should be back as of June 17 to test if this fixes the
 reported issue.

 mm/khugepaged.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -652,7 +652,6 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			spin_unlock(ptl);
 			free_page_and_swap_cache(src_page);
 		}
-		cond_resched();
 	}
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
