Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6D45C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 15:47:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D7BB20878
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 15:47:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D7BB20878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D07356B0005; Wed, 24 Apr 2019 11:47:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB6A06B0006; Wed, 24 Apr 2019 11:47:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA66A6B0007; Wed, 24 Apr 2019 11:47:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 806206B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 11:47:58 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id c7so12654775plo.8
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 08:47:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=6Dyg6P4LVPcLYhzDiJybhSFMUiH3oj6JY/r02xP+Bb8=;
        b=H3EA/9TwV+96reAijHZF2U/Asc4ma7Pl/mL/7ZmuEvEDOIoATnLE2B2swh6JOzdfCZ
         3i4bjDoDu/k6lM+EihxUk+z/zY9oM+cZjPBcvYE1S96GZvMcDEnsPZut3AeAmUam9nN+
         BcBYy7IJeiAfvxNBaQWijrFyPnq/gDGCvNQmG51X3E8Isl8P9+dRT0P2sGENCV2+8NOX
         ktx/HOp5MmfwIcu3J71hOmTddPZi8hVS8tEbPVM2zEqc680R+DVFSzYfWWsoVWr58u2D
         7vt0Hso7KpzDMDmdvHeQQpJGBWULoVAf8SwxQE700WWHfKs5twWkUAlSsIENvxk9LRDZ
         /i+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVuAqms05rSWVEaRLulqz8RUfliy9Ukt5ww7EXkSHwGN677FQOM
	0MeHIkeWvdA5pqA6SmTxA7jXSN2MLnJm3qejfJzV7ME6HmkY+KwmxwTKFenLgW+JdIUfe6/v+ld
	pS0iXXvEORGo6r8/8+XUJv5ecyI0nFqDtKISEDOGkHmtPx979diXxn7r0b3LyWRas7g==
X-Received: by 2002:a17:902:102a:: with SMTP id b39mr33471232pla.188.1556120878012;
        Wed, 24 Apr 2019 08:47:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzmWccSzA5GdWX5kZ917PjlMCc9b8R/Z+ryuDpHqAoP0xQrb/2RSovU4NR4etmKqwOIkkT
X-Received: by 2002:a17:902:102a:: with SMTP id b39mr33471153pla.188.1556120877129;
        Wed, 24 Apr 2019 08:47:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556120877; cv=none;
        d=google.com; s=arc-20160816;
        b=s/qffcfevOJ9+7UtRoRGpyLtJ/zOdbHqsYeU2VTylScWvUfSalXUW87+DeaMZNAcms
         7m/34kLnEdKGhOP6l1Tfs2NoUAUNQZ4TkBPUGwkOi1oBC5jBddk8l2aejojILO5OGdpc
         QZqzOE9rY9NJC84s+NGOD7Hcsy+JxpmBxeujPVSNmmu1gfCjCO0f6k/o70FP+d5NLmPd
         bvu4ZqedXj+zCkjaTNcWaRR9DbhsCqj7Pacu5n+L7RbIHMFkYKvFb4zJh6vEPH5+H+ac
         QsrIrQZlw7b8bP+tMQsC1OaOw9ctdFb6ZeQg8tzCW+95r4eSYSr6eUB/EUl4MbFGhq61
         mwZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6Dyg6P4LVPcLYhzDiJybhSFMUiH3oj6JY/r02xP+Bb8=;
        b=Df5LxQrM5LfYvpwfqu8GOFG3750eZowZdvvW2udfO/aoC9UtI6vkbWNvbyZCgZXdZr
         qoWvOXJPzGZemDjvvdSMtQTJcywUXpuUTcYQrwEg2kpeDQJVxovM47kf6E066J+HT4dD
         THsVHN9HTIX0QETmIzYZyvvzRHabEjh3PZEsDAstoxOZtqiItWD0+C4NldzgOATbZO6s
         t6e6nOedP8NYGUvVTZWWrwPD6IvQLhdTPL3RfqkE4H18FifdDrvuS3KhzkftxZMAKwL5
         yp2w1hWdeS0oPeHx785SomWBYRJEtM2J+izvnXGnwnZn3lUgzeUMns/eXO0bF37jyhlP
         zrWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id u31si5307491pgl.438.2019.04.24.08.47.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 08:47:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R591e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ8p1V-_1556120859;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQ8p1V-_1556120859)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 24 Apr 2019 23:47:41 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Vlastimil Babka <vbabka@suse.cz>, mhocko@suse.com, rientjes@google.com,
 kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org__handle_mm_fault
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <a0fa99eb-0efa-25ac-9228-167e89179549@suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <cca0cab8-c1a5-2ea5-0433-964b8166f54a@linux.alibaba.com>
Date: Wed, 24 Apr 2019 08:47:35 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <a0fa99eb-0efa-25ac-9228-167e89179549@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/24/19 6:10 AM, Vlastimil Babka wrote:
> On 4/23/19 6:43 PM, Yang Shi wrote:
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
> But how does this happen in the first place?
> In __handle_mm_fault() we do:
>
>          if (pmd_none(*vmf.pmd) && __transparent_hugepage_enabled(vma)) {
>                  ret = create_huge_pmd(&vmf);
>                  if (!(ret & VM_FAULT_FALLBACK))
>                          return ret;
>
> And __transparent_hugepage_enabled() checks the global THP settings.
> If THP is not enabled / is only for madvise and the vma is not madvised,
> then this should fail, and also khugepaged shouldn't either run at all,
> or don't do its job for such non-madvised vma.

If __transparent_hugepage_enabled() returns false, the code will not 
reach create_huge_pmd() at all. If it returns true, create_huge_pmd() 
actually will return VM_FAULT_FALLBACK for shmem since shmem doesn't 
have huge_fault (or pmd_fault in earlier versions) method.

Then it will get into handle_pte_fault(), finally shmem_fault() is 
called, which allocates THP by checking some global flag (i.e. 
VM_NOHUGEPAGE and MMF_DISABLE_THP) and  shmem THP knobs.

4.8 (the first version has shmem THP merged) behaves exactly in the same 
way. So, I suspect this may be intended behavior.

>
> What am I missing?
>
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
>>
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
>>

