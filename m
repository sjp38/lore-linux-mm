Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE856B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 17:27:39 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id m184so3154323ith.4
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 14:27:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x21sor1488812itb.111.2018.02.07.14.27.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 14:27:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180207165802.GC25219@hirez.programming.kicks-ass.net>
References: <20180206004903.224390-1-joelaf@google.com> <20180207080740.GH2269@hirez.programming.kicks-ass.net>
 <CAJWu+orvHb_-fSgtO0NqCai3PPc7fAe7LqNLVVhYbT+Wi-oATg@mail.gmail.com> <20180207165802.GC25219@hirez.programming.kicks-ass.net>
From: Joel Fernandes <joelaf@google.com>
Date: Wed, 7 Feb 2018 14:27:37 -0800
Message-ID: <CAJWu+opo+mE-ZAsi3=u8ogUYurVM0_qaHi7keZJ6h0Sfa7oULQ@mail.gmail.com>
Subject: Re: [PATCH RFC] ashmem: Fix lockdep RECLAIM_FS false positive
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, Neil Brown <neilb@suse.com>, Dave Chinner <david@fromorbit.com>

Hi Peter,

On Wed, Feb 7, 2018 at 8:58 AM, Peter Zijlstra <peterz@infradead.org> wrote:
[...]
>
>> Lockdep reports this issue when GFP_FS is infact set, and we enter
>> this path and acquire the lock. So lockdep seems to be doing the right
>> thing however by design it is reporting a false-positive.
>
> So I'm not seeing how its a false positive. fs/inode.c sets a different
> lock class per filesystem type. So recursing on an i_mutex within a
> filesystem does sound dodgy.

But directory inodes and file inodes in the same filesystem share the
same lock class right? All the issues I've seen (both our's and
Neil's) are similar in that a directory inode's lock is held followed
by a RECLAIM_FS allocation, and in parallel to that, memory reclaim
involving the same FS is going on in another thread. In the splat I
shared, during the VFS lookup- the d_alloc is called with an inode's
lock held (I am guessing this the lock of the directory inode which is
locked just before the d_alloc), and in parallel (kswapd or some other
thread) is doing memory reclaim.

>> The real issue is that the lock being acquired is of the same lock
>> class and a different lock instance is acquired under GFP_FS that
>> happens to be of the same class.
>>
>> So the issue seems to me to be:
>> Process A          kswapd
>> ---------          ------
>> acquire i_mutex    Enter RECLAIM_FS
>>
>> Enter RECLAIM_FS   acquire different i_mutex
>
> That's not a false positive, that's a 2 process way of writing i_mutex
> recursion.

Yes, but I mention false positive since the kswapd->ashmem_shrink_scan
path can never acquire the mutex of a directory inode AFAIK. So from
that perspective it seems a false-positive.

>
> What are the rules of acquiring two i_mutexes within a filesystem?
>

I am not fully sure. I am CC'ing Ted and linux-fs-devel as well for
any input on this question.

>> Neil tried to fix this sometime back:
>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg623909.html
>> but it was kind of NAK'ed.
>
> So that got nacked because Neil tried to fix it in the vfs core. Also
> not entirely sure that's the same problem.

Yes, a similar fix was proposed internally here, I would say the
signature of the problem reported there is quite similar (its just
that there its nfsd mentioned as doing the reclaim instead of kswapd).

thanks,

- Joel

[1] https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg623986.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
