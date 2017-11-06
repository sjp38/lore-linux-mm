Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B33D46B0260
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 13:03:01 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m81so22615386ioi.3
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 10:03:01 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0224.hostedemail.com. [216.40.44.224])
        by mx.google.com with ESMTPS id x3si8133562itb.172.2017.11.06.10.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 10:03:00 -0800 (PST)
From: Joe Perches <joe@perches.com>
Subject: [PATCH] mm/page_alloc: Avoid KERN_CONT uses in warn_alloc
Date: Mon,  6 Nov 2017 10:02:56 -0800
Message-Id: <b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

KERN_CONT/pr_cont uses should be avoided where possible.
Use single pr_warn calls instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 536431bf0f0c..82e6d2c914ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3275,19 +3275,17 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
 		return;
 
-	pr_warn("%s: ", current->comm);
-
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	pr_cont("%pV", &vaf);
-	va_end(args);
-
-	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
 	if (nodemask)
-		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
+		pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl\n",
+			current->comm, &vaf, gfp_mask, &gfp_mask,
+			nodemask_pr_args(nodemask));
 	else
-		pr_cont("(null)\n");
+		pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=(null)\n",
+			current->comm, &vaf, gfp_mask, &gfp_mask);
+	va_end(args);
 
 	cpuset_print_current_mems_allowed();
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
