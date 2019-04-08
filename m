Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0739C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:01:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C62020883
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 04:01:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C62020883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA11A6B026D; Mon,  8 Apr 2019 00:01:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4EF46B026E; Mon,  8 Apr 2019 00:01:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3D936B026F; Mon,  8 Apr 2019 00:01:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A25A56B026D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 00:01:38 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j17so7412519otp.9
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 21:01:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=DA77fJJZNzFcVQ67Xv2AKBK4HG/jjq7O5rfax4q9kUA=;
        b=a7nXhqso1aK8u2AsX15u5w0XkYJhiPZR4Zc+slQ1WC22bXcTvQmguAe3U3m8I3W/Xt
         Eao9Tt6ae1sIfzoXfL+cLYBwXFwVidrEfylVAVRJfbRD9mEczOEzaQOmzJ3L+Z8oQx9U
         XeZ+cd3nCHhIYMnKeqPVB+Jqo+GpSrOz0s2C8OP+4Lx7QyUY+LWh1PDGDznQVgF3Pp2d
         SGKY+uk6Wcs6gURUKIHWZ3wyy/GUwi3WmcLBZOtPwOK5kjcNXYTRl/5Mi4OTN03Pmeat
         WRfrQ2/QdmxU8nx0hJ2r8U6mhTCvM9q2iJ8EoVS5+fAFWUlqencbWWmARysQ8nHxMWA6
         zYMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAXQTtyjz08KbqiEHqTk1UtJpm8spR8HoJ/+LmegfzY5uBMTP3n7
	3LQIleme8yTsZvS5F6Y9r6PNCIRQ09Wo9STtHs3WFhhQgfFYfuBMqHMtv4oh1MnZjBZFCs+/Pqz
	iblAv8QUdsPmCG+y/N9SPypdh/2Lu2yOTEnHL3ev+WDbpWt7C7bPbli8QPk/z+9u/Yg==
X-Received: by 2002:aca:4507:: with SMTP id s7mr10261812oia.127.1554696098232;
        Sun, 07 Apr 2019 21:01:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyA8X69w6K9ss765NnEgMpD2hkZ0UGDczlH/IeQEXZRIQmQElnAnHaW8RJ/TWpHIeu2tSDt
X-Received: by 2002:aca:4507:: with SMTP id s7mr10261768oia.127.1554696097273;
        Sun, 07 Apr 2019 21:01:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554696097; cv=none;
        d=google.com; s=arc-20160816;
        b=AHzzVU/V0gYzkOZesLOqipbjT6L7Ug5vFE7A8SDjVA1UbjRVnpNsIv57wkbYKn2hv0
         whdueQLdqkR7PXgQ7vU3BReR/KqFlNnmQAJpR8agSDo3DwYOEjGPybyJWrIvGmdPnFQB
         kwry2U5MPYoXfVxfEna2gHl/p5VhB5w3m4+1itRyOTcev7Ikut/56g9z3xntr/i3+pOx
         ZKlLiVa19XdqRY6F8h2ihk6Gs4k06LWYPflUv+025ZZTILWEYIbk0a3m43+d87Inemz7
         roMMEWYSMqwEqUBNVip3B67drA+pUuoADoIOGOBqrxEwFlawNlFu7ML2s2ozx/R5T8E5
         tSrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=DA77fJJZNzFcVQ67Xv2AKBK4HG/jjq7O5rfax4q9kUA=;
        b=usU7lrPvUygtqwsFVcsHgOjiylxWhHREXKw3kAMrX8Hkf1PoYClCH7u5ktl3y3jKQX
         KmtNueckZVnShzogzDYhQRYjM4k2Zb+nOLLSN2Y6AyADs2/6xSPKeI48/1wQ2c2e0+17
         OprTIOQCMCTvsWn/xcOGCP3athhLl6I768ZluOg8ToZ9f3tM2MnYAhSUQY2WmHJpzG3S
         yCV8l7jFBZCEZGUAxfxgJwggreqMoO0XPDBFxl0xXcoX7kGVCXnBD3c4eC7SRrv5XE8g
         /eud51xWNvrA4BuOjyHumolGTW8ZKiwsyEN+DeJcbrq4sPrI7Wczrt4TRq2oo4cGXTN5
         Xn/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id o79si14711425ota.275.2019.04.07.21.01.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 21:01:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS413-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id CC375D64260818A7C064;
	Mon,  8 Apr 2019 12:01:31 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS413-HUB.china.huawei.com (10.3.19.213) with Microsoft SMTP Server id
 14.3.408.0; Mon, 8 Apr 2019 12:01:22 +0800
From: zhong jiang <zhongjiang@huawei.com>
To: <akpm@linux-foundation.org>, <rafael@kernel.org>, <david@redhat.com>,
	<rafael.j.wysocki@intel.com>, <mhocko@suse.com>, <osalvador@suse.de>
CC: <vbabka@suse.cz>, <iamjoonsoo.kim@lge.com>, <bsingharora@gmail.com>,
	<gregkh@linuxfoundation.org>, <yangyingliang@huawei.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
Subject: [PATCH] mm/memory_hotplug: Do not unlock when fails to take the device_hotplug_lock
Date: Mon, 8 Apr 2019 12:00:12 +0800
Message-ID: <1554696012-9254-1-git-send-email-zhongjiang@huawei.com>
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
index d9ebb89..8b0cec7 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -507,7 +507,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
 
 	ret = lock_device_hotplug_sysfs();
 	if (ret)
-		goto out;
+		goto ret;
 
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = __add_memory(nid, phys_addr,
-- 
1.7.12.4

