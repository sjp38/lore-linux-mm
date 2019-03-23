Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45C04C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0097E218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0097E218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 827BD6B000A; Sat, 23 Mar 2019 00:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 789646B000C; Sat, 23 Mar 2019 00:45:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64C856B000D; Sat, 23 Mar 2019 00:45:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 310AC6B000C
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i23so4281561pfa.0
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=M9ZFfxU3HA1GGesCdT2Kmzqdpeoh9T1PaRxIC8NiE8w=;
        b=oMu71Zzwqdg2YeNUg5esKmrpZNajaefhPOmYnQluyNRVqYCLOH+40HiUvccyBqDLK7
         vXZPVzK63OCwNIWzToJx8tbBEnJON4FV31KCBd8oVrSxv9dJLZuwecNumaYbJXG27efZ
         FtQNLzpwAHGamACmB94uEnaOQRqWwD43DoiOGmyHHkpGHE5N8wpOiLFWQ/ZADcQ3BJFs
         KEeh1Lf2CCm90zyxNVXCFXhVZVzyuN36TVg/Ht3mQ0GI8pPd7rn2WTF/QT9iqdNtd2/w
         fuODzZpiOSBDcxpm1+fVcWXDH62nlOl0Om6v1LyyvxoqJKmkAEp91g0ndmATFBzUV7UK
         Oy/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUuIMshW8t2ElxJVqLUnGncdjryS5pNnjdq7E3YLkt2xc0wSBDv
	wLlBd6Tr8HaaIPvm3igPod+d6qjfoxcr4BHkqmjIOIKGp5thfs2ylPJDwjBR/QxL8PQ2JTN3odg
	fM5/vG+PU6u9AdMw3yf7WWGgVAsRQsN3b6Dbhr4rOB1+Gk1QWETklJNlD6U0GsFUJfA==
X-Received: by 2002:a17:902:50e3:: with SMTP id c32mr13321710plj.57.1553316306891;
        Fri, 22 Mar 2019 21:45:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWU9CrB7aiZ/OdGaxzSCzduir4ALPJ30P28bDTFyH4HaH8Dpi6SecU2/ELbX2Wp2oUMpXy
X-Received: by 2002:a17:902:50e3:: with SMTP id c32mr13321664plj.57.1553316305860;
        Fri, 22 Mar 2019 21:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316305; cv=none;
        d=google.com; s=arc-20160816;
        b=j6ztZ/Lw10s9yp/CuBJ1lGHZubD6o2gApYfC7/K7U4xwPUqeYd6mZlhvnM3VRI3tR+
         Ay/haH5Rm2Ee7KgkB1N14d7NWHFNyDmVbZEYZrb6owtYrrth+c5YbRZwTXNIZyQfrNZ1
         zFGQKsRe54cimhsGcl1NypnfmwLCrh+Tl9G8l/5kuWMjUVqzbibgUP82i+qME+egxV4g
         5eLhnpzVyDgjKHp2Y9ItyiMyYpR8pUOds84Ou4OOSMRX06UllN09SkBkODVeb0GcLfYc
         ruZi8fr0JLLFJEW/4hTEWoQqi8KSFoc5KYAJ9a4vSpv/v2h9znm7uLSLuGyQfInXUNUt
         1T5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=M9ZFfxU3HA1GGesCdT2Kmzqdpeoh9T1PaRxIC8NiE8w=;
        b=hKnib3Sr64A79QaQY+XT+eWUFw9xJEjPGCy3UMJOot48AWVx6cFgCp/1TM/MHoUQ/l
         anUc7jFR4lOm/oWhIw6ZWT6/rCRIJ7ySZ56VKB2nw4v6E2zX1G5jSGegyVGNmAgb1qzN
         oLmfGqD/tW4xLLow9qZIxTNY8+NQTfOKWazSd0/U0H1hHzUJf1FYhvbrgYGcGh7QiSSs
         M4PoCQGCq7D7NAl2hO5eXI1DvQEfkiaU/VT0wtmN7pqh3s5UDLPU/z4ZJLorDISr4uEr
         YUPvcnyj0DkV0N2okAcGbSY1qrijeJqLU7oQIPXOHBWjy/8WWDb37i+OuMqX5iBRJT/3
         ztAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id b12si8167296plr.285.2019.03.22.21.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04446;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNPuxAM_1553316293)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 23 Mar 2019 12:45:04 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 09/10] doc: add description for MPOL_HYBRID mode
Date: Sat, 23 Mar 2019 12:44:34 +0800
Message-Id: <1553316275-21985-10-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add description for MPOL_HYBRID mode in kernel documentation.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/admin-guide/mm/numa_memory_policy.rst | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/admin-guide/mm/numa_memory_policy.rst b/Documentation/admin-guide/mm/numa_memory_policy.rst
index d78c5b3..3db8257 100644
--- a/Documentation/admin-guide/mm/numa_memory_policy.rst
+++ b/Documentation/admin-guide/mm/numa_memory_policy.rst
@@ -198,6 +198,16 @@ MPOL_BIND
 	the node in the set with sufficient free memory that is
 	closest to the node where the allocation takes place.
 
+MPOL_HYBRID
+        This mode specifies that the page allocation must happen on the
+        nodes specified by the policy.  If both DRAM and non-DRAM nodes
+        are specified, NUMA balancing may promote the pages from non-DRAM
+        nodes to the specified DRAM nodes.  If only non-DRAM nodes are
+        specified, NUMA balancing may promote the pages to any available
+        DRAM nodes.  Any other policy doesn't do such page promotion.  The
+        default mode may do NUMA balancing, but non-DRAM nodes are masked
+        off for default mode.
+
 MPOL_PREFERRED
 	This mode specifies that the allocation should be attempted
 	from the single node specified in the policy.  If that
-- 
1.8.3.1

