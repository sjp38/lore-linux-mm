From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 02/24] migrate: page could be locked by hwpoison, dont BUG()
Date: Wed, 02 Dec 2009 11:12:33 +0800
Message-ID: <20091202043043.840044332@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 22EC36007A5
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:37 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-migrate-trylock-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

The new page could be taken by hwpoison, in which case
return EAGAIN to allocate a new page and retry.

CC: Nick Piggin <npiggin@suse.de>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/migrate.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-mm.orig/mm/migrate.c	2009-11-02 10:18:45.000000000 +0800
+++ linux-mm/mm/migrate.c	2009-11-02 10:26:16.000000000 +0800
@@ -556,7 +556,7 @@ static int move_to_new_page(struct page 
 	 * holding a reference to the new page at this point.
 	 */
 	if (!trylock_page(newpage))
-		BUG();
+		return -EAGAIN;		/* got by hwpoison */
 
 	/* Prepare mapping for the new page.*/
 	newpage->index = page->index;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
