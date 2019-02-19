Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1307C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 16:47:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34EE421773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 16:47:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34EE421773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7C998E0003; Tue, 19 Feb 2019 11:47:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C04D98E0002; Tue, 19 Feb 2019 11:47:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA5678E0003; Tue, 19 Feb 2019 11:47:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB8E8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 11:47:11 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id m3so16631177pfj.14
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 08:47:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=mUn5vdC4XGDDXJI+fhBTHcwjd41VIvEJMT4VM2uu0f4=;
        b=F4mmnLnB9SMeCP4uNhfhsm1G9JBHPstcZAwP7s4+TdctwDkYjWxE254iMdU65IE5b+
         Ha79x0qxpKPR/R6V5PIIoUSPG8oHI5X+KtkKWU2I0/oB2Sr9aEfRn6qd3lMOQf+0MC3U
         RWJFu45v92VSX+NxqVJePOzwcScE9oTfm+9Bdxah6Hj8xMNkSw+QdCjHHnym8bN3G/EV
         eIkMsibVbPpNNncqZ4QjqksCKOtzNrpDC1oB59VvC5VjtDJAq6XwV0C//JIXbAyONaf4
         AlZ23v2tkxzAmRtkeaTK6BwVaIUBxBK1XIfYXQj80dfAEQMyMU4HCMk3F7EgSF6nWFH+
         uMsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AHQUAubF8XsaRKLn9egFRpzMOLN0xVafFmeXndGm+AVCvnlc+MzMuI1K
	HGn7b5XvGWxaJxOl4LzBhQZv4ER+KxuqMoehepAORSa7iGrjtdN/G0k9H6woz/QXBdeNz4n5QTf
	mtNVQBbETCx9UYp+TuLGInRndro9NngDJPorhTe8bSKUkC5/SPyGmVYAUjGRdtSbSpw==
X-Received: by 2002:a63:f816:: with SMTP id n22mr24857160pgh.146.1550594831005;
        Tue, 19 Feb 2019 08:47:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbAwQ29tTtvv+5RrSd/ns75cAFIZLLcvCVs7KaMYL0dgrGj9QEdnWJB2GWXTJel6pXT7VLD
X-Received: by 2002:a63:f816:: with SMTP id n22mr24857114pgh.146.1550594830146;
        Tue, 19 Feb 2019 08:47:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550594830; cv=none;
        d=google.com; s=arc-20160816;
        b=BavVGbPa/nLn7jjGsKTt6zSMI0a6c5GMlDtqPogCKExXxG6EG83QzZgRcKVOBW6VXm
         KfUcOb8HQNXP7weqW1DjBJCwdEVFvo+IWluI87mrvVsUbkpc5rWYwYlycxUxy9d91AIT
         mb2v+Dn6cqtoHVDYiX/zub1QV9trs3TIzXhRjaB+7kvMJcfe1CesNS/M8/9PPzkMO3Ic
         hZe8Y6tHT9zJzcjgTwRQf/Ue62IHZf/dYRlEhTHzVONEaSC+5nmNM9nXlCd8Di+jb0oO
         v6FCEQ8UguryhccDZ3WIUBwmH9zMx3zsgDviJ09+U6+AYUrccVAteBzEKSYMUblKtlyC
         1CuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=mUn5vdC4XGDDXJI+fhBTHcwjd41VIvEJMT4VM2uu0f4=;
        b=kghz0ZOsUSAI0XVBhQcH49oL0QhRwDWeexhXGYt/lQdhxRSf31Yab5w6tlUWIOoMbR
         iCo9PURkHqkjUic/JgL43Ds+DoKg6hkCK2SkxB6WOOqZOv245dr7L45eqkusOlF4mg94
         BXtlRwaFkfSACBg/BedPgz5sFWymPD3PJ+h00bSFcL18NWx76lzZCxm2EgXkr9fG/nJP
         H5ltZXyTdJ2mnaSlAcv51V2JU2IENHW4jxL8AGf+jCPTj2z1is/2Ltt39pvFemU55Hy5
         B1zy1lYBE8O7mD+aPskP5yJyAhVWC7g+Qa5r4J/MGO1R2Y3+4a7wmZBRzR+mbODEV2RY
         a+2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id o4si5722952pgc.345.2019.02.19.08.47.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 08:47:09 -0800 (PST)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R731e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07488;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TKabDau_1550594825;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TKabDau_1550594825)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 20 Feb 2019 00:47:07 +0800
Subject: Re: [PATCH] doc: cgroup: correct the wrong information about measure
 of memory pressure
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, corbet@lwn.net, cgroups@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1550278564-81540-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190218210504.GT50184@devbig004.ftw2.facebook.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <79dc6298-a062-51e0-64d0-9696dc602767@linux.alibaba.com>
Date: Tue, 19 Feb 2019 08:47:02 -0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190218210504.GT50184@devbig004.ftw2.facebook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/18/19 1:05 PM, Tejun Heo wrote:
> On Sat, Feb 16, 2019 at 08:56:04AM +0800, Yang Shi wrote:
>> Since PSI has implemented some kind of measure of memory pressure, the
>> statement about lack of such measure is not true anymore.
>>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Jonathan Corbet <corbet@lwn.net>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   Documentation/admin-guide/cgroup-v2.rst | 3 +--
>>   1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
>> index 7bf3f12..9a92013 100644
>> --- a/Documentation/admin-guide/cgroup-v2.rst
>> +++ b/Documentation/admin-guide/cgroup-v2.rst
>> @@ -1310,8 +1310,7 @@ network to a file can use all available memory but can also operate as
>>   performant with a small amount of memory.  A measure of memory
>>   pressure - how much the workload is being impacted due to lack of
>>   memory - is necessary to determine whether a workload needs more
>> -memory; unfortunately, memory pressure monitoring mechanism isn't
>> -implemented yet.
>> +memory.
> Maybe refer to PSI?

I thought so too, but the above "memory.pressure" has already referred 
to PSI. So, I was not sure if we should duplicate PSI information.

Thanks,
Yang

>
> Thanks.
>

