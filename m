Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 129E66B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 06:26:16 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 133so63641920itu.17
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 03:26:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r70si142121iod.216.2017.03.27.03.26.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Mar 2017 03:26:15 -0700 (PDT)
Subject: [RFC PATCH] smack: Use __GFP_NOFAIL than panic()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201703271926.JJI69202.MJVQFSFLOFtOOH@I-love.SAKURA.ne.jp>
Date: Mon, 27 Mar 2017 19:26:12 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-security-module@vger.kernel.org, linux-mm@kvack.org

>From dbdac6060ac1a741cb95f370121339bcc4176aea Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 27 Mar 2017 14:06:52 +0900
Subject: [RFC PATCH] smack: Use __GFP_NOFAIL than panic()

smk_cipso_doi() is called by two locations; upon boot up and upon writing
to /smack/doi interface.

It is theoretically possible that kmalloc(GFP_KERNEL) for the latter fails
due to being killed by the OOM killer or memory allocation fault injection.
Although use of __GFP_NOFAIL is not recommended, is it tolerable to use
__GFP_NOFAIL when adding a recovery path for unlikely failure is not
worthwhile but allocation is single-shot and amount of memory to allocate
is known to be small enough?

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 security/smack/smackfs.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
index 366b835..4e45a77 100644
--- a/security/smack/smackfs.c
+++ b/security/smack/smackfs.c
@@ -721,9 +721,7 @@ static void smk_cipso_doi(void)
 		printk(KERN_WARNING "%s:%d remove rc = %d\n",
 		       __func__, __LINE__, rc);
 
-	doip = kmalloc(sizeof(struct cipso_v4_doi), GFP_KERNEL);
-	if (doip == NULL)
-		panic("smack:  Failed to initialize cipso DOI.\n");
+	doip = kmalloc(sizeof(struct cipso_v4_doi), GFP_KERNEL | __GFP_NOFAIL);
 	doip->map.std = NULL;
 	doip->doi = smk_cipso_doi_value;
 	doip->type = CIPSO_V4_MAP_PASS;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
