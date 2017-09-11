Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0B7F6B02E4
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 15:46:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 97so9746737wrb.1
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 12:46:27 -0700 (PDT)
Received: from smtp.smtpout.orange.fr (smtp07.smtpout.orange.fr. [80.12.242.129])
        by mx.google.com with ESMTPS id 71si7402113wmf.128.2017.09.11.12.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 12:46:26 -0700 (PDT)
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] mm/backing-dev.c: fix an error handling path in 'cgwb_create()'
Date: Mon, 11 Sep 2017 21:43:23 +0200
Message-Id: <20170911194323.17833-1-christophe.jaillet@wanadoo.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@fb.com, jack@suse.cz, tj@kernel.org, geliangtang@gmail.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>

If the 'kmalloc' fails, we must go through the existing error handling
path.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 mm/backing-dev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index f028a9a472fd..e19606bb41a0 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -569,8 +569,10 @@ static int cgwb_create(struct backing_dev_info *bdi,
 
 	/* need to create a new one */
 	wb = kmalloc(sizeof(*wb), gfp);
-	if (!wb)
-		return -ENOMEM;
+	if (!wb) {
+		ret = -ENOMEM;
+		goto out_put;
+	}
 
 	ret = wb_init(wb, bdi, blkcg_css->id, gfp);
 	if (ret)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
