Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 595696B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 08:51:54 -0400 (EDT)
Message-ID: <52287E66.9010107@redhat.com>
Date: Thu, 05 Sep 2013 14:51:50 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: [PATCH 2/2 v2] mm: allow to set overcommit ratio more precisely
References: <1376925478-15506-1-git-send-email-jmarchan@redhat.com> <1376925478-15506-2-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1376925478-15506-2-git-send-email-jmarchan@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>


Changes since v1:
 - use overcommit_ratio_ppm instead of overcommit_kbytes
 - keep both variables in sync

Some applications that run on HPC clusters are designed around the
availability of RAM and the overcommit ratio is fine tuned to get the
maximum usage of memory without swapping. With growing memory, the 1%
of all RAM grain provided by overcommit_ratio has become too coarse
for these workload (on a 2TB machine it represents no less than
20GB).

This patch adds the new overcommit_ratio_ppm sysctl variable that
allow to set overcommit ratio with a part per million precision.
The old overcommit_ratio variable can still be used to set and read
the ratio with a 1% precision. That way, overcommit_ratio interface
isn't broken in any way that I can imagine.

Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
---
 include/linux/mman.h   |    6 ++--
 include/linux/sysctl.h |    2 +
 kernel/sysctl.c        |   63 +++++++++++++++++++++++++++++++++++++++++++++--
 mm/mmap.c              |    2 +-
 mm/nommu.c             |    2 +-
 5 files changed, 67 insertions(+), 8 deletions(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index d622d34..24f9c12 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -11,7 +11,7 @@
 #include <linux/swap.h>
 
 extern int sysctl_overcommit_memory;
-extern int sysctl_overcommit_ratio;
+extern int sysctl_overcommit_ratio_ppm;
 extern struct percpu_counter vm_committed_as;
 
 #ifdef CONFIG_SMP
@@ -96,7 +96,7 @@ calc_vm_flag_bits(unsigned long flags)
  */
 static inline unsigned long vm_commit_limit()
 {
-	return ((totalram_pages - hugetlb_total_pages())
-		* sysctl_overcommit_ratio / 100) + total_swap_pages;
+	return ((u64) (totalram_pages - hugetlb_total_pages())
+		* sysctl_overcommit_ratio_ppm / 100000) + total_swap_pages;
 }
 #endif /* _LINUX_MMAN_H */
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 14a8ff2..2e2389c 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -51,6 +51,8 @@ extern int proc_dointvec_userhz_jiffies(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 extern int proc_dointvec_ms_jiffies(struct ctl_table *, int,
 				    void __user *, size_t *, loff_t *);
+extern int proc_dointvec_percent_ppm(struct ctl_table *, int,
+				     void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_minmax(struct ctl_table *, int,
 				  void __user *, size_t *, loff_t *);
 extern int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 07f6fc4..a4d2e37 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -96,7 +96,7 @@
 
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
-extern int sysctl_overcommit_ratio;
+extern int sysctl_overcommit_ratio_ppm;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1116,8 +1116,15 @@ static struct ctl_table vm_table[] = {
 	},
 	{
 		.procname	= "overcommit_ratio",
-		.data		= &sysctl_overcommit_ratio,
-		.maxlen		= sizeof(sysctl_overcommit_ratio),
+		.data		= &sysctl_overcommit_ratio_ppm,
+		.maxlen		= sizeof(sysctl_overcommit_ratio_ppm),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_percent_ppm,
+	},
+	{
+		.procname	= "overcommit_ratio_ppm",
+		.data		= &sysctl_overcommit_ratio_ppm,
+		.maxlen		= sizeof(sysctl_overcommit_ratio_ppm),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
@@ -2433,6 +2440,56 @@ int proc_dointvec_ms_jiffies(struct ctl_table *table, int write,
 				do_proc_dointvec_ms_jiffies_conv, NULL);
 }
 
+static int do_proc_dointvec_percent_ppm_conv(bool *negp, unsigned long *lvalp,
+					     int *valp,
+					     int write, void *data)
+{
+	if (write) {
+		unsigned long ppm = (*negp ? -*lvalp : *lvalp) * 10000;
+
+		if (ppm > INT_MAX)
+			return 1;
+		*valp = (int)ppm;
+	} else {
+		int val = *valp;
+		unsigned long lval;
+		if (val < 0) {
+			*negp = true;
+			lval = (unsigned long)-val;
+		} else {
+			*negp = false;
+			lval = (unsigned long)val;
+		}
+		*lvalp = lval / 10000;
+		if (lval % 10000 >= 5000)
+			(*lvalp)++;
+	}
+	return 0;
+}
+
+/**
+ * proc_dointvec_percent_ppm - read a vector of integers as percent and convert it to ppm
+ * @table: the sysctl table
+ * @write: %TRUE if this is a write to the sysctl file
+ * @buffer: the user buffer
+ * @lenp: the size of the user buffer
+ * @ppos: file position
+ * @ppos: the current position in the file
+ *
+ * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
+ * values from/to the user buffer, treated as an ASCII string.
+ * The values read are assumed to be in percents, and are converted
+ * into parts per million.
+ *
+ * Returns 0 on success.
+ */
+int proc_dointvec_percent_ppm(struct ctl_table *table, int write,
+			      void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return do_proc_dointvec(table, write, buffer, lenp, ppos,
+				do_proc_dointvec_percent_ppm_conv, NULL);
+}
+
 static int proc_do_cad_pid(struct ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
diff --git a/mm/mmap.c b/mm/mmap.c
index 06c98f8..bdec0e1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -85,7 +85,7 @@ pgprot_t vm_get_page_prot(unsigned long vm_flags)
 EXPORT_SYMBOL(vm_get_page_prot);
 
 int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
-int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
+int sysctl_overcommit_ratio_ppm __read_mostly = 500000;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
 unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
diff --git a/mm/nommu.c b/mm/nommu.c
index d8a957b..cf10a9b 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -59,7 +59,7 @@ unsigned long max_mapnr;
 unsigned long highest_memmap_pfn;
 struct percpu_counter vm_committed_as;
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
-int sysctl_overcommit_ratio = 50; /* default is 50% */
+int sysctl_overcommit_ratio_ppm = 500000; /* default is 50% */
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
