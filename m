Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAE65C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72B3B2070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="OGMOvpyF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72B3B2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B895F6B0010; Mon, 26 Aug 2019 15:36:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEC056B0269; Mon, 26 Aug 2019 15:36:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A01646B026A; Mon, 26 Aug 2019 15:36:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0084.hostedemail.com [216.40.44.84])
	by kanga.kvack.org (Postfix) with ESMTP id 710F16B0010
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:55 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2546C4821
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:55 +0000 (UTC)
X-FDA: 75865586790.04.fang79_1f351a94b8d05
X-HE-Tag: fang79_1f351a94b8d05
X-Filterd-Recvd-Size: 13719
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:54 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 0509E42A6BE;
	Mon, 26 Aug 2019 12:37:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848259;
	bh=L48sD6nFkDjGLDBmCFDb6hal2JR+spCJTQ1cHrIIfa0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=OGMOvpyFR2MsBv+2Sj0RDaqNYBBylf7rCt/lgvPR81vA8DTKB+u8w2LK5P5tHSnoo
	 EtHT558zFPUsUCToAHy1O1GgbBSGGOnhEPViRgYfHwPxCtbRz2d223h4Ee6qn/goPi
	 X5hgbQBrtXrgLduk5CQq1RyGoRhMBbRo2F28jwHckgxhhDO2O7XA4bx+c3ondb9qq/
	 9iO1RFUvnOCUVCaNbJcxabxOnG7F/sGJ1tZnfN+RqhT7d4L5mC5C28Us7jbIaZVEnH
	 p5Pri5pkhbbJfHYfOlFxPDWS+oYnGhSMWr7BXgTcHMBbL8FNPfDoTKlEvkXUSsdXDy
	 8urVyMV6IZZYA==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id E55BE42A6B7;
	Mon, 26 Aug 2019 12:37:38 -0700 (PDT)
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
Subject: [PATCH 05/10] mm/oom_debug: Add Select Slabs Print
Date: Mon, 26 Aug 2019 12:36:33 -0700
Message-Id: <20190826193638.6638-6-echron@arista.com>
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

Add OOM Debug code to allow select slab entries to be printed at the
time of an OOM event. Linux has added printing slab entries on an
OOM event, if the amount of memory used by slabs exceeds the amount
of memory used by user processes. This OOM Debug option allows
slab entries of a specified minimum entry size to be printed,
limiting the amount of print output an OOM event generates for slab
entries.

Configuring this OOM Debug Option (DEBUG_OOM_SLAB_SELECT_PRINT)
---------------------------------------------------------------
To configure this OOM debug option it needs to be configured
in the OOM Debugging configure menu. The kernel configuration entry
can be found in the config at: Kernel hacking, Memory Debugging,
OOM Debugging the DEBUG_OOM_SLAB_SELECT_PRINT config entry.

Two dynamic OOM debug settings for this option: enable, tenthpercent
--------------------------------------------------------------------
The oom debugfs base directory is found at: /sys/kernel/debug/oom.
The oom debugfs for this option is: slab_select_print_
and for select options there are two files, the enable file and
the tenthpercent file are the debugfs files.

Dynamic disable or re-enable this OOM Debug option
--------------------------------------------------
This option may be disabled or re-enabled using the debugfs entry for
this OOM debug option. The debugfs file to enable this entry is found
at: /sys/kernel/debug/oom/slab_select_print_enabled where the enabled
file's value determines whether the facility is enabled or disabled.
A value of 1 is enabled (default) and a value of 0 is disabled. The
default if configured is enabled.

Specifying the minimum entry size (0-1000) in the tenthpercent file
-------------------------------------------------------------------
Also for DEBUG_OOM_SLAB_SELECT_PRINT the number of slab entries printed i=
s
adjustable. By default if the DEBUG_OOM_SLAB_SELECT_PRINT config option
is enabled entries that use 1% or more of memory are printed. This can be
adjusted to be entries as small as 0% of memory or as large as 100% of
memory in which case only a summary line is printed, as no slab entry
could possibly use 100% of memory. Adjustments are made in the debugfs
file found at: /sys/kernel/debug/oom/slab_select_print_tenthpercent
Entry values that are valid are 0 through 1000 which represent memory
usage of 0% of memory to 100% of memory. A value of of 0 prints all
slabs that have at least one slab in use, unused slabs are not printed.

Content of Slab Summary Records Output
--------------------------------------
Additional output consists of summary information that is printed
at the end of the output. This summary information includes:
  - # entries examined
  - # entries selected and printed
  - minimum entry size for selection
  - Slabs total size (kB)
  - Slabs reclaimable size (kB)
  - Slabs unreclaimable size (kB)

Sample Output
-------------
Output produced consists of the standard output currently produced
by Linux for slab entries plus two lines of summary information.
(The standard output provides a section header and entry per slab)

Summary output (minsize =3D 0kB, all entries with > 0 slabs in use printe=
d):

Jul 23 23:26:34 yoursystem kernel: Summary: Slab entries examined: 123
 printed: 83 minsize: 0kB

Jul 23 23:26:34 yoursystem kernel: Slabs Total: 151212kB Reclaim: 50632kB
 Unreclaim: 100580kB


Signed-off-by: Edward Chron <echron@arista.com>
---
 mm/Kconfig.debug    | 30 +++++++++++++++++++++
 mm/oom_kill.c       | 11 +++++++-
 mm/oom_kill_debug.c | 42 +++++++++++++++++++++++++++++
 mm/oom_kill_debug.h |  4 +++
 mm/slab.h           |  4 +++
 mm/slab_common.c    | 65 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 155 insertions(+), 1 deletion(-)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index fe4bb5ce0a6d..c7d53ca95d32 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -189,3 +189,33 @@ config DEBUG_OOM_ND_TBL
 	  A value of 1 is enabled (default) and a value of 0 is disabled.
=20
 	  If unsure, say N.
+
+config DEBUG_OOM_SLAB_SELECT_PRINT
+	bool "Debug OOM Select Slabs Print"
+	depends on DEBUG_OOM
+	help
+	  When enabled, allows the number of unreclaimable slab entries
+	  to be print rate limited based on the amount of memory the
+	  slab entry is consuming. By default all slab entries with more
+	  than one object in use are printed if the trigger condition is
+	  met to dump slab entries.
+
+	  If the option is configured it is enabled/disabled by setting
+	  the value of the file entry in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/slab_select_print_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  When enabled entries are print limited by the amount of memory
+	  they consume. The setting value defines the minimum memory
+	  size consumed and are represented in tenths of a percent.
+	  Values supported are 0 to 1000 where 0 allows all entries to be
+	  printed, 1 would allow entries using 0.1% or more to be printed,
+	  10 would allow entries using 1% or more of memory to be printed.
+
+	  If configured and enabled the rate limiting memory percentage
+	  is specified by setting a value in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/slab_select_print_tenthpercent
+	  If configured the default settings are set to enabled and
+	  print limit value of 10 or 1% of memory.
+
+	  If unsure, say N.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c10d61fe944f..9022297fa2ba 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -438,6 +438,15 @@ static void dump_tasks(struct oom_control *oc)
 	}
 }
=20
+static void oom_kill_unreclaimable_slabs_print(void)
+{
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
+	if (oom_kill_debug_unreclaimable_slabs_print())
+		return;
+#endif
+	dump_unreclaimable_slab();
+}
+
 static void dump_oom_summary(struct oom_control *oc, struct task_struct =
*victim)
 {
 	/* one line summary of the oom killer context. */
@@ -464,7 +473,7 @@ static void dump_header(struct oom_control *oc, struc=
t task_struct *p)
 	else {
 		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
 		if (is_dump_unreclaim_slabs())
-			dump_unreclaimable_slab();
+			oom_kill_unreclaimable_slabs_print();
 	}
 #ifdef CONFIG_DEBUG_OOM
 	oom_kill_debug_oom_event_is();
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index c4a9117633fd..2b5245e1134d 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -165,6 +165,9 @@
 #if defined(CONFIG_DEBUG_OOM_ARP_TBL) || defined(CONFIG_DEBUG_OOM_ND_TBL=
)
 #include <net/neighbour.h>
 #endif
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
+#include "slab.h"
+#endif
=20
 #define OOMD_MAX_FNAME 48
 #define OOMD_MAX_OPTNAME 32
@@ -214,6 +217,12 @@ static struct oom_debug_option oom_debug_options_tab=
le[] =3D {
 		.option_name	=3D "nd_table_summary_",
 		.support_tpercent =3D false,
 	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
+	{
+		.option_name	=3D "slab_select_print_",
+		.support_tpercent =3D true,
+	},
 #endif
 	{}
 };
@@ -231,6 +240,9 @@ enum oom_debug_options_index {
 #endif
 #ifdef CONFIG_DEBUG_OOM_ND_TBL
 	ND_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
+	SELECT_SLABS_STATE,
 #endif
 	OUT_OF_BOUNDS
 };
@@ -361,6 +373,36 @@ static void oom_kill_debug_system_summary_prt(void)
 }
 #endif /* CONFIG_DEBUG_OOM_SYSTEM_STATE */
=20
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
+static inline u16 oom_kill_debug_slabs_tenthpercent(void)
+{
+	return oom_kill_debug_tenthpercent(SELECT_SLABS_STATE);
+}
+
+static void oom_kill_debug_slabs_and_summary_print(void)
+{
+	u16 pcttenth =3D oom_kill_debug_slabs_tenthpercent();
+	unsigned long minkb =3D (K(totalram_pages()) * pcttenth) / 1000;
+
+	slab_common_oom_debug_dump_unreclaimable(minkb);
+
+	pr_info("Slabs Total: %lukB Reclaim: %lukB Unreclaim: %lukB\n",
+		K((global_node_page_state(NR_SLAB_RECLAIMABLE) +
+		   global_node_page_state(NR_SLAB_UNRECLAIMABLE))),
+		K(global_node_page_state(NR_SLAB_RECLAIMABLE)),
+		K(global_node_page_state(NR_SLAB_UNRECLAIMABLE)));
+}
+
+bool oom_kill_debug_unreclaimable_slabs_print(void)
+{
+	if (oom_kill_debug_enabled(SELECT_SLABS_STATE)) {
+		oom_kill_debug_slabs_and_summary_print();
+		return true;
+	}
+	return false;
+}
+#endif /* CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT */
+
 #ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
 static void oom_kill_debug_tasks_summary_print(void)
 {
diff --git a/mm/oom_kill_debug.h b/mm/oom_kill_debug.h
index 7288969db9ce..549b8da179d0 100644
--- a/mm/oom_kill_debug.h
+++ b/mm/oom_kill_debug.h
@@ -9,6 +9,10 @@
 #ifndef __MM_OOM_KILL_DEBUG_H__
 #define __MM_OOM_KILL_DEBUG_H__
=20
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
+extern bool oom_kill_debug_unreclaimable_slabs_print(void);
+#endif
+
 extern u32 oom_kill_debug_oom_event_is(void);
 extern u32 oom_kill_debug_event(void);
 extern bool oom_kill_debug_enabled(u16 index);
diff --git a/mm/slab.h b/mm/slab.h
index 9057b8056b07..703e914efedc 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -586,10 +586,14 @@ int memcg_slab_show(struct seq_file *m, void *p);
=20
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB_DEBUG)
 void dump_unreclaimable_slab(void);
+void slab_common_oom_debug_dump_unreclaimable(unsigned long minkb);
 #else
 static inline void dump_unreclaimable_slab(void)
 {
 }
+static inline void slab_common_oom_debug_dump_unreclaimable(unsigned lon=
g minkb)
+{
+}
 #endif
=20
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr=
);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 807490fe217a..9ddc95040b60 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1450,6 +1450,71 @@ void dump_unreclaimable_slab(void)
 	mutex_unlock(&slab_mutex);
 }
=20
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
+static void oom_debug_slab_header_print(void)
+{
+	pr_info("Unreclaimable slab info:\n");
+	pr_info("Name                      Used          Total\n");
+}
+
+static void oom_debug_slab_print(struct slabinfo *psi, struct kmem_cache=
 *pkc)
+{
+	pr_info("%-17s %10luKB %10luKB\n", cache_name(pkc),
+		(psi->active_objs * pkc->size) / 1024,
+		(psi->num_objs * pkc->size) / 1024);
+}
+
+static bool oom_debug_slab_check(struct slabinfo *psi, struct kmem_cache=
 *pkc,
+				 unsigned long min_kb)
+{
+	if (psi->num_objs > 0) {
+		if (((psi->active_objs * pkc->size) / 1024) >=3D min_kb) {
+			oom_debug_slab_print(psi, pkc);
+			return true;
+		}
+	}
+	return false;
+}
+
+void slab_common_oom_debug_dump_unreclaimable(unsigned long minkb)
+{
+	struct kmem_cache *s, *s2;
+	struct slabinfo sinfo;
+	u32 slabs_examined =3D 0;
+	u32 slabs_printed =3D 0;
+
+	/*
+	 * Here acquiring slab_mutex is risky since we don't prefer to get
+	 * sleep in oom path. But, without mutex hold, it may introduce a
+	 * risk of crash.
+	 * Use mutex_trylock to protect the list traverse, dump nothing
+	 * without acquiring the mutex.
+	 */
+	if (!mutex_trylock(&slab_mutex)) {
+		pr_warn("excessive unreclaimable slab but cannot dump stats\n");
+		return;
+	}
+
+	oom_debug_slab_header_print();
+
+	list_for_each_entry_safe(s, s2, &slab_caches, list) {
+		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
+			continue;
+
+		get_slabinfo(s, &sinfo);
+
+		++slabs_examined;
+
+		if (oom_debug_slab_check(&sinfo, s, minkb))
+			++slabs_printed;
+	}
+	mutex_unlock(&slab_mutex);
+
+	pr_info("Summary: Slab entries examined:%u printed:%u minsize:%lukB\n",
+		slabs_examined, slabs_printed, minkb);
+}
+#endif  /* CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT */
+
 #if defined(CONFIG_MEMCG)
 void *memcg_slab_start(struct seq_file *m, loff_t *pos)
 {
--=20
2.20.1


