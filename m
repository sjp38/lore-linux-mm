Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CCF6C31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 11:57:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 224B520870
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 11:57:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 224B520870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E8C76B0005; Sun, 16 Jun 2019 07:57:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69B0F8E0002; Sun, 16 Jun 2019 07:57:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 589BB8E0001; Sun, 16 Jun 2019 07:57:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7B46B0005
	for <linux-mm@kvack.org>; Sun, 16 Jun 2019 07:57:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f25so5147142pfk.14
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 04:57:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:reply-to
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=DAfoUTY2OELqXkX5LwgGuoerqU1jrqYqUp1TYozh4/E=;
        b=mdh2TdKF3oR8mjfjlKyvsxnNOfsG36Jo2jAaGLbCc8U9fIafk8YVFsHcHXkCT8pZ0B
         lUuv6rB8Qyb633qyAwXKU2fg+dhS/1AxhHJ3x9ZlIEZeQ2I6mW2EZLkx4ERMvGlq3GbG
         fS6ooItoNPDdSUzPTmGxYbN3q+NHWymE9+IsHrkAgYG3Qb/Ma94wo6g5yfJsiEXHBtB1
         eCw/DIMduPcQGVtVa+WzugPcxXcjGnEwQf6Upk7I4fTkSoXRtOvBZpXSJL+uHd8CdcOy
         K03T2ak90wMNN3pzDYvgvoBrOvyXfDQQj25IqZbIO+L6vEzaiB5jXNyAESxvapbiC4Ee
         Bc7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUd02G4U+e3a5Fr8JWJsAfef2fRGyuV9wesKCDf2vJ1/zIe/ylj
	AlTqH+eCO4vPuRkzfe5UvV7yIy+IcLbbO29tlnt44tf2I9mpFx/BNrG9/4IEDmgtcG3ccph9gtU
	2jGIHfczdDI7be7xMQfUbBruva5WcZerEE68yqtWhh83YSQMFMwdVhw0PLcby2uw9LQ==
X-Received: by 2002:a17:902:968c:: with SMTP id n12mr7875949plp.59.1560686239687;
        Sun, 16 Jun 2019 04:57:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNkvV4isecv4DlDL9AcMhtNMnQyFQYLjWKcXEg/8y43NqYCo+RbLxET2EKcnhUCVp/Xst9
X-Received: by 2002:a17:902:968c:: with SMTP id n12mr7875921plp.59.1560686239012;
        Sun, 16 Jun 2019 04:57:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560686239; cv=none;
        d=google.com; s=arc-20160816;
        b=hlnBHc5bPtpnR/+ItiUI611SOHWQKRaXevmBdSKT/1GlqqT7EBr4resSbJHmadhqdn
         VnzUaPds5ak3GrtVgIMB5pTi5oRU8jP/WMJRXZXy07/AIM4aYMcD0Ao6N5XYOqC1tR2w
         jEQVeAQOHmyPjPOzkTKOIH4BHHq+fSvcOOg6FlHcUXWa2aJaleFCXwp9m4N3vQ5+c+cD
         wtKbbSFX5PQ9TUiGziOXJ7gqQVzd9AKw3QKSY5XPkzRtlWSxVYbBsduGulPCDEr1c57N
         aeG2IXtHlsp8xqpwGFJ3EqcyufcfdQ0pnyCA8XGl3Jyoki0daErSu+AXnKuwenbtICJo
         DoZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject:reply-to;
        bh=DAfoUTY2OELqXkX5LwgGuoerqU1jrqYqUp1TYozh4/E=;
        b=P8gkPRSVe6JWGABzjk0yxj3yQ3qA21zDv8zhUcbc4L0yTJGBg9L0fKldV6BzxSwnu9
         4sajz8S6gExoIxwHjZGOAwv1I2CV5t1LapREi1kcYVsJ8ZfmtApnDdM7KchiYcAxFIFw
         9oKQzOvO622fGHISBtKtSkGbJDXU5zUFTSzvzeo7JdqGhzO1rHSO/qtSY2n9FphtL4In
         sReZfFT019ncqUXt7DjOxX7cfON0BMTBN/bIZz7usYGYhKva1XqYLmEuChj+VOxhOpe3
         FN7dlcJGW1P0IlmNqJcgeXf4DYK/iONPv4nkqesvyQBtrNm075touteyELbBpCXZmy04
         tHDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id o3si7763765pld.102.2019.06.16.04.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 04:57:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of xlpang@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of xlpang@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=xlpang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=xlpang@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TUK.rqV_1560686221;
Received: from xunleideMacBook-Pro.local(mailfrom:xlpang@linux.alibaba.com fp:SMTPD_---0TUK.rqV_1560686221)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sun, 16 Jun 2019 19:57:01 +0800
Reply-To: xlpang@linux.alibaba.com
Subject: Re: [PATCH] memcg: Ignore unprotected parent in
 mem_cgroup_protected()
To: Chris Down <chris@chrisdown.name>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>,
 Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190615111704.63901-1-xlpang@linux.alibaba.com>
 <20190615160820.GB1307@chrisdown.name>
 <711f086e-a2e5-bccd-72b6-b314c4461686@linux.alibaba.com>
 <20190616103745.GA2117@chrisdown.name>
From: Xunlei Pang <xlpang@linux.alibaba.com>
Message-ID: <89067792-2c39-bcf2-6a35-80cab101c5ac@linux.alibaba.com>
Date: Sun, 16 Jun 2019 19:57:01 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190616103745.GA2117@chrisdown.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chris,

On 2019/6/16 PM 6:37, Chris Down wrote:
> Hi Xunlei,
> 
> Xunlei Pang writes:
>> docker and various types(different memory capacity) of containers
>> are managed by k8s, it's a burden for k8s to maintain those dynamic
>> figures, simply set "max" to key containers is always welcome.
> 
> Right, setting "max" is generally a fine way of going about it.
> 
>> Set "max" to docker also protects docker cgroup memory(as docker
>> itself has tasks) unnecessarily.
> 
> That's not correct -- leaf memcgs have to _explicitly_ request memory
> protection. From the documentation:
> 
>    memory.low
> 
>    [...]
> 
>    Best-effort memory protection.  If the memory usages of a
>    cgroup and all its ancestors are below their low boundaries,
>    the cgroup's memory won't be reclaimed unless memory can be
>    reclaimed from unprotected cgroups.
> 
> Note the part that the cgroup itself also must be within its low
> boundary, which is not implied simply by having ancestors that would
> permit propagation of protections.
> 
> In this case, Docker just shouldn't request it for those Docker-related
> tasks, and they won't get any. That seems a lot simpler and more
> intuitive than special casing "0" in ancestors.
> 
>> This patch doesn't take effect on any intermediate layer with
>> positive memory.min set, it requires all the ancestors having
>> 0 memory.min to work.
>>
>> Nothing special change, but more flexible to business deployment...
> 
> Not so, this change is extremely "special". It violates the basic
> expectation that 0 means no possibility of propagation of protection,
> and I still don't see a compelling argument why Docker can't just set
> "max" in the intermediate cgroup and not accept any protection in leaf
> memcgs that it doesn't want protection for.

I got the reason, I'm using cgroup v1(with memory.min backport)
which permits tasks existent in "docker" cgroup.procs.

For cgroup v2, it's not a problem.

Thanks,
Xunlei

