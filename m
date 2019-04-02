Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69159C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14A362082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ZHUgm2Mu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14A362082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B49CD6B0278; Tue,  2 Apr 2019 16:44:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA7866B0279; Tue,  2 Apr 2019 16:44:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94F9D6B027A; Tue,  2 Apr 2019 16:44:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 63CB56B0278
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:44:29 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id 190so3996325itv.3
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:44:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SWwbtSuBuVRAsBvShPwVRYWt3xedhjkFQ6ROdmYUzro=;
        b=enwPbXTNGLuJBl7hEfF49lF8qDuKteghTf+0SEmHUzBxt2wqWqsb2R4QZKPpTkYkWW
         VNDqcUHc9whvZBfaKD7mD0tElq7QdOhWxnR3dMLefzoRd/DUne6RRBWaGnNO7bayTWXV
         Xi1Vr35KAYdSV02v9IB5jHLP2u29GIu9LWl0d06FQi1QTITS5YmQMMCxXV8dkIUNxkW4
         iiSSgkN2c8roMOm76AuDT9vThPLJi/OPs56n0A66OpvLKfOFg5dZ5/MvorTv6Dre/l2C
         LmcCFZMK20afxUkBsQdr5AtXbqc5nnaPLrjzufnDo7ttMpiqoLb6b7JN1N2XMyXrgWVm
         tf7Q==
X-Gm-Message-State: APjAAAXIqNxc9A+MjCBHf6GDA3D8NV8p3w4MO7T56CXRvK1mzppS7TIR
	Z8HkJNtyfM/PfA+o/QJKj/7FzC2S+5mGxS5I3XqBRNr9BaVpRhE4wpYhHlvHEfA0RffK+bx8QKg
	cWZGXmsNzJp6secix/iadUkpr27RSVwIM3MEWtHUbWHPc0h6KQBUDjOlR6ExVUJB8ew==
X-Received: by 2002:a6b:cd89:: with SMTP id d131mr47440300iog.213.1554237869147;
        Tue, 02 Apr 2019 13:44:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwC5OeuJbiVc0vSfNCLYafXdUtFwCF9i1KRvBf9dcwItabUjvC83Z+hlVL6HdVySbJsmO8
X-Received: by 2002:a6b:cd89:: with SMTP id d131mr47440261iog.213.1554237868071;
        Tue, 02 Apr 2019 13:44:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554237868; cv=none;
        d=google.com; s=arc-20160816;
        b=y+ZY5tNnOJDLPsvWPuaCLY5Y9xHSB5ja8igNm0gPyniLlkTb49vj8hRH0XRAsmlirc
         cjCwoq5yHTMK3+QN43ZGbBcQqc+juyjhrnry6hQeYKojR7M+JY3fJXXUr6EeZKmUMovy
         VRNmXDzeWFnoCTnKMHY5cnh4kvYUSShRKjzWepBXyi8bnBW8hQx8YbsV62hbpnxc1elQ
         LbskrkL+x2+0EbPEXO/iSfL75p+V5Cmeegt79R/SIkkvydtkmzzIa2sNVeAiak8YYfGM
         bGj9+ouiFW99pjVL1vQeXI+cfbqcuLJrAKO+LiM4GnCXhPY8Rhfayx7qkOe8lWpFXXa8
         8BEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SWwbtSuBuVRAsBvShPwVRYWt3xedhjkFQ6ROdmYUzro=;
        b=RQRSplMgdPi0Gay30yPQ7IOzvysPO5opCpwzDr4cIFg/DdPbfDxkrLeVA4h8NbJ4GQ
         h+GAVo1gYKheHsntH0gr/edHrZNhk0QoE7cA9zxnMxaFs6cmlhYjyFqUTUB9mk2WlQbS
         bb+pv7HQhuL7bxI9+8VZkvGXwisyqye4WiVshiOtQWJwJBMvQIKUcOIoaikeE13+8Jzh
         vHC88pxzTqq9np8ky+I35CYTuoXIDSiAguvnZ2UdhjYMEPPWq8Alfk4a31WROQUtHUHD
         OnqwJ1o/IStWBkCkBMccPUWuVi6C0+SuUG7Qdwad3ZLh61QFmA1mNLFxrcuKkyb5WZpO
         OiqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ZHUgm2Mu;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z14si6780471ioj.131.2019.04.02.13.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:44:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ZHUgm2Mu;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32Kd3oq163977;
	Tue, 2 Apr 2019 20:44:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=SWwbtSuBuVRAsBvShPwVRYWt3xedhjkFQ6ROdmYUzro=;
 b=ZHUgm2MuOOV0krty4T7QXlZIWISL8Smr5VxapxX5M+iGYwDtJrdgceBsKxYJad72jdFs
 WS6PXNlId7SQt1sMM422gZWgqsqdoOXN4TuZV9XoD+5A4MgP2ZHg4kYngmD/wvkJ+Xgj
 OcxQ0Ed7eusFEwspi+mZ4o+M15eUeGihEv2NnqjMkMR9M/SgYecFbMS2YxvOnsYMm27K
 DbDjihLSkP5+pHWFMCMIJK0R0jhEKczACn8l1Bgh/JSxMplw+viZEOvNtNzKtkwi8JNd
 G8lMfgtiWXb7/DUUffMG3VNE5jGReclP09wmyGjuhYIpBk/SM3T6LIXX7CzgD5iDuFEY xw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2rj0dnm0bs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:44:23 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32KfJxi065003;
	Tue, 2 Apr 2019 20:42:23 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2rm8f4yk08-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:42:22 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x32KgLio031444;
	Tue, 2 Apr 2019 20:42:21 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 02 Apr 2019 13:42:21 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: akpm@linux-foundation.org
Cc: daniel.m.jordan@oracle.com, Alan Tull <atull@kernel.org>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        Moritz Fischer <mdf@kernel.org>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 4/6] fpga/dlf/afu: drop mmap_sem now that locked_vm is atomic
Date: Tue,  2 Apr 2019 16:41:56 -0400
Message-Id: <20190402204158.27582-5-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=3 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020138
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=3 malwarescore=0
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
Cc: Alan Tull <atull@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Moritz Fischer <mdf@kernel.org>
Cc: Wu Hao <hao.wu@intel.com>
Cc: <linux-mm@kvack.org>
Cc: <linux-fpga@vger.kernel.org>
Cc: <linux-kernel@vger.kernel.org>
---
 drivers/fpga/dfl-afu-dma-region.c | 40 ++++++++++++-------------------
 1 file changed, 15 insertions(+), 25 deletions(-)

diff --git a/drivers/fpga/dfl-afu-dma-region.c b/drivers/fpga/dfl-afu-dma-region.c
index 08132fd9b6b7..81e3e3a71758 100644
--- a/drivers/fpga/dfl-afu-dma-region.c
+++ b/drivers/fpga/dfl-afu-dma-region.c
@@ -35,46 +35,36 @@ void afu_dma_region_init(struct dfl_feature_platform_data *pdata)
  * afu_dma_adjust_locked_vm - adjust locked memory
  * @dev: port device
  * @npages: number of pages
- * @incr: increase or decrease locked memory
  *
  * Increase or decrease the locked memory size with npages input.
  *
  * Return 0 on success.
  * Return -ENOMEM if locked memory size is over the limit and no CAP_IPC_LOCK.
  */
-static int afu_dma_adjust_locked_vm(struct device *dev, long npages, bool incr)
+static int afu_dma_adjust_locked_vm(struct device *dev, long pages)
 {
-	unsigned long locked, lock_limit;
+	unsigned long lock_limit;
 	s64 locked_vm;
 	int ret = 0;
 
 	/* the task is exiting. */
-	if (!current->mm)
+	if (!current->mm || !pages)
 		return 0;
 
-	down_write(&current->mm->mmap_sem);
-
-	locked_vm = atomic64_read(&current->mm->locked_vm);
-	if (incr) {
-		locked = locked_vm + npages;
+	locked_vm = atomic64_add_return(pages, &current->mm->locked_vm);
+	WARN_ON_ONCE(locked_vm < 0);
+	if (pages > 0 && !capable(CAP_IPC_LOCK)) {
 		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-
-		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
+		if (locked_vm > lock_limit) {
 			ret = -ENOMEM;
-		else
-			atomic64_add(npages, &current->mm->locked_vm);
-	} else {
-		if (WARN_ON_ONCE(npages > locked_vm))
-			npages = locked_vm;
-		atomic64_sub(npages, &current->mm->locked_vm);
+			atomic64_sub(pages, &current->mm->locked_vm);
+		}
 	}
 
 	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %lld/%lu%s\n", current->pid,
-		incr ? '+' : '-', npages << PAGE_SHIFT,
-		(s64)atomic64_read(&current->mm->locked_vm) << PAGE_SHIFT,
-		rlimit(RLIMIT_MEMLOCK), ret ? "- exceeded" : "");
-
-	up_write(&current->mm->mmap_sem);
+		(pages > 0) ? '+' : '-', pages << PAGE_SHIFT,
+		locked_vm << PAGE_SHIFT, rlimit(RLIMIT_MEMLOCK),
+		ret ? "- exceeded" : "");
 
 	return ret;
 }
@@ -94,7 +84,7 @@ static int afu_dma_pin_pages(struct dfl_feature_platform_data *pdata,
 	struct device *dev = &pdata->dev->dev;
 	int ret, pinned;
 
-	ret = afu_dma_adjust_locked_vm(dev, npages, true);
+	ret = afu_dma_adjust_locked_vm(dev, npages);
 	if (ret)
 		return ret;
 
@@ -123,7 +113,7 @@ static int afu_dma_pin_pages(struct dfl_feature_platform_data *pdata,
 free_pages:
 	kfree(region->pages);
 unlock_vm:
-	afu_dma_adjust_locked_vm(dev, npages, false);
+	afu_dma_adjust_locked_vm(dev, -npages);
 	return ret;
 }
 
@@ -143,7 +133,7 @@ static void afu_dma_unpin_pages(struct dfl_feature_platform_data *pdata,
 
 	put_all_pages(region->pages, npages);
 	kfree(region->pages);
-	afu_dma_adjust_locked_vm(dev, npages, false);
+	afu_dma_adjust_locked_vm(dev, -npages);
 
 	dev_dbg(dev, "%ld pages unpinned\n", npages);
 }
-- 
2.21.0

