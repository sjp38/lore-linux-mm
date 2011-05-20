Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA83D6B0022
	for <linux-mm@kvack.org>; Fri, 20 May 2011 01:15:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E52733EE0BD
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:15:43 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id BF6FA45DF5D
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:15:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9846A45DF57
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:15:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 894871DB8047
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:15:43 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B7731DB803F
	for <linux-mm@kvack.org>; Fri, 20 May 2011 14:15:43 +0900 (JST)
Date: Fri, 20 May 2011 14:08:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
Message-Id: <20110520140856.fdf4d1c8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
	<20110517060001.GC24069@localhost>
	<BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
	<BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
	<BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
	<BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com>
	<BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com>
	<BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
	<4DD5DC06.6010204@jp.fujitsu.com>
	<BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
	<BANLkTins7qxWVh0bEwtk1Vx+m98N=oYVtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Lutomirski <luto@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Fri, 20 May 2011 13:20:15 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> So I want to resolve your problem asap.
> We don't have see report about that. Could you do git-bisect?
> FYI, Recently, big change of mm is compaction,transparent huge pages.
> Kame, could you point out thing related to memcg if you have a mind?
> 

I don't doubt memcg at this stage because it never modify page->flags.
Consdering the case, PageActive() is set against off-LRU pages after
clear_active_flags() clears it.

Hmm, I think I don't understand the lock system fully but...how do you
think this ?

==

At splitting a hugepage, the routine marks all pmd as "splitting".

But assume a racy case where 2 threads run into spit at the
same time, one thread wins compound_lock() and do split, another
thread should not touch splitted pages.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Index: mmotm-May11/mm/huge_memory.c
===================================================================
--- mmotm-May11.orig/mm/huge_memory.c
+++ mmotm-May11/mm/huge_memory.c
@@ -1150,7 +1150,7 @@ static int __split_huge_page_splitting(s
 	return ret;
 }
 
-static void __split_huge_page_refcount(struct page *page)
+static bool __split_huge_page_refcount(struct page *page)
 {
 	int i;
 	unsigned long head_index = page->index;
@@ -1161,6 +1161,11 @@ static void __split_huge_page_refcount(s
 	spin_lock_irq(&zone->lru_lock);
 	compound_lock(page);
 
+	if (!PageCompound(page)) {
+		compound_unlock(page);
+		spin_unlock_irq(&zone->lru_lock);
+		return false;
+	}
 	for (i = 1; i < HPAGE_PMD_NR; i++) {
 		struct page *page_tail = page + i;
 
@@ -1258,6 +1263,7 @@ static void __split_huge_page_refcount(s
 	 * to be pinned by the caller.
 	 */
 	BUG_ON(page_count(page) <= 0);
+	return true;
 }
 
 static int __split_huge_page_map(struct page *page,
@@ -1367,7 +1373,8 @@ static void __split_huge_page(struct pag
 		       mapcount, page_mapcount(page));
 	BUG_ON(mapcount != page_mapcount(page));
 
-	__split_huge_page_refcount(page);
+	if (!__split_huge_page_refcount(page))
+		return;
 
 	mapcount2 = 0;
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
