Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D8A008E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 13:22:55 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k203so7048943qke.2
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 10:22:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n16si1112722qtr.77.2019.01.09.10.22.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 10:22:54 -0800 (PST)
Subject: Re: [PATCH] lockdep: Add debug printk() for downgrade_write()
 warning.
References: <1546771139-9349-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <e1a38e21-d5fe-dee3-7081-bc1a12965a68@i-love.sakura.ne.jp>
 <20190106201941.49f6dc4a4d2e9d15b575f88a@linux-foundation.org>
 <CACT4Y+Y=V-yRQN6YV_wXT0gejbQKTtUu7wrRmuPVojaVv6NFsQ@mail.gmail.com>
 <162036ee-81f1-36b1-7658-15a5f98c7d29@i-love.sakura.ne.jp>
From: Waiman Long <longman@redhat.com>
Message-ID: <2102acfa-72c1-6540-a434-90eea26aa732@redhat.com>
Date: Wed, 9 Jan 2019 13:22:52 -0500
MIME-Version: 1.0
In-Reply-To: <162036ee-81f1-36b1-7658-15a5f98c7d29@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Peter Zijlstra <peterz@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>

On 01/09/2019 06:47 AM, Tetsuo Handa wrote:
> Hello, Peter.
>
> We got two reports. Neither RWSEM_READER_OWNED nor RWSEM_ANONYMOUSLY_OWNED is set, and
> (presumably) sem->owner == current is true, but count is -1. What does this mean?
>
> https://syzkaller.appspot.com/text?tag=CrashLog&x=169dbb9b400000
>
> [ 2580.337550][ T3645] mmap_sem: hlock->read=1 count=-4294967295 current=ffff888050e04140, owner=ffff888050e04140
> [ 2580.353526][ T3645] ------------[ cut here ]------------
> [ 2580.367859][ T3645] downgrading a read lock
> [ 2580.367935][ T3645] WARNING: CPU: 1 PID: 3645 at kernel/locking/lockdep.c:3572 lock_downgrade+0x35d/0xbe0
> [ 2580.382206][ T3645] Kernel panic - not syncing: panic_on_warn set ...
>
> https://syzkaller.appspot.com/text?tag=CrashLog&x=1542da4f400000
>
> [  386.342585][T16698] mmap_sem: hlock->read=1 count=-4294967295 current=ffff8880512ae180, owner=ffff8880512ae180
> [  386.348586][T16698] ------------[ cut here ]------------
> [  386.357203][T16698] downgrading a read lock
> [  386.357294][T16698] WARNING: CPU: 1 PID: 16698 at kernel/locking/lockdep.c:3572 lock_downgrade+0x35d/0xbe0
> [  386.372148][T16698] Kernel panic - not syncing: panic_on_warn set ...
>
>
A call to up_read() while the count was previously 0 will cause the
count to become -1. I would suggest adding some debug code in up_read()
to catch the offending caller.

Cheers,
Longman
