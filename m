Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF48CC76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:38:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B7B122BE8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:38:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B7B122BE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 323F86B0006; Thu, 25 Jul 2019 13:38:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D52D6B0007; Thu, 25 Jul 2019 13:38:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19BEB8E0002; Thu, 25 Jul 2019 13:38:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D54296B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:38:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so31301464pfk.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:38:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=oTNtf5hiNqP/lYwgt4S5rqeAl/0Vi36SAdEbDtBSrLY=;
        b=WJ10/moAJ/3eV7WRICNIgcAxCpnDyY1X9EKi2MY0UIBN7fdYUDVT8+VcAXAUJxnGZZ
         BpjAKFNzRha7daqmRmZaUCNbelQP+LZOlFfR5Z8bg+kVSxh6LpIUUb4XI99DzHK75ZNZ
         WM4dxJ4VBk/rMm2ytZlY60jnPzbJ+bD31czXmQNJa8EN8+A5tuQdtEQUJVoaXTRQjNKS
         1yJsv7AOoXCp/CGYIH3dmUV5Hz7+A+/8v0XC6wtX7V1TjNiTI1+JYmdR+TzTnMBXLvaO
         NHNoXxQWWInCS40bsmDW6PKLUS5GrKP4HxPTPuO6oaHP23L9ZR9g+z2mA21h6asbTAFd
         K7xw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWYLi6T0eKhYfU1H4q1WQMA/8Zj/Ply/tTYqdh6k8FGdPw9/dEB
	yFcwKarRtGIFfYB3V0uqlZ9PyNzemQJNye5eXMiPD/w/S/fkelnRNXW1MvHfXWjLDj1H5ZNVsQY
	laAupjQLItmEo3sbmRQumX6FWjVuWNEz3+OpK8+gLRdMHFvXftHA0Y5ysBJifSn2HiA==
X-Received: by 2002:a17:902:704a:: with SMTP id h10mr90009335plt.337.1564076308534;
        Thu, 25 Jul 2019 10:38:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0AsB5dBCwB+I9ENigeNlPFwqf4/2MK7B/cXYT8Or1RE7xJF5FK5QZ1VzMbMKoFpQxmtjn
X-Received: by 2002:a17:902:704a:: with SMTP id h10mr90009304plt.337.1564076307825;
        Thu, 25 Jul 2019 10:38:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564076307; cv=none;
        d=google.com; s=arc-20160816;
        b=VAiJuyvRlIJK8NZoDW7pq4Mgl8W02CbGwURr5ROdcHG+tLMg9XF51lyfhpY1G3tEn3
         19VoTrCqZx2uEOpt2XbpLANBxlI7UhtDoGpCm3oiXWTGBQWbkbsNPUFtJ3axsve7Mw1g
         6JzD2JaDrSCqUstpAmJJOhcyH7xUkrcMhjuDR6jOVVwKUT4lhfQiB56GqwBD/hivrgVx
         kOOtGHOu7yqMrUAqKkfhoAT6OBVOdsv2QshivQgeBo0ZESzM7dCGSMFCMQPyBJECXWOt
         IWpQGpcWamoTrvWiLs/MJtN8B74XjPycTvqysYVvzp6bfVRcuLWukfgIElnuzosEX933
         JChw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=oTNtf5hiNqP/lYwgt4S5rqeAl/0Vi36SAdEbDtBSrLY=;
        b=vTzbOHeCCGvuAVd5KT+b06Er22MF6i+OB/ar1ngudS20rvMY3XLmhAlVVYfu1d+ye9
         txsbuyJk1ZZ6Oz64fSt2nFKuOtPQ9o52Lxy17WO2+zEc6wyGW2ESwUR4LPsV4cEO/Ora
         qymK/pOidLBhtVnod5AJj+ocQthiTy94saMvCMT2LGQ68I4MeX1oF1dUikjbIOMMciSb
         3JDHxi3vHixiUZFcZ1ipOMYDmkAILKvDU17D7K4xxjRqav69R6LjE4qkb4wYjXoOEyUt
         W4asiC81/akoVH8Dv7iOm32KNLxyV5sep23tdfTIuEeoiYihhFfLG9tWxLfr14b/FYU3
         +y7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id u6si17547888pfm.135.2019.07.25.10.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 10:38:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TXnP.Uy_1564076302;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TXnP.Uy_1564076302)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 26 Jul 2019 01:38:25 +0800
Subject: Re: [v4 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
To: Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>
Cc: mhocko@kernel.org, mgorman@techsingularity.net, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
References: <1563556862-54056-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563556862-54056-3-git-send-email-yang.shi@linux.alibaba.com>
 <6c948a96-7af1-c0d2-b3df-5fe613284d4f@suse.cz>
 <20190722180231.b7abbe8bdb046d725bdd9e6b@linux-foundation.org>
 <a9b8cae7-4bca-3c98-99f9-6b92de7e5909@linux.alibaba.com>
 <6aeca7cf-d9da-95cc-e6dc-a10c2978c523@suse.cz>
 <20190724174423.1826c92f72ce9c815ebc72d9@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6fbe0abe-d27f-36ba-ef91-09daec4b4d35@linux.alibaba.com>
Date: Thu, 25 Jul 2019 10:38:18 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190724174423.1826c92f72ce9c815ebc72d9@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/24/19 5:44 PM, Andrew Morton wrote:
> On Wed, 24 Jul 2019 10:19:34 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> On 7/23/19 7:35 AM, Yang Shi wrote:
>>>
>>> On 7/22/19 6:02 PM, Andrew Morton wrote:
>>>> On Mon, 22 Jul 2019 09:25:09 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>>>>
>>>>>> since there may be pages off LRU temporarily.  We should migrate other
>>>>>> pages if MPOL_MF_MOVE* is specified.  Set has_unmovable flag if some
>>>>>> paged could not be not moved, then return -EIO for mbind() eventually.
>>>>>>
>>>>>> With this change the above test would return -EIO as expected.
>>>>>>
>>>>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>>>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>>>> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
>>>> Thanks.
>>>>
>>>> I'm a bit surprised that this doesn't have a cc:stable.  Did we
>>>> consider that?
>>> The VM_BUG just happens on 4.9, and it is enabled only by CONFIG_VM. For
>>> post-4.9 kernel, this fixes the semantics of mbind which should be not a
>>> regression IMHO.
>> 4.9 is a LTS kernel, so perhaps worth trying?
>>
> OK, I'll add cc:stable to

Thanks.

>
> mm-mempolicy-make-the-behavior-consistent-when-mpol_mf_move-and-mpol_mf_strict-were-specified.patch
>
> and
>
> mm-mempolicy-handle-vma-with-unmovable-pages-mapped-correctly-in-mbind.patch
>
> Do we have a Fixes: for these patches?

It looks the problem has existed since very beginning. The oldest commit 
which I can find is dc9aa5b9d65fd11b1f5246b46ec610ee8b83c6dd ("[PATCH] 
Swap Migration V5: MPOL_MF_MOVE interface"), which is a 2.6.16 commit.


