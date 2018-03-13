Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DBB046B000E
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:55:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h33so11841036wrh.10
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:55:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 36si102093edk.185.2018.03.13.05.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 05:55:53 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DCsiC2086373
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:55:52 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gpep7h841-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:55:50 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 12:55:48 -0000
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH 8/8] trace_uprobe/sdt: Document about reference counter
Date: Tue, 13 Mar 2018 18:26:03 +0530
In-Reply-To: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180313125603.19819-9-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

No functionality changes.

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
---
 Documentation/trace/uprobetracer.txt | 16 +++++++++++++---
 kernel/trace/trace.c                 |  2 +-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/Documentation/trace/uprobetracer.txt b/Documentation/trace/uprobetracer.txt
index bf526a7c..8fb13b0 100644
--- a/Documentation/trace/uprobetracer.txt
+++ b/Documentation/trace/uprobetracer.txt
@@ -19,15 +19,25 @@ user to calculate the offset of the probepoint in the object.
 
 Synopsis of uprobe_tracer
 -------------------------
-  p[:[GRP/]EVENT] PATH:OFFSET [FETCHARGS] : Set a uprobe
-  r[:[GRP/]EVENT] PATH:OFFSET [FETCHARGS] : Set a return uprobe (uretprobe)
-  -:[GRP/]EVENT                           : Clear uprobe or uretprobe event
+  p[:[GRP/]EVENT] PATH:OFFSET[(REF_CTR_OFFSET)] [FETCHARGS]
+  r[:[GRP/]EVENT] PATH:OFFSET[(REF_CTR_OFFSET)] [FETCHARGS]
+  -:[GRP/]EVENT
+
+  p : Set a uprobe
+  r : Set a return uprobe (uretprobe)
+  - : Clear uprobe or uretprobe event
 
   GRP           : Group name. If omitted, "uprobes" is the default value.
   EVENT         : Event name. If omitted, the event name is generated based
                   on PATH+OFFSET.
   PATH          : Path to an executable or a library.
   OFFSET        : Offset where the probe is inserted.
+  REF_CTR_OFFSET: Reference counter offset. Optional field. Reference count
+                  gate the invocation of probe. If present, by default
+                  reference count is 0. Kernel needs to increment it before
+                  tracing the probe and decrement it when done. This is
+                  identical to semaphore in Userspace Statically Defined
+                  Tracepoints (USDT).
 
   FETCHARGS     : Arguments. Each probe can have up to 128 args.
    %REG         : Fetch register REG
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 20a2300..2104d03 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -4604,7 +4604,7 @@ static int tracing_trace_options_open(struct inode *inode, struct file *file)
   "place (kretprobe): [<module>:]<symbol>[+<offset>]|<memaddr>\n"
 #endif
 #ifdef CONFIG_UPROBE_EVENTS
-	"\t    place: <path>:<offset>\n"
+  "   place (uprobe): <path>:<offset>[(ref_ctr_offset)]\n"
 #endif
 	"\t     args: <name>=fetcharg[:type]\n"
 	"\t fetcharg: %<register>, @<address>, @<symbol>[+|-<offset>],\n"
-- 
1.8.3.1
