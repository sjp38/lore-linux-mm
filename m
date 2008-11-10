Received: by yw-out-1718.google.com with SMTP id 5so968629ywm.26
        for <linux-mm@kvack.org>; Mon, 10 Nov 2008 12:58:35 -0800 (PST)
Message-ID: <4918A074.1050003@gmail.com>
Date: Mon, 10 Nov 2008 21:58:28 +0100
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: [PATCH -mm] mm: fine-grained dirty_ratio_pcm and dirty_background_ratio_pcm
 (v2)
References: <1221232192-13553-1-git-send-email-righi.andrea@gmail.com> <20080912131816.e0cfac7a.akpm@linux-foundation.org> <532480950809221641y3471267esff82a14be8056586@mail.gmail.com> <48EB4236.1060100@linux.vnet.ibm.com> <48EB851D.2030300@gmail.com> <20081008101642.fcfb9186.kamezawa.hiroyu@jp.fujitsu.com> <48ECB215.4040409@linux.vnet.ibm.com> <48EE236A.90007@gmail.com>
In-Reply-To: <48EE236A.90007@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com
Cc: balbir@linux.vnet.ibm.com, Michael Rubin <mrubin@google.com>, menage@google.com, dave@linux.vnet.ibm.com, chlunde@ping.uio.no, dpshah@google.com, eric.rannaud@gmail.com, fernando@oss.ntt.co.jp, agk@sourceware.org, m.innocenti@cineca.it, s-uchida@ap.jp.nec.com, ryov@valinux.co.jp, matt@bluehost.com, dradford@bluehost.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, containers@lists.osdl.org
List-ID: <linux-mm.kvack.org>

The current granularity of 5% of dirtyable memory for dirty pages writeback is
too coarse for large memory machines and this will get worse as
memory-size/disk-speed ratio continues to increase.

These large writebacks can be unpleasant for desktop or latency-sensitive
environments, where the time to complete each writeback can be perceived as a
lack of responsiveness by the whole system.

Following there's a similar solution as discussed in [1], but a little
bit simplified in order to provide the same functionality (in particular
to avoid backward compatibility problems) and reduce the amount of code
needed to implement an in-kernel parser to handle percentages with
decimals digits.

The kernel provides the following parameters:
 - dirty_ratio, dirty_background_ratio in percentage (1 ... 100)
 - dirty_ratio_pcm, dirty_background_ratio_pcm in units of percent mille (1 ... 100,000)

Both dirty_ratio and dirty_ratio_pcm refer to the same vm_dirty_ratio variable,
only the interface to read/write this value is different. The same is valid for
dirty_background_ratio.

In this way it's possible to provide a fine-grained interface to configure the
writeback policy and at the same time preserve the compatibility with the old
dirty_ratio / dirty_background_ratio users.

Examples:
 # echo 5 > /proc/sys/vm/dirty_ratio
 # cat /proc/sys/vm/dirty_ratio
 5
 # cat /proc/sys/vm/dirty_ratio_pcm
 5000

 # echo 500 > /proc/sys/vm/dirty_ratio_pcm
 # cat /proc/sys/vm/dirty_ratio
 0
 # cat /proc/sys/vm/dirty_ratio_pcm
 500

 # echo 5500 > /proc/sys/vm/dirty_ratio_pcm
 # cat /proc/sys/vm/dirty_ratio
 5
 # cat /proc/sys/vm/dirty_ratio_pcm
 5500

Changelog: (v1 -> v2)

* fix overflow in 32bit systems (calc_period_shift needs a u64)
* rebase (and tested) to 2.6.28-rc2-mm1

[1] http://lkml.org/lkml/2008/10/7/230

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 Documentation/filesystems/proc.txt |   20 +++++++++
 include/linux/sysctl.h             |    7 +++
 kernel/sysctl.c                    |   80 +++++++++++++++++++++++++++++++++--
 kernel/sysctl_check.c              |    3 +
 mm/page-writeback.c                |   31 +++++++++++---
 5 files changed, 129 insertions(+), 12 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index bcceb99..38ed5bf 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -1389,6 +1389,16 @@ pages + file cache, not including locked pages and HugePages), the number of
 pages at which the pdflush background writeback daemon will start writing out
 dirty data.
 
+dirty_background_ratio_pcm
+--------------------------
+
+A fine-grained interface to configure dirty_background_ratio.
+
+Contains, as a percentage in units of pcm (percent mille) of the dirtyable
+system memory (free pages + mapped pages + file cache, not including locked
+pages and HugePages), the number of pages at which the pdflush background
+writeback daemon will start writing out dirty data.
+
 dirty_ratio
 -----------------
 
@@ -1397,6 +1407,16 @@ pages + file cache, not including locked pages and HugePages), the number of
 pages at which a process which is generating disk writes will itself start
 writing out dirty data.
 
+dirty_ratio_pcm
+---------------
+
+A fine-grained interface to configure dirty_ratio.
+
+Contains, as a percentage in units of pcm (percent mille) of the dirtyable
+system memory (free pages + mapped pages + file cache, not including locked
+pages and HugePages), the number of pages at which a process which is
+generating disk writes will itself start writing out dirty data.
+
 dirty_writeback_centisecs
 -------------------------
 
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 39d471d..799594b 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -32,6 +32,9 @@
 struct file;
 struct completion;
 
+#define PERCENT_PCM	1000
+#define ONE_HUNDRED_PCM (100 * PERCENT_PCM)
+
 #define CTL_MAXNAME 10		/* how many path components do we allow in a
 				   call to sysctl?   In other words, what is
 				   the largest acceptable value for the nlen
@@ -205,6 +208,8 @@ enum
 	VM_PANIC_ON_OOM=33,	/* panic at out-of-memory */
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
+	VM_DIRTY_BACKGROUND_PCM = 36, /* fine-grained dirty_background_ratio */
+	VM_DIRTY_RATIO_PCM = 37, /* fine-grained dirty_ratio */
 };
 
 
@@ -991,6 +996,8 @@ extern int proc_dointvec_userhz_jiffies(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
 extern int proc_dointvec_ms_jiffies(struct ctl_table *, int, struct file *,
 				    void __user *, size_t *, loff_t *);
+extern int proc_dointvec_pcm_minmax(struct ctl_table *, int, struct file *,
+				    void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_minmax(struct ctl_table *, int, struct file *,
 				  void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d14953a..06ba902 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -88,9 +88,7 @@ extern int rcutorture_runnable;
 #endif /* #ifdef CONFIG_RCU_TORTURE_TEST */
 
 /* Constants used for minimum and  maximum */
-#if defined(CONFIG_HIGHMEM) || defined(CONFIG_DETECT_SOFTLOCKUP)
 static int one = 1;
-#endif
 
 #ifdef CONFIG_DETECT_SOFTLOCKUP
 static int sixty = 60;
@@ -103,6 +101,7 @@ static int two = 2;
 
 static int zero;
 static int one_hundred = 100;
+static int one_hundred_pcm = ONE_HUNDRED_PCM;
 
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
@@ -926,12 +925,23 @@ static struct ctl_table vm_table[] = {
 		.data		= &dirty_background_ratio,
 		.maxlen		= sizeof(dirty_background_ratio),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
+		.proc_handler	= &proc_dointvec_pcm_minmax,
 		.strategy	= &sysctl_intvec,
-		.extra1		= &zero,
+		.extra1		= &one,
 		.extra2		= &one_hundred,
 	},
 	{
+		.ctl_name	= VM_DIRTY_BACKGROUND_PCM,
+		.procname	= "dirty_background_ratio_pcm",
+		.data		= &dirty_background_ratio,
+		.maxlen		= sizeof(dirty_background_ratio),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &one,
+		.extra2		= &one_hundred_pcm,
+	},
+	{
 		.ctl_name	= VM_DIRTY_RATIO,
 		.procname	= "dirty_ratio",
 		.data		= &vm_dirty_ratio,
@@ -939,10 +949,21 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &dirty_ratio_handler,
 		.strategy	= &sysctl_intvec,
-		.extra1		= &zero,
+		.extra1		= &one,
 		.extra2		= &one_hundred,
 	},
 	{
+		.ctl_name	= VM_DIRTY_RATIO_PCM,
+		.procname	= "dirty_ratio_pcm",
+		.data		= &vm_dirty_ratio,
+		.maxlen		= sizeof(vm_dirty_ratio),
+		.mode		= 0644,
+		.proc_handler	= &dirty_ratio_handler,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &one,
+		.extra2		= &one_hundred_pcm,
+	},
+	{
 		.procname	= "dirty_writeback_centisecs",
 		.data		= &dirty_writeback_interval,
 		.maxlen		= sizeof(dirty_writeback_interval),
@@ -2525,6 +2546,35 @@ int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
 				     lenp, ppos, HZ, 1000l);
 }
 
+static int do_proc_dointvec_pcm_minmax_conv(int *negp, unsigned long *lvalp,
+					 int *valp, int write, void *data)
+{
+	struct do_proc_dointvec_minmax_conv_param *param = data;
+	int val;
+
+	if (write) {
+		if (*lvalp > LONG_MAX / PERCENT_PCM)
+			return -EINVAL;
+		val = *negp ? -*lvalp : *lvalp;
+		if ((param->min && *param->min > val) ||
+		    (param->max && *param->max < val))
+			return -EINVAL;
+		*valp = val * PERCENT_PCM;
+	} else {
+		unsigned long lval;
+
+		val = *valp;
+		if (val < 0) {
+			*negp = -1;
+			lval = (unsigned long)-val;
+		} else {
+			*negp = 0;
+			lval = (unsigned long)val;
+		}
+		*lvalp = lval / PERCENT_PCM;
+	}
+	return 0;
+}
 
 static int do_proc_dointvec_jiffies_conv(int *negp, unsigned long *lvalp,
 					 int *valp,
@@ -2663,6 +2713,19 @@ int proc_dointvec_ms_jiffies(struct ctl_table *table, int write, struct file *fi
 				do_proc_dointvec_ms_jiffies_conv, NULL);
 }
 
+int proc_dointvec_pcm_minmax(struct ctl_table *table, int write,
+			struct file *filp, void __user *buffer, size_t *lenp,
+			loff_t *ppos)
+{
+	struct do_proc_dointvec_minmax_conv_param param = {
+		.min = (int *)table->extra1,
+		.max = (int *)table->extra2,
+	};
+
+	return do_proc_dointvec(table, write, filp, buffer, lenp, ppos,
+				do_proc_dointvec_pcm_minmax_conv, &param);
+}
+
 static int proc_do_cad_pid(struct ctl_table *table, int write, struct file *filp,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -2711,6 +2774,13 @@ int proc_dointvec_jiffies(struct ctl_table *table, int write, struct file *filp,
 	return -ENOSYS;
 }
 
+int proc_dointvec_pcm_minmax(struct ctl_table *table, int write,
+			struct file *filp, void __user *buffer, size_t *lenp,
+			loff_t *ppos)
+{
+	return -ENOSYS;
+}
+
 int proc_dointvec_userhz_jiffies(struct ctl_table *table, int write, struct file *filp,
 		    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index c35da23..83934a8 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -111,7 +111,9 @@ static const struct trans_ctl_table trans_vm_table[] = {
 	{ VM_OVERCOMMIT_MEMORY,		"overcommit_memory" },
 	{ VM_PAGE_CLUSTER,		"page-cluster" },
 	{ VM_DIRTY_BACKGROUND,		"dirty_background_ratio" },
+	{ VM_DIRTY_BACKGROUND_PCM,	"dirty_background_ratio_pcm" },
 	{ VM_DIRTY_RATIO,		"dirty_ratio" },
+	{ VM_DIRTY_RATIO_PCM,		"dirty_ratio_pcm" },
 	{ VM_DIRTY_WB_CS,		"dirty_writeback_centisecs" },
 	{ VM_DIRTY_EXPIRE_CS,		"dirty_expire_centisecs" },
 	{ VM_NR_PDFLUSH_THREADS,	"nr_pdflush_threads" },
@@ -1494,6 +1496,7 @@ int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
 			    (table->proc_handler == proc_dostring) ||
 			    (table->proc_handler == proc_dointvec) ||
 			    (table->proc_handler == proc_dointvec_minmax) ||
+			    (table->proc_handler == proc_dointvec_pcm_minmax) ||
 			    (table->proc_handler == proc_dointvec_jiffies) ||
 			    (table->proc_handler == proc_dointvec_userhz_jiffies) ||
 			    (table->proc_handler == proc_dointvec_ms_jiffies) ||
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b3584bf..e010a39 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -66,7 +66,7 @@ static inline long sync_writeback_pages(void)
 /*
  * Start background writeback (via pdflush) at this percentage
  */
-int dirty_background_ratio = 5;
+int dirty_background_ratio = 5 * PERCENT_PCM;
 
 /*
  * free highmem will not be subtracted from the total free memory
@@ -77,7 +77,7 @@ int vm_highmem_is_dirtyable;
 /*
  * The generator of dirty data starts writeback at this percentage
  */
-int vm_dirty_ratio = 10;
+int vm_dirty_ratio = 10 * PERCENT_PCM;
 
 /*
  * The interval between `kupdate'-style writebacks, in jiffies
@@ -133,9 +133,10 @@ static struct prop_descriptor vm_dirties;
  */
 static int calc_period_shift(void)
 {
-	unsigned long dirty_total;
+	u64 dirty_total;
 
-	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) / 100;
+	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory())
+			/ ONE_HUNDRED_PCM;
 	return 2 + ilog2(dirty_total - 1);
 }
 
@@ -147,7 +148,23 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 		loff_t *ppos)
 {
 	int old_ratio = vm_dirty_ratio;
-	int ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	int ret;
+
+	switch (table->ctl_name) {
+	case VM_DIRTY_RATIO:
+		ret = proc_dointvec_pcm_minmax(table, write, filp, buffer,
+					lenp, ppos);
+		break;
+	case VM_DIRTY_RATIO_PCM:
+		ret = proc_dointvec_minmax(table, write, filp, buffer,
+					lenp, ppos);
+		break;
+	default:
+		ret = -EINVAL;
+		WARN_ON(1);
+		break;
+	}
+
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
 		int shift = calc_period_shift();
 		prop_change_shift(&vm_completions, shift);
@@ -380,8 +397,8 @@ get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
 	if (background_ratio >= dirty_ratio)
 		background_ratio = dirty_ratio / 2;
 
-	background = (background_ratio * available_memory) / 100;
-	dirty = (dirty_ratio * available_memory) / 100;
+	background = (background_ratio * available_memory) / ONE_HUNDRED_PCM;
+	dirty = (dirty_ratio * available_memory) / ONE_HUNDRED_PCM;
 	tsk = current;
 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
 		background += background / 4;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
