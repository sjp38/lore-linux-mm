Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24843C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 15:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4D42208E3
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 15:50:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4D42208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 904D46B0005; Tue, 25 Jun 2019 11:50:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B5E18E0005; Tue, 25 Jun 2019 11:50:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77C6E8E0003; Tue, 25 Jun 2019 11:50:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5BE6B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:50:06 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o6so9409095plk.23
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 08:50:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=y5ZNy7i81Ut+mfkDSJ5o7JLLa2AHZoKYgMtKxzFwKNs=;
        b=ac8R/DJ3Lu7qAT1DapEnstiVhRu4hNM7+QD3baGgqHnTsPw6PFv+HIb3wH8QI+ndfZ
         6TFR1N7cEvzOPoqzzqgFbuXnCoIWtMXuwM14ZugmI5zHTre7ahjucTmszWeeWkkRiDlB
         7RBVMrtuFRn0sicFO2Snv9+nJ3jBQYP7Q7s9KfYI31dGRyRIPVp9AY/7yfb9XLCi03pC
         pIAym97iYhz4ViNjr9/Y//eOzNLVXbfvFJDtpBl+98GqQU60Hm0pGe72RBdvlT+S0M8i
         4OcTu0Iev4a54lg9Dkbe3aQzC0bvs6aUGrM4zPdgqWvnieXa0vJTE8LNsALlq/BksYvf
         0v8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAV0Yng3Sde5y3DXD5+cMCBeWjiKnuYPaW3wcwOVLwdapbX4VrSA
	ODqIJCKbi0FQI7X9P+bMn6I3vOlVoCZFbzFWQo68CPtFFBKUruPzdMy70KZ6rIDwxbyDV8BM/IR
	X5j9JkTFqiaOxMrW+DmQvCaTM4ocX+HCgFl4bH9N2CmkVYBPoaF/VHGprSNzkIgXdaQ==
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr32529818pji.94.1561477805838;
        Tue, 25 Jun 2019 08:50:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUzpgoK5dd5f5ChLuYAfnF8IT+QBQ1OZui239Op5g71UIiGizIUAyKwjxZ23jadgmHngK0
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr32529758pji.94.1561477805187;
        Tue, 25 Jun 2019 08:50:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561477805; cv=none;
        d=google.com; s=arc-20160816;
        b=PA5VqwOSNL0tdrQ5krGeHkOvWlre84GgHlXGUO9kEoA8gBsE1ME7y4H+vlLsd83Wj3
         64k9/wUKzw8smkMUlfL/hSehprcmyInqRokwaPQtgx9tWMXBip0MFi2Oeqo9E8gFhrsB
         K5TgcUY+wWX/tYPjSfB10CYcY8jaZdGvvvNN0MvurCHCMDlvBoLCsC4+uRKcKgFo+HyF
         9OlQBppR81yUO8vs6Evlz8tjUCGk7/QKasqxy7FhxCRbecGFEflWWOXwtgPKRvHZLunf
         NRW+sax9l2kWcZELZS9Z6Ff3VcT9kTv1fYuRiTylYwDBbsWqSG9h1qOnMo56Xu4aoeIU
         iO3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=y5ZNy7i81Ut+mfkDSJ5o7JLLa2AHZoKYgMtKxzFwKNs=;
        b=qJrv6onS8WGuJl1tBKiQF4OaGjjOWwMjA7FIcx2gsuWOssLY1dXnC7t9fr479wtbR+
         GZMMspN/PAiaU2NeNRm0xCmOdSHZkze039aM9ac6NGpMXCKPh+5qhszJpH6Fw4rULhrX
         /85U+744ROPxXL/GAYFre4WeIFtRjVO+VnLJf5p5QEqcfz9i5KyTKv6ia80YESkGshr2
         k5cfLzKAVGhxTWQwc37vckVHMEgyp99iJIMo8XAuQR52pKgD7Hn+0PTjJCXAVu8Uh4Jg
         xDRhO7aFGvgiyTB7AZljtKbcppFNKUQEUCUbhOtlBBMZZg1OTBPcIaEy1yFfX3SEVeon
         aLeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id y18si9237140pgk.286.2019.06.25.08.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 08:50:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0TVBV9sb_1561477780;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVBV9sb_1561477780)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 25 Jun 2019 23:49:44 +0800
Subject: Re: [v3 PATCH 2/4] mm: move mem_cgroup_uncharge out of
 __page_cache_release()
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: ktkhai@virtuozzo.com, kirill.shutemov@linux.intel.com,
 hannes@cmpxchg.org, mhocko@suse.com, hughd@google.com, shakeelb@google.com,
 rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <1560376609-113689-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560376609-113689-3-git-send-email-yang.shi@linux.alibaba.com>
 <20190613113943.ahmqpezemdbwgyax@box>
 <2909ce59-86ba-ea0b-479f-756020fb32af@linux.alibaba.com>
 <df469474-9b1c-6052-6aaa-be4558f7bd86@linux.alibaba.com>
 <20190625093543.qsl5l5hyjv6shvve@box>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <18396199-8997-c721-0b9f-b1d8650c0f5b@linux.alibaba.com>
Date: Tue, 25 Jun 2019 08:49:37 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190625093543.qsl5l5hyjv6shvve@box>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/25/19 2:35 AM, Kirill A. Shutemov wrote:
> On Mon, Jun 24, 2019 at 09:54:05AM -0700, Yang Shi wrote:
>>
>> On 6/13/19 10:13 AM, Yang Shi wrote:
>>>
>>> On 6/13/19 4:39 AM, Kirill A. Shutemov wrote:
>>>> On Thu, Jun 13, 2019 at 05:56:47AM +0800, Yang Shi wrote:
>>>>> The later patch would make THP deferred split shrinker memcg aware, but
>>>>> it needs page->mem_cgroup information in THP destructor, which
>>>>> is called
>>>>> after mem_cgroup_uncharge() now.
>>>>>
>>>>> So, move mem_cgroup_uncharge() from __page_cache_release() to compound
>>>>> page destructor, which is called by both THP and other compound pages
>>>>> except HugeTLB.  And call it in __put_single_page() for single order
>>>>> page.
>>>> If I read the patch correctly, it will change behaviour for pages with
>>>> NULL_COMPOUND_DTOR. Have you considered it? Are you sure it will not
>>>> break
>>>> anything?
>> Hi Kirill,
>>
>> Did this solve your concern? Any more comments on this series?
> Everyting looks good now. You can use my
>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>
> for the series.

Thanks!

>

