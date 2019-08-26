Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8635C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E6F62070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="hzGobiGn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E6F62070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76B276B026B; Mon, 26 Aug 2019 15:36:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F3A76B026D; Mon, 26 Aug 2019 15:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56F2B6B026E; Mon, 26 Aug 2019 15:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0056.hostedemail.com [216.40.44.56])
	by kanga.kvack.org (Postfix) with ESMTP id 3654C6B026B
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:57 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BCC1682437CF
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:56 +0000 (UTC)
X-FDA: 75865586832.04.chin77_1f789075aed08
X-HE-Tag: chin77_1f789075aed08
X-Filterd-Recvd-Size: 12211
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:56 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id B9C8342A6B7;
	Mon, 26 Aug 2019 12:37:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848260;
	bh=yZeSIo1yMzeevCoZoSFenzyCHvBSamWsDJbpHlAcw0g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hzGobiGnNRcU+IfgJBe3DjCKRQJdhh6XWzw/725isqWDirZKKqGTE/XjGfsZiE5Vx
	 q1emrBguNlHiK5kyzx/zr0+HZRRGEosJccej8pId9BH55BYGydjHGeS+3mbxRLKcw8
	 m3vi4IiZsHecHB1Y8JkN2TRxzXfkr/GUTa9Yfnb23WbL8AlihVdHDTXN0etnf1oT4J
	 l7R8AXNc7IKa6m3cszsL9G1ez57IDRbDFX1ZL497rCgrFw9GV3TmDnkxiTWzMVz7ty
	 GTUTAjGgb2rhBQgk6iPt7A/ZtM23D4gEMHIK2FzZyo4oFNMIT8IoP+sOiu3oMDHAna
	 tbYjL5r5b8Lpw==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id A7DDC42AD87;
	Mon, 26 Aug 2019 12:37:40 -0700 (PDT)
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
	Edward Chron <echron@arista.com>
Subject: [PATCH 07/10] mm/oom_debug: Add Select Process Entries Print
Date: Mon, 26 Aug 2019 12:36:35 -0700
Message-Id: <20190826193638.6638-8-echron@arista.com>
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

Add OOM Debug code to selectively print an entry for each user
process that was considered for OOM selection at the time of an
OOM event. Limiting the processes to print is done by specifying a
minimum amount of memory that must be used to be eligible to be
printed.

Note: memory usage for oom processes includes RAM memory as well
as swap space. The value totalpages is actually used as the memory
size for determining percentage of "memory" used.

Configuring this OOM Debug Option (DEBUG_OOM_PROCESS_SELECT_PRINT)
------------------------------------------------------------------
To configure this option it needs to be selected in the OOM
Debugging configure menu. The kernel configuration entry for this
option can be found in the config file at: Kernel hacking, Memory
Debugging, OOM Debugging the DEBUG_OOM_PROCESS_SELECT config entry.

Two dynamic OOM debug settings for this option: enable, tenthpercent
--------------------------------------------------------------------
The oom debugfs base directory is found at: /sys/kernel/debug/oom.
The oom debugfs for this option is: process_select_print_
and for select options there are two files, the enable file and
the tenthpercent file are the debugfs files.

Dynamic disable or re-enable this OOM Debug option
--------------------------------------------------
This option may be disabled or re-enabled using the debugfs entry for
this OOM debug option. The debugfs file to enable this entry is found at:
/sys/kernel/debug/oom/process_select_print_enabled where the enabled
file's value determines whether the facility is enabled or disabled.
A value of 1 is enabled (default) and a value of 0 is disabled.

Specifying the minimum entry size (0-1000) in the tenthpercent file
-------------------------------------------------------------------
For DEBUG_OOM_PROCESS_SELECT_PRINT the processes printed can be limited
by specifying the minimum percentage of memory usage to be eligible to
be printed. By default if the DEBUG_OOM_PROCESS_SELECT config option is
enabled only OOM considered processes that use 1% or more of memory are
printed. This can be adjusted to be entries as small as 0.1% of memory
or as large as 100% of memory in which case only a summary line is
printed, as no process could possibly consume 100% of the memory.
Adjustments are made through the debugfs file found at:
/sys/kernel/debug/oom/procs_select_print_tenthpercent
valid values include values 1 through 1000 which represent memory
usage of 0.1% of memory to 100% of totalpages. Also specifying a value
of zero is a valid value and when specified it prints an entry for all
OOM considered processes even if they use essentially no memory.

Sample Output
-------------
Output produced consists of one line of standard Linux OOM process
entry output for each process that is equal to or larger than the
minimum entry size specified by the percent_totalpages_print_limit
(0% to 100.0%) followed by one line of summary output.

Summary print line output (minsize =3D 0.1% of totalpages):

Aug 13 20:16:30 yourserver kernel: Summary: OOM Tasks considered:245
 printed:33 minimum size:32576kB total-pages:32579084kB


Signed-off-by: Edward Chron <echron@arista.com>
---
 include/linux/oom.h |  1 +
 mm/Kconfig.debug    | 34 ++++++++++++++++++++++++++++++++++
 mm/oom_kill.c       | 39 +++++++++++++++++++++++++++++++--------
 mm/oom_kill_debug.c | 22 ++++++++++++++++++++++
 mm/oom_kill_debug.h |  3 +++
 5 files changed, 91 insertions(+), 8 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index c696c265f019..f37af4772452 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -49,6 +49,7 @@ struct oom_control {
 	unsigned long totalpages;
 	struct task_struct *chosen;
 	unsigned long chosen_points;
+	unsigned long minpgs;
=20
 	/* Used to print the constraint info. */
 	enum oom_constraint constraint;
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index ea3465343286..0c5feb0e15a9 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -247,3 +247,37 @@ config DEBUG_OOM_VMALLOC_SELECT_PRINT
 	  print limit value of 10 or 1% of memory.
=20
 	  If unsure, say N.
+
+config DEBUG_OOM_PROCESS_SELECT_PRINT
+	bool "Debug OOM Select Process Print"
+	depends on DEBUG_OOM
+	help
+	  When enabled, allows OOM considered process OOM information
+	  to be print rate limited based on the amount of memory the
+	  considered process is consuming. The number of processes that
+	  were considered for OOM selection, the number of processes
+	  that were actually printed and the minimum memory usage
+	  percentage that was used to select to which processes are
+	  printed is printed in a summary line after printing the
+	  selected tasks.
+
+	  If the option is configured it is enabled/disabled by setting
+	  the value of the file entry in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/process_select_print_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  When enabled entries are print limited by the amount of memory
+	  they consume. The setting value defines the minimum memory
+	  size consumed and are represented in tenths of a percent.
+	  Values supported are 0 to 1000 where 0 allows all OOM considered
+	  processes to be printed, 1 would allow entries using 0.1% or
+	  more to be printed, 10 would allow entries using 1% or more of
+	  memory to be printed.
+
+	  If configured and enabled the rate limiting OOM process selection
+	  is specified by setting a value in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/process_select_print_tenthpercent
+	  If configured the default settings are set to enabled and
+	  print limit value of 10 or 1% of memory.
+
+	  If unsure, say N.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9022297fa2ba..4b37318dce4f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -380,6 +380,7 @@ static void select_bad_process(struct oom_control *oc=
)
=20
 static int dump_task(struct task_struct *p, void *arg)
 {
+	unsigned long rsspgs, swappgs, pgtbl;
 	struct oom_control *oc =3D arg;
 	struct task_struct *task;
=20
@@ -400,17 +401,29 @@ static int dump_task(struct task_struct *p, void *a=
rg)
 		return 0;
 	}
=20
+	rsspgs =3D get_mm_rss(task->mm);
+	swappgs =3D get_mm_counter(p->mm, MM_SWAPENTS);
+	pgtbl =3D mm_pgtables_bytes(p->mm);
+
+#ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
+	if ((oc->minpgs > 0) &&
+	    ((rsspgs + swappgs + pgtbl / PAGE_SIZE) < oc->minpgs)) {
+		task_unlock(task);
+		return 0;
+	}
+#endif
+
 	pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
 		task->pid, from_kuid(&init_user_ns, task_uid(task)),
-		task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
-		mm_pgtables_bytes(task->mm),
-		get_mm_counter(task->mm, MM_SWAPENTS),
+		task->tgid, task->mm->total_vm, rsspgs, pgtbl, swappgs,
 		task->signal->oom_score_adj, task->comm);
 	task_unlock(task);
=20
-	return 0;
+	return 1;
 }
=20
+#define K(x) ((x) << (PAGE_SHIFT-10))
+
 /**
  * dump_tasks - dump current memory state of all system tasks
  * @oc: pointer to struct oom_control
@@ -423,19 +436,31 @@ static int dump_task(struct task_struct *p, void *a=
rg)
  */
 static void dump_tasks(struct oom_control *oc)
 {
+	u32 total =3D 0;
+	u32 prted =3D 0;
+
 	pr_info("Tasks state (memory values in pages):\n");
 	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapent=
s oom_score_adj name\n");
=20
+#ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
+	oc->minpgs =3D oom_kill_debug_min_task_pages(oc->totalpages);
+#endif
+
 	if (is_memcg_oom(oc))
 		mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
 	else {
 		struct task_struct *p;
=20
 		rcu_read_lock();
-		for_each_process(p)
-			dump_task(p, oc);
+		for_each_process(p) {
+			++total;
+			prted +=3D dump_task(p, oc);
+		}
 		rcu_read_unlock();
 	}
+
+	pr_info("Summary: OOM Tasks considered:%u printed:%u minimum size:%lukB=
 totalpages:%lukB\n",
+		total, prted, K(oc->minpgs), K(oc->totalpages));
 }
=20
 static void oom_kill_unreclaimable_slabs_print(void)
@@ -492,8 +517,6 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
=20
 static bool oom_killer_disabled __read_mostly;
=20
-#define K(x) ((x) << (PAGE_SHIFT-10))
-
 /*
  * task->mm can be NULL if the task is the exited group leader.  So to
  * determine whether the task is using a particular mm, we examine all t=
he
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index d5e37f8508e6..66b745039771 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -232,6 +232,12 @@ static struct oom_debug_option oom_debug_options_tab=
le[] =3D {
 		.option_name	=3D "vmalloc_select_print_",
 		.support_tpercent =3D true,
 	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
+	{
+		.option_name	=3D "process_select_print_",
+		.support_tpercent =3D true,
+	},
 #endif
 	{}
 };
@@ -255,6 +261,9 @@ enum oom_debug_options_index {
 #endif
 #ifdef CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT
 	SELECT_VMALLOC_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
+	SELECT_PROCESS_STATE,
 #endif
 	OUT_OF_BOUNDS
 };
@@ -415,6 +424,19 @@ bool oom_kill_debug_unreclaimable_slabs_print(void)
 }
 #endif /* CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT */
=20
+#ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
+unsigned long oom_kill_debug_min_task_pages(unsigned long totalpages)
+{
+	u16 pct;
+
+	if (!oom_kill_debug_enabled(SELECT_PROCESS_STATE))
+		return 0;
+
+	pct =3D oom_kill_debug_tenthpercent(SELECT_PROCESS_STATE);
+	return (totalpages * pct) / 1000;
+}
+#endif /* CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT */
+
 #ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
 static void oom_kill_debug_tasks_summary_print(void)
 {
diff --git a/mm/oom_kill_debug.h b/mm/oom_kill_debug.h
index 549b8da179d0..7eec861a0009 100644
--- a/mm/oom_kill_debug.h
+++ b/mm/oom_kill_debug.h
@@ -9,6 +9,9 @@
 #ifndef __MM_OOM_KILL_DEBUG_H__
 #define __MM_OOM_KILL_DEBUG_H__
=20
+#ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
+extern unsigned long oom_kill_debug_min_task_pages(unsigned long totalpa=
ges);
+#endif
 #ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
 extern bool oom_kill_debug_unreclaimable_slabs_print(void);
 #endif
--=20
2.20.1


