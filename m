Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4942FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:59:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FECC218EA
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 15:59:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FECC218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E9EA8E0004; Thu, 14 Feb 2019 10:59:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9977E8E0001; Thu, 14 Feb 2019 10:59:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83AD68E0004; Thu, 14 Feb 2019 10:59:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 461BB8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:54 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id g188so4555169pgc.22
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:59:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=qhg9Az/DDU/n4f5fXjzWqaPfB0uzomNSOq9QUopuYBo=;
        b=ro6owR6V8YEb1bnzcVgmZfLavY02HndCFAY0J9IDhsAX/MLzPv9p8Q2PFBe7Io+D5Y
         GN1fmR4u/9zUh1Z9gUGyZfSsA5A+qkJ0Ewy8Ev0mqe9TndF8kJPHUFOkjCOizEGajH1t
         frb6iUNe6UwL64pjrNxXP/bNFRx5rt38QWVYeQFHp2KXN9IBb3bIWZLk8in5QgS1sVss
         zjXtTSIRMB3+PrqPeY5jvJRBli6p5QxmXwdYFqNZSjY2tzRKZGQqOjBJS4sTKj/slnaU
         cV7Q+W4qImirgnjt3QMhi3TTPVFT/JgqaMyhdldsoSbYKld4NltHxHf8fmubmYFCAP9D
         UvOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubaTkUJb8oGbU3GLRNxT49e70etMrBlRdBKxH/LvOWQJKh9N3uB
	MjbRegEiTxLPO8tSeksqSFqtjCpvH/r+lTWx1DWeHCOjWAUFtSJFgdB303bYJCh+alkWwdiMOcM
	kGSZfLtXPzLajUKBxz85UZz8B1eLMzy0wR9ZVT3MR3Q3UILJmuROBz6EOz/oLwgsDgA==
X-Received: by 2002:a63:2706:: with SMTP id n6mr538993pgn.352.1550159993955;
        Thu, 14 Feb 2019 07:59:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0qmPdTDHokyxLfjFGcX8ck3Fyf59kvWZ3F6wfqFhiO3fr+C+ZjRKnYoDJ+SQG9WT4DZ/3
X-Received: by 2002:a63:2706:: with SMTP id n6mr538942pgn.352.1550159993113;
        Thu, 14 Feb 2019 07:59:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550159993; cv=none;
        d=google.com; s=arc-20160816;
        b=tZ4Rz3SR8RdychaLbeb/pFZSgt9qvr62Cf2q3JupbytaJXEmPs6VktSI6j34fYBmA8
         vucvmdq5URXcybA03N0gAjWqc4h4S4p0ug/X5WRyv0MFBfMlSauxtaLRqoH98fngB6jN
         G2Wy81I20oxOXnEfgZt0Fs3O/NX1pKdjsuv5GOUHprPwXcK0B6HgQ+OmuVFC+s5FyEKB
         HfLF/kakI9jtwMjlwRKzV/1f0AfsasDLHAR8T9epldb7sVYWrbAF6t+ZeL+v4Exx8YfV
         ZiYdHbXxVhPQXzbrG6TFzIkVnfTNArv+A2D9OiTUeOKAWbcsOT88rAkhlv07LLcm1ojd
         ZMAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=qhg9Az/DDU/n4f5fXjzWqaPfB0uzomNSOq9QUopuYBo=;
        b=yOf1lor6qj4Ez9VSFhFIyl1FG8JV7SJUC+K4bQ9xT3fcGhZ9PXmue5W4VLt8JGxAfR
         HYbFNsHHF7nP1w5nCtpU9J3TxBMZHbMZlvGe8sk1wVHsp5VpdR2oZWJ1VU07rH/quAIH
         jh+dYsI+4HVqhKEV6vrjULYkKzpfbns3N9PMU/JK5uqdwXM3pPLYe8t7vkKGfRfwouMQ
         he59nh7/+23yNljckyP5AsNBCitXRg/Hua1Aqw/1LddeoENM+e1nzdwsTEAs2xGYk1Bb
         tBIrMefAGqUnMNjHUaQ+gtu8/OFeq036ro6Lo6wHzfAQ+7zpEls/VyPSHPVF3WzuZnta
         KEEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b11si2884674pla.405.2019.02.14.07.59.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 07:59:53 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1EFgasi016743
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:52 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qnaq9v3af-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:52 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 15:59:49 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 15:59:46 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1EFxjfa1114552
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Feb 2019 15:59:45 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8AAFD4C046;
	Thu, 14 Feb 2019 15:59:45 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C3AC44C040;
	Thu, 14 Feb 2019 15:59:43 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 14 Feb 2019 15:59:43 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 14 Feb 2019 17:59:43 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 2/4] hexagon: switch over to generic free_initmem()
Date: Thu, 14 Feb 2019 17:59:35 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
References: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19021415-0028-0000-0000-0000034898F5
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021415-0029-0000-0000-00002406C568
Message-Id: <1550159977-8949-3-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=761 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
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

