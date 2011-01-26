Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E61226B00E9
	for <linux-mm@kvack.org>; Wed, 26 Jan 2011 05:20:27 -0500 (EST)
Date: Wed, 26 Jan 2011 11:20:20 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch]
 epoll-fix-compiler-warning-and-optimize-the-non-blocking-path-fix
Message-ID: <20110126102020.GA2244@cmpxchg.org>
References: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: shawn.bohrer@gmail.com, davidel@xmailserver.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The non-blocking ep_poll path optimization introduced skipping over
the return value setup.

Initialize it properly, my userspace gets upset by epoll_wait()
returning random things.

In addition, remove the reinitialization at the fetch_events label,
the return value is garuanteed to be zero when execution reaches
there.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>
Cc: Davide Libenzi <davidel@xmailserver.org>
---
 fs/eventpoll.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index f7cb6cb..afe4238 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1147,7 +1147,7 @@ static int ep_send_events(struct eventpoll *ep,
 static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 		   int maxevents, long timeout)
 {
-	int res, eavail, timed_out = 0;
+	int res = 0, eavail, timed_out = 0;
 	unsigned long flags;
 	long slack = 0;
 	wait_queue_t wait;
@@ -1173,7 +1173,6 @@ static int ep_poll(struct eventpoll *ep, struct epoll_event __user *events,
 fetch_events:
 	spin_lock_irqsave(&ep->lock, flags);
 
-	res = 0;
 	if (!ep_events_available(ep)) {
 		/*
 		 * We don't have any available event to return to the caller.
-- 
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
