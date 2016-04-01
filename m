Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f172.google.com (mail-yw0-f172.google.com [209.85.161.172])
	by kanga.kvack.org (Postfix) with ESMTP id 620976B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 20:21:12 -0400 (EDT)
Received: by mail-yw0-f172.google.com with SMTP id g3so122830598ywa.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 17:21:12 -0700 (PDT)
Received: from mail-yw0-x232.google.com (mail-yw0-x232.google.com. [2607:f8b0:4002:c05::232])
        by mx.google.com with ESMTPS id b20si3229011ywe.369.2016.03.31.17.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 17:21:11 -0700 (PDT)
Received: by mail-yw0-x232.google.com with SMTP id g3so122829995ywa.3
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 17:21:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56EFB486.2090501@hpe.com>
References: <1456496467-14247-1-git-send-email-juerg.haefliger@hpe.com>
	<56D4FA15.9060700@gmail.com>
	<56EFB486.2090501@hpe.com>
Date: Fri, 1 Apr 2016 11:21:11 +1100
Message-ID: <CAKTCnzmCiBM+Y4ndCBErrdHA+8VJ+q9reQzEoToYkcEteUZnVw@mail.gmail.com>
Subject: Re: [RFC PATCH] Add support for eXclusive Page Frame Ownership (XPFO)
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juerg Haefliger <juerg.haefliger@hpe.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, vpk@cs.brown.edu

On Mon, Mar 21, 2016 at 7:44 PM, Juerg Haefliger
<juerg.haefliger@hpe.com> wrote:
> Hi Balbir,
>
> Apologies for the slow reply.
>
No problem, I lost this in my inbox as well due to the reply latency.
>
> On 03/01/2016 03:10 AM, Balbir Singh wrote:
>>
>>
>> On 27/02/16 01:21, Juerg Haefliger wrote:
>>> This patch adds support for XPFO which protects against 'ret2dir' kernel
>>> attacks. The basic idea is to enforce exclusive ownership of page frames
>>> by either the kernel or userland, unless explicitly requested by the
>>> kernel. Whenever a page destined for userland is allocated, it is
>>> unmapped from physmap. When such a page is reclaimed from userland, it is
>>> mapped back to physmap.
>> physmap == xen physmap? Please clarify
>
> No, it's not XEN related. I might have the terminology wrong. Physmap is what
> the original authors used for describing <quote> a large, contiguous virtual
> memory region inside kernel address space that contains a direct mapping of part
> or all (depending on the architecture) physical memory. </quote>
>
Thanks for clarifying
>
>>> Mapping/unmapping from physmap is accomplished by modifying the PTE
>>> permission bits to allow/disallow access to the page.
>>>
>>> Additional fields are added to the page struct for XPFO housekeeping.
>>> Specifically a flags field to distinguish user vs. kernel pages, a
>>> reference counter to track physmap map/unmap operations and a lock to
>>> protect the XPFO fields.
>>>
>>> Known issues/limitations:
>>>   - Only supported on x86-64.
>> Is it due to lack of porting or a design limitation?
>
> Lack of porting. Support for other architectures will come later.
>
OK
>
>>>   - Only supports 4k pages.
>>>   - Adds additional data to the page struct.
>>>   - There are most likely some additional and legitimate uses cases where
>>>     the kernel needs to access userspace. Those need to be identified and
>>>     made XPFO-aware.
>> Why not build an audit mode for it?
>
> Can you elaborate what you mean by this?
>
What I meant is when the kernel needs to access userspace and XPFO is
not aware of it
and is going to block it, write to a log/trace buffer so that it can
be audited for correctness

>
>>>   - There's a performance impact if XPFO is turned on. Per the paper
>>>     referenced below it's in the 1-3% ballpark. More performance testing
>>>     wouldn't hurt. What tests to run though?
>>>
>>> Reference paper by the original patch authors:
>>>   http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf
>>>
>>> Suggested-by: Vasileios P. Kemerlis <vpk@cs.brown.edu>
>>> Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
>> This patch needs to be broken down into smaller patches - a series
>
> Agreed.
>

I think it will be good to describe what is XPFO aware

1. How are device mmap'd shared between kernel/user covered?
2. How is copy_from/to_user covered?
3. How is vdso covered?
4. More...


Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
