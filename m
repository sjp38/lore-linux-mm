Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 765FEC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DDF42070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="wHGe7hy/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DDF42070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FDFA6B0269; Mon, 26 Aug 2019 15:36:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 485396B026B; Mon, 26 Aug 2019 15:36:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D4C56B026C; Mon, 26 Aug 2019 15:36:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0068.hostedemail.com [216.40.44.68])
	by kanga.kvack.org (Postfix) with ESMTP id 09AEC6B0269
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:56 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A81BB4821
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:55 +0000 (UTC)
X-FDA: 75865586790.15.curve06_1f526e026f224
X-HE-Tag: curve06_1f526e026f224
X-Filterd-Recvd-Size: 11868
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:55 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id C533D42A6BF;
	Mon, 26 Aug 2019 12:37:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848259;
	bh=h2sZyqcU0eX97/uelkpgrKWTnzRbI03aVBmior+xgOc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=wHGe7hy/DIuiWjiR3jyAwomGbapxVPLXLBJMOCQ+86Yx1nqjoY76NhD+ERUHwp/qy
	 1Qx+Qs5JZcW5fG3rmyyBTTfveOaiNKOFiMmOJCn/980Mf346b/ZsIZi0I2vxzOQgga
	 o0dyN8DferNHUydSZKssrcE7EhQdr52BaRXx9PcYwPkM6oiNSGn/O7lPjrKuwBUjtd
	 ayMxh5W80KVCPMFKx8t0MK8mQYMNmbXaiPsWuGvOgqpMvwj6/OlR9OGtW2Y1EmdyqT
	 /9izHprAIBQVCbC5OqFmB1vU7dpsnB01aOL3/BFb75kr3ZB5mm+gQ/W/mEjwJg5nlZ
	 ZTWmrv8qaxh9w==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id BC62742A6B7;
	Mon, 26 Aug 2019 12:37:39 -0700 (PDT)
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
Subject: [PATCH 06/10] mm/oom_debug: Add Select Vmalloc Entries Print
Date: Mon, 26 Aug 2019 12:36:34 -0700
Message-Id: <20190826193638.6638-7-echron@arista.com>
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

Add OOM Debug code to allow select vmalloc entries to be printed output
at the time of an OOM event. Listing some portion of the larger vmalloc
entries has proven useful in tracking memory usage during an OOM event
so the root cause of the event can be determined.

Configuring this OOM Debug Option (DEBUG_OOM_VMALLOC_SELECT_PRINT)
------------------------------------------------------------------
To configure this option it needs to be selected in the OOM Debugging
configure menu. The kernel configuration entry can be found in the
config at: Kernel hacking, Memory Debugging, OOM Debugging with the
DEBUG_OOM_VMALLOC_SELECT_PRINT config entry that configures this option.

Two dynamic OOM debug settings for this option: enable, tenthpercent
--------------------------------------------------------------------
The oom debugfs base directory is found at: /sys/kernel/debug/oom.
The oom debugfs for this option is: vmalloc_select_print_
and for select options there are two files, the enable file and
the tenthpercent file are the debugfs files.

Dynamic disable or re-enable this OOM Debug option
--------------------------------------------------
This option may be disabled or re-enabled using the debugfs entry for
this OOM debug option. The debugfs file to enable this entry is found
at: /sys/kernel/debug/oom/vmalloc_select_print_enabled where the enabled
file's value determines whether the facility is enabled or disabled.
A value of 1 is enabled (default) and a value of 0 is disabled.

Specifying the minimum entry size (0-1000) in the tenthpercent file
-------------------------------------------------------------------
Also for DEBUG_OOM_VMALLOC_SELECT_PRINT the number of vmalloc entries
printed can be adjusted. By default if the DEBUG_OOM_VMALLOC_SELECT_PRINT
config option is enabled only entries that use 1% or more of memory are
printed. This can be adjusted to be entries as small as 0% of memory
or as large as 100% of memory in which case only a summary line is
printed, as no vmalloc entry could possibly use 100% of memory.
Adjustments are made through the debugfs file found at:
/sys/kernel/debug/oom/vmalloc_select_print_tenthpercent
Entry values that are valid are 0 through 1000 which represent memory
usage of 0% of memory to 100% of memory. Only entries that are using
at least one page of memory are printed even if the minimum entry
size is specified as 0, zero page entries have no memory assigned.

Content of Vmalloc entry records and Vmalloc summary record
-----------------------------------------------------------
The output is vmalloc entry information output limited such that only
entries equal to or larger than the minimum size are printed.
Unused vmallocs (no pages assigned to the vmalloc) are never printed.
The vmalloc entry information includes:
  - Size (in bytes)
  - pages (Number pages in use)
  - Caller Information to identify the request

Additional output consists of summary information that is printed
at the end of the output. This summary information includes:
  - Number of Vmalloc entries examined
  - Number of Vmalloc entries printed
  - minimum entry size for selection

Sample Output
-------------
Output produced consists of one line of output for each vmalloc entry
that is equal to or larger than the minimum entry size specified
by the percent_totalpages_print_limit (0% to 100.0%) followed by
one line of summary output. There is also a section header output
line and a summary line that are printed.

Sample Vmalloc entries section header:

Aug 19 19:27:01 coronado kernel: Vmalloc Info:

Sample per entry selected print line output:

Jul 22 20:16:09 yoursystem kernel: Vmalloc size=3D2625536 pages=3D640
 caller=3D__do_sys_swapon+0x78e/0x1130

Sample summary print line output:

Jul 22 19:03:26 yoursystem kernel: Summary: Vmalloc entries examined:1070
 printed:989 minsize:0kB


Signed-off-by: Edward Chron <echron@arista.com>
---
 include/linux/vmalloc.h | 12 ++++++++++++
 mm/Kconfig.debug        | 28 +++++++++++++++++++++++++++
 mm/oom_kill_debug.c     | 21 ++++++++++++++++++++
 mm/vmalloc.c            | 43 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 104 insertions(+)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 9b21d0047710..09e3257fc382 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -227,4 +227,16 @@ pcpu_free_vm_areas(struct vm_struct **vms, int nr_vm=
s)
 int register_vmap_purge_notifier(struct notifier_block *nb);
 int unregister_vmap_purge_notifier(struct notifier_block *nb);
=20
+#ifdef CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT
+/**
+ * Routine used to print select vmalloc entries on an OOM event so we
+ * can identify sizeable entries that may have a significant effect on
+ * kernel memory utilization. Output goes to dmesg along with all the OO=
M
+ * related messages when the config option DEBUG_OOM_VMALLOC_SELECT_PRIN=
T
+ * is set to yes. The Option may be dyanmically enabled or disabled and
+ * the selection size is also dynamically configureable.
+ */
+extern void vmallocinfo_oom_print(unsigned long min_kb);
+#endif /* CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT */
+
 #endif /* _LINUX_VMALLOC_H */
diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index c7d53ca95d32..ea3465343286 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -219,3 +219,31 @@ config DEBUG_OOM_SLAB_SELECT_PRINT
 	  print limit value of 10 or 1% of memory.
=20
 	  If unsure, say N.
+
+config DEBUG_OOM_VMALLOC_SELECT_PRINT
+	bool "Debug OOM Select Vmallocs Print"
+	depends on DEBUG_OOM
+	help
+	  When enabled, allows the number of vmalloc entries printed
+	  to be print rate limited based on the amount of memory the
+	  vmalloc entry is consuming.
+
+	  If the option is configured it is enabled/disabled by setting
+	  the value of the file entry in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/vmalloc_select_print_enabled
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
+	  /sys/kernel/debug/oom/vmalloc_select_print_tenthpercent
+	  If configured the default settings are set to enabled and
+	  print limit value of 10 or 1% of memory.
+
+	  If unsure, say N.
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index 2b5245e1134d..d5e37f8508e6 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -168,6 +168,9 @@
 #ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
 #include "slab.h"
 #endif
+#ifdef CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT
+#include <linux/vmalloc.h>
+#endif
=20
 #define OOMD_MAX_FNAME 48
 #define OOMD_MAX_OPTNAME 32
@@ -223,6 +226,12 @@ static struct oom_debug_option oom_debug_options_tab=
le[] =3D {
 		.option_name	=3D "slab_select_print_",
 		.support_tpercent =3D true,
 	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT
+	{
+		.option_name	=3D "vmalloc_select_print_",
+		.support_tpercent =3D true,
+	},
 #endif
 	{}
 };
@@ -243,6 +252,9 @@ enum oom_debug_options_index {
 #endif
 #ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
 	SELECT_SLABS_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT
+	SELECT_VMALLOC_STATE,
 #endif
 	OUT_OF_BOUNDS
 };
@@ -431,6 +443,15 @@ u32 oom_kill_debug_oom_event_is(void)
 		neightbl_print_stats("nd_tbl", &nd_tbl);
 #endif
=20
+#ifdef CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT
+	if (oom_kill_debug_enabled(SELECT_VMALLOC_STATE)) {
+		u16 ptenth =3D oom_kill_debug_tenthpercent(SELECT_VMALLOC_STATE);
+		unsigned long minkb =3D (K(totalram_pages()) * ptenth) / 1000;
+
+		vmallocinfo_oom_print(minkb);
+	}
+#endif
+
 #ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
 	if (oom_kill_debug_enabled(TASKS_STATE))
 		oom_kill_debug_tasks_summary_print();
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7ba11e12a11f..2cdc0f0cd0af 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -3523,4 +3523,47 @@ static int __init proc_vmalloc_init(void)
 }
 module_init(proc_vmalloc_init);
=20
+#ifdef CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT
+#define K(x) ((x) << (PAGE_SHIFT-10))
+/*
+ * Routine used to print select vmalloc entries on an OOM condition so
+ * we can identify sizeable entries that may have a significant effect o=
n
+ * kernel memory utilization. Output goes to dmesg along with all the OO=
M
+ * related messages when the config option DEBUG_OOM_VMALLOC_SELECT_PRIN=
T
+ * is set to yes. Both enable / disable and size selection value are
+ * dynamically configurable.
+ */
+void vmallocinfo_oom_print(unsigned long min_kb)
+{
+	struct vmap_area *vap;
+	struct vm_struct *vsp;
+	u_int32_t entries =3D 0;
+	u_int32_t printed =3D 0;
+
+	if (!spin_trylock(&vmap_area_lock)) {
+		pr_info("Vmalloc Info: Skipped, vmap_area_lock not available\n");
+		return;
+	}
+
+	pr_info("Vmalloc Info:\n");
+	list_for_each_entry(vap, &vmap_area_list, list) {
+		if (!(vap->flags & VM_VM_AREA))
+			continue;
+		++entries;
+		vsp =3D vap->vm;
+		if ((vsp->nr_pages > 0) && (K(vsp->nr_pages) >=3D min_kb)) {
+			pr_info("vmalloc size=3D%ld pages=3D%d caller=3D%pS\n",
+				vsp->size, vsp->nr_pages, vsp->caller);
+			++printed;
+		}
+	}
+
+	spin_unlock(&vmap_area_lock);
+
+	pr_info("Summary: Vmalloc entries examined:%u printed:%u minsize:%lukB\=
n",
+		entries, printed, min_kb);
+}
+EXPORT_SYMBOL(vmallocinfo_oom_print);
+#endif /* CONFIG_DEBUG_OOM_VMALLOC_SELECT_PRINT */
+
 #endif
--=20
2.20.1


