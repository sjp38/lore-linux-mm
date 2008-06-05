Date: Thu, 5 Jun 2008 16:32:20 -0700
From: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Subject: [PATCH 2/3 v2] per-task-delay-accounting: update taskstats for
 memory reclaim delay
Message-Id: <20080605163220.8397bed6.kobayashi.kk@ncos.nec.co.jp>
In-Reply-To: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp>
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nagar@watson.ibm.com, balbir@in.ibm.com, sekharan@us.ibm.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Add members for memory reclaim delay to taskstats,
and accumulate them in __delayacct_add_tsk() .

Signed-off-by: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
---
 include/linux/taskstats.h |    4 ++++
 kernel/delayacct.c        |    3 +++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/taskstats.h b/include/linux/taskstats.h
index 5d69c07..87aae21 100644
--- a/include/linux/taskstats.h
+++ b/include/linux/taskstats.h
@@ -81,6 +81,10 @@ struct taskstats {
 	__u64	swapin_count;
 	__u64	swapin_delay_total;
 
+	/* Delay waiting for memory reclaim */
+	__u64	freepages_count;
+	__u64	freepages_delay_total;
+
 	/* cpu "wall-clock" running time
 	 * On some architectures, value will adjust for cpu time stolen
 	 * from the kernel in involuntary waits due to virtualization.
diff --git a/kernel/delayacct.c b/kernel/delayacct.c
index 84b6782..b3179da 100644
--- a/kernel/delayacct.c
+++ b/kernel/delayacct.c
@@ -145,8 +145,11 @@ int __delayacct_add_tsk(struct taskstats *d, struct task_struct *tsk)
 	d->blkio_delay_total = (tmp < d->blkio_delay_total) ? 0 : tmp;
 	tmp = d->swapin_delay_total + tsk->delays->swapin_delay;
 	d->swapin_delay_total = (tmp < d->swapin_delay_total) ? 0 : tmp;
+	tmp = d->freepages_delay_total + tsk->delays->freepages_delay;
+	d->freepages_delay_total = (tmp < d->freepages_delay_total) ? 0 : tmp;
 	d->blkio_count += tsk->delays->blkio_count;
 	d->swapin_count += tsk->delays->swapin_count;
+	d->freepages_count += tsk->delays->freepages_count;
 	spin_unlock_irqrestore(&tsk->delays->lock, flags);
 
 done:
-- 
1.5.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
