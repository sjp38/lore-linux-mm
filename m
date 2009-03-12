Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1CF086B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 21:04:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C14jsd029177
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 12 Mar 2009 10:04:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A835C45DD78
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:04:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B84345DD75
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:04:43 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 247B2E08007
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:04:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A6C9F1DB8017
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 10:04:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may  get wrongly discarded
In-Reply-To: <28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com>
References: <20090311170207.1795cad9.akpm@linux-foundation.org> <28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com>
Message-Id: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Mar 2009 10:04:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, dhowells@redhat.com, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi

> >> Page reclaim shouldn't be even attempting to reclaim or write back
> >> ramfs pagecache pages - reclaim can't possibly do anything with these
> >> pages!
> >>
> >> Arguably those pages shouldn't be on the LRU at all, but we haven't
> >> done that yet.
> >>
> >> Now, my problem is that I can't 100% be sure that we _ever_ implemented
> >> this properly. ?I _think_ we did, in which case we later broke it. ?If
> >> we've always been (stupidly) trying to pageout these pages then OK, I
> >> guess your patch is a suitable 2.6.29 stopgap.
> >
> > OK, I can't find any code anywhere in which we excluded ramfs pages
> > from consideration by page reclaim. ?How dumb.
> 
> The ramfs  considers it in just CONFIG_UNEVICTABLE_LRU case
> It that case, ramfs_get_inode calls mapping_set_unevictable.
> So,  page reclaim can exclude ramfs pages by page_evictable.
> It's problem .

Currently, CONFIG_UNEVICTABLE_LRU can't use on nommu machine
because nobody of vmscan folk havbe nommu machine.

Yes, it is very stupid reason. _very_ welcome to tester! :)



David, Could you please try following patch if you have NOMMU machine?
it is straightforward porting to nommu.


==
Subject: [PATCH] remove to depend on MMU from CONFIG_UNEVICTABLE_LRU

logically, CONFIG_UNEVICTABLE_LRU doesn't depend on MMU.
but current code does by mistake. fix it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/Kconfig |    1 -
 mm/nommu.c |   24 ++++++++++++++++++++++++
 2 files changed, 24 insertions(+), 1 deletion(-)

Index: b/mm/Kconfig
===================================================================
--- a/mm/Kconfig	2008-12-28 20:55:23.000000000 +0900
+++ b/mm/Kconfig	2008-12-28 21:24:08.000000000 +0900
@@ -212,7 +212,6 @@ config VIRT_TO_BUS
 config UNEVICTABLE_LRU
 	bool "Add LRU list to track non-evictable pages"
 	default y
-	depends on MMU
 	help
 	  Keeps unevictable pages off of the active and inactive pageout
 	  lists, so kswapd will not waste CPU time or have its balancing
Index: b/mm/nommu.c
===================================================================
--- a/mm/nommu.c	2008-12-25 08:26:37.000000000 +0900
+++ b/mm/nommu.c	2008-12-28 21:29:36.000000000 +0900
@@ -1521,3 +1521,27 @@ int access_process_vm(struct task_struct
 	mmput(mm);
 	return len;
 }
+
+/*
+ *  LRU accounting for clear_page_mlock()
+ */
+void __clear_page_mlock(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page));
+
+	if (!page->mapping) {	/* truncated ? */
+		return;
+	}
+
+	dec_zone_page_state(page, NR_MLOCK);
+	count_vm_event(UNEVICTABLE_PGCLEARED);
+	if (!isolate_lru_page(page)) {
+		putback_lru_page(page);
+	} else {
+		/*
+		 * We lost the race. the page already moved to evictable list.
+		 */
+		if (PageUnevictable(page))
+			count_vm_event(UNEVICTABLE_PGSTRANDED);
+	}
+}




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
