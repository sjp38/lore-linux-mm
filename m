Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4E8636B007E
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 14:53:36 -0500 (EST)
Received: by mail-bw0-f217.google.com with SMTP id 9so367089bwz.10
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 11:53:35 -0800 (PST)
From: John Kacur <jkacur@redhat.com>
Subject: [RFC][PATCH] vmscan: balance local_irq_disable() and local_irq_enable()
Date: Wed,  3 Feb 2010 20:53:21 +0100
Message-Id: <1265226801-6199-2-git-send-email-jkacur@redhat.com>
In-Reply-To: <1265226801-6199-1-git-send-email-jkacur@redhat.com>
References: <1265226801-6199-1-git-send-email-jkacur@redhat.com>
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Steven@kvack.org, "Rostedt <rostedt"@goodmis.org, John Kacur <jkacur@redhat.com>
List-ID: <linux-mm.kvack.org>

Balance local_irq_disable() and local_irq_enable() as well as
spin_lock_irq() and spin_lock_unlock_irq

Signed-off-by: John Kacur <jkacur@redhat.com>
---
 mm/vmscan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c26986c..b895025 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1200,8 +1200,9 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		if (current_is_kswapd())
 			__count_vm_events(KSWAPD_STEAL, nr_freed);
 		__count_zone_vm_events(PGSTEAL, zone, nr_freed);
+		local_irq_enable();
 
-		spin_lock(&zone->lru_lock);
+		spin_lock_irq(&zone->lru_lock);
 		/*
 		 * Put back any unfreeable pages.
 		 */
-- 
1.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
