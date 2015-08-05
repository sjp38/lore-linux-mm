Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0656B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 13:08:52 -0400 (EDT)
Received: by lbbpo9 with SMTP id po9so28411146lbb.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 10:08:51 -0700 (PDT)
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTP id r2si2542504lae.66.2015.08.05.10.08.50
        for <linux-mm@kvack.org>;
        Wed, 05 Aug 2015 10:08:50 -0700 (PDT)
From: Rabin Vincent <rabin.vincent@axis.com>
Subject: [PATCH] writeback: fix initial dirty limit
Date: Wed, 5 Aug 2015 19:08:40 +0200
Message-ID: <1438794520-27414-1-git-send-email-rabin.vincent@axis.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@fb.com, akpm@linux-foundation.org
Cc: tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rabin Vincent <rabinv@axis.com>

The initial value of global_wb_domain.dirty_limit set by
writeback_set_ratelimit() is zeroed out by the memset in
wb_domain_init().

Signed-off-by: Rabin Vincent <rabin.vincent@axis.com>
---
 mm/page-writeback.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 22cddd3..5cccc12 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2063,10 +2063,10 @@ static struct notifier_block ratelimit_nb = {
  */
 void __init page_writeback_init(void)
 {
+	BUG_ON(wb_domain_init(&global_wb_domain, GFP_KERNEL));
+
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
-
-	BUG_ON(wb_domain_init(&global_wb_domain, GFP_KERNEL));
 }
 
 /**
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
