Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43192C43219
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 19:13:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5EE52067C
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 19:13:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5EE52067C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B2766B0003; Sun, 28 Apr 2019 15:13:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 461C06B0006; Sun, 28 Apr 2019 15:13:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3053E6B0007; Sun, 28 Apr 2019 15:13:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E98706B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 15:13:31 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d12so6046873pfn.9
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 12:13:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=7oDL1Q58c45Slrr69XVQq9J2VKpYJhoNDNfb9g4j1/0=;
        b=GzmMgzKvMlTOPMGzyWErd94FPz+GhvvEyYjbEEwfdBSCHTx+12Sc5dGa6cAWU/S4tJ
         xmleM7wHiRn2g1PLm2Kpw1cnGk6iTtguuKjWcr12dGWz4gn2D1N2KZOL9VJMEIXFvw6A
         niXYS+ov38mou9516UbDFS5RIk4V277oXhckzRtuxP8t/bbeeDhKFyXMz+vuDubgdu8U
         Duq548fElWpXs//WDGCPfXoVgiAcqqdqOdOuY904AJ2sEmolKwweSmxdOzMKr+JK+w8Y
         QqeIx/iWnIYobCsrOKPyfxjgD7VDqcRUXFhtcqS1WUIjxlvK+9DiClDKEcik3XHvaWpz
         tURw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW9xTiQvyM1wUakl+QjxsgtnoQcFkshQX1ebH2rDellhI9dpSxE
	u9KIp4O38bIDOx+YhhDRQDnh8pM0zjtGqwQHuqDhXmdNMbWbIDw9mAjjuK+Tf/fYOvoGTs3tgIz
	s8gPjWTtf187zCbzF8i8ItO3VslkcC98cuh4Acx1qOi0CQCiac/RzqnHBnhfTRTtBJw==
X-Received: by 2002:a17:902:bd92:: with SMTP id q18mr58665767pls.136.1556478811574;
        Sun, 28 Apr 2019 12:13:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyznk7ECV8vWmcQWYiH7xTyrr9lQZSh7KU2KzZPXdmVIzNz/GIsypko3f6SYnXo+dDi/8mV
X-Received: by 2002:a17:902:bd92:: with SMTP id q18mr58665718pls.136.1556478810742;
        Sun, 28 Apr 2019 12:13:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556478810; cv=none;
        d=google.com; s=arc-20160816;
        b=hkD23GfWLHSKvfNpOI5XtgY93ftfugqx846ZByFjKozqaydKUp5AiGr4lpGQ+lJOKx
         EdqO/ps8QkpSIIjnLLS/5AwIyuUoRLCHuuGf4wDhKVvxw3hbKP068tmi4zYqgu3ZLoyi
         SL0X6iB66zQIq8rWWV81v/k1WRFG7g1Z80UjYenc4I6B0jDq6Xpk7/zF3/GZonAMDPP/
         Udh0dnu/FIMJugaA1/Un6X+NPkjlE7nOHgLLzpP7vQje6hODhCKSXvQGZC7To+PdE1se
         72ZKklC6sd21snnf59u8e4TEzvo1Pwihf5/490RSK0Gs7hBOMYoHDrInN65/Wh1b7Os+
         Bxig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=7oDL1Q58c45Slrr69XVQq9J2VKpYJhoNDNfb9g4j1/0=;
        b=TggERwd9gnMiBYSRp96QAS7TnQ13as9ob0Jcl7md5m510b8SBQ10FUiWVaSnIDjgjT
         kje2RXS3r/D3cuVnvnL6vYnFENwy3VcVQl7JtrLPhqVOiwgfcAfYXuKa33mSBtOY0d1J
         mHaeK9eYbU3nCs0aJYMNPhF0ANjEaWCFkCjMfC5tSGUl9eiCUpHOEMFjU+YBT+NIosH1
         PUXdUKzPy0CN7AP3GyRol3LpbUADVFE9DDl5vcNHE/yZ7x7sHyiOHdoCXc1+3Q5JKVP+
         VsQftSbpzhPI0P8BO0x1PGsw1z7Z3CLM2LWwkbL/BY8FvBV/UeJZP/CpZH4H+/LgqlDs
         d+UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id j8si578987pfn.74.2019.04.28.12.13.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 12:13:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TQSMxWA_1556478793;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQSMxWA_1556478793)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 29 Apr 2019 03:13:15 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Michal Hocko <mhocko@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <5a571d64-bfce-aa04-312a-8e3547e0459a@linux.alibaba.com>
Date: Sun, 28 Apr 2019 12:13:07 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190423175252.GP25106@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/23/19 10:52 AM, Michal Hocko wrote:
> On Wed 24-04-19 00:43:01, Yang Shi wrote:
>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
>> vma") introduced THPeligible bit for processes' smaps. But, when checking
>> the eligibility for shmem vma, __transparent_hugepage_enabled() is
>> called to override the result from shmem_huge_enabled().  It may result
>> in the anonymous vma's THP flag override shmem's.  For example, running a
>> simple test which create THP for shmem, but with anonymous THP disabled,
>> when reading the process's smaps, it may show:
>>
>> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
>> Size:               4096 kB
>> ...
>> [snip]
>> ...
>> ShmemPmdMapped:     4096 kB
>> ...
>> [snip]
>> ...
>> THPeligible:    0
>>
>> And, /proc/meminfo does show THP allocated and PMD mapped too:
>>
>> ShmemHugePages:     4096 kB
>> ShmemPmdMapped:     4096 kB
>>
>> This doesn't make too much sense.  The anonymous THP flag should not
>> intervene shmem THP.  Calling shmem_huge_enabled() with checking
>> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
>> dax vma check since we already checked if the vma is shmem already.
> Kirill, can we get a confirmation that this is really intended behavior
> rather than an omission please? Is this documented? What is a global
> knob to simply disable THP system wise?

Hi Kirill,

Ping. Any comment?

Thanks,
Yang

>
> I have to say that the THP tuning API is one giant mess :/
>
> Btw. this patch also seem to fix khugepaged behavior because it previously
> ignored both VM_NOHUGEPAGE and MMF_DISABLE_THP.
>
>> Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma")
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>> v2: Check VM_NOHUGEPAGE per Michal Hocko
>>
>>   mm/huge_memory.c | 4 ++--
>>   mm/shmem.c       | 3 +++
>>   2 files changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 165ea46..5881e82 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -67,8 +67,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>>   {
>>   	if (vma_is_anonymous(vma))
>>   		return __transparent_hugepage_enabled(vma);
>> -	if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
>> -		return __transparent_hugepage_enabled(vma);
>> +	if (vma_is_shmem(vma))
>> +		return shmem_huge_enabled(vma);
>>   
>>   	return false;
>>   }
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 2275a0f..6f09a31 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -3873,6 +3873,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>>   	loff_t i_size;
>>   	pgoff_t off;
>>   
>> +	if ((vma->vm_flags & VM_NOHUGEPAGE) ||
>> +	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>> +		return false;
>>   	if (shmem_huge == SHMEM_HUGE_FORCE)
>>   		return true;
>>   	if (shmem_huge == SHMEM_HUGE_DENY)
>> -- 
>> 1.8.3.1
>>

