Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB2A6B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 14:49:32 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o20so681171wro.8
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 11:49:32 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f24si875980edm.246.2017.12.05.11.49.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 11:49:30 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v3 3/7] ktask: add /proc/sys/debug/ktask_max_threads
Date: Tue,  5 Dec 2017 14:52:16 -0500
Message-Id: <20171205195220.28208-4-daniel.m.jordan@oracle.com>
In-Reply-To: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
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
index 557d46728577..e296906e609e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -67,6 +67,7 @@
 #include <linux/bpf.h>
 #include <linux/mount.h>
 #include <linux/pipe_fs_i.h>
+#include <linux/ktask_internal.h>
 
 #include <linux/uaccess.h>
 #include <asm/processor.h>
@@ -1867,6 +1868,15 @@ static struct ctl_table debug_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
+#endif
+#if defined(CONFIG_KTASK)
+	{
+		.procname	= "ktask_max_threads",
+		.data		= &ktask_max_threads,
+		.maxlen		= sizeof(ktask_max_threads),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 #endif
 	{ }
 };
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
