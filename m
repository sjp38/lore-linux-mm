Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 896A06B00FB
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 06:24:18 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so525751pbb.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2012 03:24:17 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 3/3] vmevent: Don't sample values twice
Date: Thu,  4 Oct 2012 03:21:18 -0700
Message-Id: <1349346078-24874-3-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20121004102013.GA23284@lizard>
References: <20121004102013.GA23284@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org

Currently, we sample the same values in vmevent_sample() and
vmevent_match(), but we can easily avoid this. Also saves loop iterations.

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/vmevent.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index d434c11..d643615 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -133,18 +133,22 @@ static bool vmevent_match_attr(struct vmevent_attr *attr, u64 value)
 static bool vmevent_match(struct vmevent_watch *watch)
 {
 	struct vmevent_config *config = &watch->config;
+	bool ret = 0;
 	int i;
 
 	for (i = 0; i < config->counter; i++) {
 		struct vmevent_attr *attr = &config->attrs[i];
+		struct vmevent_attr *samp = &watch->sample_attrs[i];
 		u64 val;
 
 		val = vmevent_sample_attr(watch, attr);
-		if (vmevent_match_attr(attr, val))
-			return true;
+		if (!ret && vmevent_match_attr(attr, val))
+			ret = 1;
+
+		samp->value = val;
 	}
 
-	return false;
+	return ret;
 }
 
 /*
@@ -161,20 +165,11 @@ static bool vmevent_match(struct vmevent_watch *watch)
  */
 static void vmevent_sample(struct vmevent_watch *watch)
 {
-	int i;
-
 	if (atomic_read(&watch->pending))
 		return;
 	if (!vmevent_match(watch))
 		return;
 
-	for (i = 0; i < watch->nr_attrs; i++) {
-		struct vmevent_attr *attr = &watch->sample_attrs[i];
-
-		attr->value = vmevent_sample_attr(watch,
-						  watch->config_attrs[i]);
-	}
-
 	atomic_set(&watch->pending, 1);
 }
 
-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
