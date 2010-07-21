Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 997CB6B02A6
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 22:45:12 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id o6L2jATd031984
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:10 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by hpaq3.eem.corp.google.com with ESMTP id o6L2j3MS022124
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:09 -0700
Received: by pwj1 with SMTP id 1so2512467pwj.3
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 19:45:02 -0700 (PDT)
Date: Tue, 20 Jul 2010 19:45:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/6] fs: remove dependency on __GFP_NOFAIL
In-Reply-To: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1007201939430.8728@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The kmalloc() in bio_integrity_prep() is failable, so remove __GFP_NOFAIL
from its mask.

Cc: Jens Axboe <jens.axboe@oracle.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/bio-integrity.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/bio-integrity.c b/fs/bio-integrity.c
--- a/fs/bio-integrity.c
+++ b/fs/bio-integrity.c
@@ -413,7 +413,7 @@ int bio_integrity_prep(struct bio *bio)
 
 	/* Allocate kernel buffer for protection data */
 	len = sectors * blk_integrity_tuple_size(bi);
-	buf = kmalloc(len, GFP_NOIO | __GFP_NOFAIL | q->bounce_gfp);
+	buf = kmalloc(len, GFP_NOIO | q->bounce_gfp);
 	if (unlikely(buf == NULL)) {
 		printk(KERN_ERR "could not allocate integrity buffer\n");
 		return -EIO;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
