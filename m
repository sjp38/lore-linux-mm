Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E72135F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 02:21:36 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3E6Ltke021105
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Apr 2009 15:21:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F35D45DE56
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:21:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 883C445DE58
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:21:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A57861DB803E
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:21:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CEEF1DB8040
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 15:21:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v3 5/6] don't use bio-map in read() path
In-Reply-To: <20090414151204.C647.A69D9226@jp.fujitsu.com>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
Message-Id: <20090414152020.C656.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Apr 2009 15:21:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Jens Axboe <jens.axboe@oracle.com>, James Bottomley <James.Bottomley@HansenPartnership.com>
List-ID: <linux-mm.kvack.org>

Who know proper fixing way?

=================
Subject: [Untested][RFC][PATCH] don't use bio-map in read() path

__bio_map_user_iov() has wrong usage of get_user_pages_fast().
it doesn't have prevent fork mechanism.

then, it sould be used read-side (memory to device transfer) gup only.

This patch is obviously temporally fix. we can implement fork safe bio_map_user()
the future...


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Jens Axboe <jens.axboe@oracle.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>
---
 block/blk-map.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: b/block/blk-map.c
===================================================================
--- a/block/blk-map.c	2009-02-21 16:53:21.000000000 +0900
+++ b/block/blk-map.c	2009-04-12 23:36:32.000000000 +0900
@@ -55,7 +55,7 @@ static int __blk_rq_map_user(struct requ
 	 * direct dma. else, set up kernel bounce buffers
 	 */
 	uaddr = (unsigned long) ubuf;
-	if (blk_rq_aligned(q, ubuf, len) && !map_data)
+	if (blk_rq_aligned(q, ubuf, len) && !map_data && !reading)
 		bio = bio_map_user(q, NULL, uaddr, len, reading, gfp_mask);
 	else
 		bio = bio_copy_user(q, map_data, uaddr, len, reading, gfp_mask);
@@ -208,7 +208,7 @@ int blk_rq_map_user_iov(struct request_q
 		}
 	}
 
-	if (unaligned || (q->dma_pad_mask & len) || map_data)
+	if (unaligned || (q->dma_pad_mask & len) || map_data || read)
 		bio = bio_copy_user_iov(q, map_data, iov, iov_count, read,
 					gfp_mask);
 	else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
