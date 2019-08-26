Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FB83C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFFFD21883
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="DY6w3wqt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFFFD21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19D8E6B0271; Mon, 26 Aug 2019 15:37:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 176496B0273; Mon, 26 Aug 2019 15:37:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08C246B0274; Mon, 26 Aug 2019 15:37:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0157.hostedemail.com [216.40.44.157])
	by kanga.kvack.org (Postfix) with ESMTP id CE1C86B0271
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:59 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 786BA4FED
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:59 +0000 (UTC)
X-FDA: 75865586958.26.class96_1fd92103b952c
X-HE-Tag: class96_1fd92103b952c
X-Filterd-Recvd-Size: 17287
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:58 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 7209742C3FA;
	Mon, 26 Aug 2019 12:37:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848263;
	bh=P6qcBeZLPJpeVxQ8zSOSXiPxmRjanZu8toPXO61DwXc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=DY6w3wqt1y2vmlcj7hh99UzRuze5GxzrPhVe5S8cdFJX9U0SjwndBAk1vjneLxhzw
	 QJKwNxpg5rqRBisyx3mTsVP1f4FqIW39Kk6wm9aKJe090AjZrhq9C7rXDBuMDt1ury
	 LgqC6RNuM8KJWuT7m0KSSbnagy7btMmK0Cc5WJcldRZApECszFyfBDVyd5Znorv4KN
	 ImJ14c8qnjoZs4/N3gmjvqrL8IbA3mlBLbKzDODpEVgw1zZ9CHF2VwCYkZXyLWIsPR
	 N1InihTRrLuXSQtfUC73d+6zYuk7h6uwAADSg7BzpRJ+jCDcQOnBsdI+CLb6NeCPyH
	 0zaV2M/JEvx6g==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 5B91542C3E7;
	Mon, 26 Aug 2019 12:37:43 -0700 (PDT)
From: Edward Chron <echron@arista.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>,
	Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Shakeel Butt <shakeelb@google.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	colona@arista.com,
	Edward Chron <echron@arista.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Subject: [PATCH 10/10] mm/oom_debug: Add Enhanced Process Print Information
Date: Mon, 26 Aug 2019 12:36:38 -0700
Message-Id: <20190826193638.6638-11-echron@arista.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190826193638.6638-1-echron@arista.com>
References: <20190826193638.6638-1-echron@arista.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add OOM Debug code that prints additional detailed information about
users processes that were considered for OOM killing for any print
selected processes. The information is displayed for each user process
that OOM prints in the output.

This supplemental per user process information is very helpful for
determing how process memory is used to allow OOM event root cause
identifcation that might not otherwise be possible.

Configuring Enhanced Process Print Information
----------------------------------------------
The DEBUG_OOM_ENHANCED_PROCESS_PRINT is the config entry defined for
this OOM Debug option.  This option is dependent on the OOM Debug
option DEBUG_OOM_SELECT_PROCESS which adds code to allow processes
that are considered for OOM kill to be selectively printed, only
printing processes that use a specified minimum amount of memory.

The kernel configuration entry for this option can be found in the
config file at: Kernel hacking, Memory Debugging, Debug OOM,
Debug OOM Process Selection, Debug OOM Enhanced Process Print.
Both Debug OOM Process Selection and Debug OOM Enhanced Process Print
entries must be selected.

Dynamic disable or re-enable this OOM Debug option
--------------------------------------------------
This option may be disabled or re-enabled using the debugfs entry for
this OOM debug option. The debugfs file to enable this entry is found at:
/sys/kernel/debug/oom/process_enhanced_print_enabled where the enabled
file's value determines whether the facility is enabled or disabled.
A value of 1 is enabled (default) and a value of 0 is disabled.

Content and format of process record and Task state headers
-----------------------------------------------------------
Each OOM process entry printed include memory information about the
process. Memory usage is specified in KiB for memory values instead of
pages. Each entry includes the following fields:
pid, ppid, ruid, euid, tgid, State (S), the oom_score_adjust (Adjust),
task comm value (name), and also memory values (all in KB): VmemKiB,
MaxRssKiB, CurRssKiB, PteKiB, SwapKiB, socket pages (SockKiB), LibKiB,
TextPgKiB, HeapPgKiB, StackKiB, FileKiB and shared memory (ShmemKiB).
Counts of page reads (ReadPgs) and page faults (FaultPgs) are included.

Sample Output
-------------
OOM Process select print headers and line of process enhanced output:

Aug  6 09:37:21 egc103 kernel: Tasks state (memory values in KiB):
Aug  6 09:37:21 egc103 kernel: [  pid  ]    ppid    ruid    euid
    tgid S  utimeSec  stimeSec   VmemKiB MaxRssKiB CurRssKiB
    PteKiB   SwapKiB   SockKiB     LibKiB   TextKiB   HeapKiB
  StackKiB   FileKiB  ShmemKiB   ReadPgs  FaultPgs   LockKiB
 PinnedKiB Adjust name

Aug  6 09:37:21 egc103 kernel: [   7707]    7553   10383   10383
    7707 S     0.132     0.350   1056804   1054040   1052796
      2092         0         0       1944       684   1052860
       136         4         0         0         0         0
         0   1000 oomprocs


Signed-off-by: Edward Chron <echron@arista.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 mm/Kconfig.debug    |  23 +++++
 mm/oom_kill.c       |  23 ++++-
 mm/oom_kill_debug.c | 236 ++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill_debug.h |   5 +
 4 files changed, 285 insertions(+), 2 deletions(-)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 4414e46f72c6..2bc843727968 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -320,3 +320,26 @@ config DEBUG_OOM_PROCESS_SELECT_PRINT
 	  print limit value of 10 or 1% of memory.
=20
 	  If unsure, say N.
+
+config DEBUG_OOM_ENHANCED_PROCESS_PRINT
+	bool "Debug OOM Enhanced Process Print"
+	depends on DEBUG_OOM_PROCESS_SELECT_PRINT
+	help
+	  Each OOM process entry printed include memory information about
+	  the process. Memory usage is specified in KiB (KB) for memory
+	  values, not pages. Each entry includes the following fields:
+	  pid, ppid, ruid, euid, tgid, State (S), utime in seconds,
+	  stime in seconds, the number of read pages (ReadPgs), number of
+	  page faults (FaultPgs), the number of lock pages (LockPgs), the
+	  oom_score_adjust value (Adjust), memory percentage used (MemPct),
+	  oom_score (Score), task comm value (name), and also memory values
+	  (all in KB): VmemKiB, MaxRssKiB, CurRssKiB, PteKiB, SwapKiB,
+	  socket pages (SockKiB), LibKiB, TextPgKiB, HeapPgKiB, StackKiB,
+	  FileKiB and shared memory pages (ShmemKiB).
+
+	  If the option is configured it is enabled/disabled by setting
+	  the value of the file entry in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/process_enhanced_print_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  If unsure, say N.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index cbea289c6345..cf37caea9c5c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -417,6 +417,13 @@ static int dump_task(struct task_struct *p, void *ar=
g)
 	}
 #endif
=20
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT
+	if (oom_kill_debug_enhanced_process_print_enabled()) {
+		dump_task_prt(task, rsspgs, swappgs, pgtbl);
+		task_unlock(task);
+		return 1;
+	}
+#endif
 	pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
 		task->pid, from_kuid(&init_user_ns, task_uid(task)),
 		task->tgid, task->mm->total_vm, rsspgs, pgtbl, swappgs,
@@ -426,6 +433,19 @@ static int dump_task(struct task_struct *p, void *ar=
g)
 	return 1;
 }
=20
+static void dump_tasks_headers(void)
+{
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT
+	if (oom_kill_debug_enhanced_process_print_enabled()) {
+		pr_info("Tasks state (memory values in KiB):\n");
+		pr_info("[  pid  ]    ppid    ruid    euid    tgid S  utimeSec  stimeS=
ec   VmemKiB MaxRssKiB CurRssKiB    PteKiB   SwapKiB   SockKiB     LibKiB=
   TextKiB   HeapKiB  StackKiB   FileKiB  ShmemKiB     ReadPgs    FaultPg=
s   LockKiB PinnedKiB Adjust name\n");
+		return;
+	}
+#endif
+	pr_info("Tasks state (memory values in pages):\n");
+	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapent=
s oom_score_adj name\n");
+}
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
=20
 /**
@@ -443,8 +463,7 @@ static void dump_tasks(struct oom_control *oc)
 	u32 total =3D 0;
 	u32 prted =3D 0;
=20
-	pr_info("Tasks state (memory values in pages):\n");
-	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapent=
s oom_score_adj name\n");
+	dump_tasks_headers();
=20
 #ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
 	oc->minpgs =3D oom_kill_debug_min_task_pages(oc->totalpages);
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index ad937b3d59f3..467f7add4397 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -171,6 +171,12 @@
 #ifdef CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT
 #include <linux/vmalloc.h>
 #endif
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT
+#include <linux/fdtable.h>
+#include <linux/net.h>
+#include <net/sock.h>
+#include <linux/sched/cputime.h>
+#endif
=20
 #define OOMD_MAX_FNAME 48
 #define OOMD_MAX_OPTNAME 32
@@ -250,6 +256,12 @@ static struct oom_debug_option oom_debug_options_tab=
le[] =3D {
 		.option_name	=3D "slab_enhanced_print_",
 		.support_tpercent =3D false,
 	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT
+	{
+		.option_name	=3D "process_enhanced_print_",
+		.support_tpercent =3D false,
+	},
 #endif
 	{}
 };
@@ -282,6 +294,9 @@ enum oom_debug_options_index {
 #endif
 #ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
 	ENHANCED_SLAB_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT
+	ENHANCED_PROCESS_STATE,
 #endif
 	OUT_OF_BOUNDS
 };
@@ -365,6 +380,12 @@ bool oom_kill_debug_enhanced_slab_print_information_=
enabled(void)
 	return oom_kill_debug_enabled(ENHANCED_SLAB_STATE);
 }
 #endif
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT
+bool oom_kill_debug_enhanced_process_print_enabled(void)
+{
+	return oom_kill_debug_enabled(ENHANCED_PROCESS_STATE);
+}
+#endif
=20
 #ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
 /*
@@ -513,6 +534,221 @@ u32 oom_kill_debug_oom_event_is(void)
 	return oom_kill_debug_oom_events;
 }
=20
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT
+/*
+ *  Account for socket(s) buffer memory in use by a task.
+ *  A task may have one or more sockets consuming socket buffer space.
+ *  Account for how much socket space each task has in use.
+ */
+static unsigned long account_for_socket_buffers(struct task_struct *task=
,
+						char *incomplete)
+{
+	unsigned long sockpgs =3D 0;
+	struct files_struct *files =3D task->files;
+	struct fdtable *fdt;
+	struct file **fds;
+	int openfilecount;
+	struct inode *inode;
+	struct socket *sock;
+	struct sock *sk;
+	unsigned long bytes;
+	int fdtsize;
+	int i;
+
+	/* Just to make sure the fds don't get closed */
+	atomic_inc(&files->count);
+	/* Make a best effort, but no reason to get hung up here */
+	if (!spin_trylock(&files->file_lock)) {
+		*incomplete =3D '*';
+		atomic_dec(&files->count);
+		return 0;
+	}
+
+	rcu_read_lock();
+	fdt =3D files_fdtable(files);
+	fdtsize =3D fdt->max_fds;
+	/* Determine how many words we need to check for open files */
+	for (i =3D fdtsize / BITS_PER_LONG; i > 0; ) {
+		if (fdt->open_fds[--i])
+			break;
+	}
+	openfilecount =3D (i + 1) * BITS_PER_LONG;  // Check each fd in the wor=
d
+	fds =3D fdt->fd;
+	for (i =3D openfilecount; i !=3D 0; i--) {
+		struct file *fp =3D *fds++;
+
+		if (fp) {
+			/* Any continue case doesn't need to be counted */
+			if (fp->f_path.dentry =3D=3D NULL)
+				continue;
+			inode =3D fp->f_path.dentry->d_inode;
+			if (inode =3D=3D NULL || !S_ISSOCK(inode->i_mode))
+				continue;
+			sock =3D fp->private_data;
+			if (sock =3D=3D NULL)
+				continue;
+			sk =3D sock->sk;
+			if (sk =3D=3D NULL)
+				continue;
+			bytes =3D roundup(sk->sk_rcvbuf, PAGE_SIZE);
+			sockpgs =3D bytes / PAGE_SIZE;
+			bytes =3D roundup(sk->sk_sndbuf, PAGE_SIZE);
+			sockpgs +=3D bytes / PAGE_SIZE;
+		}
+	}
+	rcu_read_unlock();
+
+	spin_unlock(&files->file_lock);
+	/* We're done looking at the fds */
+	atomic_dec(&files->count);
+
+	return sockpgs;
+}
+
+static u64 power10(u32 index)
+{
+	static u64 pwr10[11] =3D {1, 10, 100, 1000, 10000, 100000, 1000000,
+				10000000, 100000000, 1000000000,
+				10000000000};
+
+	return pwr10[index];
+}
+
+static u32 num_digits(u64 num)
+{
+	u32 i;
+
+	for (i =3D 1; i < 11; ++i) {
+		if (power10(i) > num)
+			return i;
+	}
+	return i;
+}
+
+static void digits_and_fraction(u64 num, u32 *p_digits, u32 *p_frac, u32=
 chars)
+{
+	*p_digits =3D num_digits(num);
+	// Allow for decimal place for fractional output
+	if (chars - 1 > *p_digits)
+		*p_frac =3D chars - 1 - *p_digits;
+	else
+		*p_frac =3D 0;
+}
+
+#define MAX_NUM_FIELD_SIZE	10
+/*
+ * Format timespec into seconds and possibly fraction, must fit in 9 byt=
es.
+ * Linux kernel doesn't support floating point so format as best we can.
+ * With 9 digits in seconds convers 31.7 years and where we can we provi=
de
+ * fractions of a second up to miliseconds.
+ */
+static void timespec_format(u64 nsecs_time, char *p_time, size_t time_si=
ze)
+{
+	struct timespec64 tspec =3D ns_to_timespec64(nsecs_time);
+	u32 digits, fracs, bytes, min;
+	u64 fraction;
+
+	digits_and_fraction(tspec.tv_sec, &digits, &fracs, time_size);
+
+	bytes =3D sprintf(p_time, "%llu", tspec.tv_sec);
+
+	if (fracs > 0) {
+		u32 frsize =3D num_digits(tspec.tv_nsec);
+
+		p_time +=3D bytes;
+		if (frsize >=3D 3) {
+			if (fracs >=3D 3)
+				min =3D frsize - 3;
+			else if (fracs >=3D 2)
+				min =3D frsize - 2;
+			else
+				min =3D frsize - 1;
+		} else if (frsize >=3D 2) {
+			if (fracs >=3D 2)
+				min =3D frsize - 2;
+			else
+				min =3D frsize - 1;
+		} else {
+			min =3D frsize - 1;
+		}
+		fraction =3D tspec.tv_nsec / power10(min);
+		sprintf(p_time, ".%llu", fraction);
+	}
+}
+
+/*
+ * Format utime, stime in seconds and possibly fractions, must fit in 9 =
bytes.
+ */
+static void time_format(struct task_struct *task, char *p_utime, char *p=
_stime)
+{
+	size_t num_size =3D MAX_NUM_FIELD_SIZE;
+	u64 utime, stime;
+
+	task_cputime_adjusted(task, &utime, &stime);
+	memset(p_utime, 0, num_size);
+	timespec_format(utime, p_utime, num_size - 1);
+	memset(p_stime, 0, num_size);
+	timespec_format(stime, p_stime, num_size - 1);
+}
+
+/* task_index_to_char kernel function is missing options so use this */
+#define TASK_STATE_TO_CHAR_STR "RSDTtZXxKWP"
+static const char task_to_char[] =3D TASK_STATE_TO_CHAR_STR;
+static const char get_task_state(struct task_struct *p_task, ulong state=
)
+{
+	int bit =3D state ? __ffs(state) + 1 : 0;
+
+	if (p_task->tgid =3D=3D 0)
+		return 'I';
+	return bit < sizeof(task_to_char) - 1 ? task_to_char[bit] : '?';
+}
+
+/*
+ * Code that prints the information about the specified task.
+ * Assumes task lock is held at entry.
+ */
+void dump_task_prt(struct task_struct *task,
+		   unsigned long rsspg, unsigned long swappg,
+		   unsigned long pgtbl)
+{
+	char c_utime[MAX_NUM_FIELD_SIZE], c_stime[MAX_NUM_FIELD_SIZE];
+	unsigned long vmkb, sockkb, text, maxrsspg, pgtblpg;
+	unsigned long libkb, textkb, pgtblkb;
+	struct mm_struct *mm;
+	char incomp =3D ' ';
+	kuid_t ruid, euid;
+	char tstate;
+
+	mm =3D task->mm;
+	maxrsspg =3D rsspg;
+	pgtblpg =3D pgtbl >> PAGE_SHIFT;
+	ruid =3D __task_cred(task)->uid;
+	euid =3D __task_cred(task)->euid;
+	vmkb =3D K(mm->total_vm);
+	if (maxrsspg < mm->hiwater_rss)
+		maxrsspg =3D mm->hiwater_rss;
+	sockkb =3D K(account_for_socket_buffers(task, &incomp));
+	text =3D (PAGE_ALIGN(mm->end_code) -
+		 (mm->start_code & PAGE_MASK));
+	text =3D min(text, mm->exec_vm << PAGE_SHIFT);
+	textkb =3D text >> 10;
+	libkb =3D ((mm->exec_vm << PAGE_SHIFT) - text) >> 10;
+	pgtblkb =3D pgtbl >> 10;
+	tstate =3D get_task_state(task, task->state);
+	time_format(task, c_utime, c_stime);
+
+	pr_info("[%7d] %7d %7d %7d %7d %c %9s %9s %9lu %9lu %9lu %9lu %9ld %9lu=
%c %9lu %9lu %9lu %9lu %9lu %9lu %11lu %11lu %9lu %9llu  %5hd %s\n",
+		task->pid, task_ppid_nr(task), ruid.val, euid.val, task->tgid,
+		tstate, c_utime, c_stime, vmkb, K(maxrsspg), K(rsspg), pgtblkb,
+		K(swappg), sockkb, incomp, libkb, textkb, K(mm->data_vm),
+		K(mm->stack_vm), K(get_mm_counter(mm, MM_FILEPAGES)),
+		K(get_mm_counter(mm, MM_SHMEMPAGES)), task->signal->cmaj_flt,
+		task->signal->cmin_flt,
+		K(mm->locked_vm), K((u64)atomic64_read(&mm->pinned_vm)),
+		task->signal->oom_score_adj, task->comm);
+}
+#endif /* CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT */
+
 static void __init oom_debug_init(void)
 {
 	/* Ensure we have a debugfs oom root directory */
diff --git a/mm/oom_kill_debug.h b/mm/oom_kill_debug.h
index a39bc275980e..faebb4c6097c 100644
--- a/mm/oom_kill_debug.h
+++ b/mm/oom_kill_debug.h
@@ -9,6 +9,11 @@
 #ifndef __MM_OOM_KILL_DEBUG_H__
 #define __MM_OOM_KILL_DEBUG_H__
=20
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_PROCESS_PRINT
+extern bool oom_kill_debug_enhanced_process_print_enabled(void);
+extern void dump_task_prt(struct task_struct *task, unsigned long rsspg,
+			  unsigned long swappg, unsigned long pgtbl);
+#endif
 #ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
 extern unsigned long oom_kill_debug_min_task_pages(unsigned long totalpa=
ges);
 #endif
--=20
2.20.1


