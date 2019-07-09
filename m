Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21C57C606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D795D214AF
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 10:26:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D795D214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B3338E0049; Tue,  9 Jul 2019 06:26:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 365918E0032; Tue,  9 Jul 2019 06:26:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 207338E0049; Tue,  9 Jul 2019 06:26:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE95F8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 06:26:08 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id t18so8825365ybp.13
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 03:26:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=CVX2X/Wc7acOzMkPnPicX/PVDdBk728ytKJ5cOPdNa8=;
        b=KUv5hqdBUHBx7ApdjhRuWAwcrHV8hFXYqWeXSiDWGcfDye3A49gprmqnuAzwydU0ad
         LWyEaj68CcJr5wOgLfPLHMlaV+GseEsBK+vs/gQM9ZAaYJLyw7jF10yCxbj4dZnHhKfH
         nz3gQ4oA/LpA40ZV4SRWUXsXTkEUQ4q+LWPbjWrCvw3g9sgxiyObiY6LYbnU59yTQ6u4
         OwoFImBzCpDrd+W8afBCx2uTJxjx1bDfKFHveJKhiTsR2Vydh2xQWrw0RQbn2ssM0oYe
         hFBEepAB7RY+3abWnx8qVW5VqbjI9md1UdSIafPPpimN96hCymZf5GGr6ro22ThL5yNn
         7Ukw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAU7dkX0bvd0zIaQ1exXazNM7CImoi8T/7cC+qgFJa+R1Tpwv1qo
	+7qOieAo7Aa2vZ3n7HNqJOEF7nGvcj875iie5s1+4egqVx9yUcAcKVAN+0oY6PNEW7BeU0eM4mZ
	rAlewF3iQxQLr/1LRkfgByO3kLjnXDClqYkIde6pyF19wPIAuTR8F0J2gMJylNmxFfw==
X-Received: by 2002:a25:870d:: with SMTP id a13mr12877638ybl.92.1562667968697;
        Tue, 09 Jul 2019 03:26:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrmDp+4JO/LUinrJJItljFZdO9JX2UQRPE4NobZIO5M50voQZiQoyefv8rlxnC3Af04lf4
X-Received: by 2002:a25:870d:: with SMTP id a13mr12877609ybl.92.1562667967457;
        Tue, 09 Jul 2019 03:26:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562667967; cv=none;
        d=google.com; s=arc-20160816;
        b=SdFVBgAsGxLPcvGd8h7w0sYGzZlnAzWa3dPiJNGDBWBp0RlEYoQoMLsQ/bmVU+yFWO
         9S0dOBSx+kBBv652sPpExUarIbnaKb37vLgPwyfQ0M7qV2KoU55OgCl/yOJbgkydOSw/
         Jo2oHeZGRrfxbHbOkhG261+angWv4HtjvqkmME2OelcKjLHg2zMjdQo3Fng2pepndO/9
         UA+L08i9akAVsNVKbS62Pr4HqsRwjtnB4WOfxl9CsPRtHVjvFqw74mcuXh892CrLcHyK
         wCbLYa1d+IRLY0Xfe8bYcenZXyDvviSntoWzSSBQavHg3fphqkUNG0j0TBwxmDzHdxel
         SxWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=CVX2X/Wc7acOzMkPnPicX/PVDdBk728ytKJ5cOPdNa8=;
        b=aj5vE+RVO83Y67/czIYdW5QRs9EEfXL0thabygJFv84MBYF1oYz26NXav1xjvb/cTz
         XwhXyc/5p7zc+sDqihs/FqhndQg6BNqgMYjuDRTGXKmHPHOulY5zOiXN3Zsh79zPh/h3
         GDOwa6KLtFoJrzluL5zxrL3Ca/fAcs6xUJiBEbozfvRVYkIKV09P/cVV1PzDaPZdS1Ne
         9DKHiQh/KGtdbaL2jwZAUVHcH8rqiEypa77MuM6FlG+D6109DMtOnU0uA9AaJ76rxCWc
         TlOOH9uoHBfegFs8QIWUU4M7/IOpXgJU2vUgPCcp4XupB8AjtXMcgMl3U6NCUeVBdplt
         iEFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 84si7981038ywp.221.2019.07.09.03.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 03:26:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x69ANI3m132013
	for <linux-mm@kvack.org>; Tue, 9 Jul 2019 06:26:07 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2tmptgnqwh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 09 Jul 2019 06:26:06 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 9 Jul 2019 11:26:05 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 9 Jul 2019 11:26:01 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x69APldf37552558
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 9 Jul 2019 10:25:47 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C8AD3AE053;
	Tue,  9 Jul 2019 10:25:59 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 01F44AE045;
	Tue,  9 Jul 2019 10:25:58 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.85.81.51])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  9 Jul 2019 10:25:57 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v5 2/7] kvmppc: Shared pages support for secure guests
Date: Tue,  9 Jul 2019 15:55:40 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190709102545.9187-1-bharata@linux.ibm.com>
References: <20190709102545.9187-1-bharata@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19070910-0028-0000-0000-00000382428E
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19070910-0029-0000-0000-000024424E62
Message-Id: <20190709102545.9187-3-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=727 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907090127
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A secure guest will share some of its pages with hypervisor (Eg. virtio
bounce buffers etc). Support shared pages in HMM driver.

Once a secure page is converted to shared page, HMM driver will stop
tracking that page.

Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
---
 arch/powerpc/include/asm/hvcall.h |  3 ++
 arch/powerpc/kvm/book3s_hv_hmm.c  | 66 +++++++++++++++++++++++++++++--
 2 files changed, 66 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/include/asm/hvcall.h b/arch/powerpc/include/asm/hvcall.h
index 2f6b952deb0f..05b8536f6653 100644
--- a/arch/powerpc/include/asm/hvcall.h
+++ b/arch/powerpc/include/asm/hvcall.h
@@ -337,6 +337,9 @@
 #define H_TLB_INVALIDATE	0xF808
 #define H_COPY_TOFROM_GUEST	0xF80C
 
+/* Flags for H_SVM_PAGE_IN */
+#define H_PAGE_IN_SHARED        0x1
+
 /* Platform-specific hcalls used by the Ultravisor */
 #define H_SVM_PAGE_IN		0xEF00
 #define H_SVM_PAGE_OUT		0xEF04
diff --git a/arch/powerpc/kvm/book3s_hv_hmm.c b/arch/powerpc/kvm/book3s_hv_hmm.c
index cd34323888b6..36562b382e70 100644
--- a/arch/powerpc/kvm/book3s_hv_hmm.c
+++ b/arch/powerpc/kvm/book3s_hv_hmm.c
@@ -52,6 +52,7 @@ struct kvmppc_hmm_page_pvt {
 	unsigned long *rmap;
 	unsigned int lpid;
 	unsigned long gpa;
+	bool skip_page_out;
 };
 
 struct kvmppc_hmm_migrate_args {
@@ -215,6 +216,53 @@ static const struct migrate_vma_ops kvmppc_hmm_migrate_ops = {
 	.finalize_and_map = kvmppc_hmm_migrate_finalize_and_map,
 };
 
+/*
+ * Shares the page with HV, thus making it a normal page.
+ *
+ * - If the page is already secure, then provision a new page and share
+ * - If the page is a normal page, share the existing page
+ *
+ * In the former case, uses the HMM fault handler to release the HMM page.
+ */
+static unsigned long
+kvmppc_share_page(struct kvm *kvm, unsigned long gpa, unsigned long page_shift)
+{
+
+	int ret;
+	struct page *hmm_page;
+	struct kvmppc_hmm_page_pvt *pvt;
+	unsigned long pfn;
+	unsigned long *rmap;
+	struct kvm_memory_slot *slot;
+	unsigned long gfn = gpa >> page_shift;
+	int srcu_idx;
+
+	srcu_idx = srcu_read_lock(&kvm->srcu);
+	slot = gfn_to_memslot(kvm, gfn);
+	if (!slot) {
+		srcu_read_unlock(&kvm->srcu, srcu_idx);
+		return H_PARAMETER;
+	}
+	rmap = &slot->arch.rmap[gfn - slot->base_gfn];
+	srcu_read_unlock(&kvm->srcu, srcu_idx);
+
+	if (kvmppc_is_hmm_pfn(*rmap)) {
+		hmm_page = pfn_to_page(*rmap & ~KVMPPC_PFN_HMM);
+		pvt = (struct kvmppc_hmm_page_pvt *)
+			hmm_devmem_page_get_drvdata(hmm_page);
+		pvt->skip_page_out = true;
+	}
+
+	pfn = gfn_to_pfn(kvm, gpa >> page_shift);
+	if (is_error_noslot_pfn(pfn))
+		return H_PARAMETER;
+
+	ret = uv_page_in(kvm->arch.lpid, pfn << page_shift, gpa, 0, page_shift);
+	kvm_release_pfn_clean(pfn);
+
+	return (ret == U_SUCCESS) ? H_SUCCESS : H_PARAMETER;
+}
+
 /*
  * Move page from normal memory to secure memory.
  */
@@ -235,9 +283,12 @@ kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
 	if (page_shift != PAGE_SHIFT)
 		return H_P3;
 
-	if (flags)
+	if (flags & ~H_PAGE_IN_SHARED)
 		return H_P2;
 
+	if (flags & H_PAGE_IN_SHARED)
+		return kvmppc_share_page(kvm, gpa, page_shift);
+
 	down_read(&kvm->mm->mmap_sem);
 	srcu_idx = srcu_read_lock(&kvm->srcu);
 	slot = gfn_to_memslot(kvm, gfn);
@@ -299,8 +350,17 @@ kvmppc_hmm_fault_migrate_alloc_and_copy(struct vm_area_struct *vma,
 	       hmm_devmem_page_get_drvdata(spage);
 
 	pfn = page_to_pfn(dpage);
-	ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
-			  pvt->gpa, 0, PAGE_SHIFT);
+
+	/*
+	 * This same alloc_and_copy() callback is used in two cases:
+	 * - When HV touches a secure page, for which we do page-out
+	 * - When a secure page is converted to shared page, we touch
+	 *   the page to essentially discard the HMM page. In this case we
+	 *   skip page-out.
+	 */
+	if (!pvt->skip_page_out)
+		ret = uv_page_out(pvt->lpid, pfn << PAGE_SHIFT,
+				  pvt->gpa, 0, PAGE_SHIFT);
 	if (ret == U_SUCCESS)
 		*dst_pfn = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
 }
-- 
2.21.0

