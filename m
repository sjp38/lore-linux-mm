Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id E7BC46B007E
	for <linux-mm@kvack.org>; Sun,  8 Apr 2012 19:38:43 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so4000567bkw.14
        for <linux-mm@kvack.org>; Sun, 08 Apr 2012 16:38:43 -0700 (PDT)
Date: Mon, 9 Apr 2012 03:38:35 +0400
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 3/3] vmevent: Implement cross event type
Message-ID: <20120408233835.GC4839@panacea>
References: <20120408233550.GA3791@panacea>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120408233550.GA3791@panacea>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

This patch implements a new event type, it will trigger whenever a
value crosses a user-specified threshold. It works two-way, i.e. when
a value crosses the threshold from a lesser values side to a greater
values side, and vice versa.

We use the event type in an userspace low-memory killer: we get a
notification when memory becomes low, so we start freeing memory by
killing unneeded processes, and we get notification when memory hits
the threshold from another side, so we know that we freed enough of
memory.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 include/linux/vmevent.h              |    9 +++++++++
 mm/vmevent.c                         |   21 +++++++++++++++++++++
 tools/testing/vmevent/vmevent-test.c |   15 ++++++++++-----
 3 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
index 64357e4..00cc04f 100644
--- a/include/linux/vmevent.h
+++ b/include/linux/vmevent.h
@@ -22,6 +22,15 @@ enum {
 	 * Sample value is less than user-specified value
 	 */
 	VMEVENT_ATTR_STATE_VALUE_LT	= (1UL << 0),
+	/*
+	 * Sample value crossed user-specified value
+	 */
+	VMEVENT_ATTR_STATE_VALUE_CROSS	= (1UL << 2),
+
+	/* Last saved state, used internally by the kernel. */
+	__VMEVENT_ATTR_STATE_LAST	= (1UL << 30),
+	/* Not first sample, used internally by the kernel. */
+	__VMEVENT_ATTR_STATE_NFIRST	= (1UL << 31),
 };
 
 struct vmevent_attr {
diff --git a/mm/vmevent.c b/mm/vmevent.c
index a56174f..f8fd2d6 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -1,5 +1,6 @@
 #include <linux/anon_inodes.h>
 #include <linux/atomic.h>
+#include <linux/compiler.h>
 #include <linux/vmevent.h>
 #include <linux/syscalls.h>
 #include <linux/timer.h>
@@ -94,6 +95,26 @@ static bool vmevent_match(struct vmevent_watch *watch)
 		if (attr->state & VMEVENT_ATTR_STATE_VALUE_LT) {
 			if (value < attr->value)
 				return true;
+		} else if (attr->state & VMEVENT_ATTR_STATE_VALUE_CROSS) {
+			bool fst = !(attr->state & __VMEVENT_ATTR_STATE_NFIRST);
+			bool old = attr->state & __VMEVENT_ATTR_STATE_LAST;
+			bool new = value < attr->value;
+			bool chg = old ^ new;
+			bool ret = chg;
+
+			/*
+			 * This is not 'lt' or 'gt' match, so on the first
+			 * sample assume we crossed the threshold.
+			 */
+			if (unlikely(fst)) {
+				attr->state |= __VMEVENT_ATTR_STATE_NFIRST;
+				ret = true;
+			}
+
+			attr->state &= ~__VMEVENT_ATTR_STATE_LAST;
+			attr->state |= new ? __VMEVENT_ATTR_STATE_LAST : 0;
+
+			return ret;
 		}
 	}
 
diff --git a/tools/testing/vmevent/vmevent-test.c b/tools/testing/vmevent/vmevent-test.c
index 534f827..39e93af 100644
--- a/tools/testing/vmevent/vmevent-test.c
+++ b/tools/testing/vmevent/vmevent-test.c
@@ -33,20 +33,25 @@ int main(int argc, char *argv[])
 
 	config = (struct vmevent_config) {
 		.sample_period_ns	= 1000000000L,
-		.counter		= 4,
+		.counter		= 5,
 		.attrs			= {
-			[0]			= {
+			{
+				.type	= VMEVENT_ATTR_NR_FREE_PAGES,
+				.state	= VMEVENT_ATTR_STATE_VALUE_CROSS,
+				.value	= phys_pages / 2,
+			},
+			{
 				.type	= VMEVENT_ATTR_NR_FREE_PAGES,
 				.state	= VMEVENT_ATTR_STATE_VALUE_LT,
 				.value	= phys_pages,
 			},
-			[1]			= {
+			{
 				.type	= VMEVENT_ATTR_NR_AVAIL_PAGES,
 			},
-			[2]			= {
+			{
 				.type	= VMEVENT_ATTR_NR_SWAP_PAGES,
 			},
-			[3]			= {
+			{
 				.type	= 0xffff, /* invalid */
 			},
 		},
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
