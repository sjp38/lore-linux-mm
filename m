Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 295976B025E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 07:56:33 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so12167428wme.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 04:56:33 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz300.laposte.net. [178.22.154.200])
        by mx.google.com with ESMTPS id qs7si2233494wjc.50.2016.05.10.04.56.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 04:56:32 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout012 (Postfix) with ESMTP id AB2AD8C9FD
	for <linux-mm@kvack.org>; Tue, 10 May 2016 13:56:31 +0200 (CEST)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.laposte [10.128.63.2])
	by lpn-prd-vrout012 (Postfix) with ESMTP id 9C3B18C9E8
	for <linux-mm@kvack.org>; Tue, 10 May 2016 13:56:31 +0200 (CEST)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id 7F11F366975
	for <linux-mm@kvack.org>; Tue, 10 May 2016 13:56:31 +0200 (CEST)
Message-ID: <5731CC6E.3080807@laposte.net>
Date: Tue, 10 May 2016 13:56:30 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: [PATCH] mm: add config option to select the initial overcommit mode
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>

Currently the initial value of the overcommit mode is OVERCOMMIT_GUESS.
However, on embedded systems it is usually better to disable overcommit
to avoid waking up the OOM-killer and its well known undesirable
side-effects.

This config option allows to setup the initial overcommit mode to any of
the 3 available values, OVERCOMMIT_GUESS (which remains as default),
OVERCOMMIT_ALWAYS and OVERCOMMIT_NEVER.
The overcommit mode can still be changed thru sysctl after the system
boots up.

This config option depends on CONFIG_EXPERT.
This patch does not introduces functional changes.

Signed-off-by: Sebastian Frias <sf84@laposte.net>
---

NOTE: I understand that the overcommit mode can be changed dynamically thru
sysctl, but on embedded systems, where we know in advance that overcommit
will be disabled, there's no reason to postpone such setting.

I would also be interested in knowing if you guys think this option should
disable sysctl access for overcommit mode, essentially hardcoding the
overcommit mode when this option is used.

NOTE2: I tried to track down the history of overcommit but back then there
were no single patches apparently and the patch that appears to have
introduced the first overcommit mode (OVERCOMMIT_ALWAYS) is commit
9334eab8a36f ("Import 2.1.27"). OVERCOMMIT_NEVER was introduced with commit
502bff0685b2 ("[PATCH] strict overcommit").
My understanding is that prior to commit 9334eab8a36f ("Import 2.1.27")
there was no overcommit, is that correct?

NOTE3: checkpatch.pl is warning about missing description for the config
symbols ("please write a paragraph that describes the config symbol fully")
but my understanding is that that is a false positive (or the warning message
not clear enough for me to understand it) considering that I have added
'help' sections for each 'config' section.
---
 mm/Kconfig | 32 ++++++++++++++++++++++++++++++++
 mm/util.c  |  8 +++++++-
 2 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index abb7dcf..6dad57d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -439,6 +439,38 @@ choice
 	  benefit.
 endchoice
 
+choice
+	prompt "Overcommit Mode"
+	default OVERCOMMIT_GUESS
+	depends on EXPERT
+	help
+	  Selects the initial value for Overcommit mode.
+
+	  NOTE: The overcommit mode can be changed dynamically through sysctl.
+
+	config OVERCOMMIT_GUESS
+		bool "Guess"
+	help
+	  Selecting this option forces the initial value of overcommit mode to
+	  "Guess" overcommits. This is the default value.
+	  See Documentation/vm/overcommit-accounting for more information.
+
+	config OVERCOMMIT_ALWAYS
+		bool "Always"
+	help
+	  Selecting this option forces the initial value of overcommit mode to
+	  "Always" overcommit.
+	  See Documentation/vm/overcommit-accounting for more information.
+
+	config OVERCOMMIT_NEVER
+		bool "Never"
+	help
+	  Selecting this option forces the initial value of overcommit mode to
+	  "Never" overcommit.
+	  See Documentation/vm/overcommit-accounting for more information.
+
+endchoice
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/util.c b/mm/util.c
index 917e0e3..fd098bb 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -418,7 +418,13 @@ int __page_mapcount(struct page *page)
 }
 EXPORT_SYMBOL_GPL(__page_mapcount);
 
-int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;
+#if defined(CONFIG_OVERCOMMIT_NEVER)
+int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_NEVER;
+#elif defined(CONFIG_OVERCOMMIT_ALWAYS)
+int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_ALWAYS;
+#else
+int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;
+#endif
 int sysctl_overcommit_ratio __read_mostly = 50;
 unsigned long sysctl_overcommit_kbytes __read_mostly;
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
