Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 9B60C6B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 09:27:19 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2852112pbb.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 06:27:19 -0700 (PDT)
Date: Tue, 1 May 2012 06:25:45 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 2/3] vmevent: Pass attr argument to sampling functions
Message-ID: <20120501132544.GB24226@lizard>
References: <20120501132409.GA22894@lizard>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20120501132409.GA22894@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

We'll need the argument for blended attributes, the attributes return
either 0 or the threshold value (which is in attr).

Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/vmevent.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index 9f1520b..b312236 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -39,9 +39,11 @@ struct vmevent_watch {
 	wait_queue_head_t		waitq;
 };
 
-typedef u64 (*vmevent_attr_sample_fn)(struct vmevent_watch *watch);
+typedef u64 (*vmevent_attr_sample_fn)(struct vmevent_watch *watch,
+				      struct vmevent_attr *attr);
 
-static u64 vmevent_attr_swap_pages(struct vmevent_watch *watch)
+static u64 vmevent_attr_swap_pages(struct vmevent_watch *watch,
+				   struct vmevent_attr *attr)
 {
 #ifdef CONFIG_SWAP
 	struct sysinfo si;
@@ -54,12 +56,14 @@ static u64 vmevent_attr_swap_pages(struct vmevent_watch *watch)
 #endif
 }
 
-static u64 vmevent_attr_free_pages(struct vmevent_watch *watch)
+static u64 vmevent_attr_free_pages(struct vmevent_watch *watch,
+				   struct vmevent_attr *attr)
 {
 	return global_page_state(NR_FREE_PAGES);
 }
 
-static u64 vmevent_attr_avail_pages(struct vmevent_watch *watch)
+static u64 vmevent_attr_avail_pages(struct vmevent_watch *watch,
+				    struct vmevent_attr *attr)
 {
 	return totalram_pages;
 }
@@ -74,7 +78,7 @@ static u64 vmevent_sample_attr(struct vmevent_watch *watch, struct vmevent_attr
 {
 	vmevent_attr_sample_fn fn = attr_samplers[attr->type];
 
-	return fn(watch);
+	return fn(watch, attr);
 }
 
 static bool vmevent_match(struct vmevent_watch *watch)
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
