Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 562F16B0008
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 22:28:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d4-v6so5374486pfn.9
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 19:28:39 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id y16-v6si10032939pfn.111.2018.06.29.19.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 19:28:38 -0700 (PDT)
Subject: Re: [RFC v3 PATCH 4/5] mm: mmap: zap pages with read mmap_sem for
 large mapping
References: <1530311985-31251-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530311985-31251-5-git-send-email-yang.shi@linux.alibaba.com>
 <20180629183501.9e30c26135f11853245c56c7@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <084aeccb-2c54-2299-8bf0-29a10cc0186e@linux.alibaba.com>
Date: Fri, 29 Jun 2018 19:28:15 -0700
MIME-Version: 1.0
In-Reply-To: <20180629183501.9e30c26135f11853245c56c7@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, peterz@infradead.org, mingo@redhat.com, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, tglx@linutronix.de, hpa@zytor.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org



On 6/29/18 6:35 PM, Andrew Morton wrote:
> On Sat, 30 Jun 2018 06:39:44 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>
> And...
>
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 87dcf83..d61e08b 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2763,6 +2763,128 @@ static int munmap_lookup_vma(struct mm_struct *mm, struct vm_area_struct **vma,
>>   	return 1;
>>   }
>>   
>> +/* Consider PUD size or 1GB mapping as large mapping */
>> +#ifdef HPAGE_PUD_SIZE
>> +#define LARGE_MAP_THRESH	HPAGE_PUD_SIZE
>> +#else
>> +#define LARGE_MAP_THRESH	(1 * 1024 * 1024 * 1024)
>> +#endif
> So this assumes that 32-bit machines cannot have 1GB mappings (fair
> enough) and this is the sole means by which we avoid falling into the
> "len >= LARGE_MAP_THRESH" codepath, which will behave very badly, at
> least because for such machines, VM_DEAD is zero.
>
> This is rather ugly and fragile.  And, I guess, explains why we can't
> give all mappings this treatment: 32-bit machines can't do it.  And
> we're adding a bunch of code to 32-bit kernels which will never be
> executed.
>
> I'm thinking it would be better to be much more explicit with "#ifdef
> CONFIG_64BIT" in this code, rather than relying upon the above magic.
>
> But I tend to think that the fact that we haven't solved anything on
> locked vmas or on uprobed mappings is a shostopper for the whole
> approach :(

I agree it is not that perfect. But, it still could improve the most use 
cases.

For the locked vmas and hugetlb vmas, unmapping operations need modify 
vm_flags. But, I'm wondering we might be able to separate unmap and 
vm_flags update. Because we know they will be unmapped right away, the 
vm_flags might be able to be updated in write mmap_sem critical section 
before the actual unmap is called or after it. This is just off the top 
of my head.

For uprobed mappings, I'm not sure how vital it is to this case.

Thanks,
Yang

>
