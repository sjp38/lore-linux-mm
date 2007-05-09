Date: Wed, 09 May 2007 12:12:32 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC] memory hotremove patch take 2 [10/10] (retry swap-in page)
In-Reply-To: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
References: <20070509115506.B904.Y-GOTO@jp.fujitsu.com>
Message-Id: <20070509120947.B91A.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

There is a race condition between swap-in and unmap_and_move().
When swap-in occur, page_mapped might be not set yet.
So, unmap_and_move() gives up at once, and tries later.



Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


 mm/migrate.c |    5 +++++
 1 files changed, 5 insertions(+)

Index: current_test/mm/migrate.c
===================================================================
--- current_test.orig/mm/migrate.c	2007-05-08 15:08:09.000000000 +0900
+++ current_test/mm/migrate.c	2007-05-08 15:08:09.000000000 +0900
@@ -670,6 +670,11 @@ static int unmap_and_move(new_page_t get
 		/* hold this anon_vma until remove_migration_ptes() finishes */
 		anon_vma_hold(page);
 	}
+
+	if (PageSwapCache(page) && !page_mapped(page))
+		/* swap in now. try lator*/
+		goto unlock;
+
 	/*
 	 * Establish migration ptes or remove ptes
 	 */

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
