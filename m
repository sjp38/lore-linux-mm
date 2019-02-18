Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA491C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:41:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85C6721773
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:41:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85C6721773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16EE78E0006; Mon, 18 Feb 2019 13:41:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F1778E0002; Mon, 18 Feb 2019 13:41:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E89D98E0006; Mon, 18 Feb 2019 13:41:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA3298E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:53 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k1so17736969qta.2
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:41:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=qhg9Az/DDU/n4f5fXjzWqaPfB0uzomNSOq9QUopuYBo=;
        b=VMg0GD1g9keJbbUwPzxJy9qXYjxv84oO4tOsgET8Tok1/QqchzT2HKH9L0E0zYrvHR
         339bzszhDesenhalF2M7e3hEEX7Zb+wovmfcToUcLt6AZJJ5tbR5KuCg6dgc8wWe/MID
         sTapGajL5NZl7y8iSMzOKl3gCONd5YPK8ahwIZ8aNVLoLeHac94be6LL2hkPFnFdYkpG
         c0Ov7c8/QHGlApnR3KIADXD4v1hHwqY5EdYHdECVE5nTdS0vr/BV3DJ/T32bYzZhZy74
         j29zRnuTETTvX7z+G3bdClsSCcOWWRigVbc4TLTtiHmBdM50JVHC0QJuyzAbcBRgyUf0
         j+Qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuajkeigeNo0SmGz8UR/RHhdS9hWxtYMdSVAsj0C3bJdh3Ifp4+T
	dUm2WFwiQkE99O57p5p5pCjPFzCOi/d8RIBSQnVdhqwEA7zCqae7hihGh2zXzSgr9916+//yNoS
	Q1pU8mTAXxuea4tlBFoC0eDGNIToM1G+WL7TH68EJ+C0DOGUYwO7v/OlJ4vJkFc1Ugw==
X-Received: by 2002:aed:3ef6:: with SMTP id o51mr19353784qtf.183.1550515313487;
        Mon, 18 Feb 2019 10:41:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZU53z6wnN0cWDQuZ9lnRFR2K2mPUNxCgfD41d6ovEnX7k5KCa2hZ1tIjEpBnojC/H93PXh
X-Received: by 2002:aed:3ef6:: with SMTP id o51mr19353748qtf.183.1550515312830;
        Mon, 18 Feb 2019 10:41:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550515312; cv=none;
        d=google.com; s=arc-20160816;
        b=iZdhm2sEtaoh4p2OoM12slc7h1UbLz5OI4n8rZQ5p2h5IB0j4R8aUXIMETQuJKEU39
         7Ia/P04AdIuPFMxOMsQH9WXkjGvsOJ3HQ8Q25zPznHklGJaUTC7gBgKfnGKgtLDjS8wp
         VIw/pfUgPT72WSt3SgYHBG11FNEdpkyejBi9Ns8lXNpmNzOSq4YBkVZKbexTu0z/EPQv
         el5bgUYE7kbzdv46S4Y47DgKlwne6PmR5qF5dhCebFn+R8lKWollujvZHGQ7ZsGc3E20
         JVY0mtjEFZRchHG3oSiz4mlgV/3dxcA1TVckWbzHSfRmZmI+qY27NmBjeVK8xvKuAtVH
         rJgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=qhg9Az/DDU/n4f5fXjzWqaPfB0uzomNSOq9QUopuYBo=;
        b=iAGLQSmlP81isQVWeBMGBUcrh3rCr417Gn01jhj9bVG1dCkSfwu/+Khq/17pVzB/sL
         +KF1gsByzYqgZP/a+06iilNFMkfj9L5aQdgUMWOeMPmXWb2Oyeciz6e4e1DGM6S1NzJS
         luYlKUS1l5fR1BalBGMJRFJQmkbkNyNqRYmMpqorH7uR+AqLsSBN7ye/gCt+iuXqwbU/
         J+AiberuMHjR3ikrifrRAPv4kFo2YIwJ6LewUukpi6yOh58DtgRQgPwxOjlzINwlYRy7
         JBGHdjOI7mBWmB3tu3OmSEB5bwrRTXLc94QLcuRvrN787SfJxZvjgCYcITqRm8px2ZOB
         S05w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 7si2238247qto.247.2019.02.18.10.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:41:52 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IIcpuq010870
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:52 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qr06f68v8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:41:51 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 18:41:50 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 18:41:47 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IIfkW460686370
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 18 Feb 2019 18:41:46 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 97FA0A4040;
	Mon, 18 Feb 2019 18:41:46 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7D2BFA4053;
	Mon, 18 Feb 2019 18:41:43 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 18 Feb 2019 18:41:43 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Mon, 18 Feb 2019 20:41:42 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 2/4] hexagon: switch over to generic free_initmem()
Date: Mon, 18 Feb 2019 20:41:23 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
References: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19021818-0008-0000-0000-000002C1EA72
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021818-0009-0000-0000-0000222E1A1C
Message-Id: <1550515285-17446-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=780 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

hexagon implementation of free_initmem() is currently empty and marked with
comment

 * Todo:  free pages between __init_begin and __init_end; possibly
 * some devtree related stuff as well.

Switch it to the generic implementation.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/hexagon/mm/init.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/arch/hexagon/mm/init.c b/arch/hexagon/mm/init.c
index 1719ede..41cf342 100644
--- a/arch/hexagon/mm/init.c
+++ b/arch/hexagon/mm/init.c
@@ -85,16 +85,6 @@ void __init mem_init(void)
 }
 
 /*
- * free_initmem - frees memory used by stuff declared with __init
- *
- * Todo:  free pages between __init_begin and __init_end; possibly
- * some devtree related stuff as well.
- */
-void __ref free_initmem(void)
-{
-}
-
-/*
  * free_initrd_mem - frees...  initrd memory.
  * @start - start of init memory
  * @end - end of init memory
-- 
2.7.4

