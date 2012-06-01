Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id A69F66B005C
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 08:26:32 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so3681761pbb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 05:26:32 -0700 (PDT)
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: [PATCH 3/5] vmevent: Refresh vmstats before sampling
Date: Fri,  1 Jun 2012 05:24:04 -0700
Message-Id: <1338553446-22292-3-git-send-email-anton.vorontsov@linaro.org>
In-Reply-To: <20120601122118.GA6128@lizard>
References: <20120601122118.GA6128@lizard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On SMP, kernel updates vmstats only once per second, which makes vmevent
unusable. Let's fix it by updating vmstats before sampling.

Reported-by: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
---
 mm/vmevent.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/vmevent.c b/mm/vmevent.c
index 4ca2a04..35fd0d5 100644
--- a/mm/vmevent.c
+++ b/mm/vmevent.c
@@ -2,6 +2,7 @@
 #include <linux/atomic.h>
 #include <linux/compiler.h>
 #include <linux/vmevent.h>
+#include <linux/mm.h>
 #include <linux/syscalls.h>
 #include <linux/workqueue.h>
 #include <linux/file.h>
@@ -163,6 +164,9 @@ static void vmevent_sample(struct vmevent_watch *watch)
 
 	if (atomic_read(&watch->pending))
 		return;
+
+	refresh_vm_stats();
+
 	if (!vmevent_match(watch))
 		return;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
