Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39647C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE5672082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DYQqFz1E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE5672082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52F786B0275; Tue,  2 Apr 2019 16:44:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B4AE6B0276; Tue,  2 Apr 2019 16:44:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 356EA6B0277; Tue,  2 Apr 2019 16:44:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 137436B0275
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:44:22 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id x185so10715196ywd.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:44:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DAV8hZYjlHWVUW/ro2G5efrumxLnILCMzYubKdb6RAA=;
        b=h9+QKK5e4ma7Oj1InWfBUsNrJtnoRA0lucoja8HrdhSQODMYo4wCID8rn/97hh+uyH
         2LBD9ncxQZe/Ip+6GRabzZ4L+TVnm2gyL5dT3lCOX9W1XtVFCf8SXz98H889abZwz25c
         N/NXBra75Yar8YZuH9vgjsNqcJ01eHWPlGYMjK0PAf5w0yVBtv6n56wgUZ6aoNlmFlNn
         olURUiaxrQcoXbSEAGsExrYTclMv2UgUStCTXKint77/WeFu9+q6O29os9aLMzI9BnBH
         G3Z6OuncHrH5yLZeihl59/UhW3Av8oaMCqgCowqiKKT3HKoCu7U0HK17wl1rlxuEie9s
         sTTw==
X-Gm-Message-State: APjAAAVqBu7WaR7zSuqc/v83vLJZ0T7dMUZY1twt9yib5MCxyXjSoRdv
	uHnItETJ+ggsUWOECmj1dEjc9R7uisY8sYVkIV/5lorCPDPi2VdRd3b43YmZRtpR7XYv7U5zNKo
	IF6iNY3XKw2jqJa/vuEx5SHJ1+9/+SYMxjDL16ElTMnJZ4fEQ/TjKn6paeY36ap86fg==
X-Received: by 2002:a25:a049:: with SMTP id x67mr25639577ybh.3.1554237861801;
        Tue, 02 Apr 2019 13:44:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYMK6fHsqAN/9502Vts9qe2d4rPEYnPWSJV4htTLAJwLCWuq0IoDFj+JVL+bWMUICYO8Tm
X-Received: by 2002:a25:a049:: with SMTP id x67mr25639515ybh.3.1554237860513;
        Tue, 02 Apr 2019 13:44:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554237860; cv=none;
        d=google.com; s=arc-20160816;
        b=x77NuNpGRpSZscmDjWbcl4JSsn8hSmQ6fucI3Q5LPuvkcU/eSVlMqC5ast3y+KRWKt
         mhG4+ASg4+1PP02HfaM8GRYHPfm2honi5vFsBxnMwWSZj2X12LZVZ/pNATl0s+kYwjjP
         5yjijZUsRBmHZy2B1owaOx2dcd6gO4cE/x6FY9WEE9A3OYnj0OxccbgneIQkgZpsAR6e
         Q9Ilmn9EiBvJ/zT0qS5frSC5iqu/HcXQflBb8Y8FKygqAmZevK0aISR5pE2TIn5CZL7c
         HSV47QZc8i2XXJ92s7XQS4MnK8cX5iZeuYmkSuq6QC8vguIBrjmMEhgnM6dktQhtXqWu
         BWFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=DAV8hZYjlHWVUW/ro2G5efrumxLnILCMzYubKdb6RAA=;
        b=Q8D+2/OQV8WQ7fNwyPTE85WylOEneYbPs5B5YAVY5dxvONneN8c58HEKkuA3Rriu+B
         4DYqbpHd9+9FpwbUbzCDCwTVoYCnPfQIPjT0o872C4GFedcMfSt3aNFdFvgNW11fyllR
         GXVXcOP3KNWKERqGC8QXqqIoIrHwBrU4Ngdi1u88aHSVdmL2x9PAh8mxy2kQanMPYJv/
         3Xx/xOIe9/lC7DTQcNoA0EnLsjDbbuF7kXkkqxiHFvhbWeVf1aTD1UOp23TWelciHjar
         Rf/yM5hMw/JEwOFdee6K++uLrcdiJzT26ej1+YoG36JY1cTwl4/sw9rJq+QUCPw0FWdj
         7dGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DYQqFz1E;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id 188si8721685ybr.271.2019.04.02.13.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:44:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DYQqFz1E;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32Kd3AR163985;
	Tue, 2 Apr 2019 20:44:18 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=DAV8hZYjlHWVUW/ro2G5efrumxLnILCMzYubKdb6RAA=;
 b=DYQqFz1Es0eTsjHefSJinfHkZj9GG0R6x09s5f53oykcMd5iF0EII+BlUpn+1XKZyqpy
 ehpuKE1KPh8f8+SX199aDH/x+N+c4l1g9WFEU5iJKbb/WhMXAR/+JG3Jtrq7vyhLEzuS
 yj7xGVmGvwzZdzDFVKtrc2EK1k9cDlWim983X0ss0owuMARRJf/y4yPvXj/O2j6nRI8d
 69y1hsXZe8f7O5frVrxqBnD9WhKwIdQB0yL8z2p5IwSrNFxRb/FBjMXEZfuExAqgXB8I
 NEDh13MtMZ+JfeVS5BTlZdVsZxd8eJpF+zupdafHyI8+jDyhML92kzB4j6V4IQwvewMS 9g== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2rj0dnm0b9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:44:18 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32KfI5b103059;
	Tue, 2 Apr 2019 20:42:18 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2rm9mhp3mp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:42:17 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x32KgHK2029977;
	Tue, 2 Apr 2019 20:42:17 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 02 Apr 2019 13:42:17 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: akpm@linux-foundation.org
Cc: daniel.m.jordan@oracle.com, Alex Williamson <alex.williamson@redhat.com>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 2/6] vfio/type1: drop mmap_sem now that locked_vm is atomic
Date: Tue,  2 Apr 2019 16:41:54 -0400
Message-Id: <20190402204158.27582-3-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020138
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904020138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With locked_vm now an atomic, there is no need to take mmap_sem as
writer.  Delete and refactor accordingly.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Alex Williamson <alex.williamson@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: <linux-mm@kvack.org>
Cc: <kvm@vger.kernel.org>
Cc: <linux-kernel@vger.kernel.org>
---
 drivers/vfio/vfio_iommu_type1.c | 27 +++++++++------------------
 1 file changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 5b2878697286..a227de6d9c4c 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -257,7 +257,8 @@ static int vfio_iova_put_vfio_pfn(struct vfio_dma *dma, struct vfio_pfn *vpfn)
 static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
 {
 	struct mm_struct *mm;
-	int ret;
+	s64 locked_vm;
+	int ret = 0;
 
 	if (!npage)
 		return 0;
@@ -266,25 +267,15 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
 	if (!mm)
 		return -ESRCH; /* process exited */
 
-	ret = down_write_killable(&mm->mmap_sem);
-	if (!ret) {
-		if (npage > 0) {
-			if (!dma->lock_cap) {
-				s64 locked_vm = atomic64_read(&mm->locked_vm);
-				unsigned long limit;
-
-				limit = task_rlimit(dma->task,
-						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	locked_vm = atomic64_add_return(npage, &mm->locked_vm);
 
-				if (locked_vm + npage > limit)
-					ret = -ENOMEM;
-			}
+	if (npage > 0 && !dma->lock_cap) {
+		unsigned long limit = task_rlimit(dma->task, RLIMIT_MEMLOCK) >>
+								   PAGE_SHIFT;
+		if (locked_vm > limit) {
+			atomic64_sub(npage, &mm->locked_vm);
+			ret = -ENOMEM;
 		}
-
-		if (!ret)
-			atomic64_add(npage, &mm->locked_vm);
-
-		up_write(&mm->mmap_sem);
 	}
 
 	if (async)
-- 
2.21.0

