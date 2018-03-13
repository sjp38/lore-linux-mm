Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 305016B0028
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:57 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id h21so266486qtm.22
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 11:00:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n29si648477qtl.369.2018.03.13.11.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 11:00:54 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DHvSOs011877
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:53 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gpjyksb0d-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:00:52 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 18:00:50 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v9 21/24] perf tools: Add support for the SPF perf event
Date: Tue, 13 Mar 2018 18:59:51 +0100
In-Reply-To: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1520963994-28477-22-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Add support for the new speculative faults event.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 tools/include/uapi/linux/perf_event.h | 1 +
 tools/perf/util/evsel.c               | 1 +
 tools/perf/util/parse-events.c        | 4 ++++
 tools/perf/util/parse-events.l        | 1 +
 tools/perf/util/python.c              | 1 +
 5 files changed, 8 insertions(+)

diff --git a/tools/include/uapi/linux/perf_event.h b/tools/include/uapi/linux/perf_event.h
index 6f873503552d..a6ddab9edeec 100644
--- a/tools/include/uapi/linux/perf_event.h
+++ b/tools/include/uapi/linux/perf_event.h
@@ -112,6 +112,7 @@ enum perf_sw_ids {
 	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
 	PERF_COUNT_SW_DUMMY			= 9,
 	PERF_COUNT_SW_BPF_OUTPUT		= 10,
+	PERF_COUNT_SW_SPF			= 11,
 
 	PERF_COUNT_SW_MAX,			/* non-ABI */
 };
diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index ef351688b797..45b954019118 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -428,6 +428,7 @@ const char *perf_evsel__sw_names[PERF_COUNT_SW_MAX] = {
 	"alignment-faults",
 	"emulation-faults",
 	"dummy",
+	"speculative-faults",
 };
 
 static const char *__perf_evsel__sw_name(u64 config)
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 34589c427e52..2a8189c6d5fc 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -140,6 +140,10 @@ struct event_symbol event_symbols_sw[PERF_COUNT_SW_MAX] = {
 		.symbol = "bpf-output",
 		.alias  = "",
 	},
+	[PERF_COUNT_SW_SPF] = {
+		.symbol = "speculative-faults",
+		.alias	= "spf",
+	},
 };
 
 #define __PERF_EVENT_FIELD(config, name) \
diff --git a/tools/perf/util/parse-events.l b/tools/perf/util/parse-events.l
index 655ecff636a8..5d6782426b30 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -308,6 +308,7 @@ emulation-faults				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_EM
 dummy						{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_DUMMY); }
 duration_time					{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_DUMMY); }
 bpf-output					{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_BPF_OUTPUT); }
+speculative-faults|spf				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_SPF); }
 
 	/*
 	 * We have to handle the kernel PMU event cycles-ct/cycles-t/mem-loads/mem-stores separately.
diff --git a/tools/perf/util/python.c b/tools/perf/util/python.c
index 2918cac7a142..00dd227959e6 100644
--- a/tools/perf/util/python.c
+++ b/tools/perf/util/python.c
@@ -1174,6 +1174,7 @@ static struct {
 	PERF_CONST(COUNT_SW_ALIGNMENT_FAULTS),
 	PERF_CONST(COUNT_SW_EMULATION_FAULTS),
 	PERF_CONST(COUNT_SW_DUMMY),
+	PERF_CONST(COUNT_SW_SPF),
 
 	PERF_CONST(SAMPLE_IP),
 	PERF_CONST(SAMPLE_TID),
-- 
2.7.4
