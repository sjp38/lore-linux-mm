Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DD1F6B0082
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 02:18:53 -0500 (EST)
Date: Thu, 4 Feb 2010 16:18:40 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH -mmotm 7/8] memcg: move charges of anonymous swap
Message-ID: <20100204071840.GC5574@linux-sh.org>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp> <20091221143816.9794cd17.nishimura@mxp.nes.nec.co.jp> <20100203193127.fe5efa17.akpm@linux-foundation.org> <20100204140942.0ef6d7b1.nishimura@mxp.nes.nec.co.jp> <20100204142736.2a8bec26.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100204142736.2a8bec26.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 04, 2010 at 02:27:36PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 4 Feb 2010 14:09:42 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Wed, 3 Feb 2010 19:31:27 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > On Mon, 21 Dec 2009 14:38:16 +0900 Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > 
> > > > This patch is another core part of this move-charge-at-task-migration feature.
> > > > It enables moving charges of anonymous swaps.
> > > > 
> > > > To move the charge of swap, we need to exchange swap_cgroup's record.
> > > > 
> > > > In current implementation, swap_cgroup's record is protected by:
> > > > 
> > > >   - page lock: if the entry is on swap cache.
> > > >   - swap_lock: if the entry is not on swap cache.
> > > > 
> > > > This works well in usual swap-in/out activity.
> > > > 
> > > > But this behavior make the feature of moving swap charge check many conditions
> > > > to exchange swap_cgroup's record safely.
> > > > 
> > > > So I changed modification of swap_cgroup's recored(swap_cgroup_record())
> > > > to use xchg, and define a new function to cmpxchg swap_cgroup's record.
> > > > 
> > > > This patch also enables moving charge of non pte_present but not uncharged swap
> > > > caches, which can be exist on swap-out path, by getting the target pages via
> > > > find_get_page() as do_mincore() does.
> > > > 
> > > >
> > > > ...
> > > >
> > > > +		else if (is_swap_pte(ptent)) {
> > > 
> > > is_swap_pte() isn't implemented for CONFIG_MMU=n, so the build breaks.
> > Ah, you're right. I'm sorry I don't have any evironment to test !CONFIG_MMU.
> > 
> > Using #ifdef like below would be the simplest fix(SWAP is depend on MMU),
> > but hmm, #ifdef is ugly.
> > 
> > I'll prepare another fix.
> > 
> Hmm..is there any user of memcg in !CONFIG_MMU environment ?
> Maybe memcg can be used for controling amount of file cache (per cgroup)..
> but..
> 
> I think memcg should depends on CONIFG_MMU.
> 
> How do you think ?
> 
Unless there's a real technical reason to make it depend on CONFIG_MMU,
that's just papering over the problem, and means that some nommu person
will have to come back and fix it properly at a later point in time.

CONFIG_SWAP itself is configurable even with CONFIG_MMU=y, so having
stubbed out helpers for the CONFIG_SWAP=n case would give the compiler a
chance to optimize things away in those cases, too. Embedded systems
especially will often have MMU=y and BLOCK=n, resulting in SWAP being
unset but swap cache encodings still defined.

How about just changing the is_swap_pte() definition to depend on SWAP
instead?

---

diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index cd42e30..45b5b65 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -42,12 +42,17 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 	return entry.val & SWP_OFFSET_MASK(entry);
 }
 
-#ifdef CONFIG_MMU
+#ifdef CONFIG_SWAP
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
 	return !pte_none(pte) && !pte_present(pte) && !pte_file(pte);
 }
+#else
+static inline int is_swap_pte(pte_t pte)
+{
+	return 0;
+}
 #endif
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
