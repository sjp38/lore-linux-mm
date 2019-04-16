Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 252DEC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9493222BB
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9493222BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 419B66B028B; Tue, 16 Apr 2019 09:47:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AD8F6B028C; Tue, 16 Apr 2019 09:47:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21CC36B028D; Tue, 16 Apr 2019 09:47:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C824F6B028B
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s21so3586554edd.10
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=D74TI4wTqaLm+uQLuyy7fuTf7fEfjbDu3aa1CZ6Jvec=;
        b=cWzK8FXPDD2prZ/1VZvUVw0oqIi7LXr+uA6b1rUUr95ZMSIIt/dH2RqgEFjin9Vfmt
         cWC7tk+1lffPazJ0Y0QPBO9LJe7ciLqmGhBjp4fZ3M9nT3F2bKBuu5msMnrvcRuVmeRT
         oD60njF/6QrH+S4TIUNe4UuvPX6YL2KJWmrMmOuXxeomogjYAgEtwO9z/511UbZFbUvl
         Ied5T1a/QC2V94jXH79Q4AIFA/xNHoSwsEQIrKIv9KdKhPSPPqQhbQpwcLwLkjH9v8OG
         s35zjR4Bi8UKTKiSUtrzRRf1dlArrNPaAz1KsFP0GQ07dkon0gD3kfACRsjKCkcng3jN
         kX3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUHg+Y6XLd4npp6eu8gIx1GSF56M37WUFTLHEmu30TIG5clsPw0
	oJAJ3NRmlTU5lAAxWbKvkkAY/QWytrmHlUyTly05cCfMEBWxh+Mv91DiBY1RDgUbyA5E+9gzQhm
	7ZH6D5rdE7KAlDqgegQQcaPhSu+5SHx0F2hoMbnXBJL7Cx4Zn5CgMsZB0fD4FIP6jMA==
X-Received: by 2002:a17:906:4017:: with SMTP id v23mr44333747ejj.40.1555422448192;
        Tue, 16 Apr 2019 06:47:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqziSk415UcXA4F2az/8c1fe0MSM83jAVJCkP/zuCJUOtj2pdxub+F3wC+1DVI7oOT1+3VMT
X-Received: by 2002:a17:906:4017:: with SMTP id v23mr44333660ejj.40.1555422446576;
        Tue, 16 Apr 2019 06:47:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422446; cv=none;
        d=google.com; s=arc-20160816;
        b=g++QoKbOvWJ1r05RmNVwumkxBxF9oBVBZF7JzorhhmtRdHv4L+s2lTVN2rZabVW95G
         XUP1sXrQDxbWMlyW54AqBzKjps/OcEASpBWsaYHTCtWSWcSL4GBIEWXgMaiZ0Yk14iY5
         N3HIdO/HYPhGamz4Yx71JMbmVF1fAGPApd2wEetRaTDbTa0j5xn4bLu6onot3bExfd3I
         5PfzOEsDiZ159NzX89sX17eurYmucrm66fBbXxMblspj7E3e0nZKCLoWvWbTMbfH0Idl
         Qn93EXbOznreN/Y9AR1RXJcGQXhkoLFOqK+H1OS1dNixBaeApB3pjarUxpQQCgfFEDcI
         hKBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=D74TI4wTqaLm+uQLuyy7fuTf7fEfjbDu3aa1CZ6Jvec=;
        b=mP3q5OLS8lgoL6TQwPZm4XfesSGSE9UzWk4W+A7ijCU1LTk22OKqH4mghtN/MOEC+L
         o3oAc3LLdryopwn/HZfD7+As8TiNBlBQNTPoGPdXjZJ6aZb96xSX2y+HzuSfdee85wWt
         aoHj+n/99NCwZxo55pkgOsuTpc7jZKRhkXp3HrxcycOpRYt7vn1+FTsYrHDtaeAHD1dq
         z9l/8mjWO8yydhgO6YUFMApKHJkYku36cjOJuh3+FAcQ8z+8wnjybaDF3tkSzIZdSxaE
         y/R0I0mkMfN+YF981VEO7dqYlGtCmlpgfi2c3/g+47Kbc1ELnmHoKEf8fV7+t+vynk9o
         stVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w2si7537413edh.436.2019.04.16.06.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlHPk060649
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:25 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rwe3k5vms-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:21 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:59 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:49 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDklaL24838310
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:47 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A0ADD4C044;
	Tue, 16 Apr 2019 13:46:47 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1BCED4C05E;
	Tue, 16 Apr 2019 13:46:46 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:45 +0000 (GMT)
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
Subject: [PATCH v12 29/31] powerpc/mm: add speculative page fault
Date: Tue, 16 Apr 2019 15:45:20 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0008-0000-0000-000002DA6FC4
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0009-0000-0000-00002246A849
Message-Id: <20190416134522.17540-30-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=998 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch enable the speculative page fault on the PowerPC
architecture.

This will try a speculative page fault without holding the mmap_sem,
if it returns with VM_FAULT_RETRY, the mmap_sem is acquired and the
traditional page fault processing is done.

The speculative path is only tried for multithreaded process as there is no
risk of contention on the mmap_sem otherwise.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 arch/powerpc/mm/fault.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index ec74305fa330..5d48016073cb 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -491,6 +491,21 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	if (is_exec)
 		flags |= FAULT_FLAG_INSTRUCTION;
 
+	/*
+	 * Try speculative page fault before grabbing the mmap_sem.
+	 * The Page fault is done if VM_FAULT_RETRY is not returned.
+	 * But if the memory protection keys are active, we don't know if the
+	 * fault is due to key mistmatch or due to a classic protection check.
+	 * To differentiate that, we will need the VMA we no more have, so
+	 * let's retry with the mmap_sem held.
+	 */
+	fault = handle_speculative_fault(mm, address, flags);
+	if (fault != VM_FAULT_RETRY && (IS_ENABLED(CONFIG_PPC_MEM_KEYS) &&
+					fault != VM_FAULT_SIGSEGV)) {
+		perf_sw_event(PERF_COUNT_SW_SPF, 1, regs, address);
+		goto done;
+	}
+
 	/* When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in the
 	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
@@ -600,6 +615,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 
 	up_read(&current->mm->mmap_sem);
 
+done:
 	if (unlikely(fault & VM_FAULT_ERROR))
 		return mm_fault_error(regs, address, fault);
 
-- 
2.21.0

