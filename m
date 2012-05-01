Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 4AD176B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 09:26:55 -0400 (EDT)
Received: by yenm8 with SMTP id m8so2558884yen.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 06:26:54 -0700 (PDT)
Date: Tue, 1 May 2012 06:25:32 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 1/3] vmevent: Implement equal-to attribute state
Message-ID: <20120501132531.GA24226@lizard>
References: <20120501132409.GA22894@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120501132409.GA22894@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

This complements GT and LT, making it possible to combine GE and LE
operators. We'll use it for blended attributes: the special attributes
will return either 0 or <threshold>, so to make two-way notifications
we will pass LT | EQ bits.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 include/linux/vmevent.h |    6 +++++-
 mm/vmevent.c            |   22 +++++++++++++++-------
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/linux/vmevent.h b/include/linux/vmevent.h
index ca97cf0..aae0d24 100644
--- a/include/linux/vmevent.h
+++ b/include/linux/vmevent.h
@@ -27,9 +27,13 @@ enum {
 	 */
 	VMEVENT_ATTR_STATE_VALUE_GT	= (1UL << 1),
 	/*
+	 * Sample value is equal to user-specified value
+	 */
+	VMEVENT_ATTR_STATE_VALUE_EQ	= (1UL << 2),
+	/*
 	 * One-shot mode.
 	 */
-	VMEVENT_ATTR_STATE_ONE_SHOT	= (1UL << 2),
+	VMEVENT_ATTR_STATE_ONE_SHOT	= (1UL << 3),
 
 	/* Saved state, used internally by the kernel for one-shot mode. */
 	__VMEVENT_ATTR_STATE_VALUE_WAS_LT	= (1UL << 30),
diff --git a/mm/vmevent.c b/mm/vmevent.c
index 47ed448..9f1520b 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -87,28 +87,39 @@ static bool vmevent_match(struct vmevent_watch *watch)
 		u32 state = attr->state;
 		bool attr_lt = state & VMEVENT_ATTR_STATE_VALUE_LT;
 		bool attr_gt = state & VMEVENT_ATTR_STATE_VALUE_GT;
+		bool attr_eq = state & VMEVENT_ATTR_STATE_VALUE_EQ;
 
 		if (!state)
 			continue;
 
-		if (attr_lt || attr_gt) {
+		if (attr_lt || attr_gt || attr_eq) {
 			bool one_shot = state & VMEVENT_ATTR_STATE_ONE_SHOT;
 			u32 was_lt_mask = __VMEVENT_ATTR_STATE_VALUE_WAS_LT;
 			u32 was_gt_mask = __VMEVENT_ATTR_STATE_VALUE_WAS_GT;
 			u64 value = vmevent_sample_attr(watch, attr);
 			bool lt = value < attr->value;
 			bool gt = value > attr->value;
+			bool eq = value == attr->value;
 			bool was_lt = state & was_lt_mask;
 			bool was_gt = state & was_gt_mask;
+			bool was_eq = was_lt && was_gt;
 			bool ret = false;
 
-			if (((attr_lt && lt) || (attr_gt && gt)) && !one_shot)
+			if (((attr_lt && lt) || (attr_gt && gt) ||
+					(attr_eq && eq)) && !one_shot)
 				return true;
 
-			if (attr_lt && lt && was_lt) {
+			if (attr_eq && eq && was_eq) {
 				return false;
-			} else if (attr_gt && gt && was_gt) {
+			} else if (attr_lt && lt && was_lt && !was_eq) {
 				return false;
+			} else if (attr_gt && gt && was_gt && !was_eq) {
+				return false;
+			} else if (eq) {
+				state |= was_lt_mask;
+				state |= was_gt_mask;
+				if (attr_eq)
+					ret = true;
 			} else if (lt) {
 				state |= was_lt_mask;
 				state &= ~was_gt_mask;
@@ -119,9 +130,6 @@ static bool vmevent_match(struct vmevent_watch *watch)
 				state &= ~was_lt_mask;
 				if (attr_gt)
 					ret = true;
-			} else {
-				state &= ~was_lt_mask;
-				state &= ~was_gt_mask;
 			}
 
 			attr->state = state;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
