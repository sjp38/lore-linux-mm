Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6766DC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 00:22:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAE79217D9
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 00:22:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAE79217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F68F6B0005; Tue, 23 Apr 2019 20:22:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A47C6B0006; Tue, 23 Apr 2019 20:22:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 693756B0007; Tue, 23 Apr 2019 20:22:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 319476B0005
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 20:22:52 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n63so10692986pfb.14
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 17:22:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=i7nM6cZXenJhVdsE/ILisLsz7vFb5CPoe27Cs+FCmA4=;
        b=Cq7IARDzwwUa4Vh26JKs7WAZajGu/PcyQqw6ZW4/EvsVMhAY9GpLEBWRD670HpDjOb
         iIBvS0CsGau8bznYHs7WxQabGoyZ4F/Pdv532OhI4Zexq80iwmN64yG6yGj0xjGw/u3g
         bBf+u2cISnY28bZLVGx5aO4w1NaNY0nuvpgkAU8tRZ0OfeNE/TcjYlv+Veb84kBLleC3
         RHDMYBU3mjFXJASIFkC5xOTWWfpAATJawQ9rIBBzLan7C55Jxu/289I3PMmyjxKmFaw2
         PsSrWgB/+C0vBR/q0hRFB/jUwyVZqzmunbfHjottFaRBNE9CnK2mTMqvPWpXIjlNZTts
         ycRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUbbGNnUvTGsKMGpxzo38ILQKt7b1DgPO5I8YrFdvGJBTiFN4my
	SvEHu6tqMEqyVARF4rF6oWlviAoIMk3RBNqvhhNs1Q+H7lz55aX2cytPzZHg/ntiYSNCuJMTRmt
	yjhFx/grvxHWRPgrGHgb6pwZ6Y2koy7k1R0riZtz7AjUwzxZWv2Pu45yU+gjV74naUQ==
X-Received: by 2002:a17:902:2927:: with SMTP id g36mr27853930plb.6.1556065371602;
        Tue, 23 Apr 2019 17:22:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdWyC+E5YvAACPCIjLRNJlYMLe50hjo7awhXhC4sB+7aO2cCrmkhqzVzWMuvkRHAHplseq
X-Received: by 2002:a17:902:2927:: with SMTP id g36mr27853857plb.6.1556065370579;
        Tue, 23 Apr 2019 17:22:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556065370; cv=none;
        d=google.com; s=arc-20160816;
        b=CdlhYu4X+8PBz0QjMhx/pVsohHb6+qKBljHgQS4N6+VUjEL37Dd+O8nmzuCquzPOlV
         5Ies5uKhkeY424WC+A6/EnT1B8ToD8KfsQixJbYvZnIruLiuMtA7T5RwxIZaBO5h9uuh
         uFhw4IMpVYPmp7Aco1P1mjUdiryXTlfNBU524pLbznqels8MjtF331YiPjwmeOYgveDj
         8NYs6DCyiJtkPWR5z7IhDMe4dT4YyaHKDAbcy7ldZWjzOmF24EIU7gPrNfazyLJcpZkk
         SaOGZwtc3bVKmdfQwwbpZhDzc39OKrqmu9QiP8SHEMk2LakIfpdEZhxGXbXxqLe3pvGc
         0bzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=i7nM6cZXenJhVdsE/ILisLsz7vFb5CPoe27Cs+FCmA4=;
        b=rNdwpRZ9C8qLYJ2LRZMzqt+i/GHX/COBD5MMNLvHsUE9evUdXgi9qNtJB9Ih+8Bv/I
         jCGDGyvR3nNCZQ4Cm1k0w/7Bt2PY8y6K29D4/clUoCxAwsHE3kGj4eczAwepU7BNuGVh
         xhtfuryuN6hg4TXEbuHuq/9zEvChIhJZel1luB5pyiPPxh+P+nrty0+Do6lK/UTUSv5b
         Azjmsb2OQ8msrAKR9QioTWCORpzfo6vb94/qI+vnch3mR9XycOx6j5umJAxOdV3IB4jW
         I+pFbco1BnnB8lbVnYq/Yg0dDRVvjW2iq+WdvTFejH5YGHM8JKo9sxr/kPI5uvAIxCS/
         EuWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id k70si15969031pgd.75.2019.04.23.17.22.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 17:22:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R281e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ5BmiI_1556065358;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQ5BmiI_1556065358)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 24 Apr 2019 08:22:48 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
 <6004f688-99d8-3f8c-a106-66ee52c1f0ee@linux.alibaba.com>
Message-ID: <dace50e0-b72c-33db-5624-bf7449552ff8@linux.alibaba.com>
Date: Tue, 23 Apr 2019 17:22:36 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <6004f688-99d8-3f8c-a106-66ee52c1f0ee@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/23/19 11:34 AM, Yang Shi wrote:
>
>
> On 4/23/19 10:52 AM, Michal Hocko wrote:
>> On Wed 24-04-19 00:43:01, Yang Shi wrote:
>>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for 
>>> each
>>> vma") introduced THPeligible bit for processes' smaps. But, when 
>>> checking
>>> the eligibility for shmem vma, __transparent_hugepage_enabled() is
>>> called to override the result from shmem_huge_enabled().  It may result
>>> in the anonymous vma's THP flag override shmem's.  For example, 
>>> running a
>>> simple test which create THP for shmem, but with anonymous THP 
>>> disabled,
>>> when reading the process's smaps, it may show:
>>>
>>> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
>>> Size:               4096 kB
>>> ...
>>> [snip]
>>> ...
>>> ShmemPmdMapped:     4096 kB
>>> ...
>>> [snip]
>>> ...
>>> THPeligible:    0
>>>
>>> And, /proc/meminfo does show THP allocated and PMD mapped too:
>>>
>>> ShmemHugePages:     4096 kB
>>> ShmemPmdMapped:     4096 kB
>>>
>>> This doesn't make too much sense.  The anonymous THP flag should not
>>> intervene shmem THP.  Calling shmem_huge_enabled() with checking
>>> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
>>> dax vma check since we already checked if the vma is shmem already.
>> Kirill, can we get a confirmation that this is really intended behavior
>> rather than an omission please? Is this documented? What is a global
>> knob to simply disable THP system wise?
>>
>> I have to say that the THP tuning API is one giant mess :/
>>
>> Btw. this patch also seem to fix khugepaged behavior because it 
>> previously
>> ignored both VM_NOHUGEPAGE and MMF_DISABLE_THP.

Second look shows this is not ignored. hugepage_vma_check() would check 
this for both anonymous vma and shmem vma before scanning. It is called 
before shmem_huge_enabled().

>
> Aha, I didn't notice this. It looks we need separate the patch to fix 
> that khugepaged problem for both 5.1-rc and LTS.
>
>>
>>> Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each 
>>> vma")
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>> Cc: David Rientjes <rientjes@google.com>
>>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> ---
>>> v2: Check VM_NOHUGEPAGE per Michal Hocko
>>>
>>>   mm/huge_memory.c | 4 ++--
>>>   mm/shmem.c       | 3 +++
>>>   2 files changed, 5 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>>> index 165ea46..5881e82 100644
>>> --- a/mm/huge_memory.c
>>> +++ b/mm/huge_memory.c
>>> @@ -67,8 +67,8 @@ bool transparent_hugepage_enabled(struct 
>>> vm_area_struct *vma)
>>>   {
>>>       if (vma_is_anonymous(vma))
>>>           return __transparent_hugepage_enabled(vma);
>>> -    if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
>>> -        return __transparent_hugepage_enabled(vma);
>>> +    if (vma_is_shmem(vma))
>>> +        return shmem_huge_enabled(vma);
>>>         return false;
>>>   }
>>> diff --git a/mm/shmem.c b/mm/shmem.c
>>> index 2275a0f..6f09a31 100644
>>> --- a/mm/shmem.c
>>> +++ b/mm/shmem.c
>>> @@ -3873,6 +3873,9 @@ bool shmem_huge_enabled(struct vm_area_struct 
>>> *vma)
>>>       loff_t i_size;
>>>       pgoff_t off;
>>>   +    if ((vma->vm_flags & VM_NOHUGEPAGE) ||
>>> +        test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>>> +        return false;
>>>       if (shmem_huge == SHMEM_HUGE_FORCE)
>>>           return true;
>>>       if (shmem_huge == SHMEM_HUGE_DENY)
>>> -- 
>>> 1.8.3.1
>>>
>

