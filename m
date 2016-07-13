Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id C2E346B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 01:19:51 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so64484556pap.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 22:19:51 -0700 (PDT)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id ot9si2192844pac.91.2016.07.12.22.19.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 22:19:50 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1468299403-27954-1-git-send-email-zhongjiang@huawei.com>
	<87poqi3muo.fsf@x220.int.ebiederm.org> <5785BEA6.2060404@huawei.com>
Date: Wed, 13 Jul 2016 00:07:18 -0500
In-Reply-To: <5785BEA6.2060404@huawei.com> (zhong jiang's message of "Wed, 13
	Jul 2016 12:08:06 +0800")
Message-ID: <87lh16unw9.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 1/2] kexec: remove unnecessary unusable_pages
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: dyoung@redhat.com, horms@verge.net.au, vgoyal@redhat.com, yinghai@kernel.org, akpm@linux-foundation.org, kexec@lists.infradead.org, linux-mm@kvack.org

zhong jiang <zhongjiang@huawei.com> writes:

> On 2016/7/12 23:19, Eric W. Biederman wrote:
>> zhongjiang <zhongjiang@huawei.com> writes:
>>
>>> From: zhong jiang <zhongjiang@huawei.com>
>>>
>>> In general, kexec alloc pages from buddy system, it cannot exceed
>>> the physical address in the system.
>>>
>>> The patch just remove this unnecessary code, no functional change.
>> On 32bit systems with highmem support kexec can very easily receive a
>> page from the buddy allocator that can exceed 4GiB.  This doesn't show
>> up on 64bit systems as typically the memory limits are less than the
>> address space.  But this code is very necessary on some systems and
>> removing it is not ok.
>>
>> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>
>   This viewpoint is as opposed to me,  32bit systems architectural decide it can not
>   access exceed 4GiB whether the highmem or not.   but there is one exception, 
>   when PAE enable, its physical address should be extended to 36,  new paging  mechanism
>   established for it.  therefore, the  page from the buddy allocator
>   can exceed 4GiB.

Exactly.  And I was dealing with PAE systems in 2001 or so with > 4GiB
of RAM.  Which is where the unusable_pages work comes from.

Other architectures such as ARM also followed a similar path, so
it isn't just x86 that has 32bit systems with > 32 address lines.

>   moreover,  on 32bit systems I can not understand why KEXEC_SOURCE_MEMORY_LIMIT
>   is defined to -1UL. therefore, kimge_aloc_page allocate page will always add to unusable_pages.

-1UL is a short way of writing 0xffffffffUL  Which is as close as you
can get to writing 0x100000000UL in 32bits.

kimage_alloc_page won't always add to unusable_pages as there is memory
below 4GiB but it isn't easily found so there may temporarily be a
memory shortage, as it allocates it's way there.  Unfortunately whenever
I have looked there are memory zones that line up with the memory the
kexec is looking for.  So it does a little bit of a weird dance to get
the memory it needs and to discard the memory it can't use.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
