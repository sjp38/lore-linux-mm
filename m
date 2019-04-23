Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45E20C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:34:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3FED217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:34:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3FED217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 970C26B0003; Tue, 23 Apr 2019 14:34:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91DE76B0005; Tue, 23 Apr 2019 14:34:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E8866B000A; Tue, 23 Apr 2019 14:34:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42BAF6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 14:34:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y2so10183969pfl.16
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:34:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=FcjAGiGKbvLsZU6x+h79mIFKVlxc0Lxiy+j4SpqrPo0=;
        b=Tm5yrYs3aCfjRa/pY4sbbg0tEJyx/BZOVSlY2YscrrWMqHXUjiBZWQB0C8ANDTt9Oy
         qThdYnqRkwpMAnFu/KZTE7V+11LSzQeJ0z2ytmW7Q9pQpIbFYPo2OVMdnmKxFn7b3aem
         F4WMGjFpFvsczuRaN3MUxRuBBPeScuMpavpWAf0uitbwQCBcH5Z22kqHKCqxcQc3xHR7
         6BNOOPdJjoS+iRWlX0kfpo/uNU2AmPEZJwjCnLqbSMbqmdOivKhh7XGGo7zZPg7x2Hrf
         Gk49fY2t3w2LS6jrpBr8LL2dwQbZLONmX+CRF3ujRqfNSZCLbIhxmYIOQZtIla71zWPU
         q+yA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUpDYg1o93yA893xcGdMDXG1z4agZfFTpmEih/EnFpjOScV80lK
	7JG+RzmbJJU71UqU+FmYgcvrVbYHWIThuFVlwOzcyhRbHg2AVOlmhl8gh/2Y9iF92JEsBpqgNpN
	8ma3txA+BXC7ZJqtfH8WiV0GpPXZdl3vZLAX3D+ONTIcXXRbg+2pdpNIvF7J4qvhqUQ==
X-Received: by 2002:a63:1e4f:: with SMTP id p15mr16056768pgm.289.1556044464915;
        Tue, 23 Apr 2019 11:34:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6qU0aIYQo0nqAhUGO463zwU6ti3zhnwZnOAZERAaRqf6KQRTeiCsxQDIYfjMVF1UViVa+
X-Received: by 2002:a63:1e4f:: with SMTP id p15mr16056704pgm.289.1556044464166;
        Tue, 23 Apr 2019 11:34:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556044464; cv=none;
        d=google.com; s=arc-20160816;
        b=dnLEcd1uVnrhF6931fFvxg0QvFyru9xOfnIb37uDUYMl7RrwO2KNkF4re1tAeBvhhz
         X3C2OR187L5eoIB2JZvgqor8Ir/2KcE0fM1z1TcQsSBVrS5qMJ7IrPJ1OFg41lK43Xzn
         odUAnyaHrsudMfacELMXWHdcz5YzcNasJvsmSh9X/xO8PE6gfFlCRE8n1S0U0hbdLvON
         AfAzHIdxr5suu0p4/R1EFZbUlsoyuTHddRjGfDEQVhuVvemEUz2eOzndlciH+zXlXsz8
         EmQ73gqa4q95cEopDeaGvG0xQp4XIMl0VGcIHj5yBNC77wGy2JjsWKUXyMaUvIQZOAjU
         JV1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FcjAGiGKbvLsZU6x+h79mIFKVlxc0Lxiy+j4SpqrPo0=;
        b=iqCxBH/qbHy87ItS60Q8DDC1hdw8dtYrI1XOiP1cfsusS0fhyDfc3g+8bqV5D3G8Fb
         4/P1NVYg/+WGMMMKN+h8wmNzIJFYn/KQImTfOikACr3ubFtti/uwL51fIuNprxdmADm+
         QD/M1j9QS1TQWoqa1LUHqVSCS+/2KLdjxVavxpv9WeQH7fzg8hh+KMsfq5doGmmg/oqV
         AJrXyQ57/XSVc5WrCWbsa9cc9BG14PL63olM8FVp/P1e77oNCWZpJ8p1YxVHfVVAxQs2
         bWKZYlbEYXdu5beUrJljAQaIuw/7u5Vyc/FJtX97YNrkVaKMXg5WMMALWdSv/0FBOpSA
         ZIIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id g97si15752896plb.70.2019.04.23.11.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 11:34:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R181e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ42IuD_1556044456;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQ42IuD_1556044456)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 24 Apr 2019 02:34:22 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Michal Hocko <mhocko@kernel.org>
Cc: vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6004f688-99d8-3f8c-a106-66ee52c1f0ee@linux.alibaba.com>
Date: Tue, 23 Apr 2019 11:34:13 -0700
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
>
> I have to say that the THP tuning API is one giant mess :/
>
> Btw. this patch also seem to fix khugepaged behavior because it previously
> ignored both VM_NOHUGEPAGE and MMF_DISABLE_THP.

Aha, I didn't notice this. It looks we need separate the patch to fix 
that khugepaged problem for both 5.1-rc and LTS.

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

