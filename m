Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B56BCC3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71C5C2070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:36:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="SkUBMpm0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71C5C2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 176136B000A; Mon, 26 Aug 2019 15:36:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12B6F6B000D; Mon, 26 Aug 2019 15:36:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 015E06B000E; Mon, 26 Aug 2019 15:36:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0253.hostedemail.com [216.40.44.253])
	by kanga.kvack.org (Postfix) with ESMTP id CD39E6B000A
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:52 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5FB835005
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:52 +0000 (UTC)
X-FDA: 75865586664.16.fish77_1ed7852accb0a
X-HE-Tag: fish77_1ed7852accb0a
X-Filterd-Recvd-Size: 6900
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:51 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 8E35842A6BC;
	Mon, 26 Aug 2019 12:37:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848256;
	bh=V/mOhY7XhS1f/Jh8Iiul8CdPIyA7jYqIKAUZG/uvnLY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=SkUBMpm0614z4oh4Ou9RV1ZU4w8JPkL5Ew0hBhOK7lcaxxLe9Xd4qD5/Rz/ZiWcY6
	 uq4GUTStXzVIAr+hAAqjXhFaAZAJip064kT3YHQz8mI1sXmMB1okUll8is5jtiUM0w
	 8/WmdCPVtmgix0tSpJWQubuSF4D+ug99DItgnVD9dK26z8dHDPC627LWZukaHmgiWq
	 Ngfw11gQ12y0SEp1SjpTY8DpuOyQm2MbD8jpv5PFw3xtgFMToxXkb1x9DoQRkDlKyg
	 19FmT5ae959jy/s+yLPIFzxD3I+URuSO6ThZFZDMZw8UUz4rUqdK/HaJ/w+3IPktPa
	 hd8EImz/dnIpg==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 8168442A6B7;
	Mon, 26 Aug 2019 12:37:36 -0700 (PDT)
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
Subject: [PATCH 03/10] mm/oom_debug: Add Tasks Summary
Date: Mon, 26 Aug 2019 12:36:31 -0700
Message-Id: <20190826193638.6638-4-echron@arista.com>
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

Adds config option and code to support printing a Process / Thread Summar=
y
of process / thread activity when an OOM event occurs. The information
provided includes the number of process and threads active, the number
of oom eligible and oom ineligible tasks, the total number of forks
that have happened since the system booted and the number of runnable
and I/O blocked processes. All values are at the time of the OOM event.

Configuring this Debug Option (DEBUG_OOM_TASKS_SUMMARY)
-------------------------------------------------------
To get the tasks information summary this option must be configured.
The Tasks Summary option uses the CONFIG_DEBUG_OOM_TASKS_SUMMARY
kernel config option which is found in the kernel config under the entry:
Kernel hacking, Memory Debugging, OOM Debugging entry. The config option
to select is: DEBUG_OOM_TASKS_SUMMARY.

Dynamic disable or re-enable this OOM Debug option
--------------------------------------------------
The oom debugfs base directory is found at: /sys/kernel/debug/oom.
The oom debugfs for this option is: tasks_summary_
and there is just one file for this option, the enable file.

The option may be disabled or re-enabled using the debugfs entry for
this OOM debug option. The debugfs file to enable this option is found at=
:
/sys/kernel/debug/oom/tasks_summary_enabled
The option's enabled file value determines whether the facility is enable=
d
or disabled. A value of 1 is enabled (default) and a value of 0 is
disabled. When configured the default setting is set to enabled.

Content and format of Tasks Summary Output
------------------------------------------
One line of output that includes:
  - Number of Threads
  - Number of processes
  - Forks since boot
  - Processes that are runnable
  - Processes that are in iowait

Sample Output:
-------------
Sample Tasks Summary message output:

Aug 13 18:52:48 yoursystem kernel: Threads: 492 Processes: 248
 forks_since_boot: 7786 procs_runable: 4 procs_iowait: 0


Signed-off-by: Edward Chron <echron@arista.com>
---
 mm/Kconfig.debug    | 16 ++++++++++++++++
 mm/oom_kill_debug.c | 27 +++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index dbe599b67a3b..fcbc5f9aa146 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -147,3 +147,19 @@ config DEBUG_OOM_SYSTEM_STATE
 	  A value of 1 is enabled (default) and a value of 0 is disabled.
=20
 	  If unsure, say N.
+
+config DEBUG_OOM_TASKS_SUMMARY
+	bool "Debug OOM System Tasks Summary"
+	depends on DEBUG_OOM
+	help
+	  When enabled, provides a kernel process/thread summary recording
+	  the system's process/thread activity at the time an OOM event.
+	  The number of processes and of threads, the number of runnable
+	  and I/O blocked threads, the number of forks since boot and the
+	  number of oom eligible and oom ineligble tasks are provided in
+	  the output. If configured it is enabled/disabled by setting the
+	  enabled file entry in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/tasks_summary_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  If unsure, say N.
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index 6eeaad86fca8..395b3307f822 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -152,6 +152,10 @@
 #include <linux/sched/stat.h>
 #endif
=20
+#ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
+#include <linux/sched/stat.h>
+#endif
+
 #define OOMD_MAX_FNAME 48
 #define OOMD_MAX_OPTNAME 32
=20
@@ -182,6 +186,12 @@ static struct oom_debug_option oom_debug_options_tab=
le[] =3D {
 		.option_name	=3D "system_state_summary_",
 		.support_tpercent =3D false,
 	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
+	{
+		.option_name	=3D "tasks_summary_",
+		.support_tpercent =3D false,
+	},
 #endif
 	{}
 };
@@ -190,6 +200,9 @@ static struct oom_debug_option oom_debug_options_tabl=
e[] =3D {
 enum oom_debug_options_index {
 #ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
 	SYSTEM_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
+	TASKS_STATE,
 #endif
 	OUT_OF_BOUNDS
 };
@@ -320,6 +333,15 @@ static void oom_kill_debug_system_summary_prt(void)
 }
 #endif /* CONFIG_DEBUG_OOM_SYSTEM_STATE */
=20
+#ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
+static void oom_kill_debug_tasks_summary_print(void)
+{
+	pr_info("Threads:%d Processes:%d forks_since_boot:%lu procs_runable:%lu=
 procs_iowait:%lu\n",
+		nr_threads, nr_processes(),
+		total_forks, nr_running(), nr_iowait());
+}
+#endif /* CONFIG_DEBUG_OOM_TASKS_SUMMARY */
+
 u32 oom_kill_debug_oom_event_is(void)
 {
 	++oom_kill_debug_oom_events;
@@ -329,6 +351,11 @@ u32 oom_kill_debug_oom_event_is(void)
 		oom_kill_debug_system_summary_prt();
 #endif
=20
+#ifdef CONFIG_DEBUG_OOM_TASKS_SUMMARY
+	if (oom_kill_debug_enabled(TASKS_STATE))
+		oom_kill_debug_tasks_summary_print();
+#endif
+
 	return oom_kill_debug_oom_events;
 }
=20
--=20
2.20.1


