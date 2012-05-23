Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 0234F6B00E8
	for <linux-mm@kvack.org>; Wed, 23 May 2012 03:29:49 -0400 (EDT)
Received: from euspt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M4G000WPSTE2S@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 23 May 2012 08:29:38 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M4G00KTUSTNMD@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 23 May 2012 08:29:48 +0100 (BST)
Date: Wed, 23 May 2012 09:28:39 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 2/2] vmevent: pass right attribute to vmevent_sample_attr()
Message-id: <201205230928.39861.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, linux-mm@kvack.org

From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] vmevent: pass right attribute to vmevent_sample_attr()

Pass "config attribute" (&watch->config->attrs[i]) not "sample
attribute" (&watch->sample_attrs[i]) to vmevent_sample_attr() to
allow use of the original attribute value in vmevent_attr_sample_fn().

Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
Without this patch vmevent_attr_lowmem_pages() always returns 0.

 mm/vmevent.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

Index: b/mm/vmevent.c
===================================================================
--- a/mm/vmevent.c	2012-05-22 17:55:02.000000000 +0200
+++ b/mm/vmevent.c	2012-05-22 18:10:40.075231798 +0200
@@ -31,6 +31,7 @@
 	 */
 	unsigned long			nr_attrs;
 	struct vmevent_attr		*sample_attrs;
+	struct vmevent_attr		*config_attrs[VMEVENT_CONFIG_MAX_ATTRS];
 
 	/* sampling */
 	struct timer_list		timer;
@@ -104,6 +105,7 @@
 	 */
 	if (free < val && file < val)
 		return val;
+
 	return 0;
 }
 
@@ -210,7 +212,8 @@
 	for (i = 0; i < watch->nr_attrs; i++) {
 		struct vmevent_attr *attr = &watch->sample_attrs[i];
 
-		attr->value = vmevent_sample_attr(watch, attr);
+		attr->value = vmevent_sample_attr(watch,
+						  watch->config_attrs[i]);
 	}
 
 	atomic_set(&watch->pending, 1);
@@ -353,6 +356,9 @@
 		attrs[nr].type = attr->type;
 		attrs[nr].value = 0;
 		attrs[nr].state = 0;
+
+		watch->config_attrs[nr] = attr;
+
 		nr++;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
