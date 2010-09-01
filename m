Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3EB6B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 23:52:15 -0400 (EDT)
Date: Wed, 1 Sep 2010 13:51:35 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 03/10] Use percpu stats
Message-ID: <20100901035135.GC18958@kryten>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>
 <1281374816-904-4-git-send-email-ngupta@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1281374816-904-4-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@linuxdriverproject.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Hi,

> Also remove references to removed stats (ex: good_comress).

I'm getting an oops when running mkfs on zram:

NIP [d0000000030e0340] .zram_inc_stat+0x58/0x84 [zram]
[c00000006d58f720] [d0000000030e091c] .zram_make_request+0xa8/0x6a0 [zram]
[c00000006d58f840] [c00000000035795c] .generic_make_request+0x390/0x434
[c00000006d58f950] [c000000000357b14] .submit_bio+0x114/0x140
[c00000006d58fa20] [c000000000361778] .blkdev_issue_discard+0x1ac/0x250
[c00000006d58fb10] [c000000000361f68] .blkdev_ioctl+0x358/0x7fc
[c00000006d58fbd0] [c0000000001c1c1c] .block_ioctl+0x6c/0x90
[c00000006d58fc70] [c0000000001984c4] .do_vfs_ioctl+0x660/0x6d4
[c00000006d58fd70] [c0000000001985a0] .SyS_ioctl+0x68/0xb0

Since disksize no longer starts as 0 it looks like we can call
zram_make_request before the device has been initialised. The patch below
fixes the immediate problem but this would go away if we move the
initialisation function elsewhere (as suggested in another thread).

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: powerpc.git/drivers/staging/zram/zram_drv.c
===================================================================
--- powerpc.git.orig/drivers/staging/zram/zram_drv.c	2010-09-01 12:35:14.286515175 +1000
+++ powerpc.git/drivers/staging/zram/zram_drv.c	2010-09-01 12:35:24.167930504 +1000
@@ -441,6 +441,12 @@ static int zram_make_request(struct requ
 	int ret = 0;
 	struct zram *zram = queue->queuedata;
 
+	if (unlikely(!zram->init_done)) {
+		set_bit(BIO_UPTODATE, &bio->bi_flags);
+		bio_endio(bio, 0);
+		return 0;
+	}
+
 	if (unlikely(!valid_io_request(zram, bio))) {
 		zram_inc_stat(zram, ZRAM_STAT_INVALID_IO);
 		bio_io_error(bio);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
