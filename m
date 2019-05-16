Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23FB6C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E449A2087E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 09:42:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E449A2087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70B126B0007; Thu, 16 May 2019 05:42:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66EB46B0008; Thu, 16 May 2019 05:42:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50EAA6B000A; Thu, 16 May 2019 05:42:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0849A6B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 05:42:42 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id r16so1099642wrj.13
        for <linux-mm@kvack.org>; Thu, 16 May 2019 02:42:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YN77z8gKHSuM2XjFecvZy0A0ECsUV7zC1Q0pr8QKOlY=;
        b=BVazevE4SHQIFl3lu65ZMITv0vrfIzzx4p9h9jwEeVQUdcWEyMETFYWF9/nqXdHBL1
         kky2rB8DHSwqVgwz5aax0q70S2Yiu2NZyKyGgBuKzLH+vWFfpWr8bvFlIgGP2GIjusgO
         5GLbaMeBww7b3V1sdY7S8h/J5T1blWksBi/wHfdEBSL+vzsvtcXhtmTy2D0UtCbGE+iQ
         9KeP2PWjz1RlvOAQpRLUMY1qclU6rfT2PdSLeDENRUzY79YRVM/wbCfmD+zZmAylFRYW
         z7Q0zqIm2YLerc+NKkTe4xa+Gfyisa28sagwJzREhEthxCwLW7je5uXOx+8IKuyyGOWB
         ftaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXAbqiqSjkuuE/1kEbjlr99G/oWibf5qkESJXBkdCihHKBPKjJw
	5D/C/xT+y0ItfDRgAZzvWjfVEHI9AXrk/49XMHnWpAWw0IPdLgjDp43EOMR4oMLQvOqsSwD/4Q5
	5rVcciHuyiEVXiyJIuVQibnMJHcddT32gO7vmVLjPCQoSFtr1aoO8/iRtwvLr83TPhA==
X-Received: by 2002:a1c:48d7:: with SMTP id v206mr27766233wma.38.1557999761556;
        Thu, 16 May 2019 02:42:41 -0700 (PDT)
X-Received: by 2002:a1c:48d7:: with SMTP id v206mr27766162wma.38.1557999760355;
        Thu, 16 May 2019 02:42:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557999760; cv=none;
        d=google.com; s=arc-20160816;
        b=AOmjQOPdO6AuGyTYqnxGhzdGTyTX8pKqL1FSCEMv2PqBz/GtlPnDCxdV66MWnpBTZh
         VciLAEOU5pHqxal+KO6KObZq4Z5PYCI/QWbVnQTIz5YxDumII1dCZf3+cf6zejs38dXB
         dN8Gy9y01hNmpqfBdEplv+9NYvGbyaFKvsNmmXMUeeU+mi5YFjn8eGX4BjUT3GpDCQQ3
         /5WlQaTweoqfpbwUxqBJYhye+pW+IwR1sS6EqVt/z6qXl8Rjg8ybxtyCVIVI5SHBiIYG
         boh/r5q+NKp9tyoWxyf0Z264xYGSvnmKyQ6mpQIm3OTEOOc19Bjn4zQ+UB5Rt8PYsHgi
         4KNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=YN77z8gKHSuM2XjFecvZy0A0ECsUV7zC1Q0pr8QKOlY=;
        b=Qc6EzPcNGjVyaSe7dcINvu50kAp57V/H6VzIEJUxePP/B4Ujmzd0wJWUIL7v8rVked
         ZeAZJ+11Rfmr0mtHO6rKFMx+5Jw5tC8OzLZlb/+rZqiwCf1x6EoywbT9V1c8j2/HTEmj
         lHbp3OFutC7Hy4RyVD+/xl6LtdkMel3R7VVBoEf0J8mYWQFRDXl2DwxBdyG+UFKeUrtA
         PqMJOcxJceXdkeKjjLwrBNQ9ZCdYggrlnlSWIirRv2FgMsKFWvEOMBC35lpRwtsLDj9i
         RMgZG0wTRWjloURRhaIzBNVUUNC3oBjTE/Kprmf58YzilZT4q0TcQSLmeWCpzVV1x82y
         PLPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor3820464wrt.23.2019.05.16.02.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 02:42:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqys469LpVWfYxPlfxZW3I0nW/iuorQWcrS5tP7pLu+XZ/hJioroCE9kOeMmFNuO1N+8Ds8oZA==
X-Received: by 2002:adf:f9c3:: with SMTP id w3mr20196436wrr.271.1557999759998;
        Thu, 16 May 2019 02:42:39 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id s3sm7204729wre.97.2019.05.16.02.42.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 02:42:39 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Subject: [PATCH RFC 2/5] mm/ksm: introduce ksm_madvise_merge() helper
Date: Thu, 16 May 2019 11:42:31 +0200
Message-Id: <20190516094234.9116-3-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190516094234.9116-1-oleksandr@redhat.com>
References: <20190516094234.9116-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move MADV_MERGEABLE part of ksm_madvise() into a dedicated helper since
it will be further used for marking VMAs to be merged forcibly.

This does not bring any functional changes.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 include/linux/ksm.h |  2 ++
 mm/ksm.c            | 60 +++++++++++++++++++++++++++------------------
 2 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index e48b1e453ff5..e824b3141677 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -19,6 +19,8 @@ struct stable_node;
 struct mem_cgroup;
 
 #ifdef CONFIG_KSM
+int ksm_madvise_merge(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long *vm_flags);
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		unsigned long end, int advice, unsigned long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
diff --git a/mm/ksm.c b/mm/ksm.c
index fc64874dc6f4..1fdcf2fbd58d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2442,41 +2442,53 @@ static int ksm_scan_thread(void *nothing)
 	return 0;
 }
 
-int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+int ksm_madvise_merge(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long *vm_flags)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	int err;
 
-	switch (advice) {
-	case MADV_MERGEABLE:
-		/*
-		 * Be somewhat over-protective for now!
-		 */
-		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
-				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_HUGETLB | VM_MIXEDMAP))
-			return 0;		/* just ignore the advice */
+	/*
+	 * Be somewhat over-protective for now!
+	 */
+	if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
+			 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
+			 VM_HUGETLB | VM_MIXEDMAP))
+		return 0;		/* just ignore the advice */
 
-		if (vma_is_dax(vma))
-			return 0;
+	if (vma_is_dax(vma))
+		return 0;
 
 #ifdef VM_SAO
-		if (*vm_flags & VM_SAO)
-			return 0;
+	if (*vm_flags & VM_SAO)
+		return 0;
 #endif
 #ifdef VM_SPARC_ADI
-		if (*vm_flags & VM_SPARC_ADI)
-			return 0;
+	if (*vm_flags & VM_SPARC_ADI)
+		return 0;
 #endif
 
-		if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
-			err = __ksm_enter(mm);
-			if (err)
-				return err;
-		}
+	if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
+		err = __ksm_enter(mm);
+		if (err)
+			return err;
+	}
+
+	*vm_flags |= VM_MERGEABLE;
+
+	return 0;
+}
 
-		*vm_flags |= VM_MERGEABLE;
+int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
+		unsigned long end, int advice, unsigned long *vm_flags)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	int err;
+
+	switch (advice) {
+	case MADV_MERGEABLE:
+		err = ksm_madvise_merge(mm, vma, vm_flags);
+		if (err)
+			return err;
 		break;
 
 	case MADV_UNMERGEABLE:
-- 
2.21.0

