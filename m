Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BEF4C10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 417492082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zHZtVFnZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 417492082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E30A66B0276; Tue,  2 Apr 2019 16:44:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB6B66B0277; Tue,  2 Apr 2019 16:44:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5BB96B0278; Tue,  2 Apr 2019 16:44:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3856B0276
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:44:24 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id e124so4018585ita.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:44:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S3/NdFYbeXH44L9JBwqlhAYuzDTUjFxD7HwZ/en50So=;
        b=qcody47LZS1HlHFOfQZH4Wg3rFSiHMcc8tabb19cyjSIhhyycWEhxFe/6VHnlna5fn
         Tbj4aMkTxc3wITH5A5ZN+nECHjtk57KcJ/xvqCbh/SQtRy7ItdehjQyKiPyGZ2K54zcc
         zrI1vjXCaBIjPfSL/TOl51k4CYKjQzxyNvQikkRCv8g3H+HOrtgWwD1HVZNjTGWwowjQ
         mp3qYr3Enu/1+J90QjdUKcmlTj7G/aEUPp6SEVMThecDE8dpa22T1WFbYESBvAY9Ekj6
         sCAb7hr4ihTA5OEyHxlhJlQR5XzgAtmmdr9fZXxHL8QjAjEj9AWUQkRkUNaBcj091UVk
         KqJQ==
X-Gm-Message-State: APjAAAW62KqnJ0flNz/l0FYi21jXSM0yI2kw5dlNnoi2I9FzHIvirALr
	btpZe5ziutlw2JHxMxSm5TOf2a9vFMTfBX+7rsc7DRB8PmsOOFNEnW7bCcpj1QGWdQ1MI9WWlaq
	+U66PmByZNkfzlU619U5fEvyF3txBlXq1jJTqKypsdFAWpQ4ZxeUKTsfN5Mbu8QW9Wg==
X-Received: by 2002:a24:1f50:: with SMTP id d77mr5755590itd.25.1554237864403;
        Tue, 02 Apr 2019 13:44:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz04hEuKEWCX445WVrjU98lllzT9ofzZXSnF/Pscv5AGeYYEmMFgaEomRUlkZ76ep83N/vQ
X-Received: by 2002:a24:1f50:: with SMTP id d77mr5755537itd.25.1554237863287;
        Tue, 02 Apr 2019 13:44:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554237863; cv=none;
        d=google.com; s=arc-20160816;
        b=PKpf/W3nYLTHPrFKmSK+8QnTUs/Ppt25T4y28AS6x0i8vjocwqLk8qwre1CZ6dGtBl
         STAA0N5qcK06vtuZjDahFusjzqGom301pjOodA7uU5f9ZErKBhJesTjLkuBa5UMmSUqy
         dmPI92r1XDyUCKtvXif+VmcINKrRVnV4EZ7kDS+1/mzoVuNQbugcGDj7o12nAOWR0OQT
         juINodSEQ1voyVMUX4OdrxG0138CzeotGDnUOkAp6OMMNBMhsxwmimNSCDegZ4sOae6E
         EJH5bCzHMSXFlZA5DFBU6zHAU35GyW+FMJYDmRZo+hmmoDe0+MnxZTIRw7vZQK6dBKig
         4JIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=S3/NdFYbeXH44L9JBwqlhAYuzDTUjFxD7HwZ/en50So=;
        b=XjpSYlqsQHvmKz1R3kVI2x6c8GGCF6HbrMEox++k2fmLwxrV1m4ZjDZLSWQLp3/D0j
         XEGPfbMV4TxDyMCcP0EcewMw6Tg6xUPGy31C/1zofjVS2wYom7jrSoBiVghdNF7AYLgt
         EutIhGnx24fmLuZYxN0ucWYZhBWXxaIRNSHkwFc5r/VvGZPpnGqAT0q4pUXc8cuiN8Oh
         TQ4D5jK9PPCPxx57+e3t88DhtqoC9LcMf9cEsqgr8IxulNK2zKEaWDNOrCWKZLhGwLrl
         o8IZ+HWkIWITet0L3buTAj3Er1wxcup9AZ+r+iig4nuTJOgCEdc2azAtVg7HgKY+Wm/y
         r7FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=zHZtVFnZ;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id u186si6821500ioe.104.2019.04.02.13.44.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:44:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=zHZtVFnZ;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32Kd5We164028;
	Tue, 2 Apr 2019 20:44:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=S3/NdFYbeXH44L9JBwqlhAYuzDTUjFxD7HwZ/en50So=;
 b=zHZtVFnZgKoe6ZZd0qgP5F20qgLYeOWz6WFuuVG1k0+N66MfV1nudJiuz+2DI13M9n+/
 o8CI9whu2KiVn5rsBvVo65JdlCfmh/T4jcsa/xM75AbqoeT7a4yrN2L2Bng8UYCQ6a2H
 De5IK40aPpSq6rT8IeBkUYHuDbtluEkDJy2L7Dltwn9fOJZ6KxL0Rk012ZdOtvzjspr1
 ZzGaDPdeUr4ec142YXkU37CGcy1HoStLQN7kJRtmodw6pDGhK5iwrUlP8utTFopsOkcs
 B4H4S1vHoByx7sZUZwJ2bDnQ8wcEYq95jACbPC/r64EKK7ZZzW4zat4swwLjYtWQhc+g bA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2rj0dnm0bj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:44:21 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32KfGOl064850;
	Tue, 2 Apr 2019 20:42:21 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2rm8f4yjyv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:42:20 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x32KgJlj031428;
	Tue, 2 Apr 2019 20:42:19 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 02 Apr 2019 13:42:19 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: akpm@linux-foundation.org
Cc: daniel.m.jordan@oracle.com, Alexey Kardashevskiy <aik@ozlabs.ru>,
        Alex Williamson <alex.williamson@redhat.com>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 3/6] vfio/spapr_tce: drop mmap_sem now that locked_vm is atomic
Date: Tue,  2 Apr 2019 16:41:55 -0400
Message-Id: <20190402204158.27582-4-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=29 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020138
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=29 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904020138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With locked_vm now an atomic, there is no need to take mmap_sem as
writer.  Delete and refactor accordingly.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Alex Williamson <alex.williamson@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: <linux-mm@kvack.org>
Cc: <kvm@vger.kernel.org>
Cc: <linux-kernel@vger.kernel.org>
---
 drivers/vfio/vfio_iommu_spapr_tce.c | 36 ++++++++++++-----------------
 1 file changed, 15 insertions(+), 21 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index e7d787e5d839..7675a3b28410 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -36,8 +36,9 @@ static void tce_iommu_detach_group(void *iommu_data,
 
 static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 {
-	long ret = 0, lock_limit;
+	long ret = 0;
 	s64 locked;
+	unsigned long lock_limit;
 
 	if (WARN_ON_ONCE(!mm))
 		return -EPERM;
@@ -45,39 +46,32 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
-	locked = atomic64_read(&mm->locked_vm) + npages;
+	locked = atomic64_add_return(npages, &mm->locked_vm);
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
+	if (locked > lock_limit && !capable(CAP_IPC_LOCK)) {
 		ret = -ENOMEM;
-	else
-		atomic64_add(npages, &mm->locked_vm);
-
-	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%ld%s\n", current->pid,
-			npages << PAGE_SHIFT,
-			atomic64_read(&mm->locked_vm) << PAGE_SHIFT,
-			rlimit(RLIMIT_MEMLOCK),
-			ret ? " - exceeded" : "");
+		atomic64_sub(npages, &mm->locked_vm);
+	}
 
-	up_write(&mm->mmap_sem);
+	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %lld/%lu%s\n", current->pid,
+			npages << PAGE_SHIFT, locked << PAGE_SHIFT,
+			lock_limit, ret ? " - exceeded" : "");
 
 	return ret;
 }
 
 static void decrement_locked_vm(struct mm_struct *mm, long npages)
 {
+	s64 locked;
+
 	if (!mm || !npages)
 		return;
 
-	down_write(&mm->mmap_sem);
-	if (WARN_ON_ONCE(npages > atomic64_read(&mm->locked_vm)))
-		npages = atomic64_read(&mm->locked_vm);
-	atomic64_sub(npages, &mm->locked_vm);
-	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%ld\n", current->pid,
-			npages << PAGE_SHIFT,
-			atomic64_read(&mm->locked_vm) << PAGE_SHIFT,
+	locked = atomic64_sub_return(npages, &mm->locked_vm);
+	WARN_ON_ONCE(locked < 0);
+	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %lld/%lu\n", current->pid,
+			npages << PAGE_SHIFT, locked << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
 }
 
 /*
-- 
2.21.0

