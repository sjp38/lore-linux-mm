Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 636346B0039
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 17:21:38 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id fb1so836365pad.10
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:21:37 -0700 (PDT)
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
        by mx.google.com with ESMTPS id ci3si14300700pad.332.2014.04.29.14.21.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Apr 2014 14:21:37 -0700 (PDT)
Received: by mail-pa0-f53.google.com with SMTP id ld10so829261pab.12
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 14:21:37 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 1/4] swap: Cleanup how special swap file numbers are defined
Date: Tue, 29 Apr 2014 14:21:20 -0700
Message-Id: <1398806483-19122-2-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

The SWP_HWPOISON and SWP_MIGRATION numbers are defined in
a fairly awkward way. Since they are stolen from the top
few values of the 1<<MAX_SWAPFILES_SHIFT bits, the values
themselves are calculated by taking the MAX_SWAPFILES value
(which is defined by subtraciting out all the available special
types), and re-adding all the other various special types.

However, in order to preserve the actual values when adding
new entries, one would have to re-add the new entries value
to all the type definitions. This gets ugly fast.

This patch tries to clean up how these values are defined so
its simpler to understand how they are calculated and makes it
easier add new special values.

This is done via a enum list which tracks the various special types
making the MAX_SWAPFILES definition much simpler. Then we just
define the special type as (MAX_SWAPFILES + <enum val>).

As long as the enum values are added to the top of the enum
instead of the bottom, the values for the types will be preserved.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Keith Packard <keithp@keithp.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/swap.h | 31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3507115..a32c3da 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -49,29 +49,38 @@ static inline int current_is_kswapd(void)
  * actions on faults.
  */
 
+enum {
+	/*
+	 * NOTE: We use the high bits here (subtracting from
+	 * 1<<MAX_SWPFILES_SHIFT), so to preserve the values insert
+	 * new entries here at the top of the enum, not at the bottom
+	 */
+#ifdef CONFIG_MEMORY_FAILURE
+	SWP_HWPOISON_NR,
+#endif
+#ifdef CONFIG_MIGRATION
+	SWP_MIGRATION_READ_NR,
+	SWP_MIGRATION_WRITE_NR,
+#endif
+	SWP_MAX_SPECIAL_TYPE_NR,
+};
+#define MAX_SWAPFILES ((1 << MAX_SWAPFILES_SHIFT) - SWP_MAX_SPECIAL_TYPE_NR)
+
 /*
  * NUMA node memory migration support
  */
 #ifdef CONFIG_MIGRATION
-#define SWP_MIGRATION_NUM 2
-#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_HWPOISON_NUM)
-#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_HWPOISON_NUM + 1)
-#else
-#define SWP_MIGRATION_NUM 0
+#define SWP_MIGRATION_READ	(MAX_SWAPFILES + SWP_MIGRATION_READ_NR)
+#define SWP_MIGRATION_WRITE	(MAX_SWAPFILES + SWP_MIGRATION_WRITE_NR)
 #endif
 
 /*
  * Handling of hardware poisoned pages with memory corruption.
  */
 #ifdef CONFIG_MEMORY_FAILURE
-#define SWP_HWPOISON_NUM 1
-#define SWP_HWPOISON		MAX_SWAPFILES
-#else
-#define SWP_HWPOISON_NUM 0
+#define SWP_HWPOISON		(MAX_SWAPFILES + SWP_HWPOISON_NR)
 #endif
 
-#define MAX_SWAPFILES \
-	((1 << MAX_SWAPFILES_SHIFT) - SWP_MIGRATION_NUM - SWP_HWPOISON_NUM)
 
 /*
  * Magic header for a swap area. The first part of the union is
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
