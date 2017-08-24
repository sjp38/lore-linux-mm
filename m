Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id BAB54440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:48:47 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id q33so45650uad.12
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:48:47 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q14si1966052uad.234.2017.08.24.13.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 13:48:46 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 3/7] ktask: add /proc/sys/debug/ktask_max_threads
Date: Thu, 24 Aug 2017 16:50:00 -0400
Message-Id: <20170824205004.18502-4-daniel.m.jordan@oracle.com>
In-Reply-To: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
References: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

Adds a proc file to control the maximum number of ktask threads in use
for any one job.  Its primary use is to aid in debugging.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Tim Chen <tim.c.chen@intel.com>
---
 kernel/sysctl.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6648fbbb8157..bc22c61b5d12 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -67,6 +67,7 @@
 #include <linux/kexec.h>
 #include <linux/bpf.h>
 #include <linux/mount.h>
+#include <linux/ktask_internal.h>
 
 #include <linux/uaccess.h>
 #include <asm/processor.h>
@@ -1876,6 +1877,15 @@ static struct ctl_table debug_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#if defined(CONFIG_KTASK)
+	{
+		.procname	= "ktask_max_threads",
+		.data		= &ktask_max_threads,
+		.maxlen		= sizeof(ktask_max_threads),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{ }
 };
 
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
