Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 527F9C3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B15B2070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="1IEjogex"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B15B2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39BE76B0007; Mon, 26 Aug 2019 15:36:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D4956B000A; Mon, 26 Aug 2019 15:36:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19DEB6B000C; Mon, 26 Aug 2019 15:36:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0187.hostedemail.com [216.40.44.187])
	by kanga.kvack.org (Postfix) with ESMTP id E202A6B0007
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:51 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7616082437CF
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:51 +0000 (UTC)
X-FDA: 75865586622.05.beam48_1eb30838e9a3f
X-HE-Tag: beam48_1eb30838e9a3f
X-Filterd-Recvd-Size: 8342
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:50 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 931FE42A6BB;
	Mon, 26 Aug 2019 12:37:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848255;
	bh=geOwB3duci2zbNvoXfDx+5+x5VtXw6E+x8+dOFZDgKM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=1IEjogexzuQCB3SP38md7Eq7OAtVIB9hqKIwzdhXq9OKGIHvWKGuRq1zmfcN7hdXv
	 fPd7SXHgFSThKuZJr8a5ZvI8CZib+v+FLCIf1jki8OhLBtTVx/ytVRHydiqzEaPagh
	 JPZXB4AOFk4EUCpl73dyFdgL2f8/acMUXaPoGgYh99S7RPizNVGNqNcD82fpBjgmca
	 flazzOdVEDUXatpff0Du/hlvWUAogblxYEhvPR1WAgw69bV/xHozqclJwsUctRMTH8
	 4pRu4ak3SRjysHQc1ZDP3Z1ZnImD5ycT13vKdxOJltNyRZ12aXw0jyWapP9IW4qwY+
	 ArpNl8dESBAlg==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 8537F42A6B7;
	Mon, 26 Aug 2019 12:37:35 -0700 (PDT)
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
Subject: [PATCH 02/10] mm/oom_debug: Add System State Summary
Date: Mon, 26 Aug 2019 12:36:30 -0700
Message-Id: <20190826193638.6638-3-echron@arista.com>
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

When selected, prints the number of CPUs online at the time of the OOM
event. Also prints nodename, domainname, machine type, kernel release
and version, system uptime, total memory and swap size. Produces a
single line of output holding this information.

This information is useful to help determine the state the system was
in when the event was triggered which is helpful for debugging,
performance measurements and security issues.

Configuring this Debug Option (DEBUG_OOM_SYSTEM_STATE)
------------------------------------------------------
To enable the option it needs to be configured in the OOM Debugging
configure menu. The kernel configuration entry can be found in the
config at: Kernel hacking, Memory Debugging, OOM Debugging the
DEBUG_OOM_SYSTEM_STATE config entry.

Dynamic disable or re-enable this OOM Debug option
--------------------------------------------------
The oom debugfs base directory is found at: /sys/kernel/debug/oom.
The oom debugfs for this option is: system_state_summary_
and the file for this option is the enable file.

This option may be disabled or re-enabled using the debugfs enable file
for this OOM debug option. The debugfs file to enable this entry is found
at: /sys/kernel/debug/oom/system_state_summary_enabled where the enabled
file's value determines whether the facility is enabled or disabled.
A value of 1 is enabled and a value of 0 is disabled.
When configured the default setting is set to enabled.

Content and format of System State Summary Output
-------------------------------------------------
  One line of output that includes:
  - Uptime (days, hour, minutes, seconds)
  - Number CPUs
  - Machine Type
  - Node name
  - Domain name
  - Kernel Release
  - Kernel Version

Sample Output:
-------------
Sample System State Summary message:

Jul 27 10:56:46 yoursystem kernel: System Uptime:0 days 00:17:27
 CPUs:4 Machine:x86_64 Node:yoursystem Domain:localdomain
 Kernel Release:5.3.0-rc2+ Version: #49 SMP Mon Jul 27 10:35:32 PDT 2019


Signed-off-by: Edward Chron <echron@arista.com>
---
 mm/Kconfig.debug    | 15 +++++++++
 mm/oom_kill_debug.c | 81 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 96 insertions(+)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 5610da5fa614..dbe599b67a3b 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -132,3 +132,18 @@ config DEBUG_OOM
 	  option is a prerequisite for selecting any OOM debugging options.
=20
 	  If unsure, say N
+
+config DEBUG_OOM_SYSTEM_STATE
+	bool "Debug OOM System State"
+	depends on DEBUG_OOM
+	help
+	  When enabled, provides one line of output on an oom event to
+	  document the state of the system when the oom event occurred.
+	  Prints: uptime, # threads, # processes, system memory size in KiB
+	  and swap space size in KiB, nodename, domainname, machine type,
+	  kernel release and version. If configured it is enabled/disabled
+	  by setting the enabled file entry in the debugfs OOM interface
+	  at: /sys/kernel/debug/oom/system_state_summary_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  If unsure, say N.
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index af07e662c808..6eeaad86fca8 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -144,6 +144,14 @@
 #include <linux/sysfs.h>
 #include "oom_kill_debug.h"
=20
+#ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
+#include <linux/cpumask.h>
+#include <linux/mm.h>
+#include <linux/swap.h>
+#include <linux/utsname.h>
+#include <linux/sched/stat.h>
+#endif
+
 #define OOMD_MAX_FNAME 48
 #define OOMD_MAX_OPTNAME 32
=20
@@ -169,11 +177,20 @@ struct oom_debug_option {
=20
 /* Table of oom debug options, new options need to be added here */
 static struct oom_debug_option oom_debug_options_table[] =3D {
+#ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
+	{
+		.option_name	=3D "system_state_summary_",
+		.support_tpercent =3D false,
+	},
+#endif
 	{}
 };
=20
 /* Option index by name for order one-lookup, add new options entry here=
 */
 enum oom_debug_options_index {
+#ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
+	SYSTEM_STATE,
+#endif
 	OUT_OF_BOUNDS
 };
=20
@@ -244,10 +261,74 @@ u32 oom_kill_debug_oom_event(void)
 	return oom_kill_debug_oom_events;
 }
=20
+#ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
+/*
+ * oom_kill_debug_system_summary_prt - provides one line of output to do=
cument
+ *                      some of the system state at the time of an oom e=
vent.
+ *                      Output line includes: uptime, # threads, # proce=
sses,
+ *                      system memory size in KiB and swap space size in=
 KiB,
+ *                      nodename, domainname, machine type, kernel relea=
se
+ *                      and version.
+ */
+static void oom_kill_debug_system_summary_prt(void)
+{
+	struct new_utsname *p_uts;
+	char domainname[256];
+	unsigned long upsecs;
+	unsigned short hours;
+	struct timespec64 tp;
+	unsigned short days;
+	unsigned short mins;
+	unsigned short secs;
+	char nodename[256];
+	size_t nodesize;
+	char *p_wend;
+	long uptime;
+	int procs;
+
+	p_uts =3D utsname();
+
+	memset(nodename, 0, sizeof(nodename));
+	memset(domainname, 0, sizeof(domainname));
+
+	p_wend =3D strchr(p_uts->nodename, '.');
+	if (p_wend !=3D NULL) {
+		nodesize =3D p_wend - p_uts->nodename;
+		++p_wend;
+		strncpy(nodename, p_uts->nodename, nodesize);
+		strcpy(domainname, p_wend);
+	} else {
+		strcpy(nodename, p_uts->nodename);
+		strcpy(domainname, "(none)");
+	}
+
+	procs =3D nr_processes();
+
+	ktime_get_boottime_ts64(&tp);
+	uptime =3D tp.tv_sec + (tp.tv_nsec ? 1 : 0);
+
+	days =3D uptime / 86400;
+	upsecs =3D uptime - (days * 86400);
+	hours =3D upsecs / 3600;
+	upsecs =3D upsecs - (hours * 3600);
+	mins =3D upsecs / 60;
+	secs =3D upsecs - (mins * 60);
+
+	pr_info("System Uptime:%hu days %02hu:%02hu:%02hu CPUs:%u Machine:%s No=
de:%s Domain:%s Kernel Release:%s Version:%s\n",
+		days, hours, mins, secs, num_online_cpus(), p_uts->machine,
+		nodename, domainname, p_uts->release, p_uts->version);
+}
+#endif /* CONFIG_DEBUG_OOM_SYSTEM_STATE */
+
 u32 oom_kill_debug_oom_event_is(void)
 {
 	++oom_kill_debug_oom_events;
=20
+#ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
+	if (oom_kill_debug_enabled(SYSTEM_STATE))
+		oom_kill_debug_system_summary_prt();
+#endif
+
 	return oom_kill_debug_oom_events;
 }
=20
--=20
2.20.1


