Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFF556B0003
	for <linux-mm@kvack.org>; Sat, 30 Jun 2018 00:26:35 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f5-v6so6077629plf.18
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 21:26:35 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id m3-v6si11277947plt.71.2018.06.29.21.26.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 21:26:34 -0700 (PDT)
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180629183501.9e30c26135f11853245c56c7@linux-foundation.org>
 <084aeccb-2c54-2299-8bf0-29a10cc0186e@linux.alibaba.com>
 <20180629201547.5322cfc4b52d19a0443daec2@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ce2f93d3-fe0e-89c2-5465-94cfa974f1ea@linux.alibaba.com>
Date: Fri, 29 Jun 2018 21:26:23 -0700
MIME-Version: 1.0
In-Reply-To: <20180629201547.5322cfc4b52d19a0443daec2@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org



On 6/29/18 8:15 PM, Andrew Morton wrote:
> On Fri, 29 Jun 2018 19:28:15 -0700 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>>
>>> we're adding a bunch of code to 32-bit kernels which will never be
>>> executed.
>>>
>>> I'm thinking it would be better to be much more explicit with "#ifdef
>>> CONFIG_64BIT" in this code, rather than relying upon the above magic.
>>>
>>> But I tend to think that the fact that we haven't solved anything on
>>> locked vmas or on uprobed mappings is a shostopper for the whole
>>> approach :(
>> I agree it is not that perfect. But, it still could improve the most use
>> cases.
> Well, those unaddressed usecases will need to be fixed at some point.

Yes, definitely.

> What's our plan for that?

As I mentioned in the earlier email, locked and hugetlb cases might be 
able to be solved by separating vm_flags update and actual unmap. I will 
look into it further later.

 From my point of view, uprobe mapping sounds not that vital.

>
> Would one of your earlier designs have addressed all usecases?  I
> expect the dumb unmap-a-little-bit-at-a-time approach would have?

Yes. The v1 design does unmap with holding write map_sem. So, the 
vm_flags update is not a problem.

Thanks,
Yang

>
>> For the locked vmas and hugetlb vmas, unmapping operations need modify
>> vm_flags. But, I'm wondering we might be able to separate unmap and
>> vm_flags update. Because we know they will be unmapped right away, the
>> vm_flags might be able to be updated in write mmap_sem critical section
>> before the actual unmap is called or after it. This is just off the top
>> of my head.
>>
>> For uprobed mappings, I'm not sure how vital it is to this case.
>>
>> Thanks,
>> Yang
>>
