Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A9AAC5F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 04:47:26 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3F8m95r029229
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Apr 2009 17:48:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A016A45DE53
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 17:48:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B81345DE51
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 17:48:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D65D1DB803A
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 17:48:09 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CF2361DB803C
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 17:48:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 6/6] fix wrong get_user_pages usage in iovlock.c
In-Reply-To: <20090414155719.C66B.A69D9226@jp.fujitsu.com>
References: <200904141656.14191.nickpiggin@yahoo.com.au> <20090414155719.C66B.A69D9226@jp.fujitsu.com>
Message-Id: <20090415174658.AC4F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Apr 2009 17:48:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maciej Sosnowski <maciej.sosnowski@intel.com>, "David S. Miller" <davem@davemloft.net>, Chris Leech <christopher.leech@intel.com>, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> > I would perhaps not fold gup_fast conversions into the same patch as
> > the fix.
> 
> OK. I'll fix.

Done.



===================================
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
 drivers/dma/iovlock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: b/drivers/dma/iovlock.c
===================================================================
--- a/drivers/dma/iovlock.c	2009-04-13 22:58:36.000000000 +0900
+++ b/drivers/dma/iovlock.c	2009-04-14 20:27:16.000000000 +0900
@@ -104,8 +104,6 @@ struct dma_pinned_list *dma_pin_iovec_pa
 			0,	/* force */
 			page_list->pages,
 			NULL);
-		up_read(&current->mm->mmap_sem);
-
 		if (ret != page_list->nr_pages)
 			goto unpin;
 
@@ -127,6 +125,8 @@ void dma_unpin_iovec_pages(struct dma_pi
 	if (!pinned_list)
 		return;
 
+	up_read(&current->mm->mmap_sem);
+
 	for (i = 0; i < pinned_list->nr_iovecs; i++) {
 		struct dma_page_list *page_list = &pinned_list->page_list[i];
 		for (j = 0; j < page_list->nr_pages; j++) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
