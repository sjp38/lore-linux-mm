Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A17336B01F0
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 01:39:55 -0400 (EDT)
Date: Tue, 31 Aug 2010 15:36:13 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 03/10] Use percpu stats
Message-ID: <20100831053613.GA14848@kryten>
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

> +	zram->stats = alloc_percpu(struct zram_stats_cpu);
> +	if (!zram->stats) {
> +		pr_err("Error allocating percpu stats\n");
> +		ret = -ENOMEM;
> +		goto fail;
> +	}

There doesn't seem to be a free_percpu() in the module exit path. Something
like this perhaps?

Anton
--

zram: Free percpu data on module exit.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: powerpc.git/drivers/staging/zram/zram_drv.c
===================================================================
--- powerpc.git.orig/drivers/staging/zram/zram_drv.c	2010-08-31 15:15:59.344290847 +1000
+++ powerpc.git/drivers/staging/zram/zram_drv.c	2010-08-31 15:17:00.383045836 +1000
@@ -483,8 +483,7 @@ void zram_reset_device(struct zram *zram
 	xv_destroy_pool(zram->mem_pool);
 	zram->mem_pool = NULL;
 
-	/* Reset stats */
-	memset(&zram->stats, 0, sizeof(zram->stats));
+	free_percpu(&zram->stats);
 
 	zram->disksize = zram_default_disksize();
 	mutex_unlock(&zram->init_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
