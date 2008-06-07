Date: Fri, 6 Jun 2008 17:24:37 -0700
From: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Subject: Re: [PATCH 2/3 v2] per-task-delay-accounting: update taskstats for
 memory reclaim delay
Message-Id: <20080606172437.bcd7d98a.kobayashi.kk@ncos.nec.co.jp>
In-Reply-To: <4848B983.4030502@linux.vnet.ibm.com>
References: <20080605162759.a6adf291.kobayashi.kk@ncos.nec.co.jp>
	<20080605163220.8397bed6.kobayashi.kk@ncos.nec.co.jp>
	<4848B983.4030502@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, nagar@watson.ibm.com, balbir@in.ibm.com, sekharan@us.ibm.com, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Add members for memory reclaim delay to taskstats,
and accumulate them in __delayacct_add_tsk() .

Signed-off-by: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
---

Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Two suggested changes
>
> 1. Please add all fields at the end (otherwise we risk breaking compatibility)
> 2. please also update Documentation/accounting/taskstats-struct.txt
>

Thanks for your suggestion.
Update version is here.

In taskstats-struct.txt, there was not a discription for "Time accounting for SMT machines".
This patch was made after the following patch had been applied.
http://lkml.org/lkml/2008/6/6/436 .

 Documentation/accounting/taskstats-struct.txt |    7 +++++++
 include/linux/taskstats.h                     |    6 +++++-
 kernel/delayacct.c                            |    3 +++
 3 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/Documentation/accounting/taskstats-struct.txt b/Documentation/accounting/taskstats-struct.txt
index cd784f4..b988d11 100644
--- a/Documentation/accounting/taskstats-struct.txt
+++ b/Documentation/accounting/taskstats-struct.txt
@@ -26,6 +26,8 @@ There are three different groups of fields in the struct taskstats:
 
 5) Time accounting for SMT machines
 
+6) Extended delay accounting fields for memory reclaim
+
 Future extension should add fields to the end of the taskstats struct, and
 should not change the relative position of each field within the struct.
 
@@ -170,4 +172,9 @@ struct taskstats {
 	__u64	ac_utimescaled;		/* utime scaled on frequency etc */
 	__u64	ac_stimescaled;		/* stime scaled on frequency etc */
 	__u64	cpu_scaled_run_real_total; /* scaled cpu_run_real_total */
+
+6) Extended delay accounting fields for memory reclaim
+	/* Delay waiting for memory reclaim */
+	__u64	freepages_count;
+	__u64	freepages_delay_total;
 }
diff --git a/include/linux/taskstats.h b/include/linux/taskstats.h
index 5d69c07..18269e9 100644
--- a/include/linux/taskstats.h
+++ b/include/linux/taskstats.h
@@ -31,7 +31,7 @@
  */
 
 
-#define TASKSTATS_VERSION	6
+#define TASKSTATS_VERSION	7
 #define TS_COMM_LEN		32	/* should be >= TASK_COMM_LEN
 					 * in linux/sched.h */
 
@@ -157,6 +157,10 @@ struct taskstats {
 	__u64	ac_utimescaled;		/* utime scaled on frequency etc */
 	__u64	ac_stimescaled;		/* stime scaled on frequency etc */
 	__u64	cpu_scaled_run_real_total; /* scaled cpu_run_real_total */
+
+	/* Delay waiting for memory reclaim */
+	__u64	freepages_count;
+	__u64	freepages_delay_total;
 };
 
 
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
