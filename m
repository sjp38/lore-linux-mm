Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F20FC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:38:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E85FF2173E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 17:38:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E85FF2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 715E18E0005; Tue, 16 Jul 2019 13:38:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69D988E0003; Tue, 16 Jul 2019 13:38:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53EAD8E0005; Tue, 16 Jul 2019 13:38:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A6EF8E0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 13:38:36 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i3so10555999plb.8
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:38:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=4r/NnixxherPzqVJN/qdLtBQZxn9/iqIyhYD0Xmrtn4=;
        b=gkvE/oHpcMoBdOPEQi3Te59vrpVZyPBfC+qDX3oElbeP7UzYz09vmz8PIjQ1hffeYy
         vEifb5CAZXGRkjMWCsJodypmvfP+lFzUpX3GPNTBsYXo9fwum3wsxLrZGVdOz56JkfG7
         vvJtIrgKb0AbZqBJyNZz3axAT+jS2zhTf1v5gSi6bmiAI7CIgUq+H00TBRf5leBrEVaU
         Kxd47ixcIrocLyNYIRjiLbSYPSbbtOpHaRKN0zTGfP8WA7hPzl0ZS1B/hkxRwee1iKb6
         vvaKEIkzjdtyPdhYh0n9OY4Cyo/9t6bpyZ34JVO0j4K24rKYGeARDr2fteWxgcQdOpUu
         +vow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXb0cVh3KfCvq6n8sYQvEDHiu3A7gJ0jXPCC167qethd7CqM36f
	jB9YgIouq5ChA1GoIDMWyvd8VtRjBidj3lN53NtpTS2OqlsivisR3Qf9m5TBRbb+jVqJ6DBQobU
	008CbTs50u9Fw1n3xpY1N8L9fov6JUtbOcw29w0u3qgDX6ZDoqPzsXjhiH21Njj95LQ==
X-Received: by 2002:a63:b10f:: with SMTP id r15mr35034091pgf.230.1563298715699;
        Tue, 16 Jul 2019 10:38:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyk7L5mL2f5V1f9nTbit+9cCLhlcrE5Cxw2au57sdY2kgYjmfYZT9JtjIliioI2wvFDQh3O
X-Received: by 2002:a63:b10f:: with SMTP id r15mr35034027pgf.230.1563298714934;
        Tue, 16 Jul 2019 10:38:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563298714; cv=none;
        d=google.com; s=arc-20160816;
        b=mzIiiq85o8SoptLpPX7ExIWNrO6MCTPeOCFKqLjOLJtCJLmLSjOQOQsCOq2Dzd3f2J
         YuhMr4DXtjyB4xPPAjRPxechrv4xbGPfEceyUU99ld7rdQzMXeXnczn+AEO7CLuuOA+D
         4T0BD9Rc3eqQc2A4mnFM5MQSW7HiVhr+aOvhfYUg83Y8yEVn2mky1dv0B0mNfL1lp8ZK
         33Gw21tsmU1WPp0hzImLU/SBSxtEOB9xrygeOCrLXuUDR9s8UGieGQJ+Jo2Vh5y8+COG
         NzeKYpaYmQ9wXlUKr8gbV+/1FM1XCwG2oCUvo3NIHLvIeqrS9KPooWHplOjgO3UVsg5/
         ME1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=4r/NnixxherPzqVJN/qdLtBQZxn9/iqIyhYD0Xmrtn4=;
        b=k4xRutWL+GonfOqn/WKPWJmc7YN9qmPYnyuaNDs1vJr0Irj+D2RN3OwGez0BCp0hIN
         bYzstfsccr/wv0z31ensFK2+PZD5u7hzD1xAoe4BycMyPFJxHn3fdcqgwyhAHEdfCbr7
         3APr+VRK6HWBkUKCWTFNwuzGSEdedHGGvkqPM4tKoOY5dKwW1TBYsqX0y4cgwRTVnJPz
         lnBkXU9DTe0CvG2eXxrQwi6PolHPEbGRH8loP5yZbkUK5ECTsBVz2n7SMMAJds3HCoBG
         9I5KixU1ZCzK5YEiyLxJt6ZXEhF3NGG1QJ2UTXYCJeTxzShVd/zwlY5UGcpKqwjSoo4r
         Ue6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id 73si21365925pfu.148.2019.07.16.10.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 10:38:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TX449w3_1563298709;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX449w3_1563298709)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Jul 2019 01:38:32 +0800
Subject: Re: [PATCH] mm: page_alloc: document kmemleak's non-blockable
 __GFP_NOFAIL case
To: Catalin Marinas <catalin.marinas@gmail.com>,
 Michal Hocko <mhocko@kernel.org>
Cc: "dvyukov@google.com" <dvyukov@google.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <1562964544-59519-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190715131732.GX29483@dhcp22.suse.cz>
 <F89E7123-C21C-41AA-8084-1DB4C832D7BD@gmail.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <9e31ca96-eb92-4946-d0db-b4e7b6ede057@linux.alibaba.com>
Date: Tue, 16 Jul 2019 10:38:28 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <F89E7123-C21C-41AA-8084-1DB4C832D7BD@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/15/19 8:01 AM, Catalin Marinas wrote:
> On 15 Jul 2019, at 08:17, Michal Hocko <mhocko@kernel.org> wrote:
>> On Sat 13-07-19 04:49:04, Yang Shi wrote:
>>> When running ltp's oom test with kmemleak enabled, the below warning was
>>> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
>>> passed in:
>> kmemleak is broken and this is a long term issue. I thought that
>> Catalin had something to address this.
> What needs to be done in the short term is revert commit d9570ee3bd1d4f20ce63485f5ef05663866fe6c0. Longer term the solution is to embed kmemleak metadata into the slab so that we don’t have the situation where the primary slab allocation success but the kmemleak metadata fails.
>
> I’m on holiday for one more week with just a phone to reply from but feel free to revert the above commit. I’ll follow up with a better solution.

Thanks, I'm going to submit a new patch to revert that commit.

Yang

>
> Catalin

