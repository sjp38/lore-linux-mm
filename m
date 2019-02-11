Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CD09C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D69B2186A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:46:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="HnEn0xS6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D69B2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A2DF8E0181; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7544C8E0163; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AB578E0181; Mon, 11 Feb 2019 17:46:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBEE48E017F
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:46:08 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id o8so432108ybp.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:46:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lNNVFPUWTRhNE8iqw8ALNGW4x7tdbqFw7nSGCVoIqbc=;
        b=RPItMqWNer9wJA1oL+7ptzAK/Dvk30gftoF7R0tvQAPJvakiVxGAqHIV7wsCYXGAlp
         l9dQn3C6C6sPaVxIke85rtXEL2gHP8mFC3ue4cUGAFOW5PheG5DsoJ1clWKO05Oq/cmI
         hW12ejJCbytIqRVxW38zMGYie4WJ6U3csJQBmCR8WyxtRH08C/nE1SePTQXIuKAw/v0B
         jK72rFf801ABqT+etZ28BSiLcZ1aiG1tOCk4TH2ByWuF7a7LYRjJxM8ri1Ai1sy/3at7
         qYcHETj2WKs5DboF6ypJ41IPWPf4rBMkUNPw1l2xAMuQMWLsr68dzyGrI9GkcYCV5hM3
         V9uA==
X-Gm-Message-State: AHQUAuZqof9XWAb1ENVsZOrs1Vy8wf/CB7hnDwA26dEVWStSdaslnikx
	pAgoEx7CC2ezify+XVD2HraujkxAA2bbtCFLBTXW1AWmU1zDdKgCt8HTYtb4cmRK9ZUi+8bEsP9
	JdogQPLLgLtooWExVVLL6w6yDyroqXzb6MUfMv7kHnmV/2mPYvEIVCJvNkJ6XF6p1Uw==
X-Received: by 2002:a5b:903:: with SMTP id a3mr432061ybq.445.1549925168690;
        Mon, 11 Feb 2019 14:46:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ7A3FKcui4Xk2uiPTH2tO5M4j6jbjnTuGQoFahm7Aj5+rYVWDZ6Q5k0MyE79SxYrsbJ0TP
X-Received: by 2002:a5b:903:: with SMTP id a3mr432022ybq.445.1549925167904;
        Mon, 11 Feb 2019 14:46:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925167; cv=none;
        d=google.com; s=arc-20160816;
        b=ziSvv5QM/num5kLlMW/UZfvIq2yxudGGum3et+bRkbG/I0nSIvyCZumIupT+w8KkxF
         2vfXcyt9nQvGXSYbrjy0YELd0eHabhGJmOu5zzYE2FP8FxK8f21HGCQb9qN2AeKqE2uQ
         6nsWLVGBlf7nzDpkcMwraWag/BMjt3x9PoMuItQ68NSVwt0HInW65QAgdN5uiFDhPjPx
         bzXhiNBPmdme/rJAFOB6xWOF8bWoTsNHxktS3DwoK7nl6XXGPR3ndRSjbrOsSQVgh+O9
         fTj7FYOtz7A94jwA5oL1WarNv5fkXAURmeyZ6PZWLqC/WIEO84e9V2J3BVuot8tP3tpz
         BlIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lNNVFPUWTRhNE8iqw8ALNGW4x7tdbqFw7nSGCVoIqbc=;
        b=rsmuvqrkDWwKVfqmLXzpx7nQwUdNdeKhHcIiPHdBrDtmuxivUV57pvrVkn6tdsWVO/
         jxrke6HHcvmoNvtmNXiBUO6ORttvfP9djvBX3ktdU0fUT8hmEzRe1R+EOr49sPAls/F4
         gAa3UL8Vzaq5EwP0laMuWF6JBbHC76Uepid8yVWjp081tFgJSq0AFZlvOKUujk9viMl2
         78/DOC7pGLEOQVBacK49L+cWd58n7TTywM7fYPYQ8J/9cid2pJEdtgiJ/TilP7nviLsU
         1Fzhwe7l3phUxl0uQjpBi2xx5YCpP+tEHdzjHdPZDuYgP3EYxC88QBOMtENG1borOkF6
         IdsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HnEn0xS6;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 127si6586194ybg.479.2019.02.11.14.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 14:46:07 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=HnEn0xS6;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1BMhgq5079616;
	Mon, 11 Feb 2019 22:44:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=lNNVFPUWTRhNE8iqw8ALNGW4x7tdbqFw7nSGCVoIqbc=;
 b=HnEn0xS6VXXZwacMqdL+G2YTsezKd8bC2zALO+fMvwXK7yNNIdx2SEyBXHAQcWr0hWPH
 xFL1cpGYlZeIGxFVuwVk/blwtPCZ/qitfP3s2/AqwfDM7MldOF34fKElHAoscHbHzDEH
 NODKcW8CH40UlUuWcQ6O74uctfb+VX8qmi4HJA0ssRmRYpS9HjzCYbajNJ6hdrAmp035
 ZRa4K70w/oRxK1O9L9EPCguGCbkC4mB5dk64JhtD56TcT6Ms831Diow9RBQ6Hm4Vw6hH
 BLdOK7jjHdd+EYP7nShsNbLdmOnWIbNMT2dKOItdbfzrRDlPRyguA5RQ35ZnmHE/mJlt jg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2qhredrqvq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:54 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMim4E030846
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Feb 2019 22:44:48 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1BMik3u013837;
	Mon, 11 Feb 2019 22:44:46 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 11 Feb 2019 14:44:45 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: jgg@ziepe.ca
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru,
        daniel.m.jordan@oracle.com
Subject: [PATCH 1/5] vfio/type1: use pinned_vm instead of locked_vm to account pinned pages
Date: Mon, 11 Feb 2019 17:44:33 -0500
Message-Id: <20190211224437.25267-2-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9164 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Beginning with bc3e53f682d9 ("mm: distinguish between mlocked and pinned
pages"), locked and pinned pages are accounted separately.  Type1
accounts pinned pages to locked_vm; use pinned_vm instead.

pinned_vm recently became atomic and so no longer relies on mmap_sem
held as writer: delete.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 drivers/vfio/vfio_iommu_type1.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 73652e21efec..a56cc341813f 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -257,7 +257,8 @@ static int vfio_iova_put_vfio_pfn(struct vfio_dma *dma, struct vfio_pfn *vpfn)
 static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
 {
 	struct mm_struct *mm;
-	int ret;
+	s64 pinned_vm;
+	int ret = 0;
 
 	if (!npage)
 		return 0;
@@ -266,24 +267,15 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
 	if (!mm)
 		return -ESRCH; /* process exited */
 
-	ret = down_write_killable(&mm->mmap_sem);
-	if (!ret) {
-		if (npage > 0) {
-			if (!dma->lock_cap) {
-				unsigned long limit;
-
-				limit = task_rlimit(dma->task,
-						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	pinned_vm = atomic64_add_return(npage, &mm->pinned_vm);
 
-				if (mm->locked_vm + npage > limit)
-					ret = -ENOMEM;
-			}
+	if (npage > 0 && !dma->lock_cap) {
+		unsigned long limit = task_rlimit(dma->task, RLIMIT_MEMLOCK) >>
+								   PAGE_SHIFT;
+		if (pinned_vm > limit) {
+			atomic64_sub(npage, &mm->pinned_vm);
+			ret = -ENOMEM;
 		}
-
-		if (!ret)
-			mm->locked_vm += npage;
-
-		up_write(&mm->mmap_sem);
 	}
 
 	if (async)
@@ -401,6 +393,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 	long ret, pinned = 0, lock_acct = 0;
 	bool rsvd;
 	dma_addr_t iova = vaddr - dma->vaddr + dma->iova;
+	atomic64_t *pinned_vm = &current->mm->pinned_vm;
 
 	/* This code path is only user initiated */
 	if (!current->mm)
@@ -418,7 +411,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 	 * pages are already counted against the user.
 	 */
 	if (!rsvd && !vfio_find_vpfn(dma, iova)) {
-		if (!dma->lock_cap && current->mm->locked_vm + 1 > limit) {
+		if (!dma->lock_cap && atomic64_read(pinned_vm) + 1 > limit) {
 			put_pfn(*pfn_base, dma->prot);
 			pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", __func__,
 					limit << PAGE_SHIFT);
@@ -445,7 +438,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 
 		if (!rsvd && !vfio_find_vpfn(dma, iova)) {
 			if (!dma->lock_cap &&
-			    current->mm->locked_vm + lock_acct + 1 > limit) {
+			    atomic64_read(pinned_vm) + lock_acct + 1 > limit) {
 				put_pfn(pfn, dma->prot);
 				pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n",
 					__func__, limit << PAGE_SHIFT);
-- 
2.20.1

