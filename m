Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E5BE782BDD
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 08:19:34 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so1310482pab.2
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 05:19:34 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id i7si4070286pdo.22.2014.10.21.05.19.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 05:19:33 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so1305654pad.11
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 05:19:33 -0700 (PDT)
From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH] mm/kmemleak: Do not skip stack frames
Date: Tue, 21 Oct 2014 14:19:29 +0200
Message-Id: <1413893969-25798-1-git-send-email-thierry.reding@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Trying to chase down memory leaks is much easier when the complete stack
trace is available.

Signed-off-by: Thierry Reding <treding@nvidia.com>
---
It seems like this was initially set to 1 when merged in commit
3c7b4e6b8be4 (kmemleak: Add the base support) and later increased to 2
in commit fd6789675ebf (kmemleak: Save the stack trace for early
allocations). Perhaps there was a reason to skip the first few frames,
but I've certainly found it difficult to find leaks when the stack trace
doesn't point at the proper location.
---
 mm/kmemleak.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 3cda50c1e394..55d9ad0f40d4 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -503,7 +503,7 @@ static int __save_stack_trace(unsigned long *trace)
 	stack_trace.max_entries = MAX_TRACE;
 	stack_trace.nr_entries = 0;
 	stack_trace.entries = trace;
-	stack_trace.skip = 2;
+	stack_trace.skip = 0;
 	save_stack_trace(&stack_trace);
 
 	return stack_trace.nr_entries;
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
