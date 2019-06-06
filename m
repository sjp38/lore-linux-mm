Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59179C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:59:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B30192089E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 18:59:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B30192089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A08E6B027E; Thu,  6 Jun 2019 14:59:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3514C6B0283; Thu,  6 Jun 2019 14:59:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23F216B028D; Thu,  6 Jun 2019 14:59:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0407F6B027E
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 14:59:44 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id m1so858631iop.1
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 11:59:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=o0kYLjdhrExUrOoW4LG9f3sFa4hNcrSWOLxQkVeQOEg=;
        b=TRp2sEJoZqou+yxigMEcdx+leMSrtc3+7BMWjLUKUZ6UwccR02ELagGGCGZib5Edds
         Axmf6j2+lHLvsO3970qDAMKL43PDH4GwYDzfTmJ41hKznU9CgoSa4ObPSCgleMTeVt9E
         Yqn4EtuNLukAm1DpAW3Y+Bh9hrn1GRsJDehTt/HJz6sx0cRmHAlRh7GxQqz4yoCqG+Pw
         xZZ+r2X4HBDGBRmxx8VfHFdNjxFhI3mFe1OoIyybxEIR8SY4sAvfufgo2GyIUl3zY2Fj
         TDH4AzXvVwpuDqC/Ckr3aPejk4rHf9uwlGbesYBTyy6YE28jwTjSoGWGPVTsHTR9+24e
         BhfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUy1I5H+gJh/ocmfN3xIJ60aNAgL8RXEEHor87eQ7KVfsfL26Il
	VBW8ONOcnASQWCpPI3hyBV00EjAv7RZF4SqzJ6MnoV9iyFpkLQliMxjn7R/OT+DGlJ6qFDmxtUd
	zPtmI7DgN8o1BV+aqagyYWKX99j2u+Nal343Vr3aT1dDwPS92kK360uv9QvJ/sChXKw==
X-Received: by 2002:a02:c80d:: with SMTP id p13mr6402882jao.59.1559847583682;
        Thu, 06 Jun 2019 11:59:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8zL2pU5vy09G8/pj8YzZD4TgjZQk/TMktFXGrkpCWa4ClHkXJx7EXj7Zz7RK3n28V8BEJ
X-Received: by 2002:a02:c80d:: with SMTP id p13mr6402827jao.59.1559847582542;
        Thu, 06 Jun 2019 11:59:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559847582; cv=none;
        d=google.com; s=arc-20160816;
        b=pWJet1sFBeRLNXvcJQR7+1LWXT4i2KtNPI42VljqoF21xfa4h0ihP7PhF8/RE2XEck
         hqHR/xY6OshRvQgVXMw0aEc6QhSWNWuMX9M3/Lidi+vZ3ykrT47Azab5MhLxDAQBqhqA
         i0pPY+J+oO6/nEMb9l9R/Ghq+6cGGS5hFyD63I3RvQkmgNPKlioZ06RRge/K0Vk0nbCF
         23G6hIzbdAss/y1IZjhFdhbXiGz7xAYV6K2pKqwBTqlxqRdz3Ty0rAS7k13b91lGxCYK
         8+we2h6Q7VVohehvYPAi9wPqfCzfWypX2P0l4GUPVyK7cmEJ5DlH5z8fe8r4PbFT7z6Z
         54Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=o0kYLjdhrExUrOoW4LG9f3sFa4hNcrSWOLxQkVeQOEg=;
        b=jzAhLWRFn3yXrHweFoFkkqQ74XrPUSGJdyuS6TThA9ISI4wyKTS486vck6siX73npd
         5E8+pz5HFuVHb51/f80ovBwwjdJ0Vb2Z77ngnXoqQWX7QjDezdiFDP3LnE4Z/3zLC74L
         urTT8UddPdu/WV3eZaFPM/QeORh6TLj1ys8ISNhQCQ8c9NerEVMPmXcI2hMqreSMDKt6
         jDRxl012YRxyqlHYW17lDgLYdNV13AXHV22kqzAboWTWeqXtI73V+cDyEDPEDyiwY8xK
         Ak/PYKzD9fzbPay2otVLgGJ9mSbBb4sv7qw8H1+XY5jCQs2wOlwQy1EbQzxLHv5wSrjM
         ztJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id c26si2306337jaa.104.2019.06.06.11.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 11:59:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TTau0rq_1559847565;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TTau0rq_1559847565)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 07 Jun 2019 02:59:28 +0800
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
From: Yang Shi <yang.shi@linux.alibaba.com>
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
 <ec8a65c7-9b0b-9342-4854-46c732c99390@linux.alibaba.com>
Message-ID: <217fc290-5800-31de-7d46-aa5c0f7b1c75@linux.alibaba.com>
Date: Thu, 6 Jun 2019 11:59:21 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <ec8a65c7-9b0b-9342-4854-46c732c99390@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/7/19 10:10 AM, Yang Shi wrote:
>
>
> On 5/7/19 3:47 AM, Michal Hocko wrote:
>> [Hmm, I thought, Hugh was CCed]
>>
>> On Mon 06-05-19 16:37:42, Yang Shi wrote:
>>>
>>> On 4/28/19 12:13 PM, Yang Shi wrote:
>>>>
>>>> On 4/23/19 10:52 AM, Michal Hocko wrote:
>>>>> On Wed 24-04-19 00:43:01, Yang Shi wrote:
>>>>>> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility
>>>>>> for each
>>>>>> vma") introduced THPeligible bit for processes' smaps. But, when
>>>>>> checking
>>>>>> the eligibility for shmem vma, __transparent_hugepage_enabled() is
>>>>>> called to override the result from shmem_huge_enabled().  It may 
>>>>>> result
>>>>>> in the anonymous vma's THP flag override shmem's.  For example,
>>>>>> running a
>>>>>> simple test which create THP for shmem, but with anonymous THP
>>>>>> disabled,
>>>>>> when reading the process's smaps, it may show:
>>>>>>
>>>>>> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
>>>>>> Size:               4096 kB
>>>>>> ...
>>>>>> [snip]
>>>>>> ...
>>>>>> ShmemPmdMapped:     4096 kB
>>>>>> ...
>>>>>> [snip]
>>>>>> ...
>>>>>> THPeligible:    0
>>>>>>
>>>>>> And, /proc/meminfo does show THP allocated and PMD mapped too:
>>>>>>
>>>>>> ShmemHugePages:     4096 kB
>>>>>> ShmemPmdMapped:     4096 kB
>>>>>>
>>>>>> This doesn't make too much sense.  The anonymous THP flag should not
>>>>>> intervene shmem THP.  Calling shmem_huge_enabled() with checking
>>>>>> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
>>>>>> dax vma check since we already checked if the vma is shmem already.
>>>>> Kirill, can we get a confirmation that this is really intended 
>>>>> behavior
>>>>> rather than an omission please? Is this documented? What is a global
>>>>> knob to simply disable THP system wise?
>>>> Hi Kirill,
>>>>
>>>> Ping. Any comment?
>>> Talked with Kirill at LSFMM, it sounds this is kind of intended 
>>> behavior
>>> according to him. But, we all agree it looks inconsistent.
>>>
>>> So, we may have two options:
>>>      - Just fix the false negative issue as what the patch does
>>>      - Change the behavior to make it more consistent
>>>
>>> I'm not sure whether anyone relies on the behavior explicitly or 
>>> implicitly
>>> or not.
>> Well, I would be certainly more happy with a more consistent behavior.
>> Talked to Hugh at LSFMM about this and he finds treating shmem objects
>> separately from the anonymous memory. And that is already the case
>> partially when each mount point might have its own setup. So the primary
>> question is whether we need a one global knob to controll all THP
>> allocations. One argument to have that is that it might be helpful to
>> for an admin to simply disable source of THP at a single place rather
>> than crawling over all shmem mount points and remount them. Especially
>> in environments where shmem points are mounted in a container by a
>> non-root. Why would somebody wanted something like that? One example
>> would be to temporarily workaround high order allocations issues which
>> we have seen non trivial amount of in the past and we are likely not at
>> the end of the tunel.
>
> Shmem has a global control for such use. Setting shmem_enabled to 
> "force" or "deny" would enable or disable THP for shmem globally, 
> including non-fs objects, i.e. memfd, SYS V shmem, etc.
>
>>
>> That being said I would be in favor of treating the global sysfs knob to
>> be global for all THP allocations. I will not push back on that if there
>> is a general consensus that shmem and fs in general are a different
>> class of objects and a single global control is not desirable for
>> whatever reasons.
>
> OK, we need more inputs from Kirill, Hugh and other folks.

[Forgot cc to mailing lists]

Hi guys,

How should we move forward for this one? Make the sysfs knob 
(/sys/kernel/mm/transparent_hugepage/enabled) to be global for both 
anonymous and tmpfs? Or just treat shmem objects separately from anon 
memory then fix the false-negative of THP eligibility by this patch?

>
>>
>> Kirill, Hugh othe folks?
>

