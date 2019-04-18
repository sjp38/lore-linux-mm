Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 530D0C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 12:58:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D69B21479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 12:58:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D69B21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B76D6B000A; Thu, 18 Apr 2019 08:58:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73E2B6B000D; Thu, 18 Apr 2019 08:58:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6068A6B000E; Thu, 18 Apr 2019 08:58:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB206B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:58:36 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id k76so1507255ybk.0
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 05:58:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=JnX0iCr1knkPciHRtd4SE0+1coMYysK+bNjv3CnXclU=;
        b=hmMu4qrVECKSKxhcNikE3ayXZqHbZpllgJZ5SfhdcwsN+pJ/HVuLirWOWdT7hfsw8N
         +gik7Z+RWlWVeudtEePFCbj3eJ1K++kC0qNDeaJdhwDAP8yorKONjm8au77E6nlg0rgQ
         vrLlRURYJenAAHrozK4DWoO8HyKneg2qjvrmW7IwWloU+jWb9SbW4lGuBfhp/D+OTIqQ
         u6sNU46qjuJYSDs3Glz1OuCP5z9jepqZJp8aPqHv3RUW59MccH37qsE9ZYP+1FGLcJTU
         UVmsQgh2pfuuR7bgAXY5A5yzaq/WJUR2bmkRWNpYDrYcoXSQqBG7o0RVvoJJ2ElqRzEs
         A+EQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXkntaYT+LYVuqiN2rkI69Mz2j4SBB+9v8Z7YzbE5EVD0Gs9NG2
	yBm+JRwUbIswpxooOSNPhMPJl3IYHT9C7ExbgRW93ehp4bK8VfBQGv6B+7jK7ObWZXtxj3qyZbl
	lSmzj9D855LVAJoNDXjgAKyOjwuqglEFTrY3zUbA0h86zUx+EZw/mG6fB29bzVmN9dA==
X-Received: by 2002:a81:550f:: with SMTP id j15mr74687931ywb.83.1555592315907;
        Thu, 18 Apr 2019 05:58:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYcLQAE9Ri7BsONQAQa2qKFAIImpimQmyGe10YCiGhAVgugtmckp1ngLFYcJtnkFFpzVLm
X-Received: by 2002:a81:550f:: with SMTP id j15mr74687877ywb.83.1555592314975;
        Thu, 18 Apr 2019 05:58:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555592314; cv=none;
        d=google.com; s=arc-20160816;
        b=HP6zsPFr4+GOppcqmxRWiWABNiAFa7yw5+xVZrTfpGnrNT34uJEoXSSa05N8Aan56N
         p0dk9g85HhQxqqqUWOJ7hIjyjUYG3zS+y3mdZB195wkenMbaUtlWbLmoebnDkyEC1gyF
         RWhPpgOQFh7Hjv1jArMeuWyVn+f6IHV/o1CfBu3AuM17zcwFp9mh6Gatu1ipkMB2SoF2
         tWCj7v5pZw36ppyrhqOlU+LMJVBp3WSa7AkCw5X8YF/d5WXup2dJXJ5WSfrz3RekxDPj
         337NuZat4lkKI03M7x40AS4l6GGLKB+0eeokJIRvjdd+4NAIEitXptFdsMR+Y3Ysjz/B
         0mtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=JnX0iCr1knkPciHRtd4SE0+1coMYysK+bNjv3CnXclU=;
        b=HbH3CybSlRqsUPhnlX+mhOCPezoEuQM5pA7Rz34M7otWVGdujIOH78+4Y6sNY8xsXc
         1NPhq8iBCUtOQyPvyRD/skLzcWNDtROzg5JEXDP0y6FCd1/Zn8MMmyBT0xq85ok+ww3O
         JL11vBqswzvGIQ0UWSjn5WG0oYL5a/bmGbZhZWI/1CzjyxnFBGvhCzwwDs/wYh6CpdY8
         VRb1uDVM4jAs+SeDFuj+UPYGtuhyyN5bhf5mHSR+5qcAohhCBZ44bpH8mIJXnYD73PFi
         vbiYS+Uf/UrN21DT+za3p+ZzKMiUuzQbKLGU1Vuj6WXmLBi4DKMdxu/AOhUETgERM8cX
         ltvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b10si1302508yba.142.2019.04.18.05.58.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 05:58:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3ICsAN9070693
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:58:34 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rxq726xju-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:58:33 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Thu, 18 Apr 2019 13:58:31 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 18 Apr 2019 13:58:29 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3ICwSBE5636218
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Apr 2019 12:58:28 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6CD154C04A;
	Thu, 18 Apr 2019 12:58:28 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B2E7E4C046;
	Thu, 18 Apr 2019 12:58:27 +0000 (GMT)
Received: from pomme.aus.stglabs.ibm.com (unknown [9.145.32.15])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 18 Apr 2019 12:58:27 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm: use mm.arg_lock in get_cmdline()
Date: Thu, 18 Apr 2019 14:58:27 +0200
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041812-0008-0000-0000-000002DB3862
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041812-0009-0000-0000-0000224779C7
Message-Id: <20190418125827.57479-1-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-18_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=563 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904180092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end
and env_start|end in mm_struct") introduce the spinlock arg_lock to protect
the arg_* and env_* field of the mm_struct structure.

While reading the code, I found that this new spinlock was not used in
get_cmdline() to protect access to these fields.

Fixing this even if there is no issue reported yet for this.

Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
Cc: Yang Shi <yang.shi@linux.alibaba.com>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/util.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index 05a464929b3e..789760c3028b 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
+	spin_unlock(&mm->arg_lock);
 
 	len = arg_end - arg_start;
 
-- 
2.21.0

