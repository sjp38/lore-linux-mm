Date: Thu, 5 Jun 2008 16:33:38 -0700
From: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
Subject: [PATCH 3/3 v2] per-task-delay-accounting: update document and
 getdelays.c for memory reclaim
Message-Id: <20080605163338.8880eb7f.kobayashi.kk@ncos.nec.co.jp>
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

Update document and make getdelays.c show delay accounting for memory reclaim.

For making a distinction between "swapping in pages" and "memory reclaim"
in getdelays.c, MEM is changed to SWAP.

Signed-off-by: Keika Kobayashi <kobayashi.kk@ncos.nec.co.jp>
---
 Documentation/accounting/delay-accounting.txt |   11 ++++++++---
 Documentation/accounting/getdelays.c          |    8 ++++++--
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/Documentation/accounting/delay-accounting.txt b/Documentation/accounting/delay-accounting.txt
index 1443cd7..8a12f07 100644
--- a/Documentation/accounting/delay-accounting.txt
+++ b/Documentation/accounting/delay-accounting.txt
@@ -11,6 +11,7 @@ the delays experienced by a task while
 a) waiting for a CPU (while being runnable)
 b) completion of synchronous block I/O initiated by the task
 c) swapping in pages
+d) memory reclaim
 
 and makes these statistics available to userspace through
 the taskstats interface.
@@ -41,7 +42,7 @@ this structure. See
      include/linux/taskstats.h
 for a description of the fields pertaining to delay accounting.
 It will generally be in the form of counters returning the cumulative
-delay seen for cpu, sync block I/O, swapin etc.
+delay seen for cpu, sync block I/O, swapin, memory reclaim etc.
 
 Taking the difference of two successive readings of a given
 counter (say cpu_delay_total) for a task will give the delay
@@ -94,7 +95,9 @@ CPU	count	real total	virtual total	delay total
 	7876	92005750	100000000	24001500
 IO	count	delay total
 	0	0
-MEM	count	delay total
+SWAP	count	delay total
+	0	0
+RECLAIM	count	delay total
 	0	0
 
 Get delays seen in executing a given simple command
@@ -108,5 +111,7 @@ CPU	count	real total	virtual total	delay total
 	6	4000250		4000000		0
 IO	count	delay total
 	0	0
-MEM	count	delay total
+SWAP	count	delay total
+	0	0
+RECLAIM	count	delay total
 	0	0
diff --git a/Documentation/accounting/getdelays.c b/Documentation/accounting/getdelays.c
index 40121b5..3f7755f 100644
--- a/Documentation/accounting/getdelays.c
+++ b/Documentation/accounting/getdelays.c
@@ -196,14 +196,18 @@ void print_delayacct(struct taskstats *t)
 	       "      %15llu%15llu%15llu%15llu\n"
 	       "IO    %15s%15s\n"
 	       "      %15llu%15llu\n"
-	       "MEM   %15s%15s\n"
+	       "SWAP  %15s%15s\n"
+	       "      %15llu%15llu\n"
+	       "RECLAIM  %12s%15s\n"
 	       "      %15llu%15llu\n",
 	       "count", "real total", "virtual total", "delay total",
 	       t->cpu_count, t->cpu_run_real_total, t->cpu_run_virtual_total,
 	       t->cpu_delay_total,
 	       "count", "delay total",
 	       t->blkio_count, t->blkio_delay_total,
-	       "count", "delay total", t->swapin_count, t->swapin_delay_total);
+	       "count", "delay total", t->swapin_count, t->swapin_delay_total,
+	       "count", "delay total",
+	       t->freepages_count, t->freepages_delay_total);
 }
 
 void task_context_switch_counts(struct taskstats *t)
-- 
1.5.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
