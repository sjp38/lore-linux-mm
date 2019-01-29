Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C117C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:27:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAD4B21473
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:27:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAD4B21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=il.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D4BA8E0007; Tue, 29 Jan 2019 08:27:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75B018E0001; Tue, 29 Jan 2019 08:27:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D42B8E0007; Tue, 29 Jan 2019 08:27:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D70A8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:32 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g13so14232472plo.10
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:27:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id
         :content-transfer-encoding:mime-version;
        bh=qooegnIEmPo7qM/QPyZ0qzLMUNQbQXyBL6v03pgkvwU=;
        b=SX/W9GkCfB7zWaDSQR2MNrBsdEJbVy0vxXyPH0ZCmF/Cl4lm1orl26ZNZa8DgS1aWf
         q62NKb05ghD5brI5EmmgRzaWnwS3eA0kPvLzm1j0BtyU57OyMvSYhRzpHQycT7UqRb/d
         Dnkhdplxea+Tyo+oMQDljzetNxadKL40Nk6FVVVXl62oJAUmPP5IoegnE4v1Y2qBKEep
         QHn6Th3WV1VZRpqIscldsT77UkQoSEBioceQEL6hUWKDGbTSQuKQjbVKXEsQuikvoCKu
         tKquAk2tHf1ZS8A1zGet35ERMFqoiRzEKM5fqHeIecySkU0kwSirikMEmHkjVM7u7vWy
         DQtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukcj5kvWL9CPxliQi6oVeC71HZfILaItXchdJD63DDNY3sJSE7/H
	TweHpxnSnjGb/hmo6hp09ZFxgZXMpUtbrt/iqn3R41jokiK1mfi1DomeygfR9MNLBKPKiYKJH1a
	TS6e4F5rgtUvUx/nISJW5vZCqworIPLYCE1J3IvCtg/Ks58gsKWD5RUpb3KwM/yxKiQ==
X-Received: by 2002:a65:64c8:: with SMTP id t8mr23386346pgv.31.1548768451792;
        Tue, 29 Jan 2019 05:27:31 -0800 (PST)
X-Google-Smtp-Source: ALg8bN562q/Ew2E7nrc+xNQAVDxKTWxDl58ARMUEBDXYGoHk2CvYc0moxu7EFD3BrvMohZ0aYFbD
X-Received: by 2002:a65:64c8:: with SMTP id t8mr23386310pgv.31.1548768451029;
        Tue, 29 Jan 2019 05:27:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548768451; cv=none;
        d=google.com; s=arc-20160816;
        b=ySQ4OHRG0Kd5VSND3swct44Ltv4uZmXw9AVA4bmVyXpQg/32OKAnognNJmoIk0APl3
         fKtD1kP2ojUgTliC44Jv/rc+C4lHRaxZCe3RdUJxpDt5gqlcJMnoZMQRw1I9dpvE+LzO
         7t5KIXlAA1CtD+GO8C5jA8BECtEHCQzg+zgjAyEsPkuM4ESFKWtupruDisue+WZdWELr
         +R02X6gAxKr/lZ82e+tz1l2byNkFoceAbKvSji9+pG1zzmAzpYHIGkcRT9EopZ/AQ7kr
         O1RscISCd5CiKuSq4s4c5EeePfB8oVUk57hKIMW0Vk4T461nVn6bG6Do08vVhcLNm7tw
         q2HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:message-id:references
         :in-reply-to:date:subject:cc:to:from;
        bh=qooegnIEmPo7qM/QPyZ0qzLMUNQbQXyBL6v03pgkvwU=;
        b=e9sjVvclGMoRtn6Auav0R1VHTJfS++3xXR5IRvMG7bPlMtmhM5ogEIqwGQZ1Axo+ft
         XNkVQLOuXLTNEA3iMN2RJdxcBD7ibwAzTwks10XxX45e5c65LKAqHq0CySQXTH/sHT3i
         nxrwnNssE1y7q4OT5cItTWMlIGG73hODj0UnRoNTeGQoqtowm4sMEB6XbIGk1BWRX4UJ
         GcYg5Xy9y5IIfteWUr5i+D/2x8WGCdPwuZe9J7t/uOO65uWBO99lDTQJcrVWlewga2Cc
         0dazAC1MV7YBIJAnCEs/PALCshzE133/IO6NhcRMqSOJx7bAFZlYlkPqFFx8x7BmEv7w
         iGFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id bg9si3739285plb.317.2019.01.29.05.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 05:27:30 -0800 (PST)
Received-SPF: pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joeln@il.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=joeln@il.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0TDNIsC024087
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:30 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qamfabasw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:27:14 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <joeln@il.ibm.com>;
	Tue, 29 Jan 2019 13:26:54 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 29 Jan 2019 13:26:52 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0TDQoGV53018870
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 29 Jan 2019 13:26:51 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E294BA405C;
	Tue, 29 Jan 2019 13:26:50 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 483B5A405B;
	Tue, 29 Jan 2019 13:26:49 +0000 (GMT)
Received: from tal (unknown [9.148.32.96])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 29 Jan 2019 13:26:49 +0000 (GMT)
Received: by tal (sSMTP sendmail emulation); Tue, 29 Jan 2019 15:26:48 +0200
From: Joel Nider <joeln@il.ibm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Leon Romanovsky <leon@kernel.org>, Doug Ledford <dledford@redhat.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Joel Nider <joeln@il.ibm.com>,
        linux-mm@kvack.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 1/5] mm: add get_user_pages_remote_longterm function
Date: Tue, 29 Jan 2019 15:26:22 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19012913-0016-0000-0000-0000024D50D0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19012913-0017-0000-0000-000032A753ED
Message-Id: <1548768386-28289-2-git-send-email-joeln@il.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-29_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=826 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901290101
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In order to support the RDMA reg_remote_mr function, we must have the
ability to get memory pages for an indeterminate amount of time from
a remote process. In this case, 'remote' simply means a process that is
different from the caller. Functions for getting longterm pages
(get_user_pages_longterm) and remote pages (get_user_pages_remote)
already exist - this new function combines the functionality of both
of them.

Signed-off-by: Joel Nider <joeln@il.ibm.com>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/mm.h | 28 +++++++++++++++++++++++++---
 mm/gup.c           | 15 ++++++++++-----
 2 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb640..1f5c72472 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1537,9 +1537,21 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    struct page **pages, unsigned int gup_flags);
 #ifdef CONFIG_FS_DAX
-long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
-			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas);
+long get_user_pages_remote_longterm(struct task_struct *tsk,
+			    struct mm_struct *mm, unsigned long start,
+			    unsigned long nr_pages, unsigned int gup_flags,
+			    struct page **pages, struct vm_area_struct **vmas);
+
+static inline long get_user_pages_longterm(unsigned long start,
+					   unsigned long nr_pages,
+					   unsigned int gup_flags,
+					   struct page **pages,
+					   struct vm_area_struct **vmas)
+{
+	return get_user_pages_remote_longterm(current, current->mm, start,
+					      nr_pages, gup_flags, pages,
+					      vmas);
+}
 #else
 static inline long get_user_pages_longterm(unsigned long start,
 		unsigned long nr_pages, unsigned int gup_flags,
@@ -1547,6 +1559,16 @@ static inline long get_user_pages_longterm(unsigned long start,
 {
 	return get_user_pages(start, nr_pages, gup_flags, pages, vmas);
 }
+
+static inline long get_user_pages_remote_longterm(struct task_struct *tsk,
+		struct mm_struct *mm, unsigned long start,
+		unsigned long nr_pages, unsigned int gup_flags,
+		struct page **pages, struct vm_area_struct **vmas)
+{
+	return get_user_pages_remote(tsk, mm, start, nr_pages,
+		gup_flags, pages, vmas);
+}
+
 #endif /* CONFIG_FS_DAX */
 
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
diff --git a/mm/gup.c b/mm/gup.c
index 05acd7e..bcfe5a6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1139,9 +1139,11 @@ EXPORT_SYMBOL(get_user_pages);
  * "longterm" == userspace controlled elevated page count lifetime.
  * Contrast this to iov_iter_get_pages() usages which are transient.
  */
-long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
-		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas_arg)
+long get_user_pages_remote_longterm(struct task_struct *tsk,
+			    struct mm_struct *mm, unsigned long start,
+			    unsigned long nr_pages, unsigned int gup_flags,
+			    struct page **pages,
+			    struct vm_area_struct **vmas_arg)
 {
 	struct vm_area_struct **vmas = vmas_arg;
 	struct vm_area_struct *vma_prev = NULL;
@@ -1157,7 +1159,9 @@ long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
 			return -ENOMEM;
 	}
 
-	rc = get_user_pages(start, nr_pages, gup_flags, pages, vmas);
+	rc = __get_user_pages_locked(tsk, mm, start, nr_pages,
+				     pages, vmas, NULL,
+				     gup_flags | FOLL_TOUCH | FOLL_REMOTE);
 
 	for (i = 0; i < rc; i++) {
 		struct vm_area_struct *vma = vmas[i];
@@ -1187,7 +1191,8 @@ long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
 		kfree(vmas);
 	return rc;
 }
-EXPORT_SYMBOL(get_user_pages_longterm);
+EXPORT_SYMBOL(get_user_pages_remote_longterm);
+
 #endif /* CONFIG_FS_DAX */
 
 /**
-- 
2.7.4

