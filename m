Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19DAFC41514
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA4AC21872
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="gSN9UsOx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA4AC21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56D786B0006; Mon, 26 Aug 2019 15:36:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 520E06B0007; Mon, 26 Aug 2019 15:36:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4100B6B0008; Mon, 26 Aug 2019 15:36:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 166746B0006
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:51 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id B236845CD
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:50 +0000 (UTC)
X-FDA: 75865586580.22.drop52_1e8e6dd8a041b
X-HE-Tag: drop52_1e8e6dd8a041b
X-Filterd-Recvd-Size: 19934
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:49 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 79D7F42A6BA;
	Mon, 26 Aug 2019 12:37:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848254;
	bh=46k3870V/U9Ataj0VmdZmB73M3T9mgh/jWEl9xx4hFU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gSN9UsOxDWYdnLDETVF0iaESmW3Ilg0YCq5AnfDDI5d/RwH7ykaqwJcZSYgyInC+W
	 4Kb+9/jJdIDfNqVxrZbdn9IwHiA0HhB3h3xrr7KZmhTUPFWTbOOVtEzKEs20vCMC5s
	 YHqS0gGzO/ijmM1oTe8xhslXRN45N+LucgbtHcvn2uXGkwA6f3Xf8gGY3aBg/9BVkm
	 q+/V9IDBajg8GsLDelwCLRIYDsJOwyAYMmI824xMmLC/uxOZvUtNtgoBXfzdrSLRYI
	 ShSRas3rJ7SdTuyJfXrrdmPwyXTSuycWebqtH/y46dsVl3WNwHaWlt7W3OKXxiMjA5
	 r9iSMw0vosukQ==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 6497E42A6B7;
	Mon, 26 Aug 2019 12:37:34 -0700 (PDT)
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
Subject: [PATCH 01/10] mm/oom_debug: Add Debug base code
Date: Mon, 26 Aug 2019 12:36:29 -0700
Message-Id: <20190826193638.6638-2-echron@arista.com>
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

OOM Debug code to control/limit information and to provide additional
information that is printed when an OOM event occurs.

Code is provided to provide some additional information as well as to
selectively limit the amount of information produced by an OOM event.
Additional information printed at the time of OOM event can prove
invaluable in determing the root cause of an OOM event, which is the
purpose of OOM Event reports.

Additional OOM information is provided as configurable options that once
configured can be dynamically enabled and disabled and for OOM debug
options that can potentially provide a number of records as part of their
output, a mechanism to dynamically adjust the records output based on
the amount of memory an object is using is provided. Specifying the
minimum size of objects to print is done by specifying size in units of
1/10% of the memory size.

By providing an extensible debugfs interface that allows options to be
configured, enabled and where appropriate to set a minimum size for
selecting entries to print, the output produced when an OOM event occurs
can be dynamically adjusted to produce as little or as much detail as
needed for a given system. This is useful in both production and for
test and development to debug and root cause OOM events.

-----------------------------------------------------------------------

Overview of configurable OOM Event Debug Options
------------------------------------------------
This patch provides common code needed for the various OOM debug options
to allow them to be selected for configuration. For configured options it
provides the debgufs code needed to allow configured options to be
dynamically enabled or disabled and if enabled to specify the print rate
limiting adjustment value if the option supports rate limiting.

New OOM Debug options should use and extend the base code provided here.
When possible add any new OOM debug code to mm/oom_kill_debug.c.
Configured options are compiled and included with the kernel.

To configure an option go to: Kernel hacking ---> Memory Debugging --->
Select: [*] Debug OOM to enable this OOM Debug base code and select
any OOM Debug Options as needed.

Implementation of dynamic controls using debugfs
------------------------------------------------
Each configured OOM debug option also includes code that allows the optio=
n
to be dynamically enabled or disabled. For options that can produce many
many lines of output a print rate limiting adjustment is also available.
The print rate limiting adjustment allows the amount of output for the
option for an OOM event to be adjusted.

Options may be dynamically enabled through the debugfs OOM debug interfac=
e
which can be found in entries under: /sys/kernel/debug/oom
Each configured OOM debug option adds one or two files in this directory.
All configured options add an enable file and options that can output a
number of entries add a second tenthpercent file to specify a minimum
size that entries must be to be printed, to help limit print output.

Dynamic enabled / disabled options
----------------------------------
Under the option's directory there will always be an enabled file for
each option that is configured. The ..._enabled file for each configfured
option can be used to enable or disable that option. A value of 1 is
enabled (which is the default setting) and a value of 0 is disabled.

Dynamic control of entry printing based on memory size
------------------------------------------------------
For each Select Print type of OOM debug option a second file
tenthpercent is present. The value specified in this file can range
from 0 to 1000. This value is used to specify the minimum memory
or memory and swap space (depending on the option) size the entry must
occupy to be selected for printing.

The value is specified in tenths of a percent of memory just as the
oom_score and oom_score_adj is specified. Specifying a value of zero
permits all entries for this option to be printed. A value of 1
specifies entries must be using 0.1% of the total memory or
total memory and total swap space to be selected for print. A value of
10 specifies entries must consume 1% or more and this can be increased
up to 1000 which specifies the entry must be using 100% of memory.
Entries can't possibly use 100% of memory so if the ..._tenthpercent
file has a value approaching 1000 no etries will be printed but
summary information will still be printed if the option is configured
and enabled. By default each configured Select Print OOM debug option
has a default print limiting minimum entry size of 10 or 1% of memory.

---------------------------------------------------------------------


Signed-off-by: Edward Chron <echron@arista.com>
---
 mm/Kconfig.debug    |  17 +++
 mm/Makefile         |   1 +
 mm/oom_kill.c       |   4 +
 mm/oom_kill_debug.c | 267 ++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill_debug.h |  20 ++++
 5 files changed, 309 insertions(+)
 create mode 100644 mm/oom_kill_debug.c
 create mode 100644 mm/oom_kill_debug.h

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 82b6a20898bd..5610da5fa614 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -115,3 +115,20 @@ config DEBUG_RODATA_TEST
     depends on STRICT_KERNEL_RWX
     ---help---
       This option enables a testcase for the setting rodata read-only.
+
+config DEBUG_OOM
+	bool "Debug OOM"
+	depends on DEBUG_KERNEL
+	depends on DEBUG_FS
+	help
+	  This feature enables OOM Debug common code needed to enable one
+	  or more OOM debug options that when enabled provide additional
+	  details about an OOM event. This debug option provides the common
+	  code needed to help configure the OOM options in the kernel config
+	  file and also the common code used to dynamically disable or
+	  re-enable any configured options. Some options also provide print
+	  rate limiting based on memory usage to reduce print output. The
+	  common code for print rate limiting is also provided here. This
+	  option is a prerequisite for selecting any OOM debugging options.
+
+	  If unsure, say N
diff --git a/mm/Makefile b/mm/Makefile
index d0b295c3b764..4bd7c137871c 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -105,3 +105,4 @@ obj-$(CONFIG_PERCPU_STATS) +=3D percpu-stats.o
 obj-$(CONFIG_ZONE_DEVICE) +=3D memremap.o
 obj-$(CONFIG_HMM_MIRROR) +=3D hmm.o
 obj-$(CONFIG_MEMFD_CREATE) +=3D memfd.o
+obj-$(CONFIG_DEBUG_OOM) +=3D oom_kill_debug.o
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eda2e2a0bdc6..c10d61fe944f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -44,6 +44,7 @@
 #include <linux/mmu_notifier.h>
=20
 #include <asm/tlb.h>
+#include "oom_kill_debug.h"
 #include "internal.h"
 #include "slab.h"
=20
@@ -465,6 +466,9 @@ static void dump_header(struct oom_control *oc, struc=
t task_struct *p)
 		if (is_dump_unreclaim_slabs())
 			dump_unreclaimable_slab();
 	}
+#ifdef CONFIG_DEBUG_OOM
+	oom_kill_debug_oom_event_is();
+#endif
 	if (sysctl_oom_dump_tasks)
 		dump_tasks(oc);
 	if (p)
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
new file mode 100644
index 000000000000..af07e662c808
--- /dev/null
+++ b/mm/oom_kill_debug.c
@@ -0,0 +1,267 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ *  linux/mm/oom_kill_debug.c
+ *
+ *  Copyright (C) 2019 Arista Networks Inc.
+ *  Author: Edward G. Chron (echron@arista.com)
+ *
+ *  OOM Debugfs Extensions to the Linux Out Of Memory Code found in
+ *  linux/mm/oom_kill.c
+ *
+ *  Debug OOM code, if enabled, allows supplemental output to be produce=
d at
+ *  the time of an OOM event. It uses the Debugfs file system to allow
+ *  the various options available to be enabled and to control the amoun=
t
+ *  of output they produce for options that can produce more than a few =
lines
+ *  of output.
+ *
+ *  CONFIG_DEBUG_OOM Enables generic OOM Debug Common Code Options
+ *  All other options require this option to be specified and it enables
+ *  the compilation of this module.
+ *
+ *  Debugfs OOM code for enabling and disabling OOM debug options and al=
so for
+ *  setting rate limiting values for any OOM debug options that support =
rate
+ *  limiting of what they print is provided.
+ *
+ *  Debug OOM options when configured are found under /sys/kernel/debug/=
oom
+ *  Each option has either one or two files in theis directory, dependin=
g
+ *  on the number of settings the option supports:
+ *
+ *  - All options have an enabled file that is set to true or false whic=
h
+ *    signifies: true - the option is enabled, false - the option is dis=
abled.
+ *  - Select options also have a tenthpercent file to hold the percentag=
e
+ *    of totalpages (memory and swap space totals) that is the minimum s=
ize
+ *    of totalpages the entry needs to be using to be printed.
+ *
+ *  The totalpages used depends on the option because some options are
+ *  examining kernel objects that can have pages swapped out to swap spa=
ce,
+ *  while others only occupy ram memory pages.
+ *
+ *  Note: The totalpages used value: total ram memory pages + swap pages
+ *        for process and memory file system space that is swappable.
+ *        For slabs and vmalloc the total ram memory pages should be use=
d.
+ *
+ *  Options are found as file options under the base oom debugfs directo=
ry:
+ *  /sys/kernel/debug/oom
+ *
+ *  The following option setting files are found in the oom debugfs dire=
ctory
+ *  as specified above, one for each entry in the Options / Directory
+ *  Supported Option Settings files specified above:
+ *
+ *  Option Setting / Filename:
+ *  -------------------------
+ *  Enabled / ..._enabled
+ *  ---------------------
+ *  Enable / Disable is stored as either a value of one or zero respecti=
vely.
+ *  The default for configured options is Enabled (set to 1)
+ *
+ *  So for option Tasks Summary you'll find an entry in the OOM debugfs =
at:
+ *  /sys/kernel/debug/oom/tasks_summary_enabled
+ *
+ *  Tenths of a % totalpages Usage Print Limit / ..._select_print_tenthp=
ercent
+ *  --------------------------------------------------------------------=
-------
+ *  Rate limiting is supplied as a value of zero to 1000 representing un=
its of
+ *  one tenth of a percent of totalpages. A value of zero prints all ent=
ries,
+ *  a value of 1000 prints no entries, just summary information and valu=
es
+ *  of between 1-999 print entries using from 0.1% to 99.9% of totalpage=
s.
+ *
+ *  For processes, the totalpages is total ram pages + total swap pages.
+ *  For slabs, vmallocs and in memory filesystems the totalpages consist=
s
+ *  to total ram, since none of those are held in swapable memory pages.
+ *
+ *  For option Process Select Print you'll find an entry in the OOM debu=
gfs at:
+ *  /sys/kernel/debug/oom/process_select_print_tenthpercent
+ *
+ *  Adding a new OOM Debug Option:
+ *  -----------------------------
+ *  - A Kernel config option needs to be added to mm/Kconfig.debug and i=
t
+ *    should depend on DEBUG_OOM. This will make your code configurable =
so
+ *    for systems that don't need your option it won't be compiled.
+ *    Your option should be named as config DEBUG_OOM_<YOUR_OPTION>
+ *  - Add an entry for your configuration with CONFIG_DEBUG_OOM_<YOUR_OP=
TION>
+ *    to the oom_debug_options_table[] as the last entry in the table.
+ *    You just need to define two fields in your entry, format like this=
:
+ *
+ *      #ifdef CONFIG_DEBUG_OOM_<YOUR_OPTION>
+ *	{
+ *		.option_name	=3D "oom_kill_debug_<YOUR_OPTION>"
+ *		.support_tpercent =3D true or false,
+ *	},
+ *      #endif
+ *
+ *    where .support_tpercent should be set to true if your option suppo=
rts
+ *    controlling output with the tenth of a percent option. Only option=
s
+ *    that can produce more than a few lines of output, one for each obj=
ect
+ *    of some type (like user processes, slabs, vmalloc entries) will ne=
ed
+ *    this control set to true. So most likey you want to set this to fa=
lse.
+ *  - Add an entry to the enum oom_debug_options_index list just above t=
he
+ *    last entry which is the OUT_OF_BOUNDS entry. The format should be:
+ *
+ *      #ifdef CONFIG_DEBUG_OOM_<YOUR_OPTION>
+ *		YOUR_OPTION_STATE,
+ *      #endif
+ *
+ *  - You need to add your code to produce your output.
+ *    Unless your option must live in another module to access data ther=
e you
+ *    should add your code to mm/oom_kill_debug.c to keep as much of the
+ *    OOM Debug code in one place as possible. You should add your code =
with
+ *    the config conditional so you only get compiled into the kernel if
+ *    configured. Your code in mm/oom_kill_debug.c should look like this=
:
+ *
+ *      #ifdef CONFIG_DEBUG_OOM_<YOUR_OPTION>
+ *      static void oom_kill_debug_<your_option>(void)
+ *      {
+ *		your code>
+ *      }
+ *      #endif
+ *
+ *  - Invoke your code. Ideally, if your code is located in mm/oom_kill_=
debug.c
+ *    then you can just invoke it from oom_kill_debug_oom_event_is(void)
+ *    and you will want to add your invocation code with config conditio=
nal
+ *    ifdef and endif and then in your invocation code check to see that=
 your
+ *    option is enabled before calling it:
+ *
+ *      #ifdef CONFIG_DEBUG_OOM_<YOUR_OPTION>
+ *		if (oom_kill_debug_<your_option>(YOUR_OPTION_STATE))
+ *		oom_kill_debug_<your_option>();
+ *      #endif
+ *
+ *    If your code cannot be invoked from mm/oom_kill_debug.c you will n=
eed
+ *    to add an external accessor reference in mm/oom_kill_debug.h and t=
hen
+ *    your code in mm/oom_kill_debug.c cannot be static. See code in
+ *    mm/oom_kill_debug.h for examples on how this done.
+ *
+ */
+#include <linux/types.h>
+#include <linux/debugfs.h>
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/kobject.h>
+#include <linux/oom.h>
+#include <linux/printk.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/sysfs.h>
+#include "oom_kill_debug.h"
+
+#define OOMD_MAX_FNAME 48
+#define OOMD_MAX_OPTNAME 32
+
+#define K(x) ((x) << (PAGE_SHIFT-10))
+
+static const char oom_debug_path[] =3D "/sys/kernel/debug/oom";
+
+static const char od_root_name[] =3D "oom";
+static struct dentry *od_root_dir;
+static u32 oom_kill_debug_oom_events;
+
+/* One oom_debug_option entry per debug option */
+struct oom_debug_option {
+	const char *option_name;
+	umode_t mode;
+	struct dentry *dir_dentry;
+	struct dentry *enabled_dentry;
+	struct dentry *tenthpercent_dentry;
+	bool enabled;
+	u16 tenthpercent;
+	bool support_tpercent;
+};
+
+/* Table of oom debug options, new options need to be added here */
+static struct oom_debug_option oom_debug_options_table[] =3D {
+	{}
+};
+
+/* Option index by name for order one-lookup, add new options entry here=
 */
+enum oom_debug_options_index {
+	OUT_OF_BOUNDS
+};
+
+bool oom_kill_debug_enabled(u16 index)
+{
+	return oom_debug_options_table[index].enabled;
+}
+
+u16 oom_kill_debug_tenthpercent(u16 index)
+{
+	return oom_debug_options_table[index].tenthpercent;
+}
+
+static void filename_gen(char *pdest, const char *optname, const char *f=
name)
+{
+	size_t len;
+	char *pmsg;
+
+	sprintf(pdest, "%s", optname);
+	len =3D strnlen(pdest, OOMD_MAX_OPTNAME);
+	pmsg =3D pdest + len;
+	sprintf(pmsg, "%s", fname);
+}
+
+static void enabled_file_gen(struct oom_debug_option *entry)
+{
+	char filename[OOMD_MAX_FNAME];
+
+	filename_gen(filename, entry->option_name, "enabled");
+	debugfs_create_bool(filename, 0644, entry->dir_dentry,
+			    &entry->enabled);
+	entry->enabled =3D OOM_KILL_DEBUG_DEFAULT_ENABLED;
+}
+
+static void tpercent_file_gen(struct oom_debug_option *entry)
+{
+	char filename[OOMD_MAX_FNAME];
+
+	filename_gen(filename, entry->option_name, "tenthpercent");
+	debugfs_create_u16(filename, 0644, entry->dir_dentry,
+			   &entry->tenthpercent);
+	entry->tenthpercent =3D OOM_KILL_DEBUG_DEFAULT_TENTHPERCENT;
+}
+
+static void oom_debugfs_init(void)
+{
+	struct oom_debug_option *table, *entry;
+
+	od_root_dir =3D debugfs_create_dir(od_root_name, NULL);
+
+	table =3D oom_debug_options_table;
+	for (entry =3D table; entry->option_name; entry++) {
+		entry->dir_dentry =3D od_root_dir;
+		enabled_file_gen(entry);
+		if (entry->support_tpercent)
+			tpercent_file_gen(entry);
+	}
+}
+
+static void oom_debug_common_cleanup(void)
+{
+	/* Cleanup for oom root directory */
+	debugfs_remove(od_root_dir);
+}
+
+u32 oom_kill_debug_oom_event(void)
+{
+	return oom_kill_debug_oom_events;
+}
+
+u32 oom_kill_debug_oom_event_is(void)
+{
+	++oom_kill_debug_oom_events;
+
+	return oom_kill_debug_oom_events;
+}
+
+static void __init oom_debug_init(void)
+{
+	/* Ensure we have a debugfs oom root directory */
+	od_root_dir =3D debugfs_lookup(od_root_name, NULL);
+	if (!od_root_dir)
+		oom_debugfs_init();
+}
+subsys_initcall(oom_debug_init)
+
+static void __exit oom_debug_exit(void)
+{
+	/* Cleanup for debugfs oom files and directories */
+	oom_debug_common_cleanup();
+}
diff --git a/mm/oom_kill_debug.h b/mm/oom_kill_debug.h
new file mode 100644
index 000000000000..7288969db9ce
--- /dev/null
+++ b/mm/oom_kill_debug.h
@@ -0,0 +1,20 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ *  mm / oom_kill_debug.h  Internal oom kill debug definitions.
+ *
+ *  Copyright (C) 2019 Arista Networks Inc. All Rights Reserved.
+ *  Written by Edward G. Chron (echron@arista.com)
+ */
+
+#ifndef __MM_OOM_KILL_DEBUG_H__
+#define __MM_OOM_KILL_DEBUG_H__
+
+extern u32 oom_kill_debug_oom_event_is(void);
+extern u32 oom_kill_debug_event(void);
+extern bool oom_kill_debug_enabled(u16 index);
+extern u16 oom_kill_debug_tenthpercent(u16 index);
+
+#define OOM_KILL_DEBUG_DEFAULT_ENABLED true
+#define OOM_KILL_DEBUG_DEFAULT_TENTHPERCENT 10
+
+#endif /* __MM_OOM_KILL_DEBUG_H__ */
--=20
2.20.1


