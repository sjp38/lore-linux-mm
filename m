Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C19CC4360F
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 00:56:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9DC6222DF
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 00:56:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9DC6222DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46C6A8E0002; Fri, 15 Feb 2019 19:56:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41B838E0001; Fri, 15 Feb 2019 19:56:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36AD08E0002; Fri, 15 Feb 2019 19:56:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 043F68E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 19:56:19 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id j32so8003317pgm.5
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 16:56:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=2N2EWSe2QIjfFUIlI7BzyvrKm4weSNV599whd376Ke4=;
        b=pQUfJfp6NlwS01WPnGSNANaziu3m4e84Tp45TK/gQNbj4Ad2s02NDY5J1XRhgA/SCg
         ujaSofGxRDZyOq+BbK0DwsXf7nY+a2KV+oRtfXRS6jyrz9xW0BWsRqpVDujk0TenwA3a
         yBv0Epz4DchnoQjWYP+WjD+2n/7n3DaS/vxYA4AmC1x5KD+wEDEdcCyvm/V9ZS7DZIrz
         DXZESgehWrLdaEQySKozSsZL1r/utVDzB2tnhJuBkZLy49Smm8fOQmGnNxvW1WO90GQa
         vStH17wjEuG+tvPZNeDdEvYM/RxzPtut3dSEQLXXYYrdJNUtPZs8E7Rs4FIayEoC9HzU
         7SOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AHQUAuZkUFReTF/27rFGghLWcUCwBmrKsjl2CLDaD5xlAXhifjvUJSaP
	JYg9ixTYHCU6pRupddt7RpANE3qOvgJDqm9KlBXq1ZNyxymdF13wc9yvi78/R+3I0CCjMsUGe4K
	TvoPeUda3s3ACRwhMuVJvmbtuXs+RXJYqLvNiua4EWE09oMS1YUzr9ez8X+6xier+dQ==
X-Received: by 2002:a62:569b:: with SMTP id h27mr12275659pfj.163.1550278578580;
        Fri, 15 Feb 2019 16:56:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaQmUo4DAaw+ea6Sm2wMmxRhUk506gS2c3tSUKWkFevAVr2Hgv4rghOE7vs4885qR8a88Nl
X-Received: by 2002:a62:569b:: with SMTP id h27mr12275613pfj.163.1550278577820;
        Fri, 15 Feb 2019 16:56:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550278577; cv=none;
        d=google.com; s=arc-20160816;
        b=hfV4uV7DW9Uw5ttZxVVxTzAr3EE7XH4qYUaf/lE6f7XPw/cdfypNXhS6IfZom/zU5+
         zXUh5iV8RBRK4uw8/TeNVhFFIpFCgGB0d7eo1Yc9TFB98didy684wE28CLrFzKjCWnqB
         gdwp7NQUbe2VwnAG6za4F/mqbd8zaUU1iJEHMA1gb9DEVza4KnzB9chR82+gTh0QaG9N
         4Hxma6wGbH/TqfOmeszNUTyJcPbRLrS+73RgMbUg2ZqaT1qcLHVT2uIxJkBKFsOywT6p
         JMk5vjdaUjvNuKXrm31thDZqxTOEj2n2lql4zEWS3cHMyZ39YSWrqB9AaWD0g57xwT3D
         pDog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=2N2EWSe2QIjfFUIlI7BzyvrKm4weSNV599whd376Ke4=;
        b=gWug9g9HcuByqFt2EvTk/FuaroCgeSD/2R+n18VeaC3vTdzuOMLzYbnEi9SZSUN32F
         7Z+xGE9j40uRF/OyGFDuSb3lZlUb0VI5unsICMKDA/jEdFk+d1rgaMOb2ibJj3onWnKQ
         5P+lLqhfho3ORl0N667Rk1dXdGoQ8to3BCjHrKPaiYDrB/dInqgr/W0RHSbUPE+6xLl/
         EMFn/zfPdtHXBiApLEjiEUVzMxjLJYUWbjHAhbwxhdsBEaeXoJmNXUgZwPjh85o1gLaL
         uHUVE5dLLCjq+9mznWtTgwGW2bpvreEAPpQYPNTAJscnzwZjGBV6VsS/I6hoha19+R2x
         0Krg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id l192si2454871pge.280.2019.02.15.16.56.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 16:56:17 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01424;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TKBzhpr_1550278564;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TKBzhpr_1550278564)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 16 Feb 2019 08:56:15 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: tj@kernel.org,
	hannes@cmpxchg.org,
	corbet@lwn.net
Cc: yang.shi@linux.alibaba.com,
	cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] doc: cgroup: correct the wrong information about measure of memory pressure
Date: Sat, 16 Feb 2019 08:56:04 +0800
Message-Id: <1550278564-81540-1-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since PSI has implemented some kind of measure of memory pressure, the
statement about lack of such measure is not true anymore.

Cc: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jonathan Corbet <corbet@lwn.net>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/admin-guide/cgroup-v2.rst | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 7bf3f12..9a92013 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1310,8 +1310,7 @@ network to a file can use all available memory but can also operate as
 performant with a small amount of memory.  A measure of memory
 pressure - how much the workload is being impacted due to lack of
 memory - is necessary to determine whether a workload needs more
-memory; unfortunately, memory pressure monitoring mechanism isn't
-implemented yet.
+memory.
 
 
 Memory Ownership
-- 
1.8.3.1

