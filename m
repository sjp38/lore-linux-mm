Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01F66C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADB4421872
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="Jcz7+jCQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADB4421872
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43AA46B026D; Mon, 26 Aug 2019 15:36:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25F736B026F; Mon, 26 Aug 2019 15:36:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1012E6B0270; Mon, 26 Aug 2019 15:36:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by kanga.kvack.org (Postfix) with ESMTP id DA47C6B026D
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:57 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 7BEBA82437CF
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:57 +0000 (UTC)
X-FDA: 75865586874.23.rain76_1f935d538223e
X-HE-Tag: rain76_1f935d538223e
X-Filterd-Recvd-Size: 8360
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:56 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 8D7B742ADBA;
	Mon, 26 Aug 2019 12:37:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848261;
	bh=fg1QAJS+0mJWJPO5pubyLWZxMBzE5om+KFxcqUhjlPQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Jcz7+jCQyMeUyie/El3QHIC00A53ZBaBVHosrtX8bAwPeIW9wLwVnF6kHTLSJW2Zy
	 A8JGT2eZbQ1liScaUuSnlzA0+LIYSjc9X4baCVx3Xij6a7IMHakcdn/WD4U7iJhVNM
	 uGCrrbIeRC6UsS+0VJ4rzvdE8TBsIXiDMIw0GMILbE7UcrZySGEwp9kgkVVJbeRJc0
	 Lf4Ke6oZsjjZod6VfWgth3CjBHYLvCOFbPSq3GSzpJ1n7HB/LA8GBwVsqTj8/384LY
	 IXJTfs1FxmTJu6iS1oIIJUYN+RzK7c9Y9QwhcNTR1wrhPAuFKKZiztPxs6j+xzVoIL
	 TgFWyfiXSl2fA==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 7E94C42AD87;
	Mon, 26 Aug 2019 12:37:41 -0700 (PDT)
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
Subject: [PATCH 08/10] mm/oom_debug: Add Slab Select Always Print Enable
Date: Mon, 26 Aug 2019 12:36:36 -0700
Message-Id: <20190826193638.6638-9-echron@arista.com>
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

Config option to always enable slab printing. This option will enable
slab entries to be printed even when slab memory usage does not
exceed the standard Linux user memory usage print trigger. The Standard
OOM event Slab entry print trigger is that slab memory usage exceeds user
memory usage. This covers cases where the Kernel or Kernel drivers are
driving slab memory usage up causing it to be excessive. However, OOM
Events are often caused by user processes causing too much memory usage.
In some cases where the user memory usage is quite high the amount of
slab memory consumed can still be an important factor in determining what
caused the OOM event. In such cases it would be useful to have slab
memory usage for any slab entries using a significant amount of memory.

Configuring Slab Select Always Print Enable
-------------------------------------------
This option is configured with: DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
OOM Debug options include Slab Entry print limiting with the
DEBUG_OOM_SLAB_SELECT_PRINT option. This allows entries of only a
minimum size to be printed to prevent large number of entries from being
printed. However, the Standard OOM event Slab entry print trigger prevent=
s
any entries from being printed if the Slab memory usage does not exceed
a significant portion of the user memory usage. Enabling the
DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT option allows the trigger to be
overridden.

Dynamic disable or re-enable this OOM Debug option
--------------------------------------------------
The oom debugfs base directory is found at: /sys/kernel/debug/oom.
The oom debugfs for this option is: slab_select_always_print_
and the file for this option is the enable file.

The option may be disabled or re-enabled using the debugfs entry for
this OOM debug option. The debugfs file to enable this option is found at=
:
/sys/kernel/debug/oom/slab_select_always_print_enabled
The option's enabled file value determines whether the facility is enable=
d
or disabled. A value of 1 is enabled (default) and a value of 0 is
disabled. When configured the default setting is set to enabled.

Sample Output
-------------
There is no change to the standard OOM output with this option other than
the stanrd Linux OOM report Unreclaimable info is output for every OOM
Event, not just OOM Events where slab usage exceeds user process memory
usage.


Signed-off-by: Edward Chron <echron@arista.com>
---
 mm/Kconfig.debug    | 24 ++++++++++++++++++++++++
 mm/oom_kill.c       |  4 ++++
 mm/oom_kill_debug.c | 16 ++++++++++++++++
 mm/oom_kill_debug.h |  3 +++
 4 files changed, 47 insertions(+)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 0c5feb0e15a9..68873e26afe1 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -220,6 +220,30 @@ config DEBUG_OOM_SLAB_SELECT_PRINT
=20
 	  If unsure, say N.
=20
+config DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
+	bool "Debug OOM Slabs Select Always Print Enable"
+	depends on DEBUG_OOM_SLAB_SELECT_PRINT
+	help
+	  When enabled the option allows Slab entries using the minimum
+	  memory size specified by the DEBUG_OOM_SLAB_SELECT_PRINT option
+	  to be printed even if the amount of Slab Memory in use does not
+	  exceed the amount of user memory in use. This essentially
+	  overrides the standard OOM Slab entry print tigger. This is
+	  useful when trying to determine all of the factors that
+	  contributed to an OOM event even when user memory usage was
+	  most likely the most signficant contributor. If Slab usage was
+	  higher than normal this could contribute to the OOM event. The
+	  DEBUG_OOM_SLAB_SELECT_PRINT allows entry sizes of 0% to 100%
+	  where 0% prints all the entries that the standard trigger prints
+	  (any slabs using even 1 slab entry).
+
+	  If the option is configured it is enabled/disabled by setting
+	  the value of the file entry in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/slab_select_always_print_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  If unsure, say N.
+
 config DEBUG_OOM_VMALLOC_SELECT_PRINT
 	bool "Debug OOM Select Vmallocs Print"
 	depends on DEBUG_OOM
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4b37318dce4f..cbea289c6345 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -184,6 +184,10 @@ static bool is_dump_unreclaim_slabs(void)
 		 global_node_page_state(NR_ISOLATED_FILE) +
 		 global_node_page_state(NR_UNEVICTABLE);
=20
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
+	if (oom_kill_debug_select_slabs_always_print_enabled())
+		return true;
+#endif
 	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
 }
=20
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index 66b745039771..13f1d1c25a67 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -238,6 +238,12 @@ static struct oom_debug_option oom_debug_options_tab=
le[] =3D {
 		.option_name	=3D "process_select_print_",
 		.support_tpercent =3D true,
 	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
+	{
+		.option_name	=3D "slab_select_always_print_",
+		.support_tpercent =3D false,
+	},
 #endif
 	{}
 };
@@ -264,6 +270,9 @@ enum oom_debug_options_index {
 #endif
 #ifdef CONFIG_DEBUG_OOM_PROCESS_SELECT_PRINT
 	SELECT_PROCESS_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
+	SLAB_ALWAYS_STATE,
 #endif
 	OUT_OF_BOUNDS
 };
@@ -335,6 +344,13 @@ u32 oom_kill_debug_oom_event(void)
 	return oom_kill_debug_oom_events;
 }
=20
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
+bool oom_kill_debug_select_slabs_always_print_enabled(void)
+{
+	return oom_kill_debug_enabled(SLAB_ALWAYS_STATE);
+}
+#endif
+
 #ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
 /*
  * oom_kill_debug_system_summary_prt - provides one line of output to do=
cument
diff --git a/mm/oom_kill_debug.h b/mm/oom_kill_debug.h
index 7eec861a0009..bce740573063 100644
--- a/mm/oom_kill_debug.h
+++ b/mm/oom_kill_debug.h
@@ -15,6 +15,9 @@ extern unsigned long oom_kill_debug_min_task_pages(unsi=
gned long totalpages);
 #ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
 extern bool oom_kill_debug_unreclaimable_slabs_print(void);
 #endif
+#ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
+extern bool oom_kill_debug_select_slabs_always_print_enabled(void);
+#endif
=20
 extern u32 oom_kill_debug_oom_event_is(void);
 extern u32 oom_kill_debug_event(void);
--=20
2.20.1


