Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A2C436B003C
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 19:55:00 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so6138479pdj.15
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 16:55:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gp6si42090118pac.215.2014.07.07.16.54.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 16:54:59 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 3.14 92/94] mm/numa: Remove BUG_ON() in __handle_mm_fault()
Date: Mon,  7 Jul 2014 16:58:22 -0700
Message-Id: <20140707235759.476341140@linuxfoundation.org>
In-Reply-To: <20140707235756.780319003@linuxfoundation.org>
References: <20140707235756.780319003@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sunil Pandey <sunil.k.pandey@intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, lwoodman@redhat.com, dave.hansen@intel.com, Ingo Molnar <mingo@kernel.org>

3.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Rik van Riel <riel@redhat.com>

commit 107437febd495a50e2cd09c81bbaa84d30e57b07 upstream.

Changing PTEs and PMDs to pte_numa & pmd_numa is done with the
mmap_sem held for reading, which means a pmd can be instantiated
and turned into a numa one while __handle_mm_fault() is examining
the value of old_pmd.

If that happens, __handle_mm_fault() should just return and let
the page fault retry, instead of throwing an oops. This is
handled by the test for pmd_trans_huge(*pmd) below.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reported-by: Sunil Pandey <sunil.k.pandey@intel.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org
Cc: lwoodman@redhat.com
Cc: dave.hansen@intel.com
Link: http://lkml.kernel.org/r/20140429153615.2d72098e@annuminas.surriel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Patrick McLean <chutzpah@gentoo.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 mm/memory.c |    3 ---
 1 file changed, 3 deletions(-)

--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3756,9 +3756,6 @@ static int __handle_mm_fault(struct mm_s
 		}
 	}
 
-	/* THP should already have been handled */
-	BUG_ON(pmd_numa(*pmd));
-
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
