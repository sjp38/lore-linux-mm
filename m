Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB42EsJ8025111
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 4 Dec 2008 11:14:54 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D74745DD74
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 11:14:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 21A0345DD76
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 11:14:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B41D1DB8048
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 11:14:53 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E87D1DB8045
	for <linux-mm@kvack.org>; Thu,  4 Dec 2008 11:14:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: remove UP version lru_add_drain_all()
In-Reply-To: <20081204093143.390afa9f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1228342567.13111.11.camel@nimitz> <20081204093143.390afa9f.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20081204110013.1D62.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  4 Dec 2008 11:14:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, gerald.schaefer@de.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, y-goto@jp.fujitsu.com, npiggin@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

(CC to  Christoph Lameter and Lee Schermerhorn)


> On Wed, 03 Dec 2008 14:16:07 -0800
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > > This let us run
> > > into the BUG_ON(!PageBuddy(page)) in __offline_isolated_pages() during
> > > memory hotplug stress test on s390. The page in question was still on the
> > > pcp list, because of a race with lru_add_drain_all() and drain_all_pages()
> > > on different cpus.
> > > 
> > > This is fixed with this patch by adding CONFIG_MEMORY_HOTREMOVE to the
> > > lru_add_drain_all() #ifdef, to let it run on each cpu.
> > 
> > This doesn't seem right to me.  CONFIG_MEMORY_HOTREMOVE doesn't change
> > the layout of the LRUs, unlike NUMA or UNEVICTABLE_LRU.  So, I think
> > this bug is more due to the hotremove code mis-expecting behavior out of
> > lru_add_drain_all().
> > 
> How about 
> 
> #ifdef CONFIG_SMP
> 
> #else..
> 
> #endif
> 
> rather than
> 
> -#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
> +#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU) || \
> +    defined(CONFIG_MEMORY_HOTREMOVE)
> ...


The default value of CONFIG_UNEVICTABLE_LRU is ON.
Then, almost machine use CONFIG_NUMA version lru_add_drain_all().

Therefore, this config option is not so valuable.
I like simple removing.

following patch can boot on UP machine.
===
Currently, lru_add_drain_all() has two version.
  (1) use schedule_on_each_cpu()
  (2) don't use schedule_on_each_cpu()

Gerald Schaefer reported it doesn't works well on SMP (not NUMA) S390 machine.

  offline_pages() calls lru_add_drain_all() followed by drain_all_pages().
  While drain_all_pages() works on each cpu, lru_add_drain_all() only runs
  on the current cpu for architectures w/o CONFIG_NUMA. This let us run
  into the BUG_ON(!PageBuddy(page)) in __offline_isolated_pages() during
  memory hotplug stress test on s390. The page in question was still on the
  pcp list, because of a race with lru_add_drain_all() and drain_all_pages()
  on different cpus.

Actually, Almost machine has CONFIG_UNEVICTABLE_LRU=y. Then almost machine use
(1) version lru_add_drain_all although the machine is UP.

Then this ifdef is not valueable.
simple removing is better.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

---
 mm/swap.c |   13 -------------
 1 file changed, 13 deletions(-)

Index: b/mm/swap.c
===================================================================
--- a/mm/swap.c	2008-11-24 19:33:26.000000000 +0900
+++ b/mm/swap.c	2008-12-04 09:49:05.000000000 +0900
@@ -299,7 +299,6 @@ void lru_add_drain(void)
 	put_cpu();
 }
 
-#if defined(CONFIG_NUMA) || defined(CONFIG_UNEVICTABLE_LRU)
 static void lru_add_drain_per_cpu(struct work_struct *dummy)
 {
 	lru_add_drain();
@@ -313,18 +312,6 @@ int lru_add_drain_all(void)
 	return schedule_on_each_cpu(lru_add_drain_per_cpu);
 }
 
-#else
-
-/*
- * Returns 0 for success
- */
-int lru_add_drain_all(void)
-{
-	lru_add_drain();
-	return 0;
-}
-#endif
-
 /*
  * Batched page_cache_release().  Decrement the reference count on all the
  * passed pages.  If it fell to zero then remove the page from the LRU and



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
