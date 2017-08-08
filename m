Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 072F66B049C
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 10:36:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m80so4810401wmd.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 07:36:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z76si1307902wmh.192.2017.08.08.07.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 07:36:33 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78EXdF8078623
	for <linux-mm@kvack.org>; Tue, 8 Aug 2017 10:36:31 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c7c2segc8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 08 Aug 2017 10:36:31 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 8 Aug 2017 15:36:28 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH 16/16] perf tools: Add support for SPF events
Date: Tue,  8 Aug 2017 16:35:49 +0200
In-Reply-To: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1502202949-8138-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1502202949-8138-17-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Add support for the new speculative faults events.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 tools/include/uapi/linux/perf_event.h | 2 ++
 tools/perf/util/evsel.c               | 2 ++
 tools/perf/util/parse-events.c        | 8 ++++++++
 tools/perf/util/parse-events.l        | 2 ++
 tools/perf/util/python.c              | 2 ++
 5 files changed, 16 insertions(+)

diff --git a/tools/include/uapi/linux/perf_event.h b/tools/include/uapi/linux/perf_event.h
index b1c0b187acfe..fbfb03dff334 100644
--- a/tools/include/uapi/linux/perf_event.h
+++ b/tools/include/uapi/linux/perf_event.h
@@ -111,6 +111,8 @@ enum perf_sw_ids {
 	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
 	PERF_COUNT_SW_DUMMY			= 9,
 	PERF_COUNT_SW_BPF_OUTPUT		= 10,
+	PERF_COUNT_SW_SPF_DONE			= 11,
+	PERF_COUNT_SW_SPF_FAILED		= 12,
 
 	PERF_COUNT_SW_MAX,			/* non-ABI */
 };
diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index 413f74df08de..37d55ffd98b1 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -426,6 +426,8 @@ const char *perf_evsel__sw_names[PERF_COUNT_SW_MAX] = {
 	"alignment-faults",
 	"emulation-faults",
 	"dummy",
+	"speculative-faults",
+	"speculative-faults-failed",
 };
 
 static const char *__perf_evsel__sw_name(u64 config)
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 01e779b91c8e..da1f87859366 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -135,6 +135,14 @@ struct event_symbol event_symbols_sw[PERF_COUNT_SW_MAX] = {
 		.symbol = "bpf-output",
 		.alias  = "",
 	},
+	[PERF_COUNT_SW_SPF_DONE] = {
+		.symbol = "speculative-faults",
+		.alias	= "spf",
+	},
+	[PERF_COUNT_SW_SPF_FAILED] = {
+		.symbol = "speculative-faults-failed",
+		.alias	= "spf-failed",
+	},
 };
 
 #define __PERF_EVENT_FIELD(config, name) \
diff --git a/tools/perf/util/parse-events.l b/tools/perf/util/parse-events.l
index 660fca05bc93..ca0adbc97683 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -274,6 +274,8 @@ alignment-faults				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_AL
 emulation-faults				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_EMULATION_FAULTS); }
 dummy						{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_DUMMY); }
 bpf-output					{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_BPF_OUTPUT); }
+speculative-faults|spf				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_SPF_DONE); }
+speculative-faults-failed|spf-failed		{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_SPF_FAILED); }
 
 	/*
 	 * We have to handle the kernel PMU event cycles-ct/cycles-t/mem-loads/mem-stores separately.
diff --git a/tools/perf/util/python.c b/tools/perf/util/python.c
index c129e99114ae..b85e70e0da06 100644
--- a/tools/perf/util/python.c
+++ b/tools/perf/util/python.c
@@ -1141,6 +1141,8 @@ static struct {
 	PERF_CONST(COUNT_SW_ALIGNMENT_FAULTS),
 	PERF_CONST(COUNT_SW_EMULATION_FAULTS),
 	PERF_CONST(COUNT_SW_DUMMY),
+	PERF_CONST(COUNT_SW_SPF_DONE),
+	PERF_CONST(COUNT_SW_SPF_FAILED),
 
 	PERF_CONST(SAMPLE_IP),
 	PERF_CONST(SAMPLE_TID),
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
