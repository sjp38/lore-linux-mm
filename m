Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FC14C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:59:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DD62215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:59:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DD62215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B19D66B0266; Wed, 12 Jun 2019 15:59:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC9586B0269; Wed, 12 Jun 2019 15:59:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B8776B026A; Wed, 12 Jun 2019 15:59:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 657616B0266
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:59:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id b24so10416950plz.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 12:59:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=k+H/+pzhDGWnsa/Sm3nmrd0PHH0z2B5f403LPREtH48=;
        b=SnZXxrYp32CexVhDR2B38jGAohkV9FLnbIwQ9IAmKHCWTkGzDMatGH+9VF2P3mI3bS
         Q9Gz6qjYU4ZRfsT1EMjyPEg4HggkW9OxlbfKZbNJetD1pP9lZOYP4ySKsKrFjmwBsBwc
         XpkhQrVo5DJGUzyJZH5YGn1T5uSziJr8itd8mz4uRUAQ/K80gPq3fqIVY2FqEpqUxFQ7
         HT3553/FAByLZ0p10PqEFfs66gDL3zY00quECcBtX5wD3Nhvpj+24bJPMMWjfzgCGEba
         SZDXU0eE71Oz8oUE4JsNC0Qr+aliXO/5b0RvI7T2C6U+CAP/krwpyc8/UisVb4r2kNMW
         1V+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWJik7bXGjMPBZc6m+WLnRv4GzgqK8X20VmPu+dOzVWe7z+1PEL
	5Q2fD++0puVyPVnFL1E4qcNDgK+rmgpZekxWaJYBT27YoN/h/91cRWc18q0NVB5kHilDzZvmySN
	RK7jhN+JqQ+JIJvkQVzso1FOE+jbHv7ynmTmyVwyXTwJa50EKAHoglNRRgftDd3O+ww==
X-Received: by 2002:a17:90a:c481:: with SMTP id j1mr909691pjt.96.1560369584040;
        Wed, 12 Jun 2019 12:59:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzw0INtKlWkqqZZTEa5x3pjungwMuQ0i/uZPifiYqyOC4l9vrYk00iRGbMNiZG9KSIgGkb/
X-Received: by 2002:a17:90a:c481:: with SMTP id j1mr909652pjt.96.1560369583190;
        Wed, 12 Jun 2019 12:59:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560369583; cv=none;
        d=google.com; s=arc-20160816;
        b=RsxgYzQbTsGjgGaHw+d8dawJ5mKB5HJCER5YeRg+qt3OPOAKlJf/qG7O++hRCntgXs
         giHEFwN9oSoThXZgYNh+WGfzFONgDySLZkIsykETf8YBgQMfkcCDB2YxEe33yczkKYI5
         HCtAw9Jc4grAiLH7V8GF4Jx85HFQSg/d3KRN3dq+kmQNF+QkSb6Xig6Had5kQFzxi1rM
         eBCVCBQ+qAhXMn/zNHfrKCHjuAXK8L/2zDNb/79J0DEXXPJOjsvTTm5u63Klri/vEAoV
         UAkAtktMNWkvvbWEiZ6GRRFUPlAROD/wUn/jmse2HccqD3gDQMFiFtujrEPPK3Lqz4TC
         TH+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=k+H/+pzhDGWnsa/Sm3nmrd0PHH0z2B5f403LPREtH48=;
        b=J/yf8uVkEJf0oOpFklhQ+vt0ZphX8kkM56QYY4s0HGk6x01VQNN2+UiVTcfDf1Pjq6
         wV3CPIuiczVxIgH889yPYIl0xeNKMkiszsZxatZohbLPdqYG3xamBrniqqbLsY8ZHbVu
         UR/cWgVAnb53fCe67JO+hsdaPJBVu4o4Fr+m+P28UEq6K5oVkfYAMvxagq/omh8lDzDb
         kDf8rCeNWYLZ+7xpa9HHH9dGTcTreMJLBbsYNZkCoLB3VZJwPRekaJhrRR3A0jM4L7wi
         CFIAaLT+i1n8rb1GhQ6YoWkAUt7hn227B6geRk9jkBgL2J7PLKSGB2ZA9Sl29YRhiDU1
         gnPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id 1si538804pld.6.2019.06.12.12.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 12:59:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R191e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TU03sVe_1560369565;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU03sVe_1560369565)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 13 Jun 2019 03:59:28 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Hugh Dickins <hughd@google.com>
Cc: mhocko@suse.com, vbabka@suse.cz, rientjes@google.com,
 kirill@shutemov.name, kirill.shutemov@linux.intel.com,
 akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
 <alpine.LSU.2.11.1906072008210.3614@eggly.anvils>
 <578b7903-40ef-e616-d700-473713f438c0@linux.alibaba.com>
 <alpine.LSU.2.11.1906121120240.1107@eggly.anvils>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <185ccaa5-c380-f84a-ddbb-b89c8f49445a@linux.alibaba.com>
Date: Wed, 12 Jun 2019 12:59:24 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1906121120240.1107@eggly.anvils>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/12/19 11:44 AM, Hugh Dickins wrote:
> On Mon, 10 Jun 2019, Yang Shi wrote:
>> On 6/7/19 8:58 PM, Hugh Dickins wrote:
>>> Yes, that is correct; and correctly placed. But a little more is needed:
>>> see how mm/memory.c's transhuge_vma_suitable() will only allow a pmd to
>>> be used instead of a pte if the vma offset and size permit. smaps should
>>> not report a shmem vma as THPeligible if its offset or size prevent it.
>>>
>>> And I see that should also be fixed on anon vmas: at present smaps
>>> reports even a 4kB anon vma as THPeligible, which is not right.
>>> Maybe a test like transhuge_vma_suitable() can be added into
>>> transparent_hugepage_enabled(), to handle anon and shmem together.
>>> I say "like transhuge_vma_suitable()", because that function needs
>>> an address, which here you don't have.
>> Thanks for the remind. Since we don't have an address I'm supposed we just
>> need check if the vma's size is big enough or not other than other alignment
>> check.
>>
>> And, I'm wondering whether we could reuse transhuge_vma_suitable() by passing
>> in an impossible address, i.e. -1 since it is not a valid userspace address.
>> It can be used as and indicator that this call is from THPeligible context.
> Perhaps, but sounds like it will abuse and uglify transhuge_vma_suitable()
> just for smaps. Would passing transhuge_vma_suitable() the address
>      ((vma->vm_end & HPAGE_PMD_MASK) - HPAGE_PMD_SIZE)
> give the the correct answer in all cases?

Yes, it looks better.

>
>>> The anon offset situation is interesting: usually anon vm_pgoff is
>>> initialized to fit with its vm_start, so the anon offset check passes;
>>> but I wonder what happens after mremap to a different address - does
>>> transhuge_vma_suitable() then prevent the use of pmds where they could
>>> actually be used? Not a Number#1 priority to investigate or fix here!
>>> but a curiosity someone might want to look into.
>> Will mark on my TODO list.
>>
>>> Even with your changes
>>> ShmemPmdMapped:     4096 kB
>>> THPeligible:    0
>>> will easily be seen: THPeligible reflects whether a huge page can be
>>> allocated and mapped by pmd in that vma; but if something else already
>>> allocated the huge page earlier, it will be mapped by pmd in this vma
>>> if offset and size allow, whatever THPeligible says. We could change
>>> transhuge_vma_suitable() to force ptes in that case, but it would be
>>> a silly change, just to make what smaps shows easier to explain.
>> Where did this come from? From the commit log? If so it is the example for
>> the wrong smap output. If that case really happens, I think we could document
>> it since THPeligible should just show the current status.
> Please read again what I explained there: it's not necessarily an example
> of wrong smaps output, it's reasonable smaps output for a reasonable case.
>
> Yes, maybe Documentation/filesystems/proc.txt should explain "THPeligble"
> a little better - "eligible for allocating THP pages" rather than just
> "eligible for THP pages" would be good enough? we don't want to write
> a book about the various cases.

Yes, I agree.

>
> Oh, and the "THPeligible" output lines up very nicely there in proc.txt:
> could the actual alignment of that 0 or 1 be fixed in smaps itself too?

Sure.

Thanks,
Yang

>
> Thanks,
> Hugh

