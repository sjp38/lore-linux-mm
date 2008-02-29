Date: Thu, 28 Feb 2008 21:41:41 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 01/21] move isolate_lru_page() to vmscan.c
Message-ID: <20080228214141.296335a0@bree.surriel.com>
In-Reply-To: <20080229112120.66E1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080228192908.126720629@redhat.com>
	<20080228192928.004828816@redhat.com>
	<20080229112120.66E1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008 11:29:18 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> We think this portion change to following code.
> 
> ---------------------------------------------
> 	err = isolate_lru_page(page);
> 	if (!err)
> 		list_add_tail(&page->lru, &pagelist);
> put_and_set:
> 	put_page(page);	/* drop follow_page() reference */
> ---------------------------------------------

If I understand you right, this is what the incremental patch looks like:

Index: linux-2.6.25-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/migrate.c	2008-02-28 21:32:20.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/migrate.c	2008-02-28 21:32:14.000000000 -0500
@@ -841,16 +841,10 @@ static int do_move_pages(struct mm_struc
 			goto put_and_set;
 
 		err = isolate_lru_page(page);
-		if (err) {
-put_and_set:
-			/*
-			 * Either remove the duplicate refcount from
-			 * isolate_lru_page() or drop the page ref if it was
-			 * not isolated.
-			 */
-			put_page(page);
-		} else
+		if (!err)
 			list_add_tail(&page->lru, &pagelist);
+put_and_set:
+		put_page(page);
 set_status:
 		pp->status = err;
 	}

Is this OK for me to commit to my tree?

(folding it into patch 01/21)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
