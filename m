Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5565C3A59F
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A1E002070B
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 19:37:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=arista.com header.i=@arista.com header.b="AC2mQsdx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A1E002070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D84BB6B026F; Mon, 26 Aug 2019 15:36:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D38B36B0271; Mon, 26 Aug 2019 15:36:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B64966B0272; Mon, 26 Aug 2019 15:36:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0174.hostedemail.com [216.40.44.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9116B026F
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 15:36:58 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 19C303AB7
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:58 +0000 (UTC)
X-FDA: 75865586916.05.stone79_1fac1d47b5c2a
X-HE-Tag: stone79_1fac1d47b5c2a
X-Filterd-Recvd-Size: 9014
Received: from smtp.aristanetworks.com (mx.aristanetworks.com [162.210.129.12])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 19:36:57 +0000 (UTC)
Received: from smtp.aristanetworks.com (localhost [127.0.0.1])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 5E13742AD87;
	Mon, 26 Aug 2019 12:37:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arista.com;
	s=Arista-A; t=1566848262;
	bh=S20mDshN1pQo1L5f/8CHlF5oa1OC9f9U27DdEARsaQI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AC2mQsdxK20pXBdi7vi5PCecc9RYN4oOlFGvTkCysETcJf9ul2jN0qzWMmtk57jBV
	 EYOe0yHI4Ks8lgXaxJpjf3M+Nhnz62keHqaPZ7+eNt9mvloqCX5o4gBuVICazqRrr1
	 iwcwYJuMp6p2WNQCxlELS7uWVjpIerF2+BZRTk2n+njNWpN1cJVe1V9KaxXxhJe9nN
	 SpCUQJZRAs6EDgfDozYmda8dLh7Mc8UzME1IA30hLdMhgMw9TTS4PO7VfJXRgzk+di
	 cOPK1sOpPucvWI5TqKQ0zuWsy4so2a4eai6Jhqq5OyPbAGmA4kPT2BP6akJX3dvPSt
	 iDmhfQRzibLUw==
Received: from egc101.sjc.aristanetworks.com (unknown [172.20.210.50])
	by smtp.aristanetworks.com (Postfix) with ESMTP id 4D3ED42C3CA;
	Mon, 26 Aug 2019 12:37:42 -0700 (PDT)
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
Subject: [PATCH 09/10] mm/oom_debug: Add Enhanced Slab Print Information
Date: Mon, 26 Aug 2019 12:36:37 -0700
Message-Id: <20190826193638.6638-10-echron@arista.com>
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

Add OOM Debug code that prints additional detailed information about each
slab entry that has been selected for printing. The information is
displayed for each slab enrty selected for print. The extra information
is helpful for root cause identification and problem analysis.

Configuring Enhanced Process Print Information
----------------------------------------------
The Kernel configuration option that defines this option is
DEBUG_OOM_ENHANCED_SLAB_PRINT. This additional code is dependent on the
OOM Debug option DEBUG_OOM_SLAB_SELECT_PRINT which adds code to allow
processes that are considered for OOM kill to be selectively printed,
only printing processes that use a specified minimum amount of memory.

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
When configured the default setting is set to enabled.

Content and format of slab entry messages
-----------------------------------------
In addition to the Used and Total space (in KiB) fields that are
displayed by the standard Linux OOM slab reporting code the enhanced
entries include: active objects, total objects, object and align size
(both in bytes), objects per slab, pages per slab, active slabs,
total slabs and the slab name (located at the end, easier to read).

Sample Output
-------------
Sample oom report message header and output slab entry message:

Aug 13 18:52:47 mysrvr kernel:   UsedKiB   TotalKiB  ActiveObj   TotalObj
 ObjSize AlignSize Objs/Slab Pgs/Slab ActiveSlab  TotalSlab Slab_Name

Aug 13 18:52:47 mysrvr kernel:       403        412       1613       1648
     224       256        16        1        103        103 skbuff_head..

Signed-off-by: Edward Chron <echron@arista.com>
---
 mm/Kconfig.debug    | 15 +++++++++++++++
 mm/oom_kill_debug.c | 15 +++++++++++++++
 mm/oom_kill_debug.h |  3 +++
 mm/slab_common.c    | 29 +++++++++++++++++++++++++++++
 4 files changed, 62 insertions(+)

diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
index 68873e26afe1..4414e46f72c6 100644
--- a/mm/Kconfig.debug
+++ b/mm/Kconfig.debug
@@ -244,6 +244,21 @@ config DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
=20
 	  If unsure, say N.
=20
+config DEBUG_OOM_ENHANCED_SLAB_PRINT
+	bool "Debug OOM Enhanced Slab Print"
+	depends on DEBUG_OOM_SLAB_SELECT_PRINT
+	help
+	  Each OOM slab entry printed includes slab entry information
+	  about it's memory usage. Memory usage is specified in KiB (KB)
+	  and includes the following fields:
+
+	  If the option is configured it is enabled/disabled by setting
+	  the value of the file entry in the debugfs OOM interface at:
+	  /sys/kernel/debug/oom/process_enhanced_print_enabled
+	  A value of 1 is enabled (default) and a value of 0 is disabled.
+
+	  If unsure, say N.
+
 config DEBUG_OOM_VMALLOC_SELECT_PRINT
 	bool "Debug OOM Select Vmallocs Print"
 	depends on DEBUG_OOM
diff --git a/mm/oom_kill_debug.c b/mm/oom_kill_debug.c
index 13f1d1c25a67..ad937b3d59f3 100644
--- a/mm/oom_kill_debug.c
+++ b/mm/oom_kill_debug.c
@@ -244,6 +244,12 @@ static struct oom_debug_option oom_debug_options_tab=
le[] =3D {
 		.option_name	=3D "slab_select_always_print_",
 		.support_tpercent =3D false,
 	},
+#endif
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
+	{
+		.option_name	=3D "slab_enhanced_print_",
+		.support_tpercent =3D false,
+	},
 #endif
 	{}
 };
@@ -273,6 +279,9 @@ enum oom_debug_options_index {
 #endif
 #ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
 	SLAB_ALWAYS_STATE,
+#endif
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
+	ENHANCED_SLAB_STATE,
 #endif
 	OUT_OF_BOUNDS
 };
@@ -350,6 +359,12 @@ bool oom_kill_debug_select_slabs_always_print_enable=
d(void)
 	return oom_kill_debug_enabled(SLAB_ALWAYS_STATE);
 }
 #endif
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
+bool oom_kill_debug_enhanced_slab_print_information_enabled(void)
+{
+	return oom_kill_debug_enabled(ENHANCED_SLAB_STATE);
+}
+#endif
=20
 #ifdef CONFIG_DEBUG_OOM_SYSTEM_STATE
 /*
diff --git a/mm/oom_kill_debug.h b/mm/oom_kill_debug.h
index bce740573063..a39bc275980e 100644
--- a/mm/oom_kill_debug.h
+++ b/mm/oom_kill_debug.h
@@ -18,6 +18,9 @@ extern bool oom_kill_debug_unreclaimable_slabs_print(vo=
id);
 #ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_ALWAYS_PRINT
 extern bool oom_kill_debug_select_slabs_always_print_enabled(void);
 #endif
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
+extern bool oom_kill_debug_enhanced_slab_print_information_enabled(void)=
;
+#endif
=20
 extern u32 oom_kill_debug_oom_event_is(void);
 extern u32 oom_kill_debug_event(void);
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 9ddc95040b60..c6e17e5c6c9d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -28,6 +28,10 @@
=20
 #include "slab.h"
=20
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
+#include "oom_kill_debug.h"
+#endif
+
 enum slab_state slab_state;
 LIST_HEAD(slab_caches);
 DEFINE_MUTEX(slab_mutex);
@@ -1450,15 +1454,40 @@ void dump_unreclaimable_slab(void)
 	mutex_unlock(&slab_mutex);
 }
=20
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
+static void oom_debug_slab_enhanced_print(struct slabinfo *psi,
+					  struct kmem_cache *pkc)
+{
+	pr_info("%10lu %10lu %10lu %10lu %9u %9u %9u %8u %10lu %10lu %s\n",
+		(psi->active_objs * pkc->size) / 1024,
+		(psi->num_objs * pkc->size) / 1024, psi->active_objs,
+		psi->num_objs, pkc->object_size, pkc->size,
+		psi->objects_per_slab, (1 << psi->cache_order),
+		psi->active_slabs, psi->num_slabs, cache_name(pkc));
+}
+#endif
+
 #ifdef CONFIG_DEBUG_OOM_SLAB_SELECT_PRINT
 static void oom_debug_slab_header_print(void)
 {
 	pr_info("Unreclaimable slab info:\n");
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
+	if (oom_kill_debug_enhanced_slab_print_information_enabled()) {
+		pr_info("   UsedKiB   TotalKiB  ActiveObj   TotalObj   ObjSize AlignSi=
ze Objs/Slab Pgs/Slab ActiveSlab  TotalSlab Slab_Name");
+		return;
+	}
+#endif
 	pr_info("Name                      Used          Total\n");
 }
=20
 static void oom_debug_slab_print(struct slabinfo *psi, struct kmem_cache=
 *pkc)
 {
+#ifdef CONFIG_DEBUG_OOM_ENHANCED_SLAB_PRINT
+	if (oom_kill_debug_enhanced_slab_print_information_enabled()) {
+		oom_debug_slab_enhanced_print(psi, pkc);
+		return;
+	}
+#endif
 	pr_info("%-17s %10luKB %10luKB\n", cache_name(pkc),
 		(psi->active_objs * pkc->size) / 1024,
 		(psi->num_objs * pkc->size) / 1024);
--=20
2.20.1


