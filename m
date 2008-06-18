Date: Wed, 18 Jun 2008 16:54:01 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH][-mm] remove redundant page->mapping check
In-Reply-To: <20080618134128.828156bc.nishimura@mxp.nes.nec.co.jp>
References: <20080618105400.b9f1b664.nishimura@mxp.nes.nec.co.jp> <20080618134128.828156bc.nishimura@mxp.nes.nec.co.jp>
Message-Id: <20080618164349.37B6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > > this part is really necessary?
> > > I tryed to remove it, but any problem doesn't happend.
> > > 
> > I made this part first, and added a fix for migration_entry_wait later.
> > 
> > So, I haven't test without this part, and I think it will cause
> > VM_BUG_ON() here without this part.
> > 
> > Anyway, I will test it.
> > 
> I got this VM_BUG_ON() as expected only by doing:
> 
>   # echo $$ >/cgroup/cpuset/02/tasks
> 
> So, I beleive that both fixes for migration_entry_wait and
> unmap_and_move (and, of course, removal VM_BUG_ON from
> putback_lru_page) are needed.

OK, I confirmed this part.

Andrew, please pick.


==================================================

Against: 2.6.26-rc5-mm3

remove redundant mapping check.

we'd be doing exactly what putback_lru_page() is doing.  So, this code
as always unnecessary, duplicate code.
So, just let putback_lru_page() handle this condition and conditionally
unlock_page().


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by:      Lee Schermerhorn <Lee.Schermerhorn@hp.com>

---
 mm/migrate.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

Index: b/mm/migrate.c
===================================================================
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -716,13 +716,7 @@ unlock:
  		 * restored.
  		 */
  		list_del(&page->lru);
-		if (!page->mapping) {
-			VM_BUG_ON(page_count(page) != 1);
-			unlock_page(page);
-			put_page(page);		/* just free the old page */
-			goto end_migration;
-		} else
-			unlock = putback_lru_page(page);
+		unlock = putback_lru_page(page);
 	}
 
 	if (unlock)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
