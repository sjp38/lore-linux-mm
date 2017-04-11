Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 08D7C6B039F
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 07:28:10 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id g184so127892024oif.6
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 04:28:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t125si7690566oig.33.2017.04.11.04.28.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 04:28:09 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, page_alloc: Remove debug_guardpage_minorder() test in warn_alloc().
Date: Tue, 11 Apr 2017 20:27:15 +0900
Message-Id: <1491910035-4231-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sgruszka@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>

We are using warn_alloc() for reporting both allocation failures and
allocation stalls. If we add debug_guardpage_minorder=1 parameter,
all allocation failure and allocation stall reports become pointless
like below. (Below output would be an OOM livelock where all __GFP_FS
allocations got stuck at too_many_isolated() in shrink_inactive_list()
waiting for kswapd, kswapd is waiting for !__GFP_FS allocations, and
all !__GFP_FS allocations did not get stuck at too_many_isolated() in
shrink_inactive_list() but are unable to invoke the OOM killer.)

----------
[    0.000000] Linux version 4.11.0-rc6-next-20170410 (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #578 SMP Mon Apr 10 23:08:53 JST 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc6-next-20170410 (...snipped...) debug_guardpage_minorder=1
(...snipped...)
[    0.000000] Setting debug_guardpage_minorder to 1
(...snipped...)
[   99.064207] Out of memory: Kill process 3097 (a.out) score 999 or sacrifice child
[   99.066488] Killed process 3097 (a.out) total-vm:14408kB, anon-rss:84kB, file-rss:36kB, shmem-rss:0kB
[   99.180378] oom_reaper: reaped process 3097 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[  128.310487] warn_alloc: 266 callbacks suppressed
[  133.445395] warn_alloc: 74 callbacks suppressed
[  138.517471] warn_alloc: 300 callbacks suppressed
[  143.537630] warn_alloc: 34 callbacks suppressed
[  148.610773] warn_alloc: 277 callbacks suppressed
[  153.630652] warn_alloc: 70 callbacks suppressed
[  158.639891] warn_alloc: 217 callbacks suppressed
[  163.687727] warn_alloc: 120 callbacks suppressed
[  168.709610] warn_alloc: 252 callbacks suppressed
[  173.714659] warn_alloc: 103 callbacks suppressed
[  178.730858] warn_alloc: 248 callbacks suppressed
[  183.797587] warn_alloc: 82 callbacks suppressed
[  188.825250] warn_alloc: 238 callbacks suppressed
[  193.832834] warn_alloc: 102 callbacks suppressed
[  198.876409] warn_alloc: 259 callbacks suppressed
[  203.940073] warn_alloc: 102 callbacks suppressed
[  207.620979] sysrq: SysRq : Resetting
----------

Commit c0a32fc5a2e470d0 ("mm: more intensive memory corruption debugging")
changed to check debug_guardpage_minorder() > 0 when reporting allocation
failures. But the patch description seems to lack why we want to check it.
Let's remove that check so that administrators can get some clue by
allowing warn_alloc() to report e.g. GFP_NOFS | __GFP_NOWARN allocations
are stalling.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 32b31d6..5c8cf2a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3154,8 +3154,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
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
