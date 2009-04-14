Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 33BD35F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 02:20:05 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E6KMmE020573
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 15:20:22 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E7AC45DE50
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:20:22 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E2D6545DE4F
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:20:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CF1E31DB803E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:20:21 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 867E31DB803A
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:20:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v3 4/6] aio: Don't inherit aio ring memory at fork
In-Reply-To: <20090414151204.C647.A69D9226@jp.fujitsu.com>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
Message-Id: <20090414151924.C653.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 15:20:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, Zach Brown <zach.brown@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-api@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

AIO folks, Am I missing anything?

===============
Subject: [RFC][PATCH] aio: Don't inherit aio ring memory at fork

Currently, mm_struct::ioctx_list member isn't copyed at fork. IOW aio context don't inherit at fork.
but only ring memory inherited. that's strange.

This patch mark DONTFORK to ring-memory too.
In addition, This patch has good side effect. it also fix "get_user_pages() vs fork" problem.

I think "man fork" also sould be changed. it only say

       *  The child does not inherit outstanding asynchronous I/O operations from
          its parent (aio_read(3), aio_write(3)).

but aio_context_t (return value of io_setup(2)) also don't inherit in current implementaion.


Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Zach Brown <zach.brown@oracle.com>
Cc: Jens Axboe <jens.axboe@oracle.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-api@vger.kernel.org,
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/aio.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: b/fs/aio.c
===================================================================
--- a/fs/aio.c	2009-04-12 23:33:59.000000000 +0900
+++ b/fs/aio.c	2009-04-13 02:56:05.000000000 +0900
@@ -106,6 +106,7 @@ static int aio_setup_ring(struct kioctx 
 	unsigned nr_events = ctx->max_reqs;
 	unsigned long size;
 	int nr_pages;
+	int ret;
 
 	/* Compensate for the ring buffer's head/tail overlap entry */
 	nr_events += 2;	/* 1 is required, 2 for good luck */
@@ -140,6 +141,13 @@ static int aio_setup_ring(struct kioctx 
 		return -EAGAIN;
 	}
 
+	/*
+	 * aio context doesn't inherit while fork. (see mm_init())
+	 * Then, aio ring also mark DONTFORK.
+	 */
+	ret = sys_madvise(info->mmap_base, info->mmap_size, MADV_DONTFORK);
+	BUG_ON(ret);
+
 	dprintk("mmap address: 0x%08lx\n", info->mmap_base);
 	info->nr_pages = get_user_pages(current, ctx->mm,
 					info->mmap_base, nr_pages, 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
