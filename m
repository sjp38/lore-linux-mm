Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D44F46B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 10:23:07 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o22so129644847iod.6
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 07:23:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w66si15438381ioe.198.2017.04.18.07.23.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 07:23:06 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH v2] mm, page_alloc: Remove debug_guardpage_minorder() test in warn_alloc().
Date: Tue, 18 Apr 2017 23:22:46 +0900
Message-Id: <1492525366-4929-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Stanislaw Gruszka <sgruszka@redhat.com>

Commit c0a32fc5a2e470d0 ("mm: more intensive memory corruption debugging")
changed to check debug_guardpage_minorder() > 0 when reporting allocation
failures. The reasoning was

  When we use guard page to debug memory corruption, it shrinks available
  pages to 1/2, 1/4, 1/8 and so on, depending on parameter value.
  In such case memory allocation failures can be common and printing
  errors can flood dmesg. If somebody debug corruption, allocation
  failures are not the things he/she is interested about.

but is misguided.

Allocation requests with __GFP_NOWARN flag by definition do not cause
flooding of allocation failure messages. Allocation requests with
__GFP_NORETRY flag likely also have __GFP_NOWARN flag. Costly allocation
requests likely also have __GFP_NOWARN flag.

Allocation requests without __GFP_DIRECT_RECLAIM flag likely also have
__GFP_NOWARN flag or __GFP_HIGH flag. Non-costly allocation requests with
__GFP_DIRECT_RECLAIM flag basically retry forever due to the "too small to
fail" memory-allocation rule.

Therefore, as a whole, shrinking available pages by
debug_guardpage_minorder= kernel boot parameter might cause flooding of
OOM killer messages but unlikely causes flooding of allocation failure
messages. Let's remove debug_guardpage_minorder() > 0 check which would
likely be pointless.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 362be0a..e2c687d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3162,8 +3162,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 	static DEFINE_RATELIMIT_STATE(nopage_rs, DEFAULT_RATELIMIT_INTERVAL,
 				      DEFAULT_RATELIMIT_BURST);
 
-	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs) ||
-	    debug_guardpage_minorder() > 0)
+	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
 		return;
 
 	pr_warn("%s: ", current->comm);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
