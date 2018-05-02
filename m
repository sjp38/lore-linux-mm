Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE40C6B0003
	for <linux-mm@kvack.org>; Wed,  2 May 2018 19:02:23 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id g26-v6so5175949lfb.20
        for <linux-mm@kvack.org>; Wed, 02 May 2018 16:02:23 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y8-v6sor2450996lfy.43.2018.05.02.16.02.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 16:02:21 -0700 (PDT)
Subject: Re: [PATCH 0/3 v2] linux-next: mm: Track genalloc allocations
References: <20180502010522.28767-1-igor.stoppa@huawei.com>
 <20180502145044.373c268eeaaa9022b99f9191@linux-foundation.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <e0f32b09-550d-5384-7bf0-629f5933c148@gmail.com>
Date: Thu, 3 May 2018 03:02:19 +0400
MIME-Version: 1.0
In-Reply-To: <20180502145044.373c268eeaaa9022b99f9191@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, keescook@chromium.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org, willy@infradead.org, labbott@redhat.com, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com



On 03/05/18 01:50, Andrew Morton wrote:
> On Wed,  2 May 2018 05:05:19 +0400 Igor Stoppa <igor.stoppa@gmail.com> wrote:
> 
>> This patchset was created as part of an older version of pmalloc, however
>> it has value per-se, as it hardens the memory management for the generic
>> allocator genalloc.
>>
>> Genalloc does not currently track the size of the allocations it hands
>> out.
>>
>> Either by mistake, or due to an attack, it is possible that more memory
>> than what was initially allocated is freed, leaving behind dangling
>> pointers, ready for an use-after-free attack.
>>
>> With this patch, genalloc becomes capable of tracking the size of each
>> allocation it has handed out, when it's time to free it.
>>
>> It can either verify that the size received is correct, when free is
>> invoked, or it can decide autonomously how much memory to free, if the
>> value received for the size parameter is 0.
>>
>> These patches are proposed for beign merged into linux-next, to verify
>> that they do not introduce regressions, by comparing the value received
>> from the callers of the free function with the internal tracking.
>>
>> For this reason, the patchset does not contain the removal of the size
>> parameter from users of the free() function.
>>
>> Later on, the "size" parameter can be dropped, and each caller can be
>> adjusted accordingly.
>>
>> However, I do not have access to most of the HW required for confirming
>> that all of its users are not negatively affected.
>> This is where I believe having the patches in linux-next would help to
>> coordinate with the maintaiers of the code that uses gen_alloc.
>>
>> Since there were comments about the (lack-of) efficiency introduced by
>> this patchset, I have added some more explanations and calculations to the
>> description of the first patch, the one adding the bitmap.
>> My conclusion is that this patch should not cause any major perfomance
>> problem.
>>
>> Regarding the possibility of completely changing genalloc into some other
>> type of allocator, I think it should not be a showstopper for this
>> patchset, which aims to plug a security hole in genalloc, without
>> introducing any major regression.
>>
>> The security flaw is clear and present, while the benefit of introducing a
>> new allocator is not clear, at least for the current users of genalloc.
>>
>> And anyway the users of genalloc should be fixed to not pass any size
>> parameter, which can be done after this patch is merged.
>>
>> A newer, more efficient allocator will still benefit from not receiving a
>> spurious parameter (size), when freeing memory.
>>
>> ...
>>
>>   Documentation/core-api/genalloc.rst |   4 +
>>   include/linux/genalloc.h            | 112 +++---
>>   lib/Kconfig.debug                   |  23 ++
>>   lib/Makefile                        |   1 +
>>   lib/genalloc.c                      | 742 ++++++++++++++++++++++++++----------
>>   lib/test_genalloc.c                 | 419 ++++++++++++++++++++
> 
> That's a big patch,

True, but I am afraid I do not see how to split it further without 
braking bisection.

  and I'm having trouble believing that it's
> justified?  We're trying to reduce the harm in bugs (none of which are
> known to exist) in a small number of drivers to avoid exploits, none of
> which are known to exist and which may not even be possible.

Should I create one, to justify the patch?
Maybe, what we are really discussing if security should be reactive or 
preventive. And what amount of extra complexity is acceptable, without a 
current, present threat that has already materialized.

My personal take is, if I see something that I think I could exploit, 
most likely those who do write exploits for a (really well paid) living 
can do much more harm than I can even think of.

> Or something like that.  Perhaps all this is taking defensiveness a bit
> too far?

My main goal was to remove the "size" parameter from the free() call, 
without introducing noticeable performance regression.

Is that a reasonable endeavor?

After all, we have IOMMUs also for preventing similar types of attack.

The current users of genalloc are primarily:
* SRAM memory managers, which are attractive because they are used for 
example to store system wide state inbetween transitions to off, when 
some components (like the MMU) might not be even active.

* DMA page allocators, another nice side channel, where a DMA controller 
could be used to completely side-step the type of protection enforced by 
the MMU

> And a bitmap is a pretty crappy way of managing memory anyway, surely?

I did not put it there :-P
It also depends what one needs it for and if it's good enough.
Or if something better is justified.

> If this code is indeed performance-sensitive then perhaps a
> reimplementation with some standard textbook allocator(?) is warranted?

But, is it really performance sensitive?

I might be wrong, but I think this change that I am proposing is not 
really affecting performance.

I did get a question/comment about performance implications.

I have explained why I think my patches are not adding any real 
performance problem, in the comment of the patch that does the actual 
change to the bitmap, providing numbers that I think represent the 
current real use cases.

I was hoping in a reply to that. And a review of the code, also from 
performance perspective.

If I am making some wrong assumption or some mistake, I'll be the first 
one to acknowledge it, once it is pointed out, however I have not 
received specific comments about *why* this patch is either bad or 
wrong, besides "bitmaps are crappy".

 From my POV, providing a better allocator would be nice, but I do not 
have time for it, right now.

And I am not even sure if it would make any real difference, with the 
current users of genalloc.

A new allocator would be a great thing for intensive allocation-release 
patterns, with lots of fragmentation.

The users of genalloc do not do that. If they did, I suspect someone 
else would have already come up with a patch to replace genalloc.

If a new allocator is being considered for the kernel, what I found to 
be possibly the best available at the moment is jemalloc [jemalloc.net]

It might even be better than other allocators currently in use in the 
kernel. But it would really need its own project, imho.
It shouldn't be done as side activity of kernel hardening.

Coming back to genalloc, what I think *can* be said about it, is that:
- it's risky because it blindly relies on freeing what its callers asks.
- its current users probably wouldn't benefit from a better allocator
- hardening the API, provided that there is no performance regression, 
is a separate activity from rewriting the implementation

Maybe genalloc should be renamed to low_frequency_alloc :-P

--
igor
