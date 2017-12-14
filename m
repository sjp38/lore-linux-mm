Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98D396B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 00:02:02 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id q62so1117633lfg.5
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 21:02:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t3sor600462lfd.1.2017.12.13.21.02.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 21:02:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171213104617.7lffucjhaa6xb7lp@gmail.com>
References: <CANrsvRPQcWz-p_3TYfNf+Waek3bcNNPniXhFzyyS=7qbCqzGyg@mail.gmail.com>
 <20171213104617.7lffucjhaa6xb7lp@gmail.com>
From: Byungchul Park <max.byungchul.park@gmail.com>
Date: Thu, 14 Dec 2017 14:01:59 +0900
Message-ID: <CANrsvRPuhPyh1nFnzdYj8ph7e1FQRw_W_WN2a1tm9fzpAYks4g@mail.gmail.com>
Subject: Re: [PATCH] locking/lockdep: Remove the cross-release locking checks
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, david@fromorbit.com, Theodore Ts'o <tytso@mit.edu>, willy@infradead.org, Linus Torvalds <torvalds@linux-foundation.org>, Amir Goldstein <amir73il@gmail.com>, byungchul.park@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, oleg@redhat.com

On Wed, Dec 13, 2017 at 7:46 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Byungchul Park <max.byungchul.park@gmail.com> wrote:
>
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
> Just to give a full context to everyone: the patch that removes the cross-release
> locking checks was Cc:-ed to lkml, I've attached the patch below again.
>
> In general, as described in the changelog, the cross-release checks were
> historically just too painful (first they were too slow, and they also had a lot
> of false positives), and today, 4 months after its introduction, the cross-release
> checks *still* produce numerous false positives, especially in the filesystem
> space, but the continuous-integration testing folks were still having trouble with
> kthread locking patterns causing false positives:

I admit false positives are the main problem, that should be solved.

I'm going willingly to try my best to solve that. However, as you may
know through introduction of lockdep, it's not something that I can
do easily and shortly on my own. It need take time to annotate
properly to avoid false positives.

>   https://bugs.freedesktop.org/show_bug.cgi?id=103950
>
> which were resulting in two bad reactions:
>
>  - turning off lockdep
>
>  - writing patches that uglified unrelated subsystems

I can't give you a solution at the moment but it's something we
think more so that we classify locks properly and not uglify them.

Even without cross-release, once we start to add lock_acquire() in
submit_bio_wait() in the ugly way to consider wait_for_completion()
someday, we would face this problem again. It's not an easy problem,
however, it's worth trying.

> So while I appreciate the fixes that resulted from running cross-release, there's
> still numerous false positives, months after its interaction, which is
> unacceptable. For us to have this feature it has to have roughly similar qualities
> as compiler warnings:
>
>  - there's a "zero false positive warnings" policy

It's almost impossible... but need time. I wonder if lockdep did at the
beginning. If I can, I want to fix false positive as many as possible by
myself. But, unluckily it does not happen in my machine. I want to get
informed from others, keeping it in mainline tree.

>  - plus any widespread changes to avoid warnings has to improve the code,
>    not make it uglier.

Agree.

> Lockdep itself is a following that policy: the default state is that it produces
> no warnings upstream, and any annotations added to unrelated code documents the
> locking hierarchies.
>
> While technically we could keep the cross-release checking code upstream and turn
> it off by default via the Kconfig switch, I'm not a big believer in such a policy
> for complex debugging code:
>
>  - We already did that for v4.14, two months ago:
>
>      b483cf3bc249: locking/lockdep: Disable cross-release features for now

The main reason disabling it was "performance regression".

>
>    ... and re-enabled it for v4.15 - but the false positives are still not fixed.

Right. But, all false positives cannot be fixed in a short period. We need
time to annotate them one by one.

>  - either the cross-release checking code can be fixed and then having it off by

It's not a problem of cross-release checking code. The way I have to fix it
should be to add additional annotation or change the way to assign lock
classes.

>    default is just wrong, because we can apply the fixed code again once it's
>    fixed.
>
>  - or it cannot be fixed (or we don't have the manpower/interest to fix it),
>    in which case having it off is only delaying the inevitable.

The more precisely assigning lock classes, the more false positives
would be getting fixed. It's not something messing it as time goes.

> In any case, for v4.15 it's clear that the false positives are too numerous.
>
> Thanks,
>
>         Ingo
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
