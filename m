Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 0C73B6B0037
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:10:06 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1V4Acm-00030j-9Z
	for linux-mm@kvack.org; Tue, 30 Jul 2013 16:10:04 +0200
Received: from cpe-70-112-137-178.austin.res.rr.com ([70.112.137.178])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 30 Jul 2013 16:10:04 +0200
Received: from habanero by cpe-70-112-137-178.austin.res.rr.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 30 Jul 2013 16:10:04 +0200
From: Andrew Theurer <habanero@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/18] Basic scheduler support for automatic NUMA balancing V5
Date: Tue, 30 Jul 2013 13:58:36 +0000 (UTC)
Message-ID: <loom.20130730T151357-253@post.gmane.org>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Mel Gorman <mgorman <at> suse.de> writes:

Hello, Mel.

> This continues to build on the previous feedback and further testing and
> I'm hoping this can be finalised relatively soon. False sharing is still
> a major problem but I still think it deserves its own series. Minimally I
> think the fact that we are now scanning shared pages without much additional
> system overhead is a big step in the right direction.

Unfortunately, I am not seeing any improvement for situations where there
are more than one multi-threaded processes running.  These would be one or
more processes per node, like a multi-JVM JBB test.  Or a
multi-virtual-machine test (in my case running dbench).

One of the concerns I have is that the way numa_preferred_node decision is
made.  What I am seeing is that when I run workloads as described above,
which threads of same process are likely to have accesses to same memory
areas, those threads are not grouped together and given a common preferred
node.  What happens is that the threads get different numa_preferred_nid
values, and they continue to access the same pool of memory, and just bounce
the memory back and forth.

I added a few stats to show the problem:
faults(K) is the total fault count and not decayed
aged_faults are the decayed, per node faults
switches is the number of times the preferred_nid changed

The data below is for 1 of 4 active Qemu(KVM VM) with 20 vCPUs each.  The
host is a 4 socket, 40 core, 80 thread westmere-EX.  Ideally each of the VMs
would be run in just one NUMA node.  This data was collected after dbench
was running for 5 minutes).  Notice that the tasks from a single VM are
spread across all nodes.  

pid: 57050
     tid pref_nid switches faults(K) aged_faults(K)      full_scans
   57050        2        2       3.5     .1,.2,.2,0               4
   57053        0        1      85.0 5.6,2.0,4.5,.8               4
   57054        2        2      60.5  .7,.2,2.8,2.0               4
   57055        0        2      71.0 5.0,1.0,2.0,.1               4
   57056        2        2      68.5  2.1,.3,2.5,.7               4
   57057        1        2      78.5   0,2.0,.3,1.1               4
   57058        1        2      72.0  .3,2.0,1.5,.5               4
   57059        3        2      52.0   0,.5,1.2,1.5               4
   57060        1        1      42.0     .2,2.8,0,0               4
   57061        2        2      58.0    .7,0,1.8,.8               4
   57062        0        2      48.0  2.4,1.0,.2,.6               4
   57063        2        1      45.0    .5,.2,2.7,0               4
   57064        3        2      73.5  1.5,.5,.3,2.3               4
   57065        0        1      70.0   4.2,.5,0,1.7               4
   57066        3        2      65.0    0,0,1.5,3.2               4
   57067        2        2      52.9   .2,0,5.0,4.2               4
   57068        1        2      50.0    0,1.5,0,1.5               4
   57069        1        2      45.5    .5,2.2,.8,0               4
   57070        1        2      54.0   .1,2.0,1.0,0               4
   57071        0        2      53.0  3.5,0,1.0,1.1               4
   57072        0        2      45.6      2.5,0,0,0               4
   57074       -1        0       0.0              0               0
   69199        2        1       0.0        0,0,0,0               4
   69200        0        3       0.0        0,0,0,0               4
   69201        0        3       0.0        0,0,0,0               4

Here's one more Qemu process which has pretty much the same issue (all 4
look the same)

pid: 57108
     tid pref_nid switches faults(K) aged_faults(K)      full_scans
   57108        3        1       2.3      0,.1,0,.3               5
   57111        3        1      81.2 3.7,4.5,0,13.2               5
   57112        3        2      55.0   0,1.5,.3,8.3               5
   57113        1        2     108.51.7,27.1,1.5,1.0               5
   57114        2        3      45.5 2.5,.3,4.2,1.8               5
   57115        2        3      41.5   .2,.7,3.2,.2               5
   57116        1        3      58.0 1.0,5.7,.1,4.7               5
   57117        0        4      44.3  3.5,1.0,.7,.8               5
   57118        2        3      47.5     0,0,6.7,.5               5
   57119        1        3      52.5  1.7,5.6,.1,.5               5
   57120        0        3      51.5  7.0,.5,.1,2.0               5
   57121        3        2      38.0    1.0,0,0,4.7               5
   57122        3        3      38.0   .1,1.5,0,6.5               5
   57123        1        2      43.5   0,4.5,1.1,.1               5
   57124        1        3      40.0     0,5.5,0,.2               5
   57125        1        3      30.0     0,3.5,.7,0               5
   57126        3        2      46.4    0,.1,.1,6.5               5
   57127        1        4      33.5  0,2.0,1.7,1.1               5
   57128        2        3      33.5   0,.2,5.2,1.0               5
   57129        2        1      42.5      0,0,3.2,0               5
   57130        0        2      26.5    2.1,0,1.3,0               5
   57132       -1        0       0.0              0               0
   69202       -1        0       0.0        0,0,0,0               5
   69203        3        1       0.0        0,0,0,0               5

I think we need to establish some sort of "attracting" and "opposing" forces
when deciding to choose a numa_perferred_nid.  Even if tasks of a same
process are not necessarily sharing memory accesses at the same time, it
might be beneficial to give them more "closeness" than say, a task from a
different process which has zero chance of having common accesses (no actual
shared memory between them).

One more thing regarding the common preferred_nid:  this does not have to
restrict us to just one preferred_nid for each process.  We certainly have
some situations where a multi-threaded process is so big that it spans the
entire system (single-JVM JBB).  In that case we can try to identify
multiple thread groups within that process, and each can have a different
preferred_nid.  Might even discover that the number of thread-groups =
number of threads (complete isolation in memory access pattern between the
threads).

Here's the stats patch (I am sending this via gmane, so this patch might get
garbled):

signed-off-by: Andrew Theurer <habanero@linux.vnet.ibm.com>

diff -Naurp linux-git.numabalv5-host/fs/proc/array.c
linux-git.numabalv5-stats-host/fs/proc/array.c
--- linux-git.numabalv5-host/fs/proc/array.c	2013-07-30 08:50:12.039076879 -0500
+++ linux-git.numabalv5-stats-host/fs/proc/array.c	2013-07-30
08:40:32.539036816 -0500
@@ -344,6 +344,26 @@ static inline void task_seccomp(struct s
 #endif
 }
 
+static inline void task_numa(struct seq_file *m,
+						struct task_struct *p)
+{
+	int nid;
+
+	if (p->raw_numa_faults) {
+		seq_printf(m,"full_scans:\t%d\n", ACCESS_ONCE(p->mm->numa_scan_seq));
+		seq_printf(m,"raw_faults:\t%lu\n", p->raw_numa_faults);
+	}
+	if (p->numa_faults) {
+		seq_printf(m,"aged_faults:\t");
+        	for (nid = 0; nid < nr_node_ids; nid++)
+                	seq_printf(m, "%lu ", p->numa_faults[task_faults_idx(nid,
1)]);
+	}
+	seq_printf(m, "\npreferred_nid:\t%d\n"
+			"preferred_nid_switches:\t%d\n",
+			p->numa_preferred_nid,
+			p->numa_preferred_nid_switches);
+}
+
 static inline void task_context_switch_counts(struct seq_file *m,
 						struct task_struct *p)
 {
@@ -363,6 +383,16 @@ static void task_cpus_allowed(struct seq
 	seq_putc(m, '\n');
 }
 
+int proc_pid_numa(struct seq_file *m, struct pid_namespace *ns,
+			struct pid *pid, struct task_struct *task)
+{
+	struct mm_struct *mm = get_task_mm(task);
+
+	if (mm)
+		task_numa(m, task);
+	return 0;
+}
+
 int proc_pid_status(struct seq_file *m, struct pid_namespace *ns,
 			struct pid *pid, struct task_struct *task)
 {
diff -Naurp linux-git.numabalv5-host/fs/proc/base.c
linux-git.numabalv5-stats-host/fs/proc/base.c
--- linux-git.numabalv5-host/fs/proc/base.c	2013-07-26 12:51:58.103854539 -0500
+++ linux-git.numabalv5-stats-host/fs/proc/base.c	2013-07-25
08:39:20.424140726 -0500
@@ -2853,6 +2853,7 @@ static const struct pid_entry tid_base_s
 	REG("environ",   S_IRUSR, proc_environ_operations),
 	INF("auxv",      S_IRUSR, proc_pid_auxv),
 	ONE("status",    S_IRUGO, proc_pid_status),
+	ONE("numa",      S_IRUGO, proc_pid_numa),
 	ONE("personality", S_IRUGO, proc_pid_personality),
 	INF("limits",	 S_IRUGO, proc_pid_limits),
 #ifdef CONFIG_SCHED_DEBUG
diff -Naurp linux-git.numabalv5-host/include/linux/sched.h
linux-git.numabalv5-stats-host/include/linux/sched.h
--- linux-git.numabalv5-host/include/linux/sched.h	2013-07-26
12:54:26.141858634 -0500
+++ linux-git.numabalv5-stats-host/include/linux/sched.h	2013-07-25
09:09:09.571245867 -0500
@@ -1522,8 +1522,10 @@ struct task_struct {
 	 * decay and these values are copied.
 	 */
 	unsigned long *numa_faults_buffer;
+	unsigned long raw_numa_faults;
 
 	int numa_preferred_nid;
+	int numa_preferred_nid_switches;
 #endif /* CONFIG_NUMA_BALANCING */
 
 	struct rcu_head rcu;
@@ -1604,6 +1606,10 @@ struct task_struct {
 #ifdef CONFIG_NUMA_BALANCING
 extern void task_numa_fault(int last_node, int node, int pages, bool migrated);
 extern void set_numabalancing_state(bool enabled);
+static inline int task_faults_idx(int nid, int priv)
+{
+        return 2 * nid + priv;
+}
 
 #else
 static inline void task_numa_fault(int last_node, int node, int pages,
diff -Naurp linux-git.numabalv5-host/kernel/sched/core.c
linux-git.numabalv5-stats-host/kernel/sched/core.c
--- linux-git.numabalv5-host/kernel/sched/core.c	2013-07-26
12:53:17.232856728 -0500
+++ linux-git.numabalv5-stats-host/kernel/sched/core.c	2013-07-26
12:57:24.452863565 -0500
@@ -1593,9 +1593,11 @@ static void __sched_fork(struct task_str
 	p->numa_migrate_seq = 0;
 	p->numa_scan_period = sysctl_numa_balancing_scan_delay;
 	p->numa_preferred_nid = -1;
+	p->numa_preferred_nid_switches = 0;
 	p->numa_work.next = &p->numa_work;
 	p->numa_faults = NULL;
 	p->numa_faults_buffer = NULL;
+	p->raw_numa_faults = 0;
 #endif /* CONFIG_NUMA_BALANCING */
 }
 
diff -Naurp linux-git.numabalv5-host/kernel/sched/fair.c
linux-git.numabalv5-stats-host/kernel/sched/fair.c
--- linux-git.numabalv5-host/kernel/sched/fair.c	2013-07-26
12:54:12.717858262 -0500
+++ linux-git.numabalv5-stats-host/kernel/sched/fair.c	2013-07-26
12:56:32.804862137 -0500
@@ -841,11 +841,6 @@ static unsigned int task_scan_max(struct
  */
 unsigned int sysctl_numa_balancing_settle_count __read_mostly = 3;
 
-static inline int task_faults_idx(int nid, int priv)
-{
-	return 2 * nid + priv;
-}
-
 static unsigned long source_load(int cpu, int type);
 static unsigned long target_load(int cpu, int type);
 static unsigned long power_of(int cpu);
@@ -1026,6 +1021,7 @@ static void task_numa_placement(struct t
 
 		/* Queue task on preferred node if possible */
 		p->numa_preferred_nid = max_nid;
+		p->numa_preferred_nid_switches++;
 		p->numa_migrate_seq = 0;
 		numa_migrate_preferred(p);
 
@@ -1094,6 +1090,8 @@ void task_numa_fault(int last_nidpid, in
 
 	/* Record the fault, double the weight if pages were migrated */
 	p->numa_faults_buffer[task_faults_idx(node, priv)] += pages << migrated;
+
+	p->raw_numa_faults += pages;
 }
 
 static void reset_ptenuma_scan(struct task_struct *p)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
