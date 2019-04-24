Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBCCCC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 16:21:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 699B7208E4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 16:21:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 699B7208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 153886B0005; Wed, 24 Apr 2019 12:21:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 104E66B0006; Wed, 24 Apr 2019 12:21:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F36546B0007; Wed, 24 Apr 2019 12:21:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C42E6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 12:21:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id q17so10164315eda.13
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:21:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=KDqVTxwUsKui5fUofPV6yOHEzoMA5tRFmXQyqNYKRSI=;
        b=PVzoAfaR1J6vGyWjUy5H+hURjoZ4uuw5/vTRaddHMpuVs/kRQwoK4dJ17MEYpngoS9
         3Bohf/3EekhUxgFSwVNWS7E2g1QFdrXsTtjfr7dPUDWY8X+zlTmYP+nP1WFxzogj/S5q
         M3cnZ0Vf0U4UcmNWjQ2Au9jO1momOpb6RMgnlYuGqhgfrY9UwBoQzaoDM3v74u+x0o4w
         XYLAp+tSsspRptijMPD0UU5+LqLYvChHQLnULYV9m8yqyOIDb5CfZD+n2qCJv4DJywxN
         v9AJbjkqQChUpN2Sh/fsx8zK1HXtwhfHI46NiWlEvYlKbVjZj9pDKSW13njgchpKLZWT
         8PNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXH3j7I3I+0Xg3D2pfmS3XdGQ13hLwjU3/3VwqCgJCnd9BsgtWq
	5SGvTgjJVJgfKfdOfK9JC9wuh++L3Y+MXi+XfnVLGycpFD/HK1RML9TAwlvaecNaDqYu5+n2kTa
	HHtGtW0Bk21qk9qEBpmoMPnMTKmclUi12aEe/gs6v63ILSq7fnIn/8yJTFrtTPhJO2Q==
X-Received: by 2002:aa7:d899:: with SMTP id u25mr21535121edq.219.1556122865190;
        Wed, 24 Apr 2019 09:21:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwi7VyFUBa+VpWdotwys9gktNqVJ63DezDkWlyXUQUuuhgzMVW3ZHo/DQI0hGFbBm/zsSs
X-Received: by 2002:aa7:d899:: with SMTP id u25mr21535069edq.219.1556122864219;
        Wed, 24 Apr 2019 09:21:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556122864; cv=none;
        d=google.com; s=arc-20160816;
        b=q2tY4smqqYbU9jS42vgGQ/LT/t2OqDJpzPofoKbNI8IHXL3CoM1+1/Pj10LQRZAjvG
         Ce//14Xa5Ugdv3HAJj8JuyVGk0033js4AtiFhaCAFM8wW5VZHjlzcjnOldMFLuYjxxeh
         VJrRqOMdCDdAbiBsREpNpPMOfZuWx0cSdQU2An/Npv8vxjVlzrZP9R7IcMrAIFLHCeYZ
         VnDrYAxoeS91v5QRB8QMcTFlSFoVk+Z+Uv9mHahK5DjgksvhE63rmcj6oYGMf8cAlE67
         hX1R7/Umz+OS7wkLLUgwZ6ytswqodlZRzcUybOxTGjldkDZ0WMrn0yYAKCJA7whZGsQI
         u0eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=KDqVTxwUsKui5fUofPV6yOHEzoMA5tRFmXQyqNYKRSI=;
        b=warrpoLW6OIBIIm7OSWIPssEy3uX1ltBoyfqzj0WhnfBTvZIzunDp6BwL8AXjPqFTl
         KXCdAjeWVr4e6lT9N0EnX9lZAowl8iQifNmwb0bw0YMC+43Whzt+feKmzBj0Diu4o2Kq
         uldQayT1Im41ibkuz2zLkEWaUPXIRIYfmQfE8267RdffktEev06sg+Z1YlSTrdTyfXsY
         DxJLofvrLkyJYGr1hOqxAjBNHN+o0uC+kTd64S1fFgQ3PSV4Gi2sNf44dpN7x5gGEhmk
         1W+02eFoH5IUfvjvR5GiLnRemx2yNkJx3kDRkVQJEKLlve+T6dWP6BqciQOiadgu676P
         NDPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si270797ejp.154.2019.04.24.09.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 09:21:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 62DD7AF08;
	Wed, 24 Apr 2019 16:21:03 +0000 (UTC)
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@suse.com,
 rientjes@google.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org__handle_mm_fault
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <a0fa99eb-0efa-25ac-9228-167e89179549@suse.cz>
 <cca0cab8-c1a5-2ea5-0433-964b8166f54a@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <e9feaee4-4276-e672-c852-b64fd8965838@suse.cz>
Date: Wed, 24 Apr 2019 18:17:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <cca0cab8-c1a5-2ea5-0433-964b8166f54a@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/24/19 5:47 PM, Yang Shi wrote:
> 
> 
> On 4/24/19 6:10 AM, Vlastimil Babka wrote:
>> On 4/23/19 6:43 PM, Yang Shi wrote:
>>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
>>> vma") introduced THPeligible bit for processes' smaps. But, when checking
>>> the eligibility for shmem vma, __transparent_hugepage_enabled() is
>>> called to override the result from shmem_huge_enabled().  It may result
>>> in the anonymous vma's THP flag override shmem's.  For example, running a
>>> simple test which create THP for shmem, but with anonymous THP disabled,
>>> when reading the process's smaps, it may show:
>>>
>>> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
>>> Size:               4096 kB
>>> ...
>>> [snip]
>>> ...
>>> ShmemPmdMapped:     4096 kB
>> But how does this happen in the first place?
>> In __handle_mm_fault() we do:
>>
>>          if (pmd_none(*vmf.pmd) && __transparent_hugepage_enabled(vma)) {
>>                  ret = create_huge_pmd(&vmf);
>>                  if (!(ret & VM_FAULT_FALLBACK))
>>                          return ret;
>>
>> And __transparent_hugepage_enabled() checks the global THP settings.
>> If THP is not enabled / is only for madvise and the vma is not madvised,
>> then this should fail, and also khugepaged shouldn't either run at all,
>> or don't do its job for such non-madvised vma.
> 
> If __transparent_hugepage_enabled() returns false, the code will not 
> reach create_huge_pmd() at all. If it returns true, create_huge_pmd() 
> actually will return VM_FAULT_FALLBACK for shmem since shmem doesn't 
> have huge_fault (or pmd_fault in earlier versions) method.
> 
> Then it will get into handle_pte_fault(), finally shmem_fault() is 
> called, which allocates THP by checking some global flag (i.e. 
> VM_NOHUGEPAGE and MMF_DISABLE_THP) and  shmem THP knobs.

Aha, thanks! What a mess...

> 
> 4.8 (the first version has shmem THP merged) behaves exactly in the same 
> way. So, I suspect this may be intended behavior.

Still looks like an oversight to me. And it's inconsistent... it might
fault huge shmem pages when THPs are globally disabled, but khugepaged
is still not running. I think it should just check the global THP flags
as well...

