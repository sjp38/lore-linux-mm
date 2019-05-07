Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2410BC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:10:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D64BB2053B
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:10:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D64BB2053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 712E76B0005; Tue,  7 May 2019 13:10:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C20F6B0006; Tue,  7 May 2019 13:10:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B2BA6B0007; Tue,  7 May 2019 13:10:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21CC96B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:10:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d7so5222463pgc.8
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:10:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=NJQqDI0NsxB4k9JIlwZrh6+E+Iiu0Ru/GMvVUVONdMg=;
        b=MfWZHan5gK7QqTAoaLvqqRbtK/WrHaXWa3mmLaCVjKiNernu+XUIHHzxhkTIPQK+6k
         C9+zszgIug7WF5L8Z/OnHWV19Giq5a89NDZSipxRlvflUnCPsrwzIuabfaC2B1mA0RIL
         HtBmjOzVIecENf9W1TKzv1MicRcPXokoJmOUDypJtJyME1pEgm5Cingeg6RhaSkTUuOQ
         GugjXLWnxmy66fn9th53ZOj3ZkKp8qjQIB0nB22P6tyC8SZHHtianiLKFKb6SicnZwHr
         XGm/U42UkYiDlkFil2goXwWe1pQP/DDHyvuMA9CWJaxyo6lBFcP5lDP1SvV4hNwPxo6u
         70IQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWnkwJ47HNrRTuYNBeEDBQ/EW9Ux/LjAob4hAZ3Cug4DIxl63JH
	l9jkrmnryFTk2fJuVRJ2R5QkCs4JaaEuzskiWaT8xUvIOlSAITmiZ8Uxjw1wzaGLoYPZaY1jD1k
	Fk5lPQfltCfI1pLklPLulx1W3y7f+2SKD+klkFpehMzv6so7X4N3iEEiK4FE0QBOZOA==
X-Received: by 2002:a17:902:42:: with SMTP id 60mr41381804pla.79.1557249047735;
        Tue, 07 May 2019 10:10:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw43TYjDw5062xu3k1Jc8xQZ8B3kk9BYxJVf9TGM4eRj5ldX3QUFVb2Acy+9sFT1XNBhalb
X-Received: by 2002:a17:902:42:: with SMTP id 60mr41381696pla.79.1557249046527;
        Tue, 07 May 2019 10:10:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557249046; cv=none;
        d=google.com; s=arc-20160816;
        b=DrB5oSIbFjJNTp+1XPuq1agj0F30+EIt01FsIqotejHikOghDP9c2t8Em4Tm9fZtnI
         yc/lkhF4gmO10Aah8sajoQlwRX/znlAr7YvlxlV0rl4YsPcQGGEPXuzW34/Tq547JXg/
         gzh5gqE0fq2xb5H0f1FSpNZ3WvT2bA/0inKe8Xk3UfKagltYjB4Ldgv6gVj+BRhYTPb7
         evmsmnrsPHOJLYOcuKDA7qhmGURoQYjEpqYRdJlfRA/3XE+tytYKokQD12T2LavzBalF
         uStzGXIdAgQ1VGe8DrxorYGlFyqFmJimEMmapkCBG72MHyZ+Mwu1TRXs1kwdjrkIgqV6
         BJwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=NJQqDI0NsxB4k9JIlwZrh6+E+Iiu0Ru/GMvVUVONdMg=;
        b=FYiHL7ArYX0O7sAzJd7FndYzp/18Uq16FMMId/ji46DiN1erwuXl99LPQeGyJo2LOj
         WApEBAj6c6VSxV/r9P7Du50/hIOS6OdpHDz8yAp2JAp5zCb5116UQpbtm4wMfQe74oC8
         Gcx+vSX8lK55TAGKeVnR6B+FCTRM2mgc7dP3A3GCXRfs7/vWmsXL4fo/VIj7TCb/+PSl
         O69N/Y5wKlQMamlwrft1CBoAZlh/GQvJzT0kDTZbMxUIBruoEUU2DoW/1NWZwK1qK6ln
         cJuUGz5DdPUvyrmxE0i9xQ4iX7M0xRJrSZwpJQgnJw4UhGQMRIV/6bOynWkz6bSZ3vfN
         Yamg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id f12si20456291pgg.518.2019.05.07.10.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:10:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R901e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TR7KsnZ_1557249036;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TR7KsnZ_1557249036)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 08 May 2019 01:10:41 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
 rientjes@google.com, kirill@shutemov.name, akpm@linux-foundation.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Hugh Dickins <hughd@google.com>
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190423175252.GP25106@dhcp22.suse.cz>
 <5a571d64-bfce-aa04-312a-8e3547e0459a@linux.alibaba.com>
 <859fec1f-4b66-8c2c-98ee-2aee9358a81a@linux.alibaba.com>
 <20190507104709.GP31017@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ec8a65c7-9b0b-9342-4854-46c732c99390@linux.alibaba.com>
Date: Tue, 7 May 2019 10:10:33 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190507104709.GP31017@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/7/19 3:47 AM, Michal Hocko wrote:
> [Hmm, I thought, Hugh was CCed]
>
> On Mon 06-05-19 16:37:42, Yang Shi wrote:
>>
>> On 4/28/19 12:13 PM, Yang Shi wrote:
>>>
>>> On 4/23/19 10:52 AM, Michal Hocko wrote:
>>>> On Wed 24-04-19 00:43:01, Yang Shi wrote:
>>>>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility
>>>>> for each
>>>>> vma") introduced THPeligible bit for processes' smaps. But, when
>>>>> checking
>>>>> the eligibility for shmem vma, __transparent_hugepage_enabled() is
>>>>> called to override the result from shmem_huge_enabled().  It may result
>>>>> in the anonymous vma's THP flag override shmem's.  For example,
>>>>> running a
>>>>> simple test which create THP for shmem, but with anonymous THP
>>>>> disabled,
>>>>> when reading the process's smaps, it may show:
>>>>>
>>>>> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
>>>>> Size:               4096 kB
>>>>> ...
>>>>> [snip]
>>>>> ...
>>>>> ShmemPmdMapped:     4096 kB
>>>>> ...
>>>>> [snip]
>>>>> ...
>>>>> THPeligible:    0
>>>>>
>>>>> And, /proc/meminfo does show THP allocated and PMD mapped too:
>>>>>
>>>>> ShmemHugePages:     4096 kB
>>>>> ShmemPmdMapped:     4096 kB
>>>>>
>>>>> This doesn't make too much sense.  The anonymous THP flag should not
>>>>> intervene shmem THP.  Calling shmem_huge_enabled() with checking
>>>>> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
>>>>> dax vma check since we already checked if the vma is shmem already.
>>>> Kirill, can we get a confirmation that this is really intended behavior
>>>> rather than an omission please? Is this documented? What is a global
>>>> knob to simply disable THP system wise?
>>> Hi Kirill,
>>>
>>> Ping. Any comment?
>> Talked with Kirill at LSFMM, it sounds this is kind of intended behavior
>> according to him. But, we all agree it looks inconsistent.
>>
>> So, we may have two options:
>>      - Just fix the false negative issue as what the patch does
>>      - Change the behavior to make it more consistent
>>
>> I'm not sure whether anyone relies on the behavior explicitly or implicitly
>> or not.
> Well, I would be certainly more happy with a more consistent behavior.
> Talked to Hugh at LSFMM about this and he finds treating shmem objects
> separately from the anonymous memory. And that is already the case
> partially when each mount point might have its own setup. So the primary
> question is whether we need a one global knob to controll all THP
> allocations. One argument to have that is that it might be helpful to
> for an admin to simply disable source of THP at a single place rather
> than crawling over all shmem mount points and remount them. Especially
> in environments where shmem points are mounted in a container by a
> non-root. Why would somebody wanted something like that? One example
> would be to temporarily workaround high order allocations issues which
> we have seen non trivial amount of in the past and we are likely not at
> the end of the tunel.

Shmem has a global control for such use. Setting shmem_enabled to 
"force" or "deny" would enable or disable THP for shmem globally, 
including non-fs objects, i.e. memfd, SYS V shmem, etc.

>
> That being said I would be in favor of treating the global sysfs knob to
> be global for all THP allocations. I will not push back on that if there
> is a general consensus that shmem and fs in general are a different
> class of objects and a single global control is not desirable for
> whatever reasons.

OK, we need more inputs from Kirill, Hugh and other folks.

>
> Kirill, Hugh othe folks?

