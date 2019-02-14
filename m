Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9175BC10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 09:36:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F98B222D4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 09:36:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F98B222D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C5DA8E0002; Thu, 14 Feb 2019 04:36:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 675748E0001; Thu, 14 Feb 2019 04:36:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53E148E0002; Thu, 14 Feb 2019 04:36:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C58D8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:36:40 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n197so4631096qke.0
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:36:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:mime-version:content-disposition:user-agent:message-id;
        bh=f3NXSs03Q6geYDA6XS0VqDIHPb54F7V7kcN/aKvF5oU=;
        b=aHR4uBpBo/+58vuiIjxfMilXnMmeEl1Gpn+Tb+2aVPzmhN9gk+PjE2C7G0GH29PxUN
         vuidShwgUkQF9NWCFtj0BIJYfRVwfjYrtzFMQ3lqx2NZAt7a9HTDF7rWdOUhT8UZ3KVi
         EMSn1cwjyCQUjHEbRcL3PGo71rXCBE4PoSYbqMbn8jumRUb48nW1G1qtcwVBXYfJpkrU
         4Zzuyh6W+NJA8K9iLX00owDiKDSrkPS9Raf0DFFGP4GuS5IKIkAcf8ec7xIBWHqImqea
         0qbslrziX66MRFM4UaMafs65orfO7ED2OSlMttEwMmDxu8gVPU4cL+qXePGf3uGGmu6i
         IuMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubCuSQ2Ng9EMIepH0cV7ICejH5kMiZN0gnsmbIApsIgOMS0FLRP
	elquaceu2weT53wXep2Gipdz/qInsyH6W5M7rsDZ5bfuzZ00Gw/lMf5jtUgtwdtmxRW7TgReMQ8
	Mt73Le7MbiFvD6SpYIURd/92lwgI0+/9oR6OtBDi/zirAE7B0QgIVeF8EOahfd+CVRw==
X-Received: by 2002:a0c:8938:: with SMTP id 53mr2148125qvp.165.1550136999843;
        Thu, 14 Feb 2019 01:36:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCh0R13jB1uknxQdrB4LsLJsHfJEnScTM3fBE55DIxwmSlJ0jyQsWKlLR+U3sovu3kNs1q
X-Received: by 2002:a0c:8938:: with SMTP id 53mr2148090qvp.165.1550136999160;
        Thu, 14 Feb 2019 01:36:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550136999; cv=none;
        d=google.com; s=arc-20160816;
        b=TYoSIaLklQlOXCk5MSihcRJqXT6S+Si60yidNJfNmHd+25GpNZgEhpqtKu/4cwOU0m
         MuMKN0lBOMG7tLLVPl48Pa8K3gJmAEn15GRFwHPom1+FUoT5YYJEeMx9HW0ZML/4je+n
         FAs9P5skoXW99MsCYhbUkZ7Q2spEiMe/mAFUA1dG/eppjfJKJWYBQulR0IjwardbtaOb
         OgDm1LidiDE8BoH3PYxuYZDGz91up/tqyDSH1xkFawUuWGEJvpWvzSAOdFNNSjrJrVLw
         E9DlDVHm6PZsKsqeQWfxVv2aJgjoVxIXHdV+c6Woga97IdDVmp5nY61snJDzJJLeHa3j
         TxNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:content-disposition:mime-version:subject:cc
         :to:from:date;
        bh=f3NXSs03Q6geYDA6XS0VqDIHPb54F7V7kcN/aKvF5oU=;
        b=xenypNcmXajKoHd5fP4+U+hG55aeKFivsNAZovCH+y+JN2EqlomFof/V/qJgzKd/xw
         ljei6iFwbNbHZM1NRbwong2lRCydWCY4uSlVQjDEKMeHDed4CyjfAUZ5aYWLT/xGXi8P
         CXLBO/ivhzitIJAXuJtRCDParbq4AntWgY7su9+T3nqPC/GUquOwzzRGcFwbOMQsRQqs
         MEFlQ17OERv0jS+8n9cVGgP62PZjVIkQ7cPCO+txITvtV8OAzCsPC9W+N7c2SkYbUDY3
         DonKuhdKFrz5cKF/Ih5M4CRKHRrIsz3HWfAZ7sZgY1o+zU8buT3Db9jtVgLSQhn5S4Dh
         28ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d4si1213298qvj.122.2019.02.14.01.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 01:36:39 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1E9P72O117501
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:36:38 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qn55wth9e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 04:36:37 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 09:36:36 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 09:36:34 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1E9aX373539294
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Feb 2019 09:36:33 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3E7B64C04E;
	Thu, 14 Feb 2019 09:36:33 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CC8424C044;
	Thu, 14 Feb 2019 09:36:32 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 09:36:32 +0000 (GMT)
Date: Thu, 14 Feb 2019 11:36:31 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] MAINTAINERS: add entry for memblock
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021409-0020-0000-0000-00000316B0E5
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021409-0021-0000-0000-00002167DE74
Message-Id: <20190214093630.GC9063@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=876 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140070
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I was surprised to see lots of activity around memblock (beside the churn
I create there), so I'm going to look after it.

From 7b3d02797ef18fb1c515f32125fb9b0055a312de Mon Sep 17 00:00:00 2001
From: Mike Rapoport <rppt@linux.ibm.com>
Date: Thu, 14 Feb 2019 11:21:26 +0200
Subject: [PATCH] MAINTAINERS: add entry for memblock

Add entry for memblock in MAINTAINERS file

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 MAINTAINERS | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 41ce5f4ad838..4e870d8b31af 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9792,6 +9792,14 @@ F:	kernel/sched/membarrier.c
 F:	include/uapi/linux/membarrier.h
 F:	arch/powerpc/include/asm/membarrier.h
 
+MEMBLOCK
+M:	Mike Rapoport <rppt@linux.ibm.com>
+L:	linux-mm@kvack.org
+S:	Maintained
+F:	include/linux/memblock.h
+F:	mm/memblock.c
+F:	Documentation/core-api/boot-time-mm.rst
+
 MEMORY MANAGEMENT
 L:	linux-mm@kvack.org
 W:	http://www.linux-mm.org
-- 
2.7.4

