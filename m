Date: Sat, 11 Dec 2004 14:24:15 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: PATCH: automatic tuning of swap token timeout
Message-ID: <Pine.LNX.4.61.0412111420400.9560@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At Marcelo's request.  I made this patch a while ago so I'm
not sure if it will still apply to the recent kernel, but it
should give you an idea of what I tried to achieve.

The idea is to keep the swap token timeout short on a system
with mostly small tasks, even if there is one big hog running
in the background.  The big thrashing program should not hold
the swap token for unfair amounts of time.

The swap token timeout should be the minimum required to keep
most of the processes in the system from thrashing, while
keeping some amount of fairness.

This patch is untested.  Have fun.

===== mm/thrash.c 1.2 vs edited =====
--- 1.2/mm/thrash.c	Wed Oct 20 04:37:11 2004
+++ edited/mm/thrash.c	Mon Nov  1 22:35:01 2004
@@ -19,10 +19,44 @@
  struct mm_struct * swap_token_mm = &init_mm;

  #define SWAP_TOKEN_CHECK_INTERVAL (HZ * 2)
-#define SWAP_TOKEN_TIMEOUT (HZ * 300)
+#define MIN_SWAP_TOKEN_TIMEOUT (2 * SWAP_TOKEN_CHECK_INTERVAL)
+#define SWAP_TOKEN_TIMEOUT (HZ * 30)
+#define MAX_SWAP_TOKEN_TIMEOUT (HZ * 300)
  unsigned long swap_token_default_timeout = SWAP_TOKEN_TIMEOUT;

  /*
+ * We count how often the swap token times out, and how often the
+ * swap token hold time is long enough for processes to regain their
+ * working set and make progress.
+ *
+ * The goal is to have processes in the system make progress, with the
+ * lowest possible latency.  If the token times out too often, processes
+ * are not making progress and the timeout needs to be increased.  If
+ * processes are making progress, we can decrease the timeout and improve
+ * system latency.
+ */
+#define SWAP_TOKEN_RECALC 32
+#define SWAP_TOKEN_TOO_LONG 1
+static int swap_token_timed_out;
+static int swap_token_enough_rss;
+
+static void recalculate_swap_token_timeout(void)
+{
+	unsigned long delta = (swap_token_default_timeout / 4) + 1;
+	if (swap_token_timed_out > SWAP_TOKEN_TOO_LONG) {
+		swap_token_default_timeout += delta;
+		if (swap_token_default_timeout > MAX_SWAP_TOKEN_TIMEOUT)
+			swap_token_default_timeout = MAX_SWAP_TOKEN_TIMEOUT;
+	} else {
+		swap_token_default_timeout -= delta;
+		if (swap_token_default_timeout < MIN_SWAP_TOKEN_TIMEOUT)
+			swap_token_default_timeout = MIN_SWAP_TOKEN_TIMEOUT;
+	}
+	swap_token_enough_rss /= 2;
+	swap_token_timed_out /= 2;
+}
+
+/*
   * Take the token away if the process had no page faults
   * in the last interval, or if it has held the token for
   * too long.
@@ -32,11 +66,18 @@
  static int should_release_swap_token(struct mm_struct *mm)
  {
  	int ret = 0;
-	if (!mm->recent_pagein)
+	if (!mm->recent_pagein) {
+		swap_token_enough_rss++;
  		ret = SWAP_TOKEN_ENOUGH_RSS;
-	else if (time_after(jiffies, swap_token_timeout))
+	} else if (time_after(jiffies, swap_token_timeout)) {
+		swap_token_timed_out++;
  		ret = SWAP_TOKEN_TIMED_OUT;
+	}
  	mm->recent_pagein = 0;
+
+	if (swap_token_timed_out + swap_token_enough_rss > SWAP_TOKEN_RECALC)
+		recalculate_swap_token_timeout();
+
  	return ret;
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
