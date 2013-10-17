Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D9AF46B0035
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 20:43:59 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id p10so41669pdj.11
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 17:43:59 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1898178pad.28
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 17:43:56 -0700 (PDT)
Date: Wed, 16 Oct 2013 17:43:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, vmpressure: add high level
Message-ID: <alpine.DEB.2.02.1310161738410.10147@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Vmpressure has two important levels: medium and critical.  Medium is 
defined at 60% and critical is defined at 95%.

We have a customer who needs a notification at a higher level than medium, 
which is slight to moderate reclaim activity, and before critical to start 
throttling incoming requests to save memory and avoid oom.

This patch adds the missing link: a high level defined at 80%.

In the future, it would probably be better to allow the user to specify an 
integer ratio for the notification rather than relying on arbitrarily 
specified levels.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/vmpressure.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -46,6 +46,7 @@ static const unsigned long vmpressure_win = SWAP_CLUSTER_MAX * 16;
  * unsuccessful reclaims there were.
  */
 static const unsigned int vmpressure_level_med = 60;
+static const unsigned int vmpressure_level_high = 80;
 static const unsigned int vmpressure_level_critical = 95;
 
 /*
@@ -88,6 +89,7 @@ static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
 enum vmpressure_levels {
 	VMPRESSURE_LOW = 0,
 	VMPRESSURE_MEDIUM,
+	VMPRESSURE_HIGH,
 	VMPRESSURE_CRITICAL,
 	VMPRESSURE_NUM_LEVELS,
 };
@@ -95,6 +97,7 @@ enum vmpressure_levels {
 static const char * const vmpressure_str_levels[] = {
 	[VMPRESSURE_LOW] = "low",
 	[VMPRESSURE_MEDIUM] = "medium",
+	[VMPRESSURE_HIGH] = "high",
 	[VMPRESSURE_CRITICAL] = "critical",
 };
 
@@ -102,6 +105,8 @@ static enum vmpressure_levels vmpressure_level(unsigned long pressure)
 {
 	if (pressure >= vmpressure_level_critical)
 		return VMPRESSURE_CRITICAL;
+	else if (pressure >= vmpressure_level_high)
+		return VMPRESSURE_HIGH;
 	else if (pressure >= vmpressure_level_med)
 		return VMPRESSURE_MEDIUM;
 	return VMPRESSURE_LOW;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
