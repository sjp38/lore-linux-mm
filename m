Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24BB1C282CE
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 07:09:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98A8A2133D
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 07:09:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98A8A2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02F346B0003; Sat, 25 May 2019 03:09:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F21EB6B0005; Sat, 25 May 2019 03:09:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E10D96B0007; Sat, 25 May 2019 03:09:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id C42536B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 03:09:15 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id f18so5650522otf.22
        for <linux-mm@kvack.org>; Sat, 25 May 2019 00:09:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=v9OYij6c9eNalblMpuxD7oLAlGCSrYZgSELJoBCXtXM=;
        b=JxCXCA4nEDQCBvS2y+LJy+OpwuwX3RmuVxeZ5xf4kR9f1Vc8A3FP+CqRXFr9LMm3p+
         M9Jii7gHOK3pv/yV8W1qCpdgnykk3Po4BjEHaLfNOELcIDKGeVDffgCueBXpCpJfTGc4
         kP/W9Lw+cKhp1UrkG9HdySyVIJLvzdEbyYc8jnIzcprZxtPPvWhjuV7TeYC66YQMGSD5
         +VQBt2rCVL53PxsPTrfT1Ey2Ra0x+HhXF3lHUZHxUdKrXyFKy5YUhG97cHF555HbyVc7
         1zmEj+k7chccF/iJDGkkXsqQHoNk6lbF1b+4guF/7NYUCfkliMlzcyB3s66sAgoVrE5W
         mD8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAXE1siI9Pn0hl4COTXXndr9e+68Ka36Unh047g+W8PM75GvNFzV
	shlbasTHW2UIAXHf5eTll690d8DoKLQ8Hdqv3HZLwk5ggpODD+yp9NAMhvVEAnprljRffZOSLLH
	lmxlRYFf5f+szivGVmy4XneUNxQlRcmHwOmfCVjEfg/ieVhEI6sSNZ75LHNSwX/COmw==
X-Received: by 2002:aca:56c1:: with SMTP id k184mr8431330oib.152.1558768155466;
        Sat, 25 May 2019 00:09:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQ04Up2rQpbrAlskK5iasqn0GL9cc4DpkvN1JIMbfbndvQrqXrhMc/LOpVVc6Xbol6uAtC
X-Received: by 2002:aca:56c1:: with SMTP id k184mr8431307oib.152.1558768154775;
        Sat, 25 May 2019 00:09:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558768154; cv=none;
        d=google.com; s=arc-20160816;
        b=euTUBuX0B6A8TbjY64nT1CyrBRAVpJFOaZM06IOSlmwGKFCfujbM/hbMrKoapMicSx
         oWYc7hBXE2B5JCIr0FH6N5F3xR6bTBjomWJpM2tI7r0r010LrRR7LxHtuZKaDVllAdnJ
         ofN1y2xXtBbNtmSdNwZj4blcbICvPdgVyszoKoGwbYCFJdXrT7wkrH2HFtgDkHbOxK6Y
         LTjck0z4BBWupaHvtb5Q3WkS6pCqDNHihQ1Tt7rowhd5lO7igAS8Ofle9WKlSHhmSBTZ
         FzjmVqSiWjEXsV3A1f+fnb6O+/wvv5xR7M7nxX0yPVansy4WikN+l4fNsij3ghRhkdPx
         FG8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=v9OYij6c9eNalblMpuxD7oLAlGCSrYZgSELJoBCXtXM=;
        b=Jv/p9aiBXjcF348JX9g2SrwC6qRRg/oawHypawD0NpIuSg6ij/fCsT2MZwaIv0LTnc
         obRRqeNI8K1Z2lqLyry7cPeKiEErHZH2ZoySrCJOfL8wef2a2WjuqOtwe+wMN+S4arOb
         v+kpT5/yBhNcv1Y2WCbsBGPjPSQMpfX/Q8Npi7TkJ2WWN4Bj8rQs/icQB7QEHgLgGDs7
         I0TNFQGB8aQ1I3Hah/EelDV8CLD5JcTDgtxyfSxxuCoqLDZ1fcgYHN/q6tryADszTpx5
         ppSqX0xkVekRsTizEZnBdfkguGVvFCwT1zHk11yw03WltzF6TJtAIKQZCkQxaZNC5FI2
         dS1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id n204si2646569oih.75.2019.05.25.00.09.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 00:09:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 4D45CB5C057E2B867E12;
	Sat, 25 May 2019 15:09:10 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS402-HUB.china.huawei.com (10.3.19.202) with Microsoft SMTP Server id
 14.3.439.0; Sat, 25 May 2019 15:09:06 +0800
From: zhong jiang <zhongjiang@huawei.com>
To: <akpm@linux-foundation.org>, <osalvador@suse.de>,
	<khandual@linux.vnet.ibm.com>, <mhocko@suse.com>,
	<mgorman@techsingularity.net>, <aarcange@redhat.com>
CC: <rcampbell@nvidia.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
Subject: [PATCH] mm/mempolicy: Fix an incorrect rebind node in mpol_rebind_nodemask
Date: Sat, 25 May 2019 15:07:23 +0800
Message-ID: <1558768043-23184-1-git-send-email-zhongjiang@huawei.com>
X-Mailer: git-send-email 1.7.12.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We bind an different node to different vma, Unluckily,
it will bind different vma to same node by checking the /proc/pid/numa_maps.   
Commit 213980c0f23b ("mm, mempolicy: simplify rebinding mempolicies when updating cpusets")
has introduced the issue.  when we change memory policy by seting cpuset.mems,
A process will rebind the specified policy more than one times. 
if the cpuset_mems_allowed is not equal to user specified nodes. hence the issue will trigger.
Maybe result in the out of memory which allocating memory from same node.

Fixes: 213980c0f23b ("mm, mempolicy: simplify rebinding mempolicies when updating cpusets") 
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index e3ab1d9..a60a3be 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -345,7 +345,7 @@ static void mpol_rebind_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
 	else {
 		nodes_remap(tmp, pol->v.nodes,pol->w.cpuset_mems_allowed,
 								*nodes);
-		pol->w.cpuset_mems_allowed = tmp;
+		pol->w.cpuset_mems_allowed = *nodes;
 	}
 
 	if (nodes_empty(tmp))
-- 
1.7.12.4

