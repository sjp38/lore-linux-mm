Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98152C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:09:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60F0C20833
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 16:09:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60F0C20833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10BA58E0001; Thu, 31 Jan 2019 11:09:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B9948E0003; Thu, 31 Jan 2019 11:09:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECC7F8E0001; Thu, 31 Jan 2019 11:09:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE9D68E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:09:17 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id d31so4155514qtc.4
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 08:09:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=iejj4wu/BQRH+YpqaPT9jfVpdxmb688KVAe4bN511Xg=;
        b=puKGXWim+qu0VmOlATkVn3DzgSGQ29wDQq327pNPC3osQpSrjjllCAXJaVpVuh/HGn
         ih3JHTYgd88gTO1OcJUFi7cFCmqmYrU0qCp1okLAHMg6REmotpfw9t2qU/bbUcUpfbnL
         LxfzlRUCe02yWNw8Gs+kbe4pFwWr3WLAJwvE2AIMCObsYEqjU5INm5AArEBvGA+QLFNJ
         ChzVYRIbh4J9fthHTJ96Qt8iigLTUKIyx9nc1trLMR7448flAfSO12+L3ygINP1rJLd6
         JzoQu/ZFWznHt5aVuzSnJoiBSJOG2XKiWexCvkd1Gj2c5TdhCUarSAxUIxk068xTaIRp
         mzPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfi+mEiHmq43lXl5sk+FswV8TBwzffnSXIb44E/7Gnj4pjFucs0
	ENyipNxTmiotAtWDA+FdShKUpd3b/E6qCyo4eEjfo2t+nVufp74mfXGiO6qfSRFF0Fx559qYkwq
	O9bHQ636jJPPmLQ5kBglKG740v0zNXh+hTkpMGSYvvpNnQA53N7UltUGhJ8INNewQUQ==
X-Received: by 2002:ac8:7181:: with SMTP id w1mr34958341qto.271.1548950957512;
        Thu, 31 Jan 2019 08:09:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN50PfXYwfN0GzRs2L3Nl+5xeedCuRowYqDVQcT4/X/pLmkWc7Qgk9PZCC3u/1RrFEu6jFoB
X-Received: by 2002:ac8:7181:: with SMTP id w1mr34958276qto.271.1548950956796;
        Thu, 31 Jan 2019 08:09:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548950956; cv=none;
        d=google.com; s=arc-20160816;
        b=Wz+V6V1ZZW1x27TGIlP6CwLCgSbutxRtUU2lwhEKFi2e1KMqcnHV6v1olATl+hEHlj
         ZSD5IRyRvfwwTeKlZcsk7+bhyg7lE5ttgXO8RJZygava8jxSxN27N6CoaL8Qk/3m2gRa
         PBAYWf/BF+p7ywL8r8K9YFzuqEZiMZHDeA4T7PGFIPyyZrv36qzeHy39YCLVpg2N1Mk2
         4qfivHE6KVysH9OtCIJ0732u/6irmMVtxmk1G6O15XQzSn2sEk/UTgaPiQ6Ds5xk3RgQ
         vSeO6+OJ/6r7x+5Iflo5ikUdogIAY7sUmebi6kOqFERWxUZ99cLN73ITXNseeUl2Gytq
         AaUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=iejj4wu/BQRH+YpqaPT9jfVpdxmb688KVAe4bN511Xg=;
        b=xVjjnhF2PogMMAIPSGFhzEnWBg7ZQNoTykHi7J4KPylifGNe+RR1Nrz6IqMgZldyTN
         ieyFIp0Nze+0Lj9ht/Tsgzq5FViyEXVyFHnFvrz1FZYZ8ZrGBY/B8XWmE4t7Vgq+eHJQ
         3oGkbmRByNUdpvvYnSkmobyD7pTNYAdFG12exmbUQ9H8PoPsYwbrf98vsH8kRP7waJRX
         DYu3PYFz+AIAVQuYXHNnNVpI5k7C5xOBLtFhIMP2ATzbUjOa5/D9jnRC7VNxYRR8lUHW
         zp+yaCXHHvRevjV55IFskMy+rrZDYaeIVea2wB0BezzbTR+gSaKJLvdrbIfL560jdPYX
         Zvvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n37si2721890qtc.72.2019.01.31.08.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 08:09:16 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0VG3FN7086737
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:09:16 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qc3a83rac-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:09:15 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 31 Jan 2019 16:09:14 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 16:09:11 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0VG99gh56492062
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 16:09:10 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 940C052059;
	Thu, 31 Jan 2019 16:09:09 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 4CD895204F;
	Thu, 31 Jan 2019 16:09:08 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 31 Jan 2019 18:09:07 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] memblock: fix format strings for panics after memblock_alloc
Date: Thu, 31 Jan 2019 18:09:00 +0200
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19013116-4275-0000-0000-000003086DBD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013116-4276-0000-0000-0000381677F8
Message-Id: <1548950940-15145-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310123
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Using "%lu" to print size_t variables causes build warnings on i386 and
probably other architectures:

kernel/dma/swiotlb.c:210:35: warning: format '%lu' expects argument of type
'long unsigned int', but argument 3 has type 'size_t' {aka 'unsigned int'}
[-Wformat=]
      panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
                                    ~~^
                                    %u
            __func__, alloc_size, PAGE_SIZE);
                      ~~~~~~~~~~

Replace "%lu" with "%zu".

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---

Andrew, can you please fold this into "treewide: add checks for the return
value of memblock_alloc*()"?

 arch/x86/platform/olpc/olpc_dt.c | 2 +-
 kernel/dma/swiotlb.c             | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/platform/olpc/olpc_dt.c b/arch/x86/platform/olpc/olpc_dt.c
index dad3b60..ac9e7bf 100644
--- a/arch/x86/platform/olpc/olpc_dt.c
+++ b/arch/x86/platform/olpc/olpc_dt.c
@@ -142,7 +142,7 @@ void * __init prom_early_alloc(unsigned long size)
 		 */
 		res = memblock_alloc(chunk_size, SMP_CACHE_BYTES);
 		if (!res)
-			panic("%s: Failed to allocate %lu bytes\n", __func__,
+			panic("%s: Failed to allocate %zu bytes\n", __func__,
 			      chunk_size);
 		BUG_ON(!res);
 		prom_early_allocated += chunk_size;
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index b64b500..ad33fee 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -207,13 +207,13 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	alloc_size = PAGE_ALIGN(io_tlb_nslabs * sizeof(int));
 	io_tlb_list = memblock_alloc(alloc_size, PAGE_SIZE);
 	if (!io_tlb_list)
-		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		panic("%s: Failed to allocate %zu bytes align=0x%lx\n",
 		      __func__, alloc_size, PAGE_SIZE);
 
 	alloc_size = PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_addr_t));
 	io_tlb_orig_addr = memblock_alloc(alloc_size, PAGE_SIZE);
 	if (!io_tlb_orig_addr)
-		panic("%s: Failed to allocate %lu bytes align=0x%lx\n",
+		panic("%s: Failed to allocate %zu bytes align=0x%lx\n",
 		      __func__, alloc_size, PAGE_SIZE);
 
 	for (i = 0; i < io_tlb_nslabs; i++) {
-- 
2.7.4

