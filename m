Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8806DC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:38:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 465E22087F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:38:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 465E22087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF98A6B0005; Mon,  6 May 2019 19:38:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BABC86B0006; Mon,  6 May 2019 19:38:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9A876B0007; Mon,  6 May 2019 19:38:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 733336B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:38:01 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x5so8911531pfi.5
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:38:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=oVOivhHJxacHPN+YIpK1Obzte1LyffmfLP5KLoyrsYc=;
        b=VM6b7QB8o9xQe0+QSnAYu5M98OsyPPvfjwr1kXYrp75TUXkw8zvzFvTgKED4eJPzBk
         HjubpNq2b+W/cd5dp6wr5ymNLhUQdwvBFlbdAeC9cOdVdL2/WPzg+zZTp4pw3J8HRewx
         p0PKC+0c1KW+IHPTFOlkPFx/2HwTcLsEf5XtxjHUHLQhdOJ6QjendZbSRYVM/oIZuxeY
         lydD1yF/HWxqXskEirbANTiMz/eKXrHYvlyN5gfkT/ZWrdZCSjwcimxoUyv69dXXEPBz
         KAJQbpCoDsOe5tJC1GtzHeSy3I07P/zLUfWu1IrGPmUzmS6OqZh+S904kUs7qXQF5suR
         LXmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWconzgnNT4OsAiw73C3GQTvTxaqi86bfXecFnCoOVjcrOylLXa
	XVbHFrgb6ipsdwj2PSaII2v4Cd5VPu6ARLC43S8N4JRTVdblPb1ACXM4MRpEn2srVoo54hcYcgb
	h2MylsYyrkaudG11MVCZPGJlUhIUsYrF/77pFIlJfz1owXfvv9RkVTN1Q+HjYtg1gfQ==
X-Received: by 2002:a63:5947:: with SMTP id j7mr36169327pgm.62.1557185881131;
        Mon, 06 May 2019 16:38:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy47KLQqC2A5EWamXC6o0Vag76dmQQuHFv9xl0fYOYtIKKxZTtm9rM1kQrNTBG67KQY9AXR
X-Received: by 2002:a63:5947:: with SMTP id j7mr36169277pgm.62.1557185880318;
        Mon, 06 May 2019 16:38:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557185880; cv=none;
        d=google.com; s=arc-20160816;
        b=qo0kS7GPkL93hbhzaAErtEMb5Qp0pxn081xGmNOd1aSXIwkLxoj2mHNHMBdcQUgKq2
         sbXzIozpmxXOJ1/WexnWOfeFHHmgvZnEz2BAJO8T63IRCxfdhciI36ts76xDCnPVEBaa
         qh+p4QBiPivn0ZnSklvKR61ya/tWh1u71ckayWvtKTktTcs7cB0+ZWBtntUVr8s65Hry
         MP/09OVBvWS3718j1h7DnDdo0u3ZHnE+l77pBdkxZO+b1CjJpXZardTjKF8wORmwDPCI
         ZgXJv1KXF00SDnUYJiwD8L9ra2GivGjQ2ukSVNX1xuGvtWa4bBZMNxww6BYlSN+FByf8
         Deuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=oVOivhHJxacHPN+YIpK1Obzte1LyffmfLP5KLoyrsYc=;
        b=j/2kCpABgydTYPUzHZ97IWdO8FZV4pwXM4c9kQSd+1TsX6bm/lsR6chac2R5+ssnhx
         omBjyMxyB8uxEBLTPi3dxAMfgiz0+hxKaP1xxO+DbM76S1yjWUwO3Gpo3ReFubQofK0i
         wO3UncfeiTp1gAAIpoCNHKhGqC73Zz414IeCjVFS1pG6C+N9Ce0SOPjqZck54DpddRla
         9Ifm43SAD7pC05FAYa0V2I1hrrohqrEKLDVoF+OhwEjmKyexeDVsGaWm6ggVCwGQLDZb
         JGGt1CegIEmmlH9jXVBcFiAJaTrcqVOgafJu3uednTgD9knE4O8RHy6XiuZY6LvZ8caM
         oFTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id u1si17543227pgq.551.2019.05.06.16.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:38:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=8;SR=0;TI=SMTPD_---0TR3ml8T_1557185863;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TR3ml8T_1557185863)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 07 May 2019 07:37:45 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
From: Yang Shi <yang.shi@linux.alibaba.com>
To: Michal Hocko <mhocko@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
 <5a571d64-bfce-aa04-312a-8e3547e0459a@linux.alibaba.com>
Message-ID: <859fec1f-4b66-8c2c-98ee-2aee9358a81a@linux.alibaba.com>
Date: Mon, 6 May 2019 16:37:42 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <5a571d64-bfce-aa04-312a-8e3547e0459a@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 4/28/19 12:13 PM, Yang Shi wrote:
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
>
> Hi Kirill,
>
> Ping. Any comment?

Talked with Kirill at LSFMM, it sounds this is kind of intended behavior 
according to him. But, we all agree it looks inconsistent.

So, we may have two options:
     - Just fix the false negative issue as what the patch does
     - Change the behavior to make it more consistent

I'm not sure whether anyone relies on the behavior explicitly or 
implicitly or not.

If we would like to change the behavior, I may consider to take a step 
further to refactor the code a little bit to use huge_fault() to handle 
THP fault instead of falling back to handle_pte_fault() in the current 
implementation. This may make adding THP for other filesystems easier.

>
> Thanks,
> Yang
>
>>
>> I have to say that the THP tuning API is one giant mess :/
>>
>> Btw. this patch also seem to fix khugepaged behavior because it 
>> previously
>> ignored both VM_NOHUGEPAGE and MMF_DISABLE_THP.
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

