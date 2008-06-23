Date: Mon, 23 Jun 2008 20:21:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [bad page] memcg: another bad page at page migration
 (2.6.26-rc5-mm3 + patch collection)
Message-Id: <20080623202111.f2c54e21.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080623150817.628aef9f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080623145341.0a365c67.nishimura@mxp.nes.nec.co.jp>
	<20080623150817.628aef9f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jun 2008 15:08:17 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 23 Jun 2008 14:53:41 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > It seems the current -mm has been gradually stabilized,
> > but I encounter another bad page problem in my test(*1)
> > on 2.6.26-rc5-mm3 + patch collection(*2).
> > 
> > Compared to previous probrems fixed by the patch collection,
> > the frequency is law.
> > 
> > - 1 time in 1 hour running(1'st one was seen after 30 minutes)
> > - 3 times in 16 hours running(1'st one was seen after 4 hours)
> > - 10 times in 70 hours running(1'st one was seen after 8 hours)
> > 
> > All bad pages show similar message like below:
> > 
> Thank you. I'll dig this.
> 
> 
Here is one possibilty. But if your test doesn't migrate any shmem, 
I'll have to dig more ;)
Anyway, I'll schedule this patch.

-Kame
=
mem_cgroup_uncharge() against old page is done after radix-tree-replacement.
And there were special handling to ingore swap-cache page. But, shmem can
be swap-cache and file-cache at the same time. Chekcing PageSwapCache() is
not correct here. Check PageAnon() instead.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/migrate.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

Index: test2-2.6.26-rc5-mm3/mm/migrate.c
===================================================================
--- test2-2.6.26-rc5-mm3.orig/mm/migrate.c
+++ test2-2.6.26-rc5-mm3/mm/migrate.c
@@ -330,7 +330,13 @@ static int migrate_page_move_mapping(str
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
 
 	spin_unlock_irq(&mapping->tree_lock);
-	if (!PageSwapCache(newpage))
+
+	/*
+	 * The page is removed from radix-tree implicitly.
+	 * We uncharge it here but swap cache of anonymous page should be
+	 * uncharged by mem_cgroup_ucharge_page().
+	 */
+	if (!PageAnon(newpage))
 		mem_cgroup_uncharge_cache_page(page);
 
 	return 0;
@@ -379,7 +385,8 @@ static void migrate_page_copy(struct pag
 		/*
 		 * SwapCache is removed implicitly. Uncharge against swapcache
 		 * should be called after ClearPageSwapCache() because
-		 * mem_cgroup_uncharge_page checks the flag.
+		 * mem_cgroup_uncharge_page checks the flag. shmem's swap cache
+		 * is uncharged before here.
 		 */
 		mem_cgroup_uncharge_page(page);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
