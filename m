Date: Wed, 28 Sep 2005 22:50:31 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [patch] bug of pgdat_list connection in init_bootmem()
Message-Id: <20050928223844.8655.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I think 2.6.14-rc2 has a bug in init_bootmem().
There are just 2 pgdat in pgdat_list even if node num is 3 or more,
because pgdat_last is not updated.

Bye.

P.S.
  I would like to remove this pgdat_list, to simplify hot-add/remove
  a node. and posted patch before.
   http://marc.theaimsgroup.com/?l=linux-mm&m=111596924629564&w=2
   http://marc.theaimsgroup.com/?l=linux-mm&m=111596953711780&w=2

  I would like to repost after getting performance impact by this.
  But it is very hard that I can get time to use big NUMA machine now.
  So, I don't know when I will be able to repost it.

  Anyway, this should be modified before remove pgdat_list.


Signed-off-by Yasunori Goto <y-goto@jp.fujitsu.com>

Index: bootmem_new/mm/bootmem.c
===================================================================
--- bootmem_new.orig/mm/bootmem.c	2005-09-23 17:42:06.000000000 +0900
+++ bootmem_new/mm/bootmem.c	2005-09-23 17:44:59.000000000 +0900
@@ -66,9 +66,10 @@ static unsigned long __init init_bootmem
 	pgdat->pgdat_next = NULL;
 	/* Add new nodes last so that bootmem always starts
 	   searching in the first nodes, not the last ones */
-	if (pgdat_last)
+	if (pgdat_last){
 		pgdat_last->pgdat_next = pgdat;
-	else {
+		pgdat_last = pgdat;
+	} else {
 		pgdat_list = pgdat; 	
 		pgdat_last = pgdat;
 	}

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
