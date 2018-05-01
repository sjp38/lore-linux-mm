Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DD6B6B0003
	for <linux-mm@kvack.org>; Tue,  1 May 2018 17:31:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 127-v6so8802495pge.10
        for <linux-mm@kvack.org>; Tue, 01 May 2018 14:31:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f19-v6sor3742504plj.13.2018.05.01.14.31.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 May 2018 14:31:03 -0700 (PDT)
Subject: Re: INFO: task hung in wb_shutdown (2)
References: <94eb2c05b2d83650030568cc8bd9@google.com>
 <e56c1600-8923-dd6b-d065-c2fd2a720404@I-love.SAKURA.ne.jp>
 <43302799-1c50-4cab-b974-9fe1ca584813@I-love.SAKURA.ne.jp>
 <CA+55aFxaa_+uZ=bOVdevcUwG7ncue7O+i06q4Kb=bWACGwCBjQ@mail.gmail.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <bd3e8460-9794-6b57-e7d6-7e18ea34ac0c@kernel.dk>
Date: Tue, 1 May 2018 15:30:59 -0600
MIME-Version: 1.0
In-Reply-To: <CA+55aFxaa_+uZ=bOVdevcUwG7ncue7O+i06q4Kb=bWACGwCBjQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, syzbot+c0cf869505e03bdf1a24@syzkaller.appspotmail.com, christophe.jaillet@wanadoo.fr, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com, zhangweiping@didichuxing.com, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-block <linux-block@vger.kernel.org>

On 5/1/18 10:06 AM, Linus Torvalds wrote:
> On Tue, May 1, 2018 at 3:27 AM Tetsuo Handa <
> penguin-kernel@i-love.sakura.ne.jp> wrote:
> 
>> Can you review this patch? syzbot has hit this bug for nearly 4000 times
> but
>> is still unable to find a reproducer. Therefore, the only way to test
> would be
>> to apply this patch upstream and test whether the problem is solved.
> 
> Looks ok to me, except:
> 
>>>       smp_wmb();
>>>       clear_bit(WB_shutting_down, &wb->state);
>>> +     smp_mb(); /* advised by wake_up_bit() */
>>> +     wake_up_bit(&wb->state, WB_shutting_down);
> 
> This whole sequence really should just be a pattern with a helper function.
> 
> And honestly, the pattern probably *should* be
> 
>      clear_bit_unlock(bit, &mem);
>      smp_mb__after_atomic()
>      wake_up_bit(&mem, bit);
> 
> which looks like it is a bit cleaner wrt memory ordering rules.

Agree, that construct looks saner than introducing a "random"
smp_mb(). As a pattern helper, should probably be introduced
after the fact.

-- 
Jens Axboe
