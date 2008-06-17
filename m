Subject: [PATCH] unevictable mlocked pages:  initialize mm member of
	munlock mm_walk structure
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1213727385.8707.53.camel@lts-notebook>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <20080617163501.7cf411ee.nishimura@mxp.nes.nec.co.jp>
	 <20080617164709.de4db070.nishimura@mxp.nes.nec.co.jp>
	 <20080617180314.2d1b0efa.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080617181527.5bcbbccc.nishimura@mxp.nes.nec.co.jp>
	 <1213727385.8707.53.camel@lts-notebook>
Content-Type: text/plain
Date: Tue, 17 Jun 2008 16:00:43 -0400
Message-Id: <1213732843.8707.70.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Rik van Riel <riel@redhat.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

kernel BUG at mm/migrate.c:719! in 2.6.26-rc5-mm3)

On Tue, 2008-06-17 at 14:29 -0400, Lee Schermerhorn wrote:
> On Tue, 2008-06-17 at 18:15 +0900, Daisuke Nishimura wrote:
> > On Tue, 17 Jun 2008 18:03:14 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Tue, 17 Jun 2008 16:47:09 +0900
> > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > On Tue, 17 Jun 2008 16:35:01 +0900, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > > Hi.
> > > > > 
> > > > > I got this bug while migrating pages only a few times
> > > > > via memory_migrate of cpuset.
> > > > > 
> > > > > Unfortunately, even if this patch is applied,
> > > > > I got bad_page problem after hundreds times of page migration
> > > > > (I'll report it in another mail).
> > > > > But I believe something like this patch is needed anyway.
> > > > > 
> > > > 
> > > > I got bad_page after hundreds times of page migration.
> > > > It seems that a locked page is being freed.
> 
> I'm seeing *mlocked* pages [PG_mlocked] being freed now with my stress
> load, with just the "if(!page->mapping) { } clause removed, as proposed
> in your rfc patch in previous mail.  Need to investigate this...
> 
<snip>

This [freeing of mlocked pages] also occurs in unpatched 26-rc5-mm3.

Fixed by the following:

PATCH:  fix munlock page table walk - now requires 'mm'

Against 2.6.26-rc5-mm3.

Incremental fix for: mlock-mlocked-pages-are-unevictable-fix.patch 

Initialize the 'mm' member of the mm_walk structure, else the
page table walk doesn't occur, and mlocked pages will not be
munlocked.  This is visible in the vmstats:  

	noreclaim_pgs_munlocked - should equal noreclaim_pgs_mlocked
	  less (nr_mlock + noreclaim_pgs_cleared), but is always zero 
	  [munlock_vma_page() never called]

	noreclaim_pgs_mlockfreed - should be zero [for debug only],
	  but == noreclaim_pgs_mlocked - (nr_mlock + noreclaim_pgs_cleared)


Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mlock.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6.26-rc5-mm3/mm/mlock.c
===================================================================
--- linux-2.6.26-rc5-mm3.orig/mm/mlock.c	2008-06-17 15:20:57.000000000 -0400
+++ linux-2.6.26-rc5-mm3/mm/mlock.c	2008-06-17 15:23:17.000000000 -0400
@@ -318,6 +318,8 @@ static void __munlock_vma_pages_range(st
 	VM_BUG_ON(start < vma->vm_start);
 	VM_BUG_ON(end > vma->vm_end);
 
+	munlock_page_walk.mm = mm;
+
 	lru_add_drain_all();	/* push cached pages to LRU */
 	walk_page_range(start, end, &munlock_page_walk);
 	lru_add_drain_all();	/* to update stats */



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
