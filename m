Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id C88036B026E
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 03:09:07 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id b93so5024367ybi.13
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 00:09:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a17sor10031106ybm.13.2017.12.29.00.09.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Dec 2017 00:09:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171229014736.GA10341@X58A-UD3R>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171229014736.GA10341@X58A-UD3R>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 29 Dec 2017 10:09:05 +0200
Message-ID: <CAOQ4uxin+OEZrkb_fQvJHP2jU_DBRqC9w7uwcPUDaOYv-MrvXg@mail.gmail.com>
Subject: Re: About the try to remove cross-release feature entirely by Ingo
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Byungchul Park <max.byungchul.park@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Dave Chinner <david@fromorbit.com>, Theodore Tso <tytso@mit.edu>, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-block <linux-block@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, kernel-team@lge.com

On Fri, Dec 29, 2017 at 3:47 AM, Byungchul Park <byungchul.park@lge.com> wrote:
> On Wed, Dec 13, 2017 at 03:24:29PM +0900, Byungchul Park wrote:
>> Lockdep works, based on the following:
>>
>>    (1) Classifying locks properly
>>    (2) Checking relationship between the classes
>>
>> If (1) is not good or (2) is not good, then we
>> might get false positives.
>>
>> For (1), we don't have to classify locks 100%
>> properly but need as enough as lockdep works.
>>
>> For (2), we should have a mechanism w/o
>> logical defects.
>>
>> Cross-release added an additional capacity to
>> (2) and requires (1) to get more precisely classified.
>>
>> Since the current classification level is too low for
>> cross-release to work, false positives are being
>> reported frequently with enabling cross-release.
>> Yes. It's a obvious problem. It needs to be off by
>> default until the classification is done by the level
>> that cross-release requires.
>>
>> But, the logic (2) is valid and logically true. Please
>> keep the code, mechanism, and logic.
>
> I admit the cross-release feature had introduced several false positives
> about 4 times(?), maybe. And I suggested roughly 3 ways to solve it. I
> should have explained each in more detail. The lack might have led some
> to misunderstand.
>
>    (1) The best way: To classify all waiters correctly.
>
>       Ultimately the problems should be solved in this way. But it
>       takes a lot of time so it's not easy to use the way right away.
>       And I need helps from experts of other sub-systems.
>
>       While talking about this way, I made a trouble.. I still believe
>       that each sub-system expert knows how to solve dependency problems
>       most, since each has own dependency rule, but it was not about
>       responsibility. I've never wanted to charge someone else it but me.
>
>    (2) The 2nd way: To make cross-release off by default.
>
>       At the beginning, I proposed cross-release being off by default.
>       Honestly, I was happy and did it when Ingo suggested it on by
>       default once lockdep on. But I shouldn't have done that but kept
>       it off by default. Cross-release can make some happy but some
>       unhappy until problems go away through (1) or (2).
>
>    (3) The 3rd way: To invalidate waiters making trouble.
>
>       Of course, this is not the best. Now that you have already spent
>       a lot of time to fix original lockdep's problems since lockdep was
>       introduced in 2006, we don't need to use this way for typical
>       locks except a few special cases. Lockdep is fairly robust by now.
>
>       And I understand you don't want to spend more time to fix
>       additional problems again. Now that the situation is different
>       from the time, 2006, it's not too bad to use this way to handle
>       the issues.
>

Purely logically, aren't you missing a 4th option:

    (4) The 4th way: To validate specific waiters.

Is it not an option for a subsystem to opt-in for cross-release validation
of specific locks/waiters? This may be a much preferred route for cross-
release. I remember seeing a post from a graphic driver developer that
found cross-release useful for finding bugs in his code.

For example, many waiters in kernel can be waiting for userspace code,
so does that mean the cross-release is going to free the world from
userspace deadlocks as well?? Possibly I am missing something.

In any way, it seem logical to me that some waiters should particpate
in lock chain dependencies, while other waiters should break the chain
to avoid false positives and to avoid protecting against user configurable
deadlocks (like loop mount over file inside the loop mounted fs).
And if you agree that this logic claim is correct, than surely, an inclusive
approach is the best way forward.

Cheers,
Amir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
