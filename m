Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5939EC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:46:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 183B0222B2
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:46:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 183B0222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FECC6B000D; Tue, 16 Apr 2019 09:46:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85EE26B000E; Tue, 16 Apr 2019 09:46:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 700FA6B0010; Tue, 16 Apr 2019 09:46:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 221E46B000D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f7so11004963edi.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=9ekLajwcLy0Sow96Zz9b/mB4kzMw9l9rEQcwQPWbNlo=;
        b=PK5lddnZyzbkvtSBVLui4tikJ4Uej8nq8TCAFpJhzzJSGY1sOBfwBaMneoEmB4gHDv
         6VZxBRtbmCLtZCuLTWcMTSeuuhCMo4KjXiHgrsdI4JaAcH3XGYGfY8qWbpXFW8nBL/Yk
         YDCT5bPJAGIu3oMAsQWvoj0D169tNi2qLmsRkOQEMQ61f9S9UJWvyu20ej/javATzP24
         1asI0lgGwC9KT5fmlzv2jMlJ7DIaCKi3gxFDgE1Yg2X8lAAgEnwURLQtZR5hG7c7srNt
         ILv/ECz0s9NWlQ4Fmxlm64gsMxdaYvgHXjWNi/ikE8RDN2dEE3Ld14we9edVXKERDKe/
         m6hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWT5Hy1SLuQOzk/Uz6cMH3ETJSAUqM5xnkTQMWLeJF0XUipSzNQ
	9dl7Y1NNq3UOhT2pJq73Wt5NdLMxfb+R6IBj+6zoGvzxON+FePmF7EpyOh86NSOHUooVLPCMLyg
	l/Ugwbgf+YC+4t26w63v1kR4+IAVPrZbFIkl4amKlue7Wjx6o/mmzcBb4Y0rj5L7hjw==
X-Received: by 2002:a50:a4e4:: with SMTP id x33mr51420589edb.61.1555422411632;
        Tue, 16 Apr 2019 06:46:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIRFjejtvJPDXMg4xFT+409iDZOwHtn60SE/kg29Ok5Pg5gWt4KpZxTVEPT1NJft7acIdz
X-Received: by 2002:a50:a4e4:: with SMTP id x33mr51420288edb.61.1555422406863;
        Tue, 16 Apr 2019 06:46:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422406; cv=none;
        d=google.com; s=arc-20160816;
        b=MMQIy43jhkul99LPmEX6Gwn7z6H2+KeCoD0PACKe/V4Bw8SINPTkT/anyP8RzegQTD
         3ZtILySEQsHS6e7acYkaht9KrKwTaNu/aEQ3FTd2c+bwQ+3BsiHwloyaXhqUY8/Rvi7K
         7WPmdMxNET8juygMlrQhZWpv1cdC4j/PVFxAiO1EttLR0Hxns6xjBlMJB7Hfb2TnEi1a
         oxVosKWMEtya6uNfaO6lNsmYYyw8HJxXKQUCF7TQXOR+NQEpYP/Shuy6cvH+OBvOgPlx
         qJltJDwyAmR09soqWQKT8sLFBJot9C2xF4Duox9lckPuKbp67s9kmOC/3r4GWU4EO7N6
         P5rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=9ekLajwcLy0Sow96Zz9b/mB4kzMw9l9rEQcwQPWbNlo=;
        b=kRFuJZQ6t2zQh3gmSjjPwy9PuFMa1V49RYETSDiEEh5x3e+AyLVf9lXaUMJMY9QMrI
         sTgWeQooEqKaqG8hygOWwHkxGsV2lJhbtTWQ5uWwVy/al0MXjpSvzzRGM01hYVSRVnbR
         v1rRAsQraPVyizFBM08hsGcI0lf3uyhduyDP52BXO+aTroWS9nq7mJkNOX246tjkqIwu
         ZuWi6Xmg0KCOx8XlNVwuHW5YATRqIq8bDP/gedsdYtnBtDcHV0lQaVsi/jyJTZ8LWMUb
         fvRVtEzAbj3HdbVPHRdS02t2hmpt//NgYatgAVdAGe+Sp4Uc7fv+Z/9cETLSNAy109VX
         c80g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n10si8759006ejh.79.2019.04.16.06.46.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkW02070715
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:45 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rwftpha5x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:41 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:09 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:59 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjvHK45482116
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:58 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D07D04C058;
	Tue, 16 Apr 2019 13:45:57 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 27A384C05A;
	Tue, 16 Apr 2019 13:45:55 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:55 +0000 (GMT)
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
Subject: [PATCH v12 12/31] mm: protect SPF handler against anon_vma changes
Date: Tue, 16 Apr 2019 15:45:03 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F7271
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD87
Message-Id: <20190416134522.17540-13-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The speculative page fault handler must be protected against anon_vma
changes. This is because page_add_new_anon_rmap() is called during the
speculative path.

In addition, don't try speculative page fault if the VMA don't have an
anon_vma structure allocated because its allocation should be
protected by the mmap_sem.

In __vma_adjust() when importer->anon_vma is set, there is no need to
protect against speculative page faults since speculative page fault
is aborted if the vma->anon_vma is not set.

When calling page_add_new_anon_rmap() vma->anon_vma is necessarily
valid since we checked for it when locking the pte and the anon_vma is
removed once the pte is unlocked. So even if the speculative page
fault handler is running concurrently with do_unmap(), as the pte is
locked in unmap_region() - through unmap_vmas() - and the anon_vma
unlinked later, because we check for the vma sequence counter which is
updated in unmap_page_range() before locking the pte, and then in
free_pgtables() so when locking the pte the change will be detected.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/memory.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 423fa8ea0569..2cf7b6185daa 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -377,7 +377,9 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 * Hide vma from rmap and truncate_pagecache before freeing
 		 * pgtables
 		 */
+		vm_write_begin(vma);
 		unlink_anon_vmas(vma);
+		vm_write_end(vma);
 		unlink_file_vma(vma);
 
 		if (is_vm_hugetlb_page(vma)) {
@@ -391,7 +393,9 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			       && !is_vm_hugetlb_page(next)) {
 				vma = next;
 				next = vma->vm_next;
+				vm_write_begin(vma);
 				unlink_anon_vmas(vma);
+				vm_write_end(vma);
 				unlink_file_vma(vma);
 			}
 			free_pgd_range(tlb, addr, vma->vm_end,
-- 
2.21.0

