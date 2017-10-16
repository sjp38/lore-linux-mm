Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 205906B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:59:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s2so8120353pge.19
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 15:59:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v32sor2350180plg.72.2017.10.16.15.59.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 15:59:16 -0700 (PDT)
Date: Mon, 16 Oct 2017 15:59:13 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] writeback: Convert timers to use timer_setup()
Message-ID: <20171016225913.GA99214@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Matthew Wilcox <mawilcox@microsoft.com>, Jeff Layton <jlayton@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Jeff Layton <jlayton@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/page-writeback.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 94854e243b11..65ba42c7c7da 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -628,9 +628,9 @@ EXPORT_SYMBOL_GPL(wb_writeout_inc);
  * On idle system, we can be called long after we scheduled because we use
  * deferred timers so count with missed periods.
  */
-static void writeout_period(unsigned long t)
+static void writeout_period(struct timer_list *t)
 {
-	struct wb_domain *dom = (void *)t;
+	struct wb_domain *dom = from_timer(dom, t, period_timer);
 	int miss_periods = (jiffies - dom->period_time) /
 						 VM_COMPLETIONS_PERIOD_LEN;
 
@@ -653,8 +653,7 @@ int wb_domain_init(struct wb_domain *dom, gfp_t gfp)
 
 	spin_lock_init(&dom->lock);
 
-	setup_deferrable_timer(&dom->period_timer, writeout_period,
-			       (unsigned long)dom);
+	timer_setup(&dom->period_timer, writeout_period, TIMER_DEFERRABLE);
 
 	dom->dirty_limit_tstamp = jiffies;
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
