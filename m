Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAFE4C282DD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:08:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A440420863
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:08:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A440420863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F0716B0271; Mon,  8 Apr 2019 00:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 274BC6B0272; Mon,  8 Apr 2019 00:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 118196B0273; Mon,  8 Apr 2019 00:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF29D6B0271
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 00:08:40 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id q82so5091792oif.7
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 21:08:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=auHua6TDjUjJypkBH39nTXAWmc6hRGA200Jkk6kcPx0=;
        b=DM2z/Acz3bU2wGyX2jObnHUMEWyqjUjAlG7br78zhk9zIJa+DYCNXrJG06a7Ag1kkk
         SeOPZkG1oMKESQ46JR/DQodNmDi8Ro2TlmsVmT7BlEeppsslJVlM2yftCBp6GxTWxu/h
         r/kcPKdGuNC4/11v2xrYnSTN9fUFXPncbpW4At+Uh9V5yyjRu8QDqCCDtMmf0T/mpEqS
         Ykr4Y2IaoVmcEnZzjr7vomCj3Hrss+k2//QsHTcaHWqsnOTHd11+Lb2Oa+uiyic1a4Xd
         skGDdsiJtFJsjUPF3uuwhJYpUeZmUZgBjhSn++9fzXf8CCDFaWNoLLUrSMN4o5gzeU9N
         QtSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAXJT8s8FIJzqTdSZb1I/AC+Cg+f5OJ28x8Klaf/Dyha4C96vo53
	wIiBTlIlIZWRu+m4DblvAKckmP5+OzVLR1QoPA8qwHCDApswYj1bvc8aJrXO7zqu5QMrb20/QbF
	9RtVAMm8BtZ20yzXmrYG09kjcZCt/Jx7HU0/GjJ/MXi5CUky2mJ21KatTvq5wqgVKTA==
X-Received: by 2002:a9d:61cf:: with SMTP id h15mr17434665otk.140.1554696520610;
        Sun, 07 Apr 2019 21:08:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwanovt0vYwi7HEEtfWIYHm0n+hPFyaDqCYAZ18Y+YYPhyHxcPMsFq8H1lrtPYE1Pa7chl4
X-Received: by 2002:a9d:61cf:: with SMTP id h15mr17434647otk.140.1554696520100;
        Sun, 07 Apr 2019 21:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554696520; cv=none;
        d=google.com; s=arc-20160816;
        b=EuLrHXQxy3smwWDuAUKvPCW4FdSJxr2QRhlMjuChMGx/z9jt7uHiiMZbPUksL6jhXq
         gaxUXhAy7GHEsxMyeTGwS/QCCnTLjxkLS+ufUKOScabuX//Oh9zmR0CS6V6DCC1qQcVe
         4Yrk4OMb5oAdlv5ckuzIQS197yjLT8WWjiaIOXk5X9Q8GaVpOt9aL2Ugf4TIhjjNgvWN
         9Xx9bodNxCbJ1J6jkg56DNVNeXw99bS7615FnjcUPwXv52SL28gqwTv4UZc4WkTpzZsj
         UrvNmINiL6tvzZMuhEgx3z+Lf1g+ni8fh+rUZcPRHgiGpHvShT7APl5PX5kp3IRQvEzZ
         XXOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=auHua6TDjUjJypkBH39nTXAWmc6hRGA200Jkk6kcPx0=;
        b=hQLiHQskW9IdbWkj+GUCXc+QgvrVo+jOzgZ7++C54HlB1y7/FrrdCX5qvDX3JHyUqH
         ixlNUGI8SIUETh22N2Fj0vPA7dm149vfCBfRnAhLgDFDW4a8FNGGwk9Sy5PVbkxD0xPe
         0ohRIO1RrlnGNXHUO14zVz2WO2i/VrO4QsOZYYtfltpWDDsxJeYluUvuNN60CSqRrOgt
         Nb3ycl8VZz5hw/AZbUODfp47wdwmwcqhxYYQWtXCeVmMOGpFCfKGaYcP46hUVq7n/F89
         yj5ipm+S4VyUDWs/K6QpfcYorVWncDfYNdArM1z0gFbnuLA6P2XKwYID15rVMuhFCc0x
         8VMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id h2si12869885otk.10.2019.04.07.21.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 21:08:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id AAC264C1AFEBD929EC33;
	Mon,  8 Apr 2019 12:08:34 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS409-HUB.china.huawei.com (10.3.19.209) with Microsoft SMTP Server id
 14.3.408.0; Mon, 8 Apr 2019 12:08:27 +0800
From: zhong jiang <zhongjiang@huawei.com>
To: <akpm@linux-foundation.org>, <rafael@kernel.org>, <david@redhat.com>,
	<rafael.j.wysocki@intel.com>, <mhocko@suse.com>, <osalvador@suse.de>
CC: <vbabka@suse.cz>, <iamjoonsoo.kim@lge.com>, <bsingharora@gmail.com>,
	<gregkh@linuxfoundation.org>, <yangyingliang@huawei.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
Subject: [RESENT PATCH] mm/memory_hotplug: Do not unlock when fails to take the device_hotplug_lock
Date: Mon, 8 Apr 2019 12:07:17 +0800
Message-ID: <1554696437-9593-1-git-send-email-zhongjiang@huawei.com>
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

When adding the memory by probing memory block in sysfs interface, there is an
obvious issue that we will unlock the device_hotplug_lock when fails to takes it.

That issue was introduced in Commit 8df1d0e4a265
("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")

We should drop out in time when fails to take the device_hotplug_lock.

Fixes: 8df1d0e4a265 ("mm/memory_hotplug: make add_memory() take the device_hotplug_lock")
Reported-by: Yang yingliang <yangyingliang@huawei.com>
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 drivers/base/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index d9ebb89..0c9e22f 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -507,7 +507,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
 
 	ret = lock_device_hotplug_sysfs();
 	if (ret)
-		goto out;
+		return ret;
 
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = __add_memory(nid, phys_addr,
-- 
1.7.12.4

