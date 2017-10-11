Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 87D766B027D
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:59 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id a43so4565501qta.23
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 06:53:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w23si687987qtb.136.2017.10.11.06.53.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 06:53:58 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9BDrKuv060385
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:57 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dhj86hvu9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:53:57 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 11 Oct 2017 14:53:54 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v5 20/22] perf tools: Add support for the SPF perf event
Date: Wed, 11 Oct 2017 15:52:44 +0200
In-Reply-To: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1507729966-10660-21-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>
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
index 140ae638cfd6..101e509ee39b 100644
--- a/tools/include/uapi/linux/perf_event.h
+++ b/tools/include/uapi/linux/perf_event.h
@@ -111,6 +111,7 @@ enum perf_sw_ids {
 	PERF_COUNT_SW_EMULATION_FAULTS		= 8,
 	PERF_COUNT_SW_DUMMY			= 9,
 	PERF_COUNT_SW_BPF_OUTPUT		= 10,
+	PERF_COUNT_SW_SPF			= 11,
 
 	PERF_COUNT_SW_MAX,			/* non-ABI */
 };
diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index f894893c203d..5cff5936a9ac 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -437,6 +437,7 @@ const char *perf_evsel__sw_names[PERF_COUNT_SW_MAX] = {
 	"alignment-faults",
 	"emulation-faults",
 	"dummy",
+	"speculative-faults",
 };
 
 static const char *__perf_evsel__sw_name(u64 config)
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 9183913a6174..0914d3b94ae8 100644
--- a/tools/perf/util/parse-events.c
+++ b/tools/perf/util/parse-events.c
@@ -136,6 +136,10 @@ struct event_symbol event_symbols_sw[PERF_COUNT_SW_MAX] = {
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
index ea2426daf7e8..67d2d9c79c28 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -290,6 +290,7 @@ emulation-faults				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_EM
 dummy						{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_DUMMY); }
 duration_time					{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_DUMMY); }
 bpf-output					{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_BPF_OUTPUT); }
+speculative-faults|spf				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_SPF); }
 
 	/*
 	 * We have to handle the kernel PMU event cycles-ct/cycles-t/mem-loads/mem-stores separately.
diff --git a/tools/perf/util/python.c b/tools/perf/util/python.c
index c129e99114ae..12209adb7cb5 100644
--- a/tools/perf/util/python.c
+++ b/tools/perf/util/python.c
@@ -1141,6 +1141,7 @@ static struct {
 	PERF_CONST(COUNT_SW_ALIGNMENT_FAULTS),
 	PERF_CONST(COUNT_SW_EMULATION_FAULTS),
 	PERF_CONST(COUNT_SW_DUMMY),
+	PERF_CONST(COUNT_SW_SPF),
 
 	PERF_CONST(SAMPLE_IP),
 	PERF_CONST(SAMPLE_TID),
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
