Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 50DAB5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 02:22:58 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E6NIGX021827
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 15:23:18 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FF8E45DE4E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:23:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F36345DE53
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:23:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C4E86E08003
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:23:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A76F1DB803E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:23:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v3 6/6] fix wrong get_user_pages usage in iovlock.c
In-Reply-To: <20090414151204.C647.A69D9226@jp.fujitsu.com>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
Message-Id: <20090414152151.C659.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 15:23:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maciej Sosnowski <maciej.sosnowski@intel.com>, "David S. Miller" <davem@davemloft.net>, Chris Leech <christopher.leech@intel.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I don't have NET-DMA usable device. I hope to get expert review.

=========================
Subject: [Untested][RFC][PATCH] fix wrong get_user_pages usage in iovlock.c

	down_read(mmap_sem)
	get_user_pages()
	up_read(mmap_sem)

is fork unsafe.
fix it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Maciej Sosnowski <maciej.sosnowski@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Chris Leech <christopher.leech@intel.com>
Cc: netdev@vger.kernel.org
---
 drivers/dma/iovlock.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

Index: b/drivers/dma/iovlock.c
===================================================================
--- a/drivers/dma/iovlock.c	2009-02-21 16:53:23.000000000 +0900
+++ b/drivers/dma/iovlock.c	2009-04-13 04:46:02.000000000 +0900
@@ -94,18 +94,10 @@ struct dma_pinned_list *dma_pin_iovec_pa
 		pages += page_list->nr_pages;
 
 		/* pin pages down */
-		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(
-			current,
-			current->mm,
-			(unsigned long) iov[i].iov_base,
-			page_list->nr_pages,
-			1,	/* write */
-			0,	/* force */
-			page_list->pages,
-			NULL);
-		up_read(&current->mm->mmap_sem);
-
+		down_read(&current->mm->mm_pinned_sem);
+		ret = get_user_pages_fast((unsigned long) iov[i].iov_base,
+					  page_list->nr_pages, 1,
+					  page_list->pages);
 		if (ret != page_list->nr_pages)
 			goto unpin;
 
@@ -127,6 +119,8 @@ void dma_unpin_iovec_pages(struct dma_pi
 	if (!pinned_list)
 		return;
 
+	up_read(&current->mm->mm_pinned_sem);
+
 	for (i = 0; i < pinned_list->nr_iovecs; i++) {
 		struct dma_page_list *page_list = &pinned_list->page_list[i];
 		for (j = 0; j < page_list->nr_pages; j++) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
