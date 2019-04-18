Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E3EDC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:48:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E836121479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:48:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E836121479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B6C76B0007; Thu, 18 Apr 2019 12:48:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 865706B0008; Thu, 18 Apr 2019 12:48:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77D466B000A; Thu, 18 Apr 2019 12:48:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7136B0007
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:48:16 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b7so164110plb.17
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:48:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=7fd//MdsUnuf1kx0gSh/g4qsh6yU8kXSazoNNEO7Dy0=;
        b=fLW/BnpypWGkeDv0iRzkAL0k2yfJSKLST0n1VgLdL1nAfRIbAuLdBM5ZtrQEvoUfTE
         XsCOjjh0yueK2zSH/bUmT4RwhEwWSM2ILxggJSUS7HZ6nj+rIGmfntoVGvhWyo7u3eHG
         iWIBJiThv5wiVZkEykYxDkV74ei+nn7d5cyDY6BCNqdxOwlu/RuNt9z1yqiDLOMUKG7e
         9lew9BN9mqpjdDeLeoiYaqgVzoY4CwyC5Sk9KsiQs1zw5p9J84GWhrzDnpUAvJnDn1Zc
         5gaSaFWH/AOQ9J5FiviSMMwUqoYC0PYFUP041WOooneW0JxD2DKc8HZDD3ElpywS7GMp
         zrxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUNbOSBAAR67OvkFUa6XTjL4V2IzFYy1NTLSk1m4MpVWtXNSq26
	5cznDK2seTJb+y00scC1w5yLACB5oNj4mPYsEvBthtnOBRZFIWgLOCb2pSvbyms8uYl97cBOivX
	x5Ch15LPRDzpea5wQKz/C86hH4aDuCABPPa05y0MAcfnTaq725yVg1ymEYt+l9bkgUg==
X-Received: by 2002:aa7:820c:: with SMTP id k12mr96357576pfi.177.1555606095698;
        Thu, 18 Apr 2019 09:48:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMWp4/yfC9IwC4VNAJ8Bs/lcY0WuvaB5ZGsKTeAPnNS/sTrLz/V9Niq24vgw0bFzfzr0pB
X-Received: by 2002:aa7:820c:: with SMTP id k12mr96357503pfi.177.1555606094773;
        Thu, 18 Apr 2019 09:48:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555606094; cv=none;
        d=google.com; s=arc-20160816;
        b=tEIKptNbyUuFacdRQ2mHwR+jw5+vJosux6AVGkY9wyEjdxbHTWvZkeCQQIRKXeHuF1
         cdSjOGE+1K+5jLJwJg7W9tzfTiZlwYltW8hDLXLubPhYZQFijDHtrozCUgH4nE+rtqBx
         NGlcjppgkKdv0rTRnfaNrD9HtkNsfJ9wpiaFFI+FcSX0YQnAiLxIKuc21cLRfBIVqa5l
         e8/lR8hmqEDEpwsMYwzfoPW1pYYl9GjDj7m4KLRZW55oEWXAaK2aaA8zcalwcpdYEgrK
         q4Xk3At0ObOf7hkXNYRVtVWpB6+ad9Qh5RYXpdVuEda3Jc2JFFg+Xnvt6h0Hchz2IRma
         YHSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=7fd//MdsUnuf1kx0gSh/g4qsh6yU8kXSazoNNEO7Dy0=;
        b=vkpyAHv7L4bvSwexZ8/lgg4iPo1Mn4UZUn0N/a3wawIUEBG+m+OM8j7b4p2CK1xFhc
         d1FMhKxYNf4M1he77uOYWw71afbucl1v4NmsSXfo+V64hQwhhDVYXdisjTOK1iUmoAem
         NwQlXH//wUQ+XC+8rCKFvSl1DupHtysiwuREeRm4EIFC0QzhYYei/uPts0SeYgv/6koC
         +Tb6uMT09RExkFhFwYse+tEo84kbhcELqZUfKh3u9NdSbzC8jUceHOW2Yc3/4XUFHjsZ
         Xt263K4AKW4SAuHCe+N3trLQakXZxwQITSC4ONUUaAzLKHs2660iwcg8N6EYtuD/wE+U
         uHYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id l191si2715980pfc.213.2019.04.18.09.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 09:48:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TPeyfr1_1555606089;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPeyfr1_1555606089)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 19 Apr 2019 00:48:12 +0800
Subject: Re: [PATCH] mm: use mm.arg_lock in get_cmdline()
To: Laurent Dufour <ldufour@linux.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Michal Koutny <mkoutny@suse.com>
References: <20190418125827.57479-1-ldufour@linux.ibm.com>
 <20190418130310.GJ6567@dhcp22.suse.cz>
 <749b8c73-a97d-b568-c0e5-a7bda77090c9@linux.ibm.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <efc01241-1ef0-09ed-e3b5-c4b04a0f64e8@linux.alibaba.com>
Date: Thu, 18 Apr 2019 09:48:09 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <749b8c73-a97d-b568-c0e5-a7bda77090c9@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/18/19 6:05 AM, Laurent Dufour wrote:
> Le 18/04/2019 à 15:03, Michal Hocko a écrit :
>> Michal has posted the same patch few days ago 
>> http://lkml.kernel.org/r/20190417120347.15397-1-mkoutny@suse.com
>
> Oups, sorry for the noise, I missed it.

Yes, Michal already posted a similar patch. Anyway, thanks for catching 
this.

>
>> On Thu 18-04-19 14:58:27, Laurent Dufour wrote:
>>> The commit 88aa7cc688d4 ("mm: introduce arg_lock to protect 
>>> arg_start|end
>>> and env_start|end in mm_struct") introduce the spinlock arg_lock to 
>>> protect
>>> the arg_* and env_* field of the mm_struct structure.
>>>
>>> While reading the code, I found that this new spinlock was not used in
>>> get_cmdline() to protect access to these fields.
>>>
>>> Fixing this even if there is no issue reported yet for this.
>>>
>>> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect 
>>> arg_start|end and env_start|end in mm_struct")
>>> Cc: Yang Shi <yang.shi@linux.alibaba.com>
>>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>>> ---
>>>   mm/util.c | 4 ++--
>>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/util.c b/mm/util.c
>>> index 05a464929b3e..789760c3028b 100644
>>> --- a/mm/util.c
>>> +++ b/mm/util.c
>>> @@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char 
>>> *buffer, int buflen)
>>>       if (!mm->arg_end)
>>>           goto out_mm;    /* Shh! No looking before we're done */
>>>   -    down_read(&mm->mmap_sem);
>>> +    spin_lock(&mm->arg_lock);
>>>       arg_start = mm->arg_start;
>>>       arg_end = mm->arg_end;
>>>       env_start = mm->env_start;
>>>       env_end = mm->env_end;
>>> -    up_read(&mm->mmap_sem);
>>> +    spin_unlock(&mm->arg_lock);
>>>         len = arg_end - arg_start;
>>>   --
>>> 2.21.0
>>

