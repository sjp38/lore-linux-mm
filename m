Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6F68C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:28:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8BF22173E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 16:28:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8BF22173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44F2A8E0006; Wed, 19 Jun 2019 12:28:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FFD58E0001; Wed, 19 Jun 2019 12:28:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F81A8E0006; Wed, 19 Jun 2019 12:28:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEB018E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:28:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b24so10132852plz.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:28:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=arYgjf8u/K6k4mBeFecJDAyvmeQXfup1Kljv1rw5lDc=;
        b=qDg77p29cRcUi10BFy7BtKHf2J1OVj1IPzWXWr52Qv5K3ZYEEjtdEBUvSHvAVZHMI/
         383497GHwx7ZPndSAEr1L1FCwrJ8Mgi/ppUgUeRNj5+Ml5pqJC6A7eTbzIi+hMzDV8T5
         WzWtvyCrD/wDCgtfo4dZ0DUAIflqYl0L5yMX5yuQPu4Cq7+o+5QVCsZFPo+eVZn23N8H
         RR/Jhedip4O+YwRhG+jkA6LWSnOrYm6IiTubLLMSLjGTVYopkTovLmYKhiYqpWxmJwa2
         b4DaefoQngVPGYHINVTvCJIn02AAWYE7gT9NogsEm6bSnP6+7PasgT6FT+cNpNYOW+u9
         yqVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXhszx48+WvB4Iuu6AWA4lB0yikRL5yLkKac7nPe0w4K0MzCC96
	AZVmUtfepXFIVZjXzzx+kO42Dq5st+2RMyCKVhulNlcL51S+3QWTa/enCx6/hbxu23fQvD9gkdo
	RZlN4sQMiZVNwUBign8AylMqAF3JNdqWv5VkT/x2lqu+2/HmXgcXNAmXuP7bBNypu9A==
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr6217878plb.30.1560961730652;
        Wed, 19 Jun 2019 09:28:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/2GFa4o0XAk+NHmB/ab2wwLaPyQ7MMBK4uqMvtLam1VjYPEpaX9jLYurZTqQDTIjfkRon
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr6217819plb.30.1560961729875;
        Wed, 19 Jun 2019 09:28:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560961729; cv=none;
        d=google.com; s=arc-20160816;
        b=eT4QRiPaBKRxd486qhvTl+SCGti4e/9hUrN0DRHQQnCzUszjLW84W24kume80yYeDB
         wPRFZakHvkUUEmjhRpMoQnYkgT1b/y4Rq4AX0lBXpwq5vveRUv4f8t2yxagkd931hz1T
         jlqmk3zynqVpqVlSnyEyG3XDHK9FjlUSGD0wgtMAAx+gzGge7q7YN5Jcc4HLWEVnP9LL
         b/E12/2TC11QzZeF5OVpuf6/FcSvOYROZmDcVj/03prarpu09B/MMUMMBWno/0UvTvp+
         yzv23aCm8oRuOxcJt3KUGGEqTL6V6BB1pBhFktqbq8SAZg4ioDuCQ3V1UUoW3pK8NyE6
         B0UA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=arYgjf8u/K6k4mBeFecJDAyvmeQXfup1Kljv1rw5lDc=;
        b=t1nMK7j5YgHgbApcYrNcAz3dc+FWGPhsPspRN4mqrHJUe95l8VeiZqIX4dpGOWFKKS
         TiDsj5bqFwO8ztSpznhKrBAijqaklJKIBdzlJoNqjem+AFVxlB67QAmf9lji7bp7Qo19
         mlvebm4HZ0uENUV5qSfrkJ3Df5aPqqTdPlU7jXIOO8XOXXvsO7ZyTd/VGeLsAKxripKl
         QZzHepx960gQE46oI+notVhnQvMxHgkH3xCyrY0uMS0WM1SAEDOGJylG4iU7FRTqryjb
         SnYOtdkCz/kuEhi0Em1hYce5PRE21r3NkTyVJFvzY6g97PODYSFOFgoD2d7pvmh9LzTF
         306w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id j3si15459074plk.79.2019.06.19.09.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 09:28:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R991e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04426;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TUccovW_1560961724;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TUccovW_1560961724)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 20 Jun 2019 00:28:47 +0800
Subject: Re: [v3 PATCH 2/2] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Vlastimil Babka <vbabka@suse.cz>, hughd@google.com,
 kirill.shutemov@linux.intel.com, mhocko@suse.com, rientjes@google.com,
 akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com>
 <4a07a6b8-8ff2-419c-eac8-3e7dc17670df@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <5dde4380-68b4-66ee-2c3c-9b9da0c243ca@linux.alibaba.com>
Date: Wed, 19 Jun 2019 09:28:42 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <4a07a6b8-8ff2-419c-eac8-3e7dc17670df@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/19/19 5:12 AM, Vlastimil Babka wrote:
> On 6/13/19 6:44 AM, Yang Shi wrote:
>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
>> vma") introduced THPeligible bit for processes' smaps. But, when checking
>> the eligibility for shmem vma, __transparent_hugepage_enabled() is
>> called to override the result from shmem_huge_enabled().  It may result
>> in the anonymous vma's THP flag override shmem's.  For example, running a
>> simple test which create THP for shmem, but with anonymous THP disabled,
>> when reading the process's smaps, it may show:
> ...
>
>> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
>> index 01d4eb0..6a13882 100644
>> --- a/fs/proc/task_mmu.c
>> +++ b/fs/proc/task_mmu.c
>> @@ -796,7 +796,8 @@ static int show_smap(struct seq_file *m, void *v)
>>   
>>   	__show_smap(m, &mss);
>>   
>> -	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
>> +	seq_printf(m, "THPeligible:		%d\n",
>> +		   transparent_hugepage_enabled(vma));
>>   
>>   	if (arch_pkeys_enabled())
>>   		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 4bc2552..36f0225 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -65,10 +65,15 @@
>>   
>>   bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>>   {
>> +	/* The addr is used to check if the vma size fits */
>> +	unsigned long addr = (vma->vm_end & HPAGE_PMD_MASK) - HPAGE_PMD_SIZE;
>> +
>> +	if (!transhuge_vma_suitable(vma, addr))
>> +		return false;
> Sorry for replying rather late, and not in the v2 thread, but unlike
> Hugh I'm not convinced that we should include vma size/alignment in the
> test for reporting THPeligible, which was supposed to reflect
> administrative settings and madvise hints. I guess it's mostly a matter
> of personal feeling. But one objective distinction is that the admin
> settings and madvise do have an exact binary result for the whole VMA,
> while this check is more fuzzy - only part of the VMA's span might be
> properly sized+aligned, and THPeligible will be 1 for the whole VMA.

I think THPeligible is used to tell us if the vma is suitable for 
allocating THP. Both anonymous and shmem THP checks vma size/alignment 
to decide to or not to allocate THP.

And, if vma size/alignment is not checked, THPeligible may show "true" 
for even 4K mapping. This doesn't make too much sense either.

>
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
>> index 1bb3b8d..a807712 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -3872,6 +3872,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>>   	loff_t i_size;
>>   	pgoff_t off;
>>   
>> +	if ((vma->vm_flags & VM_NOHUGEPAGE) ||
>> +	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>> +		return false;
>>   	if (shmem_huge == SHMEM_HUGE_FORCE)
>>   		return true;
>>   	if (shmem_huge == SHMEM_HUGE_DENY)
>>

