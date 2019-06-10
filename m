Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B2B6C31E43
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:33:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C73E20820
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 17:33:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C73E20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BC886B026A; Mon, 10 Jun 2019 13:33:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96DD16B026B; Mon, 10 Jun 2019 13:33:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 85C036B026C; Mon, 10 Jun 2019 13:33:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1CE6B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:33:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so7658764pfb.7
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 10:33:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=s7UqxSKHyYHx7L1/V8jLKrzpYQYyfl1+7r9dz3vkT4M=;
        b=MGHktmC48mhT1z35LZo0Ymn+hl0wnCdD8h89zy3p1RciE+CmoAjqab0B/GuYLkS+S9
         96VAKirDqwN8kdUsDatJG0fnUAAqQGC8/40NTMR6uhffEaT9SXCe5yBEI0uP5D4jeNln
         0ez7PJrkqMCpBQ8tRMYu4a7BUwnepd8BKSzVNZI1YHpstyFi97a9INz3i3fWloJW13+c
         7GPkFHQ1f4vpWP067bwdep6iMuoGoJ2h/BWxUd6Ojnww+RkCyzL7xuaiH/prcB8XdI5z
         2MqGMKGP8aTigbNmFPgvQ0Bd/ELVrrqyMS2gjOpIk3JQ2lXTWxCvrfu+8Md0gw2L10xm
         Ybmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUz8O9A3jVmA52ryZNCbHHeuqmuszhDGOj59RyMsnabKIsXHgSg
	Fn59fP7jqUtkfUOY2dt00femf70bQV1LB08Qt4xw/9O9LQulAYe50fa+lhP7mMzA+mqubvIj3WV
	rOMqeu4NsouPUX4SfcBPZAaRCh6fpudwMp3lR7XbanX9G27sThnKpOrBtJ7dFqcjlIQ==
X-Received: by 2002:a17:902:8303:: with SMTP id bd3mr71371626plb.240.1560187998947;
        Mon, 10 Jun 2019 10:33:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhSyJJextijUzxVuMfsypvM7Bb2qi26SaOn/RIyaDAh8w/lEZIpHXR9fUbYDvlPqq39PTf
X-Received: by 2002:a17:902:8303:: with SMTP id bd3mr71371566plb.240.1560187998175;
        Mon, 10 Jun 2019 10:33:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560187998; cv=none;
        d=google.com; s=arc-20160816;
        b=xh8Q62Gze3N3w0UwITra3p1aFyD1quobSvmE+dla+CnRPg/zQSwDqZI/8DnLCgfhnf
         F9jKvZUNWuo7oMcroIUYi+y42T2Qcfx0kYjypycJIhQSEss/kRvC6vXDdPAUgsCyNp0v
         09XP59L/POsYJkcn4BmDVWhcnHClv5Ns5JG4+IX8twL2AxSbWeOGxGsWQ2G2cUZbTfHo
         UE/co68iuSErM+u3VVNRyDnOBApPuZzS8tRgAXHtOBZ7ap5bWtXUk3HQowVcJkQ8WpNt
         VJCuXwns2gwOWbZYqjHubEQNoKsekGdsn74N3GZu158okzTnVTz1UUPpufOaa+jSFql0
         DlqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=s7UqxSKHyYHx7L1/V8jLKrzpYQYyfl1+7r9dz3vkT4M=;
        b=wdt5069E6r+jhpk9hfBohKWo2X/k6cN4kRKOG2d/OkV4OBqVcNl9CikqDgSQ2IMFH8
         FmqL1WfrOum+DluXM2o1Ms6ygM597ZI2naNApHaglcz570gQH0PwhNOhucKB2/gEsZM+
         u1Gp0bSPbsYrAlWSGGWl1oAhZ6ve6+djifLN05YaMyXFuVknOuSLP5Kbdi0/8AKMmZqr
         LnvTndbIi3IvBH3HIjvAXXkj40De4TmD0wDobVNTZty6KaLEftbFVjNjCssjHNm0t+9Y
         HzyJulxqLB27oFhpS3FghEU66XGCqZfK00IeOQrhwSg6rZkHRZmvpjOJ3iY9I/aUcZnW
         2ifg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id r129si10309336pgr.307.2019.06.10.10.33.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 10:33:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TTrbe0._1560187990;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTrbe0._1560187990)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 11 Jun 2019 01:33:13 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Hugh Dickins <hughd@google.com>
Cc: mhocko@suse.com, vbabka@suse.cz, rientjes@google.com,
 kirill@shutemov.name, kirill.shutemov@linux.intel.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.LSU.2.11.1906072008210.3614@eggly.anvils>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <578b7903-40ef-e616-d700-473713f438c0@linux.alibaba.com>
Date: Mon, 10 Jun 2019 10:33:05 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1906072008210.3614@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/7/19 8:58 PM, Hugh Dickins wrote:
> On Wed, 24 Apr 2019, Yang Shi wrote:
>
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
> Yes, that is correct; and correctly placed. But a little more is needed:
> see how mm/memory.c's transhuge_vma_suitable() will only allow a pmd to
> be used instead of a pte if the vma offset and size permit. smaps should
> not report a shmem vma as THPeligible if its offset or size prevent it.
>
> And I see that should also be fixed on anon vmas: at present smaps
> reports even a 4kB anon vma as THPeligible, which is not right.
> Maybe a test like transhuge_vma_suitable() can be added into
> transparent_hugepage_enabled(), to handle anon and shmem together.
> I say "like transhuge_vma_suitable()", because that function needs
> an address, which here you don't have.

Thanks for the remind. Since we don't have an address I'm supposed we 
just need check if the vma's size is big enough or not other than other 
alignment check.

And, I'm wondering whether we could reuse transhuge_vma_suitable() by 
passing in an impossible address, i.e. -1 since it is not a valid 
userspace address. It can be used as and indicator that this call is 
from THPeligible context.

>
> The anon offset situation is interesting: usually anon vm_pgoff is
> initialized to fit with its vm_start, so the anon offset check passes;
> but I wonder what happens after mremap to a different address - does
> transhuge_vma_suitable() then prevent the use of pmds where they could
> actually be used? Not a Number#1 priority to investigate or fix here!
> but a curiosity someone might want to look into.

Will mark on my TODO list.

>
>>   	if (shmem_huge == SHMEM_HUGE_FORCE)
>>   		return true;
>>   	if (shmem_huge == SHMEM_HUGE_DENY)
>> -- 
>> 1.8.3.1
>
> Even with your changes
> ShmemPmdMapped:     4096 kB
> THPeligible:    0
> will easily be seen: THPeligible reflects whether a huge page can be
> allocated and mapped by pmd in that vma; but if something else already
> allocated the huge page earlier, it will be mapped by pmd in this vma
> if offset and size allow, whatever THPeligible says. We could change
> transhuge_vma_suitable() to force ptes in that case, but it would be
> a silly change, just to make what smaps shows easier to explain.

Where did this come from? From the commit log? If so it is the example 
for the wrong smap output. If that case really happens, I think we could 
document it since THPeligible should just show the current status.

>
> Hugh

