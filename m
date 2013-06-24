Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 373B96B0038
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 19:20:42 -0400 (EDT)
Subject: [PATCH v2 3/5] rwsem: remove try_reader_grant label do_wake
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <cover.1372112541.git.tim.c.chen@linux.intel.com>
References: <cover.1372112541.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 24 Jun 2013 16:20:45 -0700
Message-ID: <1372116045.22432.93.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

Make code simple and more readable.

Signed-off-by: Alex Shi <alex.shi@intel.com>
---
 lib/rwsem.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/lib/rwsem.c b/lib/rwsem.c
index 42f1b1a..a8055cf 100644
--- a/lib/rwsem.c
+++ b/lib/rwsem.c
@@ -85,15 +85,17 @@ __rwsem_do_wake(struct rw_semaphore *sem, enum rwsem_wake_type wake_type)
 	adjustment = 0;
 	if (wake_type != RWSEM_WAKE_READ_OWNED) {
 		adjustment = RWSEM_ACTIVE_READ_BIAS;
- try_reader_grant:
-		oldcount = rwsem_atomic_update(adjustment, sem) - adjustment;
-		if (unlikely(oldcount < RWSEM_WAITING_BIAS)) {
-			/* A writer stole the lock. Undo our reader grant. */
+		while (1) {
+			oldcount = rwsem_atomic_update(adjustment, sem)
+								- adjustment;
+			if (likely(oldcount >= RWSEM_WAITING_BIAS))
+				break;
+
+			 /* A writer stole the lock.  Undo our reader grant. */
 			if (rwsem_atomic_update(-adjustment, sem) &
 						RWSEM_ACTIVE_MASK)
 				return sem;
 			/* Last active locker left. Retry waking readers. */
-			goto try_reader_grant;
 		}
 	}
 
-- 
1.7.4.4



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
