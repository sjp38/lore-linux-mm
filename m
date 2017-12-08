Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 91F9F6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 20:23:17 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g69so1288784ita.9
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 17:23:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v62sor274993itf.143.2017.12.07.17.23.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 17:23:14 -0800 (PST)
From: Suren Baghdasaryan <surenb@google.com>
Subject: [PATCH v2] mm: terminate shrink_slab loop if signal is pending
Date: Thu,  7 Dec 2017 17:23:05 -0800
Message-Id: <20171208012305.83134-1-surenb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, mgorman@techsingularity.net, ying.huang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: timmurray@google.com, tkjos@google.com, Suren Baghdasaryan <surenb@google.com>

Slab shrinkers can be quite time consuming and when signal
is pending they can delay handling of the signal. If fatal
signal is pending there is no point in shrinking that process
since it will be killed anyway. This change checks for pending
fatal signals inside shrink_slab loop and if one is detected
terminates this loop early.

Signed-off-by: Suren Baghdasaryan <surenb@google.com>

---
V2:
Sergey Senozhatsky:
  - Fix missing parentheses
---
 mm/vmscan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c02c850ea349..28e4bdc72c16 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -486,6 +486,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			.memcg = memcg,
 		};
 
+		/*
+		 * We are about to die and free our memory.
+		 * Stop shrinking which might delay signal handling.
+		 */
+		if (unlikely(fatal_signal_pending(current)))
+			break;
+
 		/*
 		 * If kernel memory accounting is disabled, we ignore
 		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
-- 
2.15.1.424.g9478a66081-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
