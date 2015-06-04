Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id AAEBC900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 17:20:58 -0400 (EDT)
Received: by padj3 with SMTP id j3so36932654pad.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 14:20:58 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id gm10si7580643pbd.148.2015.06.04.14.20.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 14:20:57 -0700 (PDT)
Received: by pdbnf5 with SMTP id nf5so38698669pdb.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 14:20:57 -0700 (PDT)
Date: Fri, 5 Jun 2015 06:20:51 +0900
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH block/for-4.2/writeback] bdi: fix wrong error return value in
 cgwb_create()
Message-ID: <20150604212051.GV20091@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>

On wb_congested_get_create() failure, cgwb_create() forgot to set @ret
to -ENOMEM ending up returning 0.  Fix it so that it returns -ENOMEM.

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 mm/backing-dev.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 887d72a8..436bb53 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -554,8 +554,10 @@ static int cgwb_create(struct backing_dev_info *bdi,
 		goto err_ref_exit;
 
 	wb->congested = wb_congested_get_create(bdi, blkcg_css->id, gfp);
-	if (!wb->congested)
+	if (!wb->congested) {
+		ret = -ENOMEM;
 		goto err_fprop_exit;
+	}
 
 	wb->memcg_css = memcg_css;
 	wb->blkcg_css = blkcg_css;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
