Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F59CC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D9AC222DF
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 13:48:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D9AC222DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CC066B0296; Tue, 16 Apr 2019 09:47:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 380376B0298; Tue, 16 Apr 2019 09:47:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26C136B0299; Tue, 16 Apr 2019 09:47:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0697E6B0296
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:52 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id g186so15674158ybg.16
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:47:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=h+dSz3dIugqGQM4BNY4sysZNpxbYjrXmKmAZ5NCn5zQ=;
        b=QyP5WRPSHJAqyKLfyKhADlXtBO2aXIFZBi0LmloNa8c3mHyMF9XUoqJKrzPOrKMmQz
         YBTRl6ZZHGT7pm1BmVJ0nhLF99WdU8qAy8o/GoAvwgVtppn/REaGQ0vAuJYStqtxQANb
         ipGsg1YtqUv6689tim1mTg0vAsOF6no+4ACEvL05Kxsx6Huq0H2spEdzZsC00apasr7W
         0lHqHp4kc3cVSnUrn4E/htcKXopthj38Eg2D8v96n7fTVTSdo2rH10rlP9CmP0aSjBJL
         GSv9rV/OqDtVAA5p58FQYfOzivEJIDeHkOX2qRRIZ6Fqb48/BYG/8Oj/jGdi43ib3hxf
         0MYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVsBJv7SvYxr2b+5QOOc01bQzI54nmLV/F+6n7sbAfZMxuq/Y17
	TCUrr4XT4ViOFCNXRXwW264JgKNBXyam/z8vN/GS0AqA8YILUSgVRA+tQhunZn9uhtTWQm12lp8
	uBcyZK9OMrEea9lluXORMdN5t4wB4KhjE3HFm22ZS1N0W4OL0MksBSeuKBtT/o2eO4A==
X-Received: by 2002:a25:c8c7:: with SMTP id y190mr15979914ybf.285.1555422471763;
        Tue, 16 Apr 2019 06:47:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQchnBrhhdSDL7Yz6aZZYHC/sMs+WJPhfCvMh+VmTFKElfBus83ypuJmvlxtgMXpXJo+jV
X-Received: by 2002:a25:c8c7:: with SMTP id y190mr15979820ybf.285.1555422470624;
        Tue, 16 Apr 2019 06:47:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555422470; cv=none;
        d=google.com; s=arc-20160816;
        b=Q5puU3BDxlWUj/iMSi1ozBSEKVkHsGphwA5YmmMtikVepjZ6F4QXOeTpDJ+U9gyQ1g
         qloBEhxGjBniNhDXL7lZ2cigSxYPN8y4y6opczwyK2RWxFKvxGUWtS+Rzi00n1jZzjX8
         mf+5H3ur7nO6ye6c7O4o+BhGQ8RwVNLE0pN9OTrlVhy+JzliBw4n1QtMktgP5bxinE8F
         Bu054hCSNUocGCkKslJ/7UIBdIL6W9HM+TnzDYN7TxmXFFLnDEqGCEkOsS14aV6AQHhr
         to7p3d4GSOY/OQuLxZQR1r6n88fFn1gdAYe8iyJe3+mozZsueF258LwriXOhJky0jhb9
         9WfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=h+dSz3dIugqGQM4BNY4sysZNpxbYjrXmKmAZ5NCn5zQ=;
        b=Q3RM39NP6IYYdI0jGv0WiXYTJfh8hD4gaCWVfs+iS6ZEXi3hdczmYO2JGrC5Dmjnza
         uWNuvoN+A7fR94UP/o9zdK2o/wIqPn6+Hhx3MkC6olKFhg6dUyWd0YWlOamvFJwoxrCF
         wMZopx8bRpiwbEK/+Ow4ppMnjSttczWfyBC0K/REd3rilYlOo+PFZwMLff6rHTMsz8KW
         pJJyZ3P2rAaazSOfZkU7LOB4Uw3NVaaP44u/f+aPJrRi+w3m9dS0d86Lnz3m5cEe/yxg
         lJH35pKpNrG7wY/BoDzncDbRYaV7JWREENqHvZ6qegar1MP8aPlR4XFIGgj6OYY2Sgf/
         Whsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x17si10550696ybj.198.2019.04.16.06.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:47:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GDlT6E093889
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:49 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rwe1t6d9k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 09:47:41 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 14:45:53 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 14:45:43 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GDjfqs27262988
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 13:45:41 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C7A184C062;
	Tue, 16 Apr 2019 13:45:41 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5A8EA4C058;
	Tue, 16 Apr 2019 13:45:40 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 13:45:40 +0000 (GMT)
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
Subject: [PATCH v12 06/31] mm: introduce pte_spinlock for FAULT_FLAG_SPECULATIVE
Date: Tue, 16 Apr 2019 15:44:57 +0200
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190416134522.17540-1-ldufour@linux.ibm.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041613-0016-0000-0000-0000026F7267
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041613-0017-0000-0000-000032CBBD77
Message-Id: <20190416134522.17540-7-ldufour@linux.ibm.com>
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

When handling page fault without holding the mmap_sem the fetch of the
pte lock pointer and the locking will have to be done while ensuring
that the VMA is not touched in our back.

So move the fetch and locking operations in a dedicated function.

Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/memory.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index fc3698d13cb5..221ccdf34991 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2073,6 +2073,13 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
+static inline bool pte_spinlock(struct vm_fault *vmf)
+{
+	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
+	spin_lock(vmf->ptl);
+	return true;
+}
+
 static inline bool pte_map_lock(struct vm_fault *vmf)
 {
 	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd,
@@ -3656,8 +3663,8 @@ static vm_fault_t do_numa_page(struct vm_fault *vmf)
 	 * validation through pte_unmap_same(). It's of NUMA type but
 	 * the pfn may be screwed if the read is non atomic.
 	 */
-	vmf->ptl = pte_lockptr(vma->vm_mm, vmf->pmd);
-	spin_lock(vmf->ptl);
+	if (!pte_spinlock(vmf))
+		return VM_FAULT_RETRY;
 	if (unlikely(!pte_same(*vmf->pte, vmf->orig_pte))) {
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		goto out;
@@ -3850,8 +3857,8 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
 	if (pte_protnone(vmf->orig_pte) && vma_is_accessible(vmf->vma))
 		return do_numa_page(vmf);
 
-	vmf->ptl = pte_lockptr(vmf->vma->vm_mm, vmf->pmd);
-	spin_lock(vmf->ptl);
+	if (!pte_spinlock(vmf))
+		return VM_FAULT_RETRY;
 	entry = vmf->orig_pte;
 	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
-- 
2.21.0

