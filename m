Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 340FAC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5CFA222BC
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5CFA222BC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA51C6B0270; Tue, 16 Apr 2019 09:47:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E29EB6B0272; Tue, 16 Apr 2019 09:47:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF5CB6B0273; Tue, 16 Apr 2019 09:47:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A742E6B0270
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:04 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 204so15703212ybf.5
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=tfdZgFh2HKDjltbc+4Gn/jcI1gLnMp7/QqrTaygkNoI=;
        b=RaeVjWKigX6Zn2MvxlOlWtyBe4kaBujpqvGREHoKwBNUqE3MEa99P2TZmj9kor+Auu
         eyunKrIZudz/cYFNhknqKBLsTT/mFZ13cPIOCHAWwXsgi2CFWWUlODe/t3TLNA82tVHm
         c82KV2eimzw5ZpMPqdCqKFEll0j9a8d1XTCRJuvTjlqYiTItT0Zu8pC+1ueUUthsf6M9
         ttrOqO6vKwgdVK9O5Trb5dfOe/q/LEw2F6NDOrc1HSQN294MsHdq2a8d2DHQgPfIfWS6
         p7ogwVIJnMrTrYLTU6CCqIWj52oHxvIbSMVMgcnlKriXZan55ajkSPUL+7c8T8rV+TdS
         hkQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWE55ah8b8utyPwHZ2edAqIPVUywdS7c/HfPX47fTHe7Yl/J26k
	1gmuKNI+ymRnNFROt+2/VBBqO9xLNaeEIstWkAckUivW8EtZP7oJq0d+Uga9uNbTDDPl6k7RYxc
	5tzWJhXvP6W9BuJBHY2KVlduDC1Bl0dDK56hrgSY2DvTt8p37deYPflvvNE6TOjLkjA==
X-Received: by 2002:a81:1390:: with SMTP id 138mr63912526ywt.230.1555422424366;
        Tue, 16 Apr 2019 06:47:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4cSNjRsO9WT0/7KmlcO9K+5yvbnoJi+ham/ICSpPpxXsyRa/GzOL+KV5ycDV3obFGOfiM
X-Received: by 2002:a81:1390:: with SMTP id 138mr63912449ywt.230.1555422423450;
        Tue, 16 Apr 2019 06:47:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422423; cv=none;
        d=google.com; s=arc-20160816;
        b=EpUYyTVVFzHz9OviQFXVTaHDOz4tpLpH2FJDnDUSmzxQgwGWgQ86Wh0F63HL6mkqi8
         43gPjOeqPBSMO6gV2ZgW+Cz/3LuVpfvZnE2fVwEVOqSGN2UDnF2S5e9Q38kkfGbJ+CZL
         W+lw8FLmpeaZCqtDexIkE+bjCUAzBmcBY0ZFXjC6ycpBdvbrSZ7fhCaWmYMzZXnMHLJG
         NxqxchVtkimoGyGkC/TA3t5LQ/bWXd7ebPPHZA+kQxZeuP81D9sMILSRGhb7Sj7R/GaD
         Ss64BQd0ItVV/luti2u6wVItOVLZ9Y8SFQuOEGL09dHk2xjPMr3B9udlTV2rzx2+/op/
         NzfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=tfdZgFh2HKDjltbc+4Gn/jcI1gLnMp7/QqrTaygkNoI=;
        b=uS4c7rtHmvP55Nv9+Y/PEBlFVPCbKk2WHQM84Rkn/yoJUXRzuYKgrVJEEpYEVqaegN
         FWst8mM4Oi5gZbs65qgpYkcMa+cnnzdGvtxq4OeiwcQPbifhzGBjmP4Qb2lgn6n+4J+j
         is5jlBDKFuURLdv5iUSkW/zYYAIPPinIkpHI2rWYWVCx1QrYv6cwUjBdF3XV8jeiM312
         e6InvdTsB2qRzOKXH7aR2M64DRe8OkuYKo6t9/8ivIWFmziyJC1xf5xyb7XaQv0T4mQp
         QT9wMDzEAsY0XyPKPUF3jO+YYzJGWNnVRq4rM/BvA81YEeLlBfebe00YwI16AkOzpmj5
         rvCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 198si33407466ywh.53.2019.04.16.06.47.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkUZ3022324
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:02 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe8rwcf4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:57 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:52 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:42 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkeG417104934
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:41 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CF1644C05C;
	Tue, 16 Apr 2019 13:46:39 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 60C684C058;
	Tue, 16 Apr 2019 13:46:38 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:38 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com,
        npiggin@gmail.com, paulmck@linux.vnet.ibm.com,
        Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org,
        x86@kernel.org
Subject: [PATCH v12 26/31] perf tools: add support for the SPF perf event
Date: Tue, 16 Apr 2019 15:45:17 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0020-0000-0000-00000330705D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0021-0000-0000-00002182B50A
Message-Id: <20190416134522.17540-27-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add support for the new speculative faults event.

Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 tools/include/uapi/linux/perf_event.h | 1 +
 tools/perf/util/evsel.c               | 1 +
 tools/perf/util/parse-events.c        | 4 ++++
 tools/perf/util/parse-events.l        | 1 +
 tools/perf/util/python.c              | 1 +
 5 files changed, 8 insertions(+)

diff --git a/tools/include/uapi/linux/perf_event.h b/tools/include/uapi/linux/perf_event.h
index 7198ddd0c6b1..3b4356c55caa 100644
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
index 66d066f18b5b..1f3bea4379b2 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -435,6 +435,7 @@ const char *perf_evsel__sw_names[PERF_COUNT_SW_MAX] = {
 	"alignment-faults",
 	"emulation-faults",
 	"dummy",
+	"speculative-faults",
 };
 
 static const char *__perf_evsel__sw_name(u64 config)
diff --git a/tools/perf/util/parse-events.c b/tools/perf/util/parse-events.c
index 5ef4939408f2..effa8929cc90 100644
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
index 7805c71aaae2..d28a6edd0a95 100644
--- a/tools/perf/util/parse-events.l
+++ b/tools/perf/util/parse-events.l
@@ -324,6 +324,7 @@ emulation-faults				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_EM
 dummy						{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_DUMMY); }
 duration_time					{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_DUMMY); }
 bpf-output					{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_BPF_OUTPUT); }
+speculative-faults|spf				{ return sym(yyscanner, PERF_TYPE_SOFTWARE, PERF_COUNT_SW_SPF); }
 
 	/*
 	 * We have to handle the kernel PMU event cycles-ct/cycles-t/mem-loads/mem-stores separately.
diff --git a/tools/perf/util/python.c b/tools/perf/util/python.c
index dda0ac978b1e..c617a4751549 100644
--- a/tools/perf/util/python.c
+++ b/tools/perf/util/python.c
@@ -1200,6 +1200,7 @@ static struct {
 	PERF_CONST(COUNT_SW_ALIGNMENT_FAULTS),
 	PERF_CONST(COUNT_SW_EMULATION_FAULTS),
 	PERF_CONST(COUNT_SW_DUMMY),
+	PERF_CONST(COUNT_SW_SPF),
 
 	PERF_CONST(SAMPLE_IP),
 	PERF_CONST(SAMPLE_TID),
-- 
2.21.0

