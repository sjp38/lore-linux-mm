Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id E93E06B0038
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 14:20:44 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id w141so2347276ywa.2
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 11:20:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t3sor1244052ybc.208.2017.12.06.11.20.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 11:20:42 -0800 (PST)
From: Suren Baghdasaryan <surenb@google.com>
Subject: [PATCH] mm: terminate shrink_slab loop if signal is pending
Date: Wed,  6 Dec 2017 11:20:26 -0800
Message-Id: <20171206192026.25133-1-surenb@google.com>
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
 mm/vmscan.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c02c850ea349..69296528ff33 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -486,6 +486,13 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
 			.memcg = memcg,
 		};
 
+		/*
+		 * We are about to die and free our memory.
+		 * Stop shrinking which might delay signal handling.
+		 */
+		if (unlikely(fatal_signal_pending(current))
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
