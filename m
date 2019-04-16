Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C71BC282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A517222DF
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A517222DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A13276B029A; Tue, 16 Apr 2019 09:48:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 997716B029B; Tue, 16 Apr 2019 09:48:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 836DE6B029D; Tue, 16 Apr 2019 09:48:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 284A26B029B
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:48:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e6so10970553edi.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:48:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=Jz5rqUkE6WFM4DKQsFaVvFygOBtBuOfuq1p+t1n4dxE=;
        b=DRKJudefvI4Rm86eUpUuK9/bRtq6/65XTPBK1GcklwRkZTvya+OB+Rr27Zf8l11PoE
         FIqVwbHO1N+WAnNp39jyBWDcREigRlxIZqblAMrT5b7jvcKRzD1YjVl1RUyIRzfO4I5Q
         1d9BxaaqAItr6re5nvDymP1C5oSO8bMiUMFPWNzhQRpu0SJ1WYN2v18TuCSwn0FbylEh
         WQn8mAAoIqtfx0nB0yobLy0GbPDIyqK+5MQOhfb709L29iNXzHZTLGqf0V8wPi+BTJd9
         boV9UwRbCHteqtDnv2G8sDGZLMLMO3DclLF+r+CHX90A5o7uLYjuAbZgPE1F3PWueBmR
         fhYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXTX53MxHIur1mLgcSWsGWizzIHbULjQ7RGtrszKG/zTugVv7RJ
	yMI6Owy2/kpgZtE/q+F5xT2JzWTSJR7WOzcdtUTGop93ZZ638rvgxQ0H/CZNdgFSOnAjuIFY0ly
	ztUP7gF2lQ4rLmJyz086HZp7pDRp50KXoJl+3Z3qYT18cckYge6wUbzLVY0+11X9btA==
X-Received: by 2002:a50:a7a6:: with SMTP id i35mr50296119edc.96.1555422482652;
        Tue, 16 Apr 2019 06:48:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhSyTnGcxWEbPKdSLEuN8TYB3ABYWUHOwmeYxRBJ1PQhQTX8TH68P1kooHu7DjDx6GDdTz
X-Received: by 2002:a50:a7a6:: with SMTP id i35mr50296009edc.96.1555422480608;
        Tue, 16 Apr 2019 06:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422480; cv=none;
        d=google.com; s=arc-20160816;
        b=wIaWdwayg5urejySgyLnImYXPgf5oNz6wuzqG9P/hN6/FqoQwKTyl6Z0sdhE16HZQI
         cOeQwqg+q5/0XTdTsqJY5pNIVVkA8JoXmvbVvd8c8GpMieSADmZzn0FqPlYYC89F6/Cf
         GMMvqEAqe6OgyuzNoh/YqtnAkR22g3Nqcumn/idLBd29Lt7JBx2GlXADiZyKaNhRRcFp
         qr51K2t2b0JggimcILIvSS75P0jmPFzc1/Enn4vLpxtoDBlUp/xk6TgE1XIypWAa5L1v
         TZCvY+ZvLzX8X9KQ15BBN3G69n5TDpmkU4mNbg9orjxvfHNoHGf41ZAPzyKUUEAP+fRj
         bR+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=Jz5rqUkE6WFM4DKQsFaVvFygOBtBuOfuq1p+t1n4dxE=;
        b=DbuBQhmZPMSDNyb+XpQN2wUiX16CVdQ242q9255OVLhnkkXETx77hJy6DIyX/PHQiK
         teupCCEHn5/SWHZO6zz3/IKnFqikivin357HV5RuXRUVRmdf4XursnK+XIfCsr+6qSi1
         CtADqZVQBxMPzzSf+F0dcn6EAPoDnNRzSudJnQBI1D2UAmjPxSmpqQRKv0uYBkGgC7SN
         /1b/DvprQqyYny3N++1HCXLSZlpxkGH1YeKXxmRibCv9Pr1OrqGY+gqCkkU8C6y9ihdj
         lXO0whT6855X5rKJAoJpriVHoapWOmBFbVpuT/cmQdbXJ8RhY4t1PO4yi4yINOhQZJBE
         vv/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id c45si15955833ede.103.2019.04.16.06.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:48:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlGXl060623
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:59 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rwe3k5vd6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:20 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:43 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:33 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkVc961145266
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:31 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 80BDA4C050;
	Tue, 16 Apr 2019 13:46:31 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 102364C046;
	Tue, 16 Apr 2019 13:46:30 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:29 +0000 (GMT)
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
        x86@kernel.org, Vinayak Menon <vinmenon@codeaurora.org>
Subject: [PATCH v12 23/31] mm: don't do swap readahead during speculative page fault
Date: Tue, 16 Apr 2019 15:45:14 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0008-0000-0000-000002DA6FB6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0009-0000-0000-00002246A83F
Message-Id: <20190416134522.17540-24-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=934 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vinayak Menon faced a panic because one thread was page faulting a page in
swap, while another one was mprotecting a part of the VMA leading to a VMA
split.
This raise a panic in swap_vma_readahead() because the VMA's boundaries
were not more matching the faulting address.

To avoid this, if the page is not found in the swap, the speculative page
fault is aborted to retry a regular page fault.

Reported-by: Vinayak Menon <vinmenon@codeaurora.org>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/memory.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 6e6bf61c0e5c..1991da97e2db 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2900,6 +2900,17 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 				lru_cache_add_anon(page);
 				swap_readpage(page, true);
 			}
+		} else if (vmf->flags & FAULT_FLAG_SPECULATIVE) {
+			/*
+			 * Don't try readahead during a speculative page fault
+			 * as the VMA's boundaries may change in our back.
+			 * If the page is not in the swap cache and synchronous
+			 * read is disabled, fall back to the regular page
+			 * fault mechanism.
+			 */
+			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
+			ret = VM_FAULT_RETRY;
+			goto out;
 		} else {
 			page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE,
 						vmf);
-- 
2.21.0

