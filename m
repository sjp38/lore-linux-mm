Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 7B3116B004D
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 04:38:23 -0500 (EST)
From: =?ks_c_5601-1987?B?uc7C+cij?= <chanho.min@lge.com>
Subject: [PATCH] mm/backing-dev.c: fix crash when USB/SCSI device is detached
Date: Mon, 2 Jan 2012 18:38:21 +0900
Message-ID: <004401ccc932$444a0070$ccde0150$@min@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="ks_c_5601-1987"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: 'Jens Axboe' <axboe@kernel.dk>, 'Wu Fengguang' <fengguang.wu@intel.com>, 'Andrew Morton' <akpm@linux-foundation.org>

from Chanho Min <chanho.min@lge.com>

System may crash in backing-dev.c when removal SCSI device is detached.
bdi task is killed by bdi_unregister()/'khubd', but task's point remains.
Shortly afterward, If 'wb->wakeup_timer' is expired before
del_timer()/bdi_forker_thread,
wakeup_timer_fn() may wake up the dead thread which cause the crash.
'bdi->wb.task' should be NULL as this patch.

Signed-off-by: Chanho Min <chanho.min@lge.com>
---
 mm/backing-dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 71034f4..4378a5e 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -607,6 +607,7 @@ static void bdi_wb_shutdown(struct backing_dev_info
*bdi)
        if (bdi->wb.task) {
                thaw_process(bdi->wb.task);
                kthread_stop(bdi->wb.task);
+               bdi->wb.task = NULL;
        }
 }

-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
