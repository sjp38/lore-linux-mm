Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9A36B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 04:46:51 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 73so30000073pfz.11
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 01:46:51 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 68si27981688pff.213.2017.12.29.01.46.49
        for <linux-mm@kvack.org>;
        Fri, 29 Dec 2017 01:46:49 -0800 (PST)
Subject: Re: About the try to remove cross-release feature entirely by Ingo
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R>
 <CAOQ4uxin+OEZrkb_fQvJHP2jU_DBRqC9w7uwcPUDaOYv-MrvXg@mail.gmail.com>
From: Byungchul Park <byungchul.park@lge.com>
Message-ID: <8f67b09c-8f0a-09ed-65b1-4c6658c93ec0@lge.com>
Date: Fri, 29 Dec 2017 18:46:45 +0900
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxin+OEZrkb_fQvJHP2jU_DBRqC9w7uwcPUDaOYv-MrvXg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Dave Chinner <david@fromorbit.com>, Theodore Tso <tytso@mit.edu>, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-block <linux-block@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, kernel-team@lge.com

On 12/29/2017 5:09 PM, Amir Goldstein wrote:
> On Fri, Dec 29, 2017 at 3:47 AM, Byungchul Park <byungchul.park@lge.com> wrote:
>> On Wed, Dec 13, 2017 at 03:24:29PM +0900, Byungchul Park wrote:
>>> Lockdep works, based on the following:
>>>
>>>     (1) Classifying locks properly
>>>     (2) Checking relationship between the classes
>>>
>>> If (1) is not good or (2) is not good, then we
>>> might get false positives.
>>>
>>> For (1), we don't have to classify locks 100%
>>> properly but need as enough as lockdep works.
>>>
>>> For (2), we should have a mechanism w/o
>>> logical defects.
>>>
>>> Cross-release added an additional capacity to
>>> (2) and requires (1) to get more precisely classified.
>>>
>>> Since the current classification level is too low for
>>> cross-release to work, false positives are being
>>> reported frequently with enabling cross-release.
>>> Yes. It's a obvious problem. It needs to be off by
>>> default until the classification is done by the level
>>> that cross-release requires.
>>>
>>> But, the logic (2) is valid and logically true. Please
>>> keep the code, mechanism, and logic.
>>
>> I admit the cross-release feature had introduced several false positives
>> about 4 times(?), maybe. And I suggested roughly 3 ways to solve it. I
>> should have explained each in more detail. The lack might have led some
>> to misunderstand.
>>
>>     (1) The best way: To classify all waiters correctly.
>>
>>        Ultimately the problems should be solved in this way. But it
>>        takes a lot of time so it's not easy to use the way right away.
>>        And I need helps from experts of other sub-systems.
>>
>>        While talking about this way, I made a trouble.. I still believe
>>        that each sub-system expert knows how to solve dependency problems
>>        most, since each has own dependency rule, but it was not about
>>        responsibility. I've never wanted to charge someone else it but me.
>>
>>     (2) The 2nd way: To make cross-release off by default.
>>
>>        At the beginning, I proposed cross-release being off by default.
>>        Honestly, I was happy and did it when Ingo suggested it on by
>>        default once lockdep on. But I shouldn't have done that but kept
>>        it off by default. Cross-release can make some happy but some
>>        unhappy until problems go away through (1) or (2).
>>
>>     (3) The 3rd way: To invalidate waiters making trouble.
>>
>>        Of course, this is not the best. Now that you have already spent
>>        a lot of time to fix original lockdep's problems since lockdep was
>>        introduced in 2006, we don't need to use this way for typical
>>        locks except a few special cases. Lockdep is fairly robust by now.
>>
>>        And I understand you don't want to spend more time to fix
>>        additional problems again. Now that the situation is different
>>        from the time, 2006, it's not too bad to use this way to handle
>>        the issues.
>>
> 
> Purely logically, aren't you missing a 4th option:
> 
>      (4) The 4th way: To validate specific waiters.
> 

Hello,

Thanks for your opinion. I will add my opinion on you.

> Is it not an option for a subsystem to opt-in for cross-release validation
> of specific locks/waiters? This may be a much preferred route for cross-

Yes. I think it can be a good option.

I think we have to choose a better one between (3) and (4) depending
on the following:

    In case that there are few waiters making trouble, it would be
    better to choose (3).

    In case that there are a lot of waiter making trouble, it would be
    better to chosse (4).

I think (3) is better for now because there's only one or two cases
making us hard to handle it. However, if you don't agree, I also
think (4) can be an available option.

> release. I remember seeing a post from a graphic driver developer that
> found cross-release useful for finding bugs in his code.
> 
> For example, many waiters in kernel can be waiting for userspace code,
> so does that mean the cross-release is going to free the world from
> userspace deadlocks as well?? Possibly I am missing something.

I don't see what you are saying exactly.. but cross-release can be
used if we know (a) the spot waiting for an event and (3) the other
spot triggering the event. Please explain it more if I miss something.

> In any way, it seem logical to me that some waiters should particpate
> in lock chain dependencies, while other waiters should break the chain
> to avoid false positives and to avoid protecting against user configurable
> deadlocks (like loop mount over file inside the loop mounted fs).

For example, when we had cross-release enabled, the following chain
was built and false positives were produced:

    link 1: ext4 spin lock class A (in a lower fs) ->
            waiter class B (in submit_bio_wait())

    link 2: waiter class B (in submit_bio_wait()) ->
            ext4 spin lock class A (in an upper fs)

Even though conceptually it should have been "class A in lower fs
!= class A in upper fs", current code registers these two as class A.

So we need to correct the chain like, using (1):

    link 1: ext4 spin lock class A (in a lower fs) ->
            waiter class B (in submit_bio_wait())

    link 2: waiter class B (in submit_bio_wait()) ->
            ext4 spin lock class *C* (in an upper fs)

Or using (3) or (4):

    no link (because waiter class B does not exist anymore)

> And if you agree that this logic claim is correct, than surely, an inclusive
> approach is the best way forward.

I'm also curious about other opinions..

> Cheers,
2> Amir.
> 

-- 
Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
