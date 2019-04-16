Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8EBDC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9142D21B68
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:47:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9142D21B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70EAF6B0266; Tue, 16 Apr 2019 09:46:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68FAF6B026C; Tue, 16 Apr 2019 09:46:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43EDC6B026A; Tue, 16 Apr 2019 09:46:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1B2A96B0269
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:55 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id j62so15657861ywe.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:46:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=WKVMnBgOI6B/J82OoWTSlIuYM7akWgmuMADBH08y4RQ=;
        b=ZuPwkU0aCMaZ7NVWQoAQRHRyJ8TSjIL5tv/m5KTVNZJiQ6Ul69rCCf+VRPHXBvMn9w
         Lx4ZCxxEUhwVTSV5/satKUgXo4CfzOLKUO62TEBZKxVa6ebjUD0ru2cIZwfp00JHutVx
         e48Mp+hrggvY5CuhkQXqEfVbEvWEPm0X6VFUeJ/xskeweFJ2bNEB1FvIMzn2jGSa7F7l
         klwxoEYjKOHK0SxQiqOq7VGqa+F3NE8aAk0NaSxrwROTzHciskyjZkW5VRzKl2rm2dv/
         beaOBQk1xGlKprZpCMQBBvLDzXPwWF7gAMoLtNtemIcy/Gzwh2uOqsCNhxB4uvoKb7bl
         AKHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWeTMMCkek/4ojzwBhuABSLhaivuIbUf5YMWagEZVPJUQC0m3S3
	5W5gGyAi/jNoQxQFBo2zhb8Mgqv8hRLbZdkTTCKzR9YEzs/niXH8bFtoFosU2sjroWUTSHhhbdC
	0hTU9I5VlSo/xfxkjsZs3/Sp46W43HDpnDClRNw6XPGbI1kHVJXeFmFNMLFdQ+scpjA==
X-Received: by 2002:a81:3253:: with SMTP id y80mr64586434ywy.63.1555422414777;
        Tue, 16 Apr 2019 06:46:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6DtSnNAjMahPxwsTjFVQpJ0APoWsyYH6afLqcxOEBZX5Hs9GQaP1oUOznnfgc68+Y6vNH
X-Received: by 2002:a81:3253:: with SMTP id y80mr64586308ywy.63.1555422413186;
        Tue, 16 Apr 2019 06:46:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422413; cv=none;
        d=google.com; s=arc-20160816;
        b=hbI8D6FXCNbzKHF1lHKZIjwP99RzyHfJHkd3qoFMOzyYTX3ALP8I9pncHN8oioNewR
         EqavznOWMYQQKQyqkbipyvsh1TQhpEWaPIht29IGkYACVgaSd+rIyLnqGPGekgVh/B3Q
         qh8AEurTi03LmSzulesL9xLvaOIEMCp2wJc6HRQXLu2hWsEwOwX3UPIQfoU/J9C4eZH1
         OPv92KeEZI1vhKCr2QCjEPNjGboUuaubCvUnfwEZcxeo509mnajevOv9/qssI1Dpv5QM
         s3e0zoaUpW7oyRMKOCNwrEvwesUN7ZKAOeKZL2Ot1dUSizwMWO9sATlAystbiB3L66KM
         /zww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=WKVMnBgOI6B/J82OoWTSlIuYM7akWgmuMADBH08y4RQ=;
        b=ZlICak8N4g/nHX5ocpz3hHLr2mEdrB2Ug+KLLQCfWvFY8ssDqC7HyE9/I0taComoHq
         4BWSXJ4BIDiFjNsEjjsji2u23WMD3YHPq657Immxt5x8ZYCdpK0DuOXLn1EGRA7zT+Pv
         wA8X6yIbW+p3Xg81r1nD51lZxpVAvU8dw6UxJDUMwmDEiDLqgPpUczRzea6Z0QYft8rN
         sxveXI2TWYvd4U3hmiHHi3jYmzpMcRXw5uC/84khEu7b/btG3IsjsubCi3pQvFpYLm6v
         Grvcbq8+meyPCK7mdqPCGqlTY2F5dXQqYh57ib07bREZ9TnJDqKmc1KmS0hwgYU+OQs4
         RdRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w5si34891547yww.420.2019.04.16.06.46.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:46:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDkmvl059220
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:52 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe36nymw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:46:50 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:46:46 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:46:36 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDkYua30736478
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:46:34 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 623894C040;
	Tue, 16 Apr 2019 13:46:34 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8FE474C04A;
	Tue, 16 Apr 2019 13:46:32 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:46:32 +0000 (GMT)
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
Subject: [PATCH v12 24/31] mm: adding speculative page fault failure trace events
Date: Tue, 16 Apr 2019 15:45:15 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0008-0000-0000-000002DA6FB7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0009-0000-0000-00002246A840
Message-Id: <20190416134522.17540-25-ldufour@linux.ibm.com>
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

This patch a set of new trace events to collect the speculative page fault
event failures.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 include/trace/events/pagefault.h | 80 ++++++++++++++++++++++++++++++++
 mm/memory.c                      | 57 ++++++++++++++++++-----
 2 files changed, 125 insertions(+), 12 deletions(-)
 create mode 100644 include/trace/events/pagefault.h

diff --git a/include/trace/events/pagefault.h b/include/trace/events/pagefault.h
new file mode 100644
index 000000000000..d9438f3e6bad
--- /dev/null
+++ b/include/trace/events/pagefault.h
@@ -0,0 +1,80 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM pagefault
+
+#if !defined(_TRACE_PAGEFAULT_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_PAGEFAULT_H
+
+#include <linux/tracepoint.h>
+#include <linux/mm.h>
+
+DECLARE_EVENT_CLASS(spf,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, caller)
+		__field(unsigned long, vm_start)
+		__field(unsigned long, vm_end)
+		__field(unsigned long, address)
+	),
+
+	TP_fast_assign(
+		__entry->caller		= caller;
+		__entry->vm_start	= vma->vm_start;
+		__entry->vm_end		= vma->vm_end;
+		__entry->address	= address;
+	),
+
+	TP_printk("ip:%lx vma:%lx-%lx address:%lx",
+		  __entry->caller, __entry->vm_start, __entry->vm_end,
+		  __entry->address)
+);
+
+DEFINE_EVENT(spf, spf_vma_changed,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_vma_noanon,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_vma_notsup,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_vma_access,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+DEFINE_EVENT(spf, spf_pmd_changed,
+
+	TP_PROTO(unsigned long caller,
+		 struct vm_area_struct *vma, unsigned long address),
+
+	TP_ARGS(caller, vma, address)
+);
+
+#endif /* _TRACE_PAGEFAULT_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/memory.c b/mm/memory.c
index 1991da97e2db..509851ad7c95 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -81,6 +81,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/pagefault.h>
+
 #if defined(LAST_CPUPID_NOT_IN_PAGE_FLAGS) && !defined(CONFIG_COMPILE_TEST)
 #warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_cpupid.
 #endif
@@ -2100,8 +2103,10 @@ static bool pte_spinlock(struct vm_fault *vmf)
 
 again:
 	local_irq_disable();
-	if (vma_has_changed(vmf))
+	if (vma_has_changed(vmf)) {
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	/*
@@ -2109,8 +2114,10 @@ static bool pte_spinlock(struct vm_fault *vmf)
 	 * is not a huge collapse operation in progress in our back.
 	 */
 	pmdval = READ_ONCE(*vmf->pmd);
-	if (!pmd_same(pmdval, vmf->orig_pmd))
+	if (!pmd_same(pmdval, vmf->orig_pmd)) {
+		trace_spf_pmd_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 #endif
 
 	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
@@ -2121,6 +2128,7 @@ static bool pte_spinlock(struct vm_fault *vmf)
 
 	if (vma_has_changed(vmf)) {
 		spin_unlock(vmf->ptl);
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
 	}
 
@@ -2154,8 +2162,10 @@ static bool pte_map_lock(struct vm_fault *vmf)
 	 */
 again:
 	local_irq_disable();
-	if (vma_has_changed(vmf))
+	if (vma_has_changed(vmf)) {
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	/*
@@ -2163,8 +2173,10 @@ static bool pte_map_lock(struct vm_fault *vmf)
 	 * is not a huge collapse operation in progress in our back.
 	 */
 	pmdval = READ_ONCE(*vmf->pmd);
-	if (!pmd_same(pmdval, vmf->orig_pmd))
+	if (!pmd_same(pmdval, vmf->orig_pmd)) {
+		trace_spf_pmd_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
+	}
 #endif
 
 	/*
@@ -2184,6 +2196,7 @@ static bool pte_map_lock(struct vm_fault *vmf)
 
 	if (vma_has_changed(vmf)) {
 		pte_unmap_unlock(pte, ptl);
+		trace_spf_vma_changed(_RET_IP_, vmf->vma, vmf->address);
 		goto out;
 	}
 
@@ -4187,47 +4200,60 @@ vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
 
 	/* rmb <-> seqlock,vma_rb_erase() */
 	seq = raw_read_seqcount(&vma->vm_sequence);
-	if (seq & 1)
+	if (seq & 1) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	/*
 	 * Can't call vm_ops service has we don't know what they would do
 	 * with the VMA.
 	 * This include huge page from hugetlbfs.
 	 */
-	if (vma->vm_ops && vma->vm_ops->fault)
+	if (vma->vm_ops && vma->vm_ops->fault) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	/*
 	 * __anon_vma_prepare() requires the mmap_sem to be held
 	 * because vm_next and vm_prev must be safe. This can't be guaranteed
 	 * in the speculative path.
 	 */
-	if (unlikely(!vma->anon_vma))
+	if (unlikely(!vma->anon_vma)) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	vmf.vma_flags = READ_ONCE(vma->vm_flags);
 	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
 
 	/* Can't call userland page fault handler in the speculative path */
-	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
+	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING)) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
-	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
+	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP) {
 		/*
 		 * This could be detected by the check address against VMA's
 		 * boundaries but we want to trace it as not supported instead
 		 * of changed.
 		 */
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	if (address < READ_ONCE(vma->vm_start)
-	    || READ_ONCE(vma->vm_end) <= address)
+	    || READ_ONCE(vma->vm_end) <= address) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
 				       flags & FAULT_FLAG_INSTRUCTION,
 				       flags & FAULT_FLAG_REMOTE)) {
+		trace_spf_vma_access(_RET_IP_, vma, address);
 		ret = VM_FAULT_SIGSEGV;
 		goto out_put;
 	}
@@ -4235,10 +4261,12 @@ vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
 	/* This is one is required to check that the VMA has write access set */
 	if (flags & FAULT_FLAG_WRITE) {
 		if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
+			trace_spf_vma_access(_RET_IP_, vma, address);
 			ret = VM_FAULT_SIGSEGV;
 			goto out_put;
 		}
 	} else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
+		trace_spf_vma_access(_RET_IP_, vma, address);
 		ret = VM_FAULT_SIGSEGV;
 		goto out_put;
 	}
@@ -4252,8 +4280,10 @@ vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
 	pol = __get_vma_policy(vma, address);
 	if (!pol)
 		pol = get_task_policy(current);
-	if (pol && pol->mode == MPOL_INTERLEAVE)
+	if (pol && pol->mode == MPOL_INTERLEAVE) {
+		trace_spf_vma_notsup(_RET_IP_, vma, address);
 		goto out_put;
+	}
 #endif
 
 	/*
@@ -4326,8 +4356,10 @@ vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
 	 * We need to re-validate the VMA after checking the bounds, otherwise
 	 * we might have a false positive on the bounds.
 	 */
-	if (read_seqcount_retry(&vma->vm_sequence, seq))
+	if (read_seqcount_retry(&vma->vm_sequence, seq)) {
+		trace_spf_vma_changed(_RET_IP_, vma, address);
 		goto out_put;
+	}
 
 	mem_cgroup_enter_user_fault();
 	ret = handle_pte_fault(&vmf);
@@ -4346,6 +4378,7 @@ vm_fault_t __handle_speculative_fault(struct mm_struct *mm,
 	return ret;
 
 out_walk:
+	trace_spf_vma_notsup(_RET_IP_, vma, address);
 	local_irq_enable();
 out_put:
 	put_vma(vma);
-- 
2.21.0

