Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 745E6C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:31:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EEFB22C7C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:31:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EEFB22C7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E8788E005B; Thu, 25 Jul 2019 05:31:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 099CA8E0059; Thu, 25 Jul 2019 05:31:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA4148E005B; Thu, 25 Jul 2019 05:30:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B17A28E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:30:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b33so31768251edc.17
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:30:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=ANloll+lDEyK8HTSoUx8RdE6WQYNlRi+76MuD4ZqnNQ=;
        b=f+bnKcg8u9iCfg7WmO1wSxfjPaINsXHaioyLfSzfR/jyo2PeEcSKMMB2FZBSlDH13R
         wzPx9tq5qUnUnqzm36D/zsv2BFg+2X954UcC9OWoKnghA+tTuN24bxFvMlHq2+ImhfrE
         RWc6XEXSNR4YQC5KgDXRyVbFTRCs1+WXia+IKrrnpc+rQm0G2rjAoCggwDu0S9jtgYqg
         8u+tAe2G0njzCMzvAEKJ98ceUlZeR8fdLKnGTuQkJGGSdall02Gd1IFwZF9r1DVXWQZf
         tXPc/UPDTyXkFVg6n40BDygudj/A7rwoQlXXBcBk6FcH6HuNAe57l7DCaFFtI1I+0o2Z
         rDcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
X-Gm-Message-State: APjAAAVRvIe6ZSOJfXiWtRDKK8jXmOyriA++wCjXlFlgh17RrrHkP2NJ
	cOK6E8VeLJwHWHVmWySkw41PfJXhDBF6VODSYMSKAMgzWyTKB2/8VJ8pmcvvV3pT1wQHU4cN52u
	iInM0Y7biYIUw5PGtSj7/6GqXwUiVAcQWANbaonGbzcTe10ybIsyqn+djf0/ghPHvEg==
X-Received: by 2002:a50:eaca:: with SMTP id u10mr74944125edp.42.1564047059326;
        Thu, 25 Jul 2019 02:30:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0i1FIAGQGGJRGdY3IRFi5AXOmNMStL1hyyRkQyrkltPHl0zG5UIfqM+PiXY+RimXpmlXx
X-Received: by 2002:a50:eaca:: with SMTP id u10mr74944064edp.42.1564047058468;
        Thu, 25 Jul 2019 02:30:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564047058; cv=none;
        d=google.com; s=arc-20160816;
        b=TlUvDLzIg3mtKqjB2I15DEeBx+gau9LiZ4U9MhnTSp+o8bWjX1Cqd4CrPGDVlcEX7/
         QY2Wd3odcHRHtPzpwMR63QkS/33ysVIC1LJPxJALAEwsMCZWFxQNsiipHVJeVjXFlUA4
         BZ2Hf0t9CjefliBMrs9WrMIZzegEvFnJaaq78t+ZI0dK+V3GzpAQMfX9wQf+9UMfVVgD
         boaLOGCPHbLl2IBsaXj+3EeKPXXmRtVEnk+zPbIvV9eiaBPp5fPh+38EP1m6GKzA6G9t
         mkWFkltQnUCfg55Cph6wKBxUcrgMLclc/97i8+B3iJMns8C9oVSsQS7hffByXB1qihaC
         lQ8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=ANloll+lDEyK8HTSoUx8RdE6WQYNlRi+76MuD4ZqnNQ=;
        b=dcuRJAE+a5qBQh5vr6O5Y7ACB1BvFXR48jjDUHUg4j945Hawz+/sPT7pQ8ixt6PaHh
         VYmXd2hP1APOGbYf8KCwt0KBdXzmvBkd1f0BZBc2SLtuwb/jki54m3tggoyV9WX8lxb/
         Iq+zca1eJXliSUoYBEXUUaRrvV1rKGbDPqGrg7gJ1G8vLI3+L9kXCHKZ86rGmSqs2V6n
         T962UlMGjb+sbpIEyiGWGQcTEofsL+GpF/McWjbG+g6VVJikl2KJm5Xp1II/AxMxv1Ej
         BfBr+4jz+KWS8YEkJ2eBdEoXgC/BtDzaEfpPMNOiOUcUXunxdGBBZcVO/6OnKFeCMT2G
         lJBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id 4si10782933edz.269.2019.07.25.02.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:30:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 0E1A46F2570EFC64F2F5;
	Thu, 25 Jul 2019 17:30:54 +0800 (CST)
Received: from [127.0.0.1] (10.133.213.239) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.439.0; Thu, 25 Jul 2019
 17:30:52 +0800
Subject: Re: [PATCH] mm/mmap.c: silence variable 'new_start' set but not used
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
References: <20190724140739.59532-1-yuehaibing@huawei.com>
 <20190724143445.ezii7bwbbxxxtu2k@black.fi.intel.com>
CC: <akpm@linux-foundation.org>, <mhocko@suse.com>, <vbabka@suse.cz>,
	<yang.shi@linux.alibaba.com>, <jannh@google.com>, <walken@google.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
From: Yuehaibing <yuehaibing@huawei.com>
Message-ID: <18e48f75-782d-0aba-4ac4-85347db74f68@huawei.com>
Date: Thu, 25 Jul 2019 17:30:52 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.2.0
MIME-Version: 1.0
In-Reply-To: <20190724143445.ezii7bwbbxxxtu2k@black.fi.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.133.213.239]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/7/24 22:34, Kirill A. Shutemov wrote:
> On Wed, Jul 24, 2019 at 02:07:39PM +0000, YueHaibing wrote:
>> 'new_start' is used in is_hugepage_only_range(),
>> which do nothing in some arch. gcc will warning:
> 
> Make is_hugepage_only_range() reference the variable on such archs:
> 
> #define is_hugepage_only_range(mm, addr, len)   ((void) addr, 0)

Thank you for suggestion, I will try this.

> 

