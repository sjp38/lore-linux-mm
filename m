Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79222C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34B12222B2
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34B12222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FDA06B0003; Tue, 16 Apr 2019 09:47:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8ACB46B0006; Tue, 16 Apr 2019 09:47:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7747D6B0274; Tue, 16 Apr 2019 09:47:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 529E26B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:11 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id k2so4779916ybp.17
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=EstedJQx7ODAKKF9fts52ZGdTMASFCC7o1iQQyKc1w4=;
        b=uBN9vNIeEOrRnLISMZwOk7EF3dO5OpbAncgq+QpdB6uDrDlWxXOprUi7YsCh2uybMe
         wgbJOpvpWvXsI5kgiRRnuHCYT05g0q9ORGwDUXWdZRIDEOHXlmm6QzYjhXd0BOSJeRsO
         EyQJQiAC4pDbKkHup2Uha7tpg6lmgHKI/rV4lOJqbH4gXaUdKaiPLc4loBvV+UjW8NaG
         qwoHSzB9j7fZaHvXyByVMGCLtVgKSamw66IXTSYfLfyNnyyyXJ+WZsyJB7xiWIIAW3YE
         caKkiz+yQO+YYh/NTBAbttxhpDDI5EWVfvgUeVFlWN0LMGdwlm/OrrsfljZF8375NNQw
         Cxmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVoQ2IDg25zUHsRu9P4sHOmx9rkVD5biMytfn94VG5yg6j4ikHF
	FdoMD2ISZZ6KNHkiV3FVtvsO2Fx5mj+qLIRdzmNWrQyPAnhrVJB+PoKmJiRlRJ3J5LHLEmIBa59
	IUv6maI5gAzejCBdqV9pwX+Gm24J1/tS0oHQYe1deRc7zPQrfl4j58vzWOQkR2R/3Sw==
X-Received: by 2002:a81:9404:: with SMTP id l4mr64707946ywg.89.1555422431021;
        Tue, 16 Apr 2019 06:47:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfJ3M155anGVMAocL+OgyeOZIdZ0j2+fM2LGeLhchAcIFZudpbF6Gq5Gh8No+wlXmGpp0U
X-Received: by 2002:a81:9404:: with SMTP id l4mr64707832ywg.89.1555422429847;
        Tue, 16 Apr 2019 06:47:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422429; cv=none;
        d=google.com; s=arc-20160816;
        b=phQufYB8VOkVGHOI+WOwqxeS134yF/Du2ArGapZeiuNQav1fk95HJigl1WC5G5UssK
         xDts3MIn9/SWt+OAmgnOXWj7Y8QN9fnfa1esib6Eeh40s39wcATf9jXS8uquSTdcsS5n
         /JUPuk2N4jgq4KkWwD9AvKJvACW88vUn9OLZluCGmvlKae7AK+d8tULfPH7XrNCGyQHv
         BV/PLDvKLzog4YMXIyOUzbk9qyJTDT4zCyc/hdilwe5MQlrXmwC/S1tvzxN5cLV/lSrq
         y/UaQRCjMxq16OVLcNTCJRqfHya/foU0gikSxY6u3Yq4/DFKF48HnB7XAkyG144Lhjpc
         2Qzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=EstedJQx7ODAKKF9fts52ZGdTMASFCC7o1iQQyKc1w4=;
        b=VlVdNgsoxs6JYycZSn/gM12dB8wu2cXZ2n25WQ23XwOLgLkr/mG34vnjI+w6fp2npQ
         WpwPnBycbRlbbdJ+7NMgotpjL1cQH/aPjyuZ1PFRJVW94NdKt0Krc8H3l+Ic5WcD2zUU
         vvXFJcD01PwUgF0WjShXt/4Fy/dd0xCDgaR9lP+sKTPC++aJ5card8sFM2QnxHPlfYw/
         z9i7NSjiMKIHIypDylRZb1gIAfkR5DpcNKRJBTZRo7DcYLpSGs7k5fR++Tr6/GFLzjP8
         mKKo3uS63ICcp55x9HazMuanvDEod5mghsVmL84fkwwQNRODaejOMydUtRisiy/00+Qc
         s/XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s1si32040778ybs.76.2019.04.16.06.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkWxY113195
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:09 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwentmv3g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:07 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:47:01 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:51 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDknUt21561348
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:49 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 594DE4C044;
	Tue, 16 Apr 2019 13:46:49 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D75944C05E;
	Tue, 16 Apr 2019 13:46:47 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:47 +0000 (GMT)
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
Subject: [PATCH v12 30/31] arm64/mm: add speculative page fault
Date: Tue, 16 Apr 2019 15:45:21 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0012-0000-0000-0000030F6F13
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0013-0000-0000-00002147A86B
Message-Id: <20190416134522.17540-31-ldufour@linux.ibm.com>
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

From: Mahendran Ganesh <opensource.ganesh@gmail.com>

This patch enables the speculative page fault on the arm64
architecture.

I completed spf porting in 4.9. From the test result,
we can see app launching time improved by about 10% in average.
For the apps which have more than 50 threads, 15% or even more
improvement can be got.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

[handle_speculative_fault() is no more returning the vma pointer]
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 arch/arm64/mm/fault.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 4f343e603925..b5e2a93f9c21 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -485,6 +485,16 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 
 	perf_sw_event(PERF_COUNT_SW_PAGE_FAULTS, 1, regs, addr);
 
+	/*
+	 * let's try a speculative page fault without grabbing the
+	 * mmap_sem.
+	 */
+	fault = handle_speculative_fault(mm, addr, mm_flags);
+	if (fault != VM_FAULT_RETRY) {
+		perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, addr);
+		goto done;
+	}
+
 	/*
 	 * As per x86, we may deadlock here. However, since the kernel only
 	 * validly references user space from well defined areas of the code,
@@ -535,6 +545,8 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	}
 	up_read(&mm->mmap_sem);
 
+done:
+
 	/*
 	 * Handle the "normal" (no error) case first.
 	 */
-- 
2.21.0

