Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD62DC282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:30:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DF3921773
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:30:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DF3921773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC4526B0007; Tue, 23 Apr 2019 12:30:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D735F6B0008; Tue, 23 Apr 2019 12:30:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C89F86B000A; Tue, 23 Apr 2019 12:30:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9E76B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:30:51 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f7so10324178pgi.20
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:30:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=T3DNsPpus+LKe1g+W1omVLgiVZeg2r40yne7jRLjnMc=;
        b=AAoCcP/gDB2HwYh/jdfpQFp7be7/xwpR06aDp5PAwL1xMYJCBSGqumVhrpmeutVwcA
         WC/EYd5bF8WYoFijSFOICcRiSEJhKKxWzjCZ16gdt8y1CIEaDalxcjm3nBoCubzpWQ2I
         FFoxPO7DD7HzcEb7iVYlhsSxVHZZVEsHeMK0tF0AHqd1IdHulPZsecGgc/32BjoT1lAm
         lVBh0+BfIbCUs0hIacTodi5qE8FufaB9CSERyJ1Zm+4ygrghLidrCJJkDr+Wm4fFq6JY
         vTAGXJuyaucvjP7nds2GtO4LcDCrh69/nlV1vElJOvPcLVdBLQmYkjSRHCugM6y29Paf
         0BFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUELih989MvcDZRYUVpUapOJXdu2o0f9NPUZ+Oo1Vw3qHDGGyu5
	iunFZpr5FTgmyV27A2SAzC30i1iMiyQffVTe4xmfbPqq6wV1LoEZu5Ffnwnr953c+VP/FAFm1Qo
	HZJ0BZOnw1nG0rFUA9aayqGffHE0DtdbW7HP+gz7ayw8m/KX0GkiSBXTsWsEWYTtbIQ==
X-Received: by 2002:a62:388d:: with SMTP id f135mr28110265pfa.103.1556037050852;
        Tue, 23 Apr 2019 09:30:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDX3S1yHHVVsf5fEXlu8oE0oHbeTSo3Ybox18RxNNGwglUOBwSsSJ8Qi3pEme+1/IfvOC6
X-Received: by 2002:a62:388d:: with SMTP id f135mr28110180pfa.103.1556037049998;
        Tue, 23 Apr 2019 09:30:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556037049; cv=none;
        d=google.com; s=arc-20160816;
        b=El2e3WgDpE44YR5ovnDd8J9cPN4edcYnPqMKrqvGSdZDriYVBMXKsly27pcjjaHtCW
         GRBFSOlULFvo6f625VQb84S/R9AaDX2EEIr2FTr/msOBT9lO1FCx+cILumWE9yYSR0oX
         HDXDaQ34AjGBIGcyfJBzgkGuQJVeGHwGk2fdFm+EpZyBYyOdgFagxrJ3qsEKFTZzPBMI
         bjyvLKFMsVBrX6/HGEkWhHIjdh3A+5gpXzFkWEazHY83ApHXS07l5znd64AuySbgR46F
         srM+OqMGMI1vav9evynEHM//jWdZJ0t5SESPiEHR8zeOylh0AD16rqdaMOgTt0pNYx78
         dxyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=T3DNsPpus+LKe1g+W1omVLgiVZeg2r40yne7jRLjnMc=;
        b=e7kk/yjH3Ov+vw7HKP5OALuJmsFQCmRjQhI5IEP5izIDGsY9pouNhvMKefqUulx+2o
         +VsLb9FR1HCwewwh5RJz6U92EGhjoPHtrf0WyL4G+ttcR9ZsCf6WtiXZQLvAYREMhG+i
         Zjh1RarZ5qP6Z+vkXO1udh/iboesx+QG28KTHN6H0MbBse0S4WfTJGjk5YYLd/MAXDhI
         ped3zxrGNhki2pQrAlNjVcxzAmHs59MOA0TIzuJCE+92kWoP8eBherGNUWw551RkMBY+
         JmQwphNfDtx7FPgcRPJATk8C0mINkYvxAOrKbZW9Ak39XgS4sV6FYn6BaZ6mAIdKQN9P
         zM6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id i9si14373430pgq.23.2019.04.23.09.30.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:30:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R931e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TQ40AXp_1556037044;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TQ40AXp_1556037044)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 24 Apr 2019 00:30:47 +0800
Subject: Re: [PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Michal Hocko <mhocko@kernel.org>
Cc: vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1555971893-52276-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423065023.GA25106@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b16183a7-4ac6-0314-3cfc-6d630e70bf4f@linux.alibaba.com>
Date: Tue, 23 Apr 2019 09:30:44 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190423065023.GA25106@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/22/19 11:50 PM, Michal Hocko wrote:
> On Tue 23-04-19 06:24:53, Yang Shi wrote:
>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
>> vma") introduced THPeligible bit for processes' smaps. But, when checking
>> the eligibility for shmem vma, __transparent_hugepage_enabled() is
>> called to override the result from shmem_huge_enabled().  It may result
>> in the anonymous vma's THP flag override shmem's.
> Hmm, I was under impression that thw global sysfs is not anonymous
> memory specific and it overrides whatever sysfs comes with. Isn't
> ignoring the global setting a bug in the shmemfs allocation paths?
> Kirill what is the actual semantic here?

I tried 4.9, 4.14, 4.20 and 5.1-rc5, all behaves in the same way. So, 
I'm supposed "enabled" is for anonymous THP only.

>
>> For example, running a
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
> Even if I am wrong about the /sys/kernel/mm/transparent_hugepage/enabled
> being the global setting for _all_ THP then this patch is not sufficient
> because it doesn't reflect VM_NOHUGEPAGE.

Aha, yes, thanks for catching this. Will fix in v2.

>> Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma")
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   mm/huge_memory.c | 4 ++--
>>   mm/shmem.c       | 2 ++
>>   2 files changed, 4 insertions(+), 2 deletions(-)
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
>> index 2275a0f..be15e9b 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -3873,6 +3873,8 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>>   	loff_t i_size;
>>   	pgoff_t off;
>>   
>> +	if (test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>> +		return false;
>>   	if (shmem_huge == SHMEM_HUGE_FORCE)
>>   		return true;
>>   	if (shmem_huge == SHMEM_HUGE_DENY)
>> -- 
>> 1.8.3.1
>>

