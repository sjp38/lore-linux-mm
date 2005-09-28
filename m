Date: Wed, 28 Sep 2005 10:50:09 -0700
From: "Seth, Rohit" <rohit.seth@intel.com>
Subject: [patch] Reset the high water marks in CPUs pcp list
Message-ID: <20050928105009.B29282@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: "Seth, Rohit" <rohit.seth@intel.com>, linux-mm@kvack.org, Mattia Dongili <malattia@linux.it>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Recent changes in page allocations for pcps has increased the high watermark for these lists.  This has resulted in scenarios where pcp lists could be having bigger number of free pages even under low memory conditions. 

 	[PATCH]: Reduce the high mark in cpu's pcp lists.
 
 	Signed-off-by: Rohit Seth <rohit.seth@intel.com>


--- linux-2.6.14-rc2-mm1.org/mm/page_alloc.c	2005-09-27 10:03:51.000000000 -0700
+++ linux-2.6.14-rc2-mm1/mm/page_alloc.c	2005-09-27 18:01:21.000000000 -0700
@@ -1859,15 +1859,15 @@
 	pcp = &p->pcp[0];		/* hot */
 	pcp->count = 0;
 	pcp->low = 0;
-	pcp->high = 6 * batch;
+	pcp->high = 4 * batch;
 	pcp->batch = max(1UL, 1 * batch);
 	INIT_LIST_HEAD(&pcp->list);
 
 	pcp = &p->pcp[1];		/* cold*/
 	pcp->count = 0;
 	pcp->low = 0;
-	pcp->high = 2 * batch;
 	pcp->batch = max(1UL, batch/2);
+	pcp->high = pcp->batch + 1;
 	INIT_LIST_HEAD(&pcp->list);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
