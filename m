Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 4B0936B00F9
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 06:24:16 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so428226pad.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 03:24:15 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 2/3] vmevent: Factor vmevent_match_attr() out of vmevent_match()
Date: Thu,  4 Oct 2012 03:21:17 -0700
Message-Id: <1349346078-24874-2-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20121004102013.GA23284@lizard>
References: <20121004102013.GA23284@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Soon we'll use this new function for other code; plus this makes code less
indented.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/vmevent.c | 107 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 57 insertions(+), 50 deletions(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index 39ef786..d434c11 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -77,6 +77,59 @@ enum {
 	VMEVENT_ATTR_STATE_VALUE_WAS_GT	= (1UL << 31),
 };
 
+static bool vmevent_match_attr(struct vmevent_attr *attr, u64 value)
+{
+	u32 state = attr->state;
+	bool attr_lt = state & VMEVENT_ATTR_STATE_VALUE_LT;
+	bool attr_gt = state & VMEVENT_ATTR_STATE_VALUE_GT;
+	bool attr_eq = state & VMEVENT_ATTR_STATE_VALUE_EQ;
+	bool edge = state & VMEVENT_ATTR_STATE_EDGE_TRIGGER;
+	u32 was_lt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_LT;
+	u32 was_gt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_GT;
+	bool lt = value < attr->value;
+	bool gt = value > attr->value;
+	bool eq = value == attr->value;
+	bool was_lt = state & was_lt_mask;
+	bool was_gt = state & was_gt_mask;
+	bool was_eq = was_lt && was_gt;
+	bool ret = false;
+
+	if (!state)
+		return false;
+
+	if (!attr_lt && !attr_gt && !attr_eq)
+		return false;
+
+	if (((attr_lt && lt) || (attr_gt && gt) || (attr_eq && eq)) && !edge)
+		return true;
+
+	if (attr_eq && eq && was_eq) {
+		return false;
+	} else if (attr_lt && lt && was_lt && !was_eq) {
+		return false;
+	} else if (attr_gt && gt && was_gt && !was_eq) {
+		return false;
+	} else if (eq) {
+		state |= was_lt_mask;
+		state |= was_gt_mask;
+		if (attr_eq)
+			ret = true;
+	} else if (lt) {
+		state |= was_lt_mask;
+		state &= ~was_gt_mask;
+		if (attr_lt)
+			ret = true;
+	} else if (gt) {
+		state |= was_gt_mask;
+		state &= ~was_lt_mask;
+		if (attr_gt)
+			ret = true;
+	}
+
+	attr->state = state;
+	return ret;
+}
+
 static bool vmevent_match(struct vmevent_watch *watch)
 {
 	struct vmevent_config *config = &watch->config;
@@ -84,57 +137,11 @@ static bool vmevent_match(struct vmevent_watch *watch)
 
 	for (i = 0; i < config->counter; i++) {
 		struct vmevent_attr *attr = &config->attrs[i];
-		u32 state = attr->state;
-		bool attr_lt = state & VMEVENT_ATTR_STATE_VALUE_LT;
-		bool attr_gt = state & VMEVENT_ATTR_STATE_VALUE_GT;
-		bool attr_eq = state & VMEVENT_ATTR_STATE_VALUE_EQ;
-
-		if (!state)
-			continue;
+		u64 val;
 
-		if (attr_lt || attr_gt || attr_eq) {
-			bool edge = state & VMEVENT_ATTR_STATE_EDGE_TRIGGER;
-			u32 was_lt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_LT;
-			u32 was_gt_mask = VMEVENT_ATTR_STATE_VALUE_WAS_GT;
-			u64 value = vmevent_sample_attr(watch, attr);
-			bool lt = value < attr->value;
-			bool gt = value > attr->value;
-			bool eq = value == attr->value;
-			bool was_lt = state & was_lt_mask;
-			bool was_gt = state & was_gt_mask;
-			bool was_eq = was_lt && was_gt;
-			bool ret = false;
-
-			if (((attr_lt && lt) || (attr_gt && gt) ||
-					(attr_eq && eq)) && !edge)
-				return true;
-
-			if (attr_eq && eq && was_eq) {
-				return false;
-			} else if (attr_lt && lt && was_lt && !was_eq) {
-				return false;
-			} else if (attr_gt && gt && was_gt && !was_eq) {
-				return false;
-			} else if (eq) {
-				state |= was_lt_mask;
-				state |= was_gt_mask;
-				if (attr_eq)
-					ret = true;
-			} else if (lt) {
-				state |= was_lt_mask;
-				state &= ~was_gt_mask;
-				if (attr_lt)
-					ret = true;
-			} else if (gt) {
-				state |= was_gt_mask;
-				state &= ~was_lt_mask;
-				if (attr_gt)
-					ret = true;
-			}
-
-			attr->state = state;
-			return ret;
-		}
+		val = vmevent_sample_attr(watch, attr);
+		if (vmevent_match_attr(attr, val))
+			return true;
 	}
 
 	return false;
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
