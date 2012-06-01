Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 3B44E6B0062
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 08:26:35 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so3681761pbb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 05:26:34 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 4/5] vmevent: Hide meaningful names from the user-visible header
Date: Fri,  1 Jun 2012 05:24:05 -0700
Message-Id: <1338553446-22292-4-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20120601122118.GA6128@lizard>
References: <20120601122118.GA6128@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

...so that nobody would try to use the internally used bits.

Suggested-by: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 include/linux/vmevent.h |    6 ++----
 mm/vmevent.c            |    9 +++++++--
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
index aae0d24..b8ec0ac 100644
--- a/include/linux/vmevent.h
+++ b/include/linux/vmevent.h
@@ -35,10 +35,8 @@ enum {
 	 */
 	VMEVENT_ATTR_STATE_ONE_SHOT	= (1UL << 3),
 
-	/* Saved state, used internally by the kernel for one-shot mode. */
-	__VMEVENT_ATTR_STATE_VALUE_WAS_LT	= (1UL << 30),
-	/* Saved state, used internally by the kernel for one-shot mode. */
-	__VMEVENT_ATTR_STATE_VALUE_WAS_GT	= (1UL << 31),
+	__VMEVENT_ATTR_STATE_INTERNAL	= (1UL << 30) |
+					  (1UL << 31),
 };
 
 struct vmevent_attr {
diff --git a/mm/vmevent.c b/mm/vmevent.c
index 35fd0d5..e64a92d 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -83,6 +83,11 @@ static u64 vmevent_sample_attr(struct vmevent_watch *watch, struct vmevent_attr
 	return fn(watch, attr);
 }
 
+enum {
+	VMEVENT_ATTR_STATE_VALUE_WAS_LT	= (1UL << 30),
+	VMEVENT_ATTR_STATE_VALUE_WAS_GT	= (1UL << 31),
+};
+
 static bool vmevent_match(struct vmevent_watch *watch)
 {
 	struct vmevent_config *config = &watch->config;
@@ -100,8 +105,8 @@ static bool vmevent_match(struct vmevent_watch *watch)
 
 		if (attr_lt || attr_gt || attr_eq) {
 			bool one_shot = state & VMEVENT_ATTR_STATE_ONE_SHOT;
-			u32 was_lt_mask = __VMEVENT_ATTR_STATE_VALUE_WAS_LT;
-			u32 was_gt_mask = __VMEVENT_ATTR_STATE_VALUE_WAS_GT;
+			u32 was_lt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_LT;
+			u32 was_gt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_GT;
 			u64 value = vmevent_sample_attr(watch, attr);
 			bool lt = value < attr->value;
 			bool gt = value > attr->value;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
