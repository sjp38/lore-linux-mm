Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C17B6C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:58:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D70A20838
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:58:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D70A20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF5FF6B0005; Mon, 15 Jul 2019 12:58:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA59C6B0006; Mon, 15 Jul 2019 12:58:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 996946B000A; Mon, 15 Jul 2019 12:58:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EFFE6B0005
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:58:24 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so8585202pla.3
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:58:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=ULXV39pNHGikizkxwRCBtvYSHzgqvtTQ2vGt7g7eQ8M=;
        b=UprenSyuQtg2iV5RYqwntxOlNynATIHR4Z0JmNPrnZE6HO8mNca4URr83F2+9cbhcO
         9M7n19F5ASLhLDZdbtgRLwTrg56uef8TTiCXp1Qh5734fq67og580HatpyccqoQX1s7A
         77atz0635Tw4gFTqSXEyOA358hqoLNA+iSxxjc7gZ2rrD2ulod1wIvEht11kF0uRww6B
         Jn+B812S0wvHn38QpSk2N3zyGgUsNrxk9gWtFXLfPjy3gb+y5mMuh5jlIUMFSSjGrkoH
         uerKRtQ1YGnrs1NZVIdzcha4767QwMxxZsFSVCQZa7/dw2JT8geeGhR9ZSdtqhjOuwW0
         5ASg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV+wMjX8UONFipMF/fq3u/OCVjL2d6JdwQfhzcqm+XHHw5wAQs/
	/ohyTTd2MYiNSm5Ivy08ReC3e1tsPulydgp4ay1CqlyhKIJ4tP2I4Zag3YHaXb/s13qhz9Xr2RZ
	GrO9JpKjqsVAd6eJPrkTV+iuCXlXtl5fe5pLjWJ/BGalGOaV2jzTKlD6MO+juF1XfuA==
X-Received: by 2002:a63:2cc7:: with SMTP id s190mr16245879pgs.236.1563209903867;
        Mon, 15 Jul 2019 09:58:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGNHmg9nVgXDYHGOLBtQ7gNnV8v8+j8fprDIT6dAjEWIUYoQoY+YZgn08khLrvpkbkv0u+
X-Received: by 2002:a63:2cc7:: with SMTP id s190mr16245827pgs.236.1563209902971;
        Mon, 15 Jul 2019 09:58:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563209902; cv=none;
        d=google.com; s=arc-20160816;
        b=YPDKyxSWEUH3zB3mNo2gM3BgkJLK8HsqGfR+OKalVkNxXZIwBtq6GrLpaPoRqKYeIs
         1NiNNiggayE3VVjtSr6jn6vD/VhF8yG3l+5nmykmgUtdXdTtLlC4tpvhnA2UT9pu69be
         fifsFnSSTRd5B/J4A30cUn4qZ+o7ojVzmZl0i86WuY6EPhpPlvVowY7WYzkY6bsXykpW
         OWdPhtcmgiNEm/y18gKme9mEgGcL9qS3dWPEf63geuIW0nXXsm/0/TH6AOdUfpVSWAAQ
         V+dYMQhkVYiAyGNq384nkh76sAH2p4vaqgxaAfDg7XFmzp/kqBDFek+0qStyxH4nc1ZD
         +s6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ULXV39pNHGikizkxwRCBtvYSHzgqvtTQ2vGt7g7eQ8M=;
        b=dLEOsINo0z4G/vAKcDFWeuriF+ObqjWu5O0oy1mkLmBYgGSVaMlwZyaNOfKsgM4/TF
         QsLZWS7DJEkaJi3nNhlbmzvptAULOxZdxg+nsVkUg6jZNT9+PriKP9iWGK4EJz+myptv
         1nRYkC4nzGN+/8CSXQ1QxH6+YmIycHal4hPxNn4FizVnlhYxSC1KZLSatiDv8ENXTm6s
         G1YdajPr+gUjO68tWb1KRBA9/7ZO5FhGBONsCSzSGCDKXfCzhsjO3sF7XWQEVr/i+mSG
         LiTEyoO1pWiofGye/XsvQjUiLlfzorNBnywhbsJxPH3DYpY6II5XahgCMYTbksM4Ugum
         GbxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id u7si12861125pgb.103.2019.07.15.09.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 09:58:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R391e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TX.M-FQ_1563209898;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX.M-FQ_1563209898)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 00:58:20 +0800
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
To: Qian Cai <cai@lca.pw>, Catalin Marinas <catalin.marinas@gmail.com>,
 Michal Hocko <mhocko@kernel.org>
Cc: "dvyukov@google.com" <dvyukov@google.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190715131732.GX29483@dhcp22.suse.cz>
 <F89E7123-C21C-41AA-8084-1DB4C832D7BD@gmail.com>
 <1563203882.4610.1.camel@lca.pw>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <82cbc350-c2a8-e653-208a-a533771fe653@linux.alibaba.com>
Date: Mon, 15 Jul 2019 09:58:14 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1563203882.4610.1.camel@lca.pw>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/15/19 8:18 AM, Qian Cai wrote:
> On Mon, 2019-07-15 at 10:01 -0500, Catalin Marinas wrote:
>> On 15 Jul 2019, at 08:17, Michal Hocko <mhocko@kernel.org> wrote:
>>> On Sat 13-07-19 04:49:04, Yang Shi wrote:
>>>> When running ltp's oom test with kmemleak enabled, the below warning was
>>>> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
>>>> passed in:
>>> kmemleak is broken and this is a long term issue. I thought that
>>> Catalin had something to address this.
>> What needs to be done in the short term is revert commit
>> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0. Longer term the solution is to embed
>> kmemleak metadata into the slab so that we don’t have the situation where the
>> primary slab allocation success but the kmemleak metadata fails.
>>
>> I’m on holiday for one more week with just a phone to reply from but feel free
>> to revert the above commit. I’ll follow up with a better solution.
> Well, the reverting will only make the situation worst for the kmemleak under
> memory pressure. In the meantime, if someone wants to push for the mempool

I think this is expected by reverting that commit since kmemleak 
metadata could fail. But, it could fail too even though that commit is 
not reverted if the context is non-blockable.

> solution with tunable pool sizes along with the reverting, that could be an
> improvement.
>
> https://lore.kernel.org/linux-mm/20190328145917.GC10283@arrakis.emea.arm.com/

