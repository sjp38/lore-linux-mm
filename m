Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f52.google.com (mail-oa0-f52.google.com [209.85.219.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6795A6B0037
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 18:38:23 -0400 (EDT)
Received: by mail-oa0-f52.google.com with SMTP id j17so40589oag.25
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 15:38:23 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id u1si24725obs.48.2014.06.17.15.38.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 15:38:22 -0700 (PDT)
From: Waiman Long <Waiman.Long@hp.com>
Subject: [PATCH v2 2/2] mm, thp: replace smp_mb after atomic_add by smp_mb__after_atomic
Date: Tue, 17 Jun 2014 18:37:59 -0400
Message-Id: <1403044679-9993-3-git-send-email-Waiman.Long@hp.com>
In-Reply-To: <1403044679-9993-1-git-send-email-Waiman.Long@hp.com>
References: <1403044679-9993-1-git-send-email-Waiman.Long@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>, Waiman Long <Waiman.Long@hp.com>

In some architectures like x86, atomic_add() is a full memory
barrier. In that case, an additional smp_mb() is just a waste of time.
This patch replaces that smp_mb() by smp_mb__after_atomic() which
will avoid the redundant memory barrier in some architectures.

With a 3.16-rc1 based kernel, this patch reduced the execution time
of breaking 1000 transparent huge pages from 38,245us to 30,964us. A
reduction of 19% which is quite sizeable. It also reduces the %cpu
time of the __split_huge_page_refcount function in the perf profile
from 2.18% to 1.15%.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 mm/huge_memory.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index be84c71..e2ee131 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1650,7 +1650,7 @@ static void __split_huge_page_refcount(struct page *page,
 			   &page_tail->_count);
 
 		/* after clearing PageTail the gup refcount can be released */
-		smp_mb();
+		smp_mb__after_atomic();
 
 		/*
 		 * retain hwpoison flag of the poisoned tail page:
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
