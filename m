Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45D77C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 15:49:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FACC20881
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 15:49:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FACC20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99A2D6B0003; Fri, 10 May 2019 11:49:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 923386B0007; Fri, 10 May 2019 11:49:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C41F6B0008; Fri, 10 May 2019 11:49:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42F5B6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 11:49:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j18so4377491pfi.20
        for <linux-mm@kvack.org>; Fri, 10 May 2019 08:49:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=F5RRAZgYBHg+JUMgqcubRvcD90i31sIBcAyK0Op7bF0=;
        b=mtoI0NjSNG6Sr9AJWrD9/AovNqtk9MDEP8HLMjrQYyg4nef68AikozE79eafFt4OW4
         BKk465TORBw4Ohjdz9AmVOJ8YgbiiCpcaXWY+HZAx0i/GsC2e1c0XlGqbDMa1HkEupBa
         +xrDNHl2GIyPh22WYx+68mC7vAH8UnaHJ9Vy2gGOzv2yQ/6ikU8sl10//a5rGfVRwQem
         Y/cg36zKbZ7QljxciL8md3rPxXpxCRgzC7AHVMdPrTIFJTzyk0f4g138v+Nl+9AvThfF
         8sCEHFuwy53JdfYNOecYuI8yvAC3yC/kmFqTEuKAu2VkCRNhvZ8B5DOKwklu0+j9dO8O
         yhug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVmu5lHpwYB0aZPTuPkYIQf8RmbPzWUeOSbRa8n+h3v3nNzwZ1k
	Ol0sDyrv62YF5q6yd9FIVnfRpOggOqh3Z+iCr//v0ZSXHw43WPtMoGzthd07bX5o4VqmnxOqzS7
	wg/5kl47TDT4K9M9Rql+iboAcTTR4PDISthSrtgshgWI/KJXgpIByu7SnDf4T67OsmQ==
X-Received: by 2002:a65:4183:: with SMTP id a3mr14451095pgq.121.1557503350976;
        Fri, 10 May 2019 08:49:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM9OUs4J0gViQVBYyRPXke3sNEc6QoV69/frBZ2Yt2O7Z6c6N7qE/8axZhQX0MOAFtBN6N
X-Received: by 2002:a65:4183:: with SMTP id a3mr14450984pgq.121.1557503350089;
        Fri, 10 May 2019 08:49:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557503350; cv=none;
        d=google.com; s=arc-20160816;
        b=XUGgGYDMqrL2YO58uYXlio3DftRwPIloCRMN4VM5QiderdSMoRnm1xlmCrV/bJwrIs
         f0XA0GSl7B1qbMi1ugaF/GRYZlVP21ppf1EleRn7WlL/97g7bwg/C84aniDdH52EMWFb
         Ppm768QcX+IY+FErCiGThWhi+q9l3ln8JyHZ9sfHFSTZaUv3tFWTxv731s9QVUdTn7qB
         CUD8tCzALEGaem44YYPllFB3ZP0gi/XTxLM0SndBY1Iv+4cFSJ2LLJZhtnVf/Q54P0FN
         UQTnZkZpclilAGXGO7dPRGJN2uQUCtraiguZLkGpeJK7WIIyZucaA7QEE04RQA4+YCDC
         eX4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=F5RRAZgYBHg+JUMgqcubRvcD90i31sIBcAyK0Op7bF0=;
        b=xoF2QNSboB7rTlqu1NKI9YUTxvEYudceoEw1dcdgKx8N+Tg+MaUw2hA6/bWvrJ+/xk
         +CmOHefsthGVNGqbceSstRIMbV0NoMtBZ5YuQAsOM+npzqHF+m/qJnM+Ii6DhYVHj5c6
         xoUmURudlZXhpCTy3dXC9E8/ldvk89O8K6cuwnhcnFT41V1Ck0MIcGy2mTLYtiSeLxR9
         Ks/g+ixKcU/yx8qqzNabU/CKLunJAXlhPcz9RcrPbeP2sov7N69wos20Rb2TJes4p8HB
         tJUB/DsWFXbhHMRRF0TlzmC5zgUQHX2oWeAskuRp2xrPe3BtO2cmnNPKVLH2UUuvTKtu
         xAuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id p19si242059pgm.175.2019.05.10.08.49.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 08:49:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R501e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TRMCMo-_1557503341;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TRMCMo-_1557503341)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 10 May 2019 23:49:04 +0800
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
To: William Kucharski <william.kucharski@oracle.com>,
 "Huang, Ying" <ying.huang@intel.com>
Cc: hannes@cmpxchg.org, mhocko@suse.com, mgorman@techsingularity.net,
 kirill.shutemov@linux.intel.com, hughd@google.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
 <1fb73973-f409-1411-423b-c48895d3dde8@linux.alibaba.com>
 <87tve3j9jf.fsf@yhuang-dev.intel.com>
 <640160C2-4579-45FC-AABB-B60185A2348D@oracle.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b8930783-ec73-7330-903f-93a81efb2cd3@linux.alibaba.com>
Date: Fri, 10 May 2019 08:48:58 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <640160C2-4579-45FC-AABB-B60185A2348D@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/9/19 9:33 PM, William Kucharski wrote:
>
>> On May 9, 2019, at 9:03 PM, Huang, Ying <ying.huang@intel.com> wrote:
>>
>> Yang Shi <yang.shi@linux.alibaba.com> writes:
>>
>>> On 5/9/19 7:12 PM, Huang, Ying wrote:
>>>> How about to change this to
>>>>
>>>>
>>>>          nr_reclaimed += hpage_nr_pages(page);
>>> Either is fine to me. Is this faster than "1 << compound_order(page)"?
>> I think the readability is a little better.  And this will become
>>
>>         nr_reclaimed += 1
>>
>> if CONFIG_TRANSPARENT_HUAGEPAGE is disabled.
> I find this more legible and self documenting, and it avoids the bit shift
> operation completely on the majority of systems where THP is not configured.

Yes, I do agree. Thanks for the suggestion.
>

