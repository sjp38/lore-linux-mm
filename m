Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4E1D6B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 21:29:03 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id n70so2619972ywd.20
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 18:29:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w22sor1110107ywg.155.2018.02.07.18.29.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 18:29:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87k1vomi74.fsf@notabene.neil.brown.name>
References: <20180206004903.224390-1-joelaf@google.com> <20180207080740.GH2269@hirez.programming.kicks-ass.net>
 <CAJWu+orvHb_-fSgtO0NqCai3PPc7fAe7LqNLVVhYbT+Wi-oATg@mail.gmail.com>
 <20180207165802.GC25219@hirez.programming.kicks-ass.net> <CAJWu+opo+mE-ZAsi3=u8ogUYurVM0_qaHi7keZJ6h0Sfa7oULQ@mail.gmail.com>
 <87k1vomi74.fsf@notabene.neil.brown.name>
From: Joel Fernandes <joelaf@google.com>
Date: Wed, 7 Feb 2018 18:29:01 -0800
Message-ID: <CAJWu+orVE-mnyFJZv6MjP4QJizv6onc0QVs19QR3XH==7hzLYQ@mail.gmail.com>
Subject: Re: [PATCH RFC] ashmem: Fix lockdep RECLAIM_FS false positive
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>

On Wed, Feb 7, 2018 at 4:35 PM, NeilBrown <neilb@suse.com> wrote:
>> On Wed, Feb 7, 2018 at 8:58 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>> [...]
>>>
>>>> Lockdep reports this issue when GFP_FS is infact set, and we enter
>>>> this path and acquire the lock. So lockdep seems to be doing the right
>>>> thing however by design it is reporting a false-positive.
>>>
>>> So I'm not seeing how its a false positive. fs/inode.c sets a different
>>> lock class per filesystem type. So recursing on an i_mutex within a
>>> filesystem does sound dodgy.
>>
>> But directory inodes and file inodes in the same filesystem share the
>> same lock class right?
>
> Not since v2.6.24
> Commit: 14358e6ddaed ("lockdep: annotate dir vs file i_mutex")
>
> You were using 4.9.60. so they should be separate....
>
> Maybe shmem_get_inode() needs to call unlock_new_inode() or just
> lockdep_annotate_inode_mutex_key() after inode_init_owner().
>
> Maybe inode_init_owner() should call lockdep_annotate_inode_mutex_key()
> directly.

Thanks for the ideas! I will test lockdep_annotate_inode_mutex_key
after inode_init_owner in shmem and let you know if the issue goes
away. It seems hugetlbfs does this too (I think for similar reasons).

- Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
