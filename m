Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8B225900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 12:23:14 -0400 (EDT)
Date: Sun, 17 Apr 2011 21:53:08 +0530
From: Raghavendra D Prabhu <rprabhu@wnohang.net>
Subject: [PATCH 1/1] Add check for dirty_writeback_interval in
 bdi_wakeup_thread_delayed
Message-ID: <20110417162308.GA1208@Xye>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>, Jens Axboe <jaxboe@fusionio.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

In the function bdi_wakeup_thread_delayed, no checks are performed on
dirty_writeback_interval unlike other places and timeout is being set to
zero as result, thus defeating the purpose. So, I have changed it to be
passed default value of interval which is 500 centiseconds, when it is
set to zero.
I have also verified this and tested it.

Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
---
  mm/backing-dev.c |    5 ++++-
  1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index befc875..d06533c 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -336,7 +336,10 @@ void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
  {
  	unsigned long timeout;
  
-	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
+	if (dirty_writeback_interval)
+		timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
+	else
+		timeout = msecs_to_jiffies(5000);
  	mod_timer(&bdi->wb.wakeup_timer, jiffies + timeout);
  }
  
-- 
1.7.4.4

--------------------------
Raghavendra Prabhu
GPG Id : D72BE977

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
