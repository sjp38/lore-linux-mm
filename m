Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id F10E88E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 17:46:08 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id j5so8174571qtk.11
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 14:46:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e38si1682570qvh.0.2019.01.09.14.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 14:46:07 -0800 (PST)
Subject: Re: WARNING: locking bug in lock_downgrade
References: <00000000000043ae20057b974f14@google.com>
 <f0acc6af-cdd5-0e46-bca5-2e2a9a4c983e@linux.alibaba.com>
 <69273d51-c129-6b0f-35eb-d98655476ff9@redhat.com>
 <d61e0a3e-a71e-9e42-7a56-d6fcfc0f6b63@I-love.SAKURA.ne.jp>
From: Waiman Long <longman@redhat.com>
Message-ID: <864e2d6b-f471-cc04-311f-473da43b409a@redhat.com>
Date: Wed, 9 Jan 2019 17:46:03 -0500
MIME-Version: 1.0
In-Reply-To: <d61e0a3e-a71e-9e42-7a56-d6fcfc0f6b63@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, peterz@infradead.org, "mingo@redhat.com" <mingo@redhat.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, syzbot <syzbot+53383ae265fb161ef488@syzkaller.appspotmail.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@dominikbrodowski.net, mhocko@suse.com, rientjes@google.com, syzkaller-bugs@googlegroups.com, vbabka@suse.cz, boqun.feng@gmail.com

On 01/09/2019 09:18 AM, Tetsuo Handa wrote:
> On 2018/12/14 4:46, Waiman Long wrote:
>> On 12/12/2018 08:14 PM, Yang Shi wrote:
>>> By looking into lockdep code, I'm not sure if lockdep may get confused
>>> by such sequence or not?
>>>
>>>
>>> Any hint is appreciated.
>>>
>>>
>>> Regards,
>>>
>>> Yang 
>> The warning was printed because hlock->read was set when doing the
>> downgrade_write(). So it is either downgrade_write() was called a second
>> time or a read lock was held originally. It is hard to tell what is the
>> root cause without a reproducer.
>>
>> Cheers,
>> Longman
>>
> Comparing with output from
>
>         struct rw_semaphore *sem = &current->mm->mmap_sem;
>
>         down_write(sem);
>         pr_warn("mmap_sem: count=%ld current=%px, owner=%px\n", atomic_long_read(&sem->count), current, READ_ONCE(sem->owner));
>         /* mmap_sem: count=-4294967295 current=ffff88813095ca80, owner=ffff88813095ca80 */
>         downgrade_write(sem);
>         pr_warn("mmap_sem: count=%ld current=%px, owner=%px\n", atomic_long_read(&sem->count), current, READ_ONCE(sem->owner));
>         /* mmap_sem: count=1 current=ffff88813095ca80, owner=ffff88813095ca83 */
>         up_read(sem);
>         pr_warn("mmap_sem: count=%ld current=%px, owner=%px\n", atomic_long_read(&sem->count), current, READ_ONCE(sem->owner));
>         /* mmap_sem: count=0 current=ffff88813095ca80, owner=0000000000000003 */

The behavior is correct. The current code will leave the reader task
structure pointer in owner even if it is a read lock. You have to look
at bit 0 to know if the owner is a reader or writer.

> what we got with debug printk() patch
>
>   https://syzkaller.appspot.com/text?tag=CrashLog&x=169dbb9b400000
>
>   [ 2580.337550][ T3645] mmap_sem: hlock->read=1 count=-4294967295 current=ffff888050e04140, owner=ffff888050e04140
>   [ 2580.353526][ T3645] ------------[ cut here ]------------
>   [ 2580.367859][ T3645] downgrading a read lock
>   [ 2580.367935][ T3645] WARNING: CPU: 1 PID: 3645 at kernel/locking/lockdep.c:3572 lock_downgrade+0x35d/0xbe0
>   [ 2580.382206][ T3645] Kernel panic - not syncing: panic_on_warn set ...
>
>   https://syzkaller.appspot.com/text?tag=CrashLog&x=1542da4f400000
>
>   [  386.342585][T16698] mmap_sem: hlock->read=1 count=-4294967295 current=ffff8880512ae180, owner=ffff8880512ae180
>   [  386.348586][T16698] ------------[ cut here ]------------
>   [  386.357203][T16698] downgrading a read lock
>   [  386.357294][T16698] WARNING: CPU: 1 PID: 16698 at kernel/locking/lockdep.c:3572 lock_downgrade+0x35d/0xbe0
>   [  386.372148][T16698] Kernel panic - not syncing: panic_on_warn set ...
>
> indicates that lockdep is saying that "current->mm->mmap_sem is held for read"
> while "struct rw_semaphore" is saying that "current->mm->mmap_sem is held for write".
> Something made lockdep confused. Possibly a lockdep bug.
>
It could be a bug in lockdep regarding downgrade. Someone else has
reported similar problem before.

-Longman
