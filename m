Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 7F1A56B0037
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 06:01:33 -0400 (EDT)
Message-ID: <51BAE9F3.5030301@parallels.com>
Date: Fri, 14 Jun 2013 14:01:23 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: Change soft-dirty interface?
References: <20130613015329.GA3894@bbox> <51B98C9A.8020602@parallels.com> <20130614003213.GD4533@bbox> <20130614004133.GE4533@bbox> <20130614050738.GA21852@bbox>
In-Reply-To: <20130614050738.GA21852@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

>>>>> If it's not allowed, another approach should be new system call.
>>>>>
>>>>>         int sys_softdirty(pid_t pid, void *addr, size_t len);
>>>>
>>>> This looks like existing sys_madvise() one.
>>>
>>> Except pid part. It is added by your purpose, which external task
>>> can control any process.

In CRIU we can work with pid-less syscalls just fine :) So extending regular
madvise would work.

>>>>
>>>>> If we approach new system call, we don't need to maintain current
>>>>> proc interface and it would be very handy to get a information
>>>>> without pagemap (open/read/close) so we can add a parameter to
>>>>> get a dirty information easily.
>>>>>
>>>>>         int sys_softdirty(pid_t pid, void *addr, size_t len, unsigned char *vec)
>>>>>
>>>>> What do you think about it?
>>>>>
>>>>
>>>> This is OK for me, though there's another issue with this API I'd like
>>>> to mention -- consider your app is doing these tricks with soft-dirty
>>>> and at the same time CRIU tools live-migrate it using the soft-dirty bits
>>>> to optimize the freeze time.
>>>>
>>>> In that case soft-dirty bits would be in wrong state for both -- you app
>>>> and CRIU, but with the proc API we could compare the ctime-s of the 
>>>> clear_refs file and find out, that someone spoiled the soft-dirty state
>>>> from last time we messed with it and handle it somehow (copy all the memory
>>>> in the worst case). Can we somehow handle this with your proposal?
>>>
>>> Good point I didn't think over that.
>>> A simple idea popped from my mind is we can use read/write lock
>>> so if pid is equal to calling process's one or pid is NULL,
>>> we use read side lock, which can allow marking soft-dirty 
>>> several vmas with parallel. And pid is not equal to calling
>>> process's one, the API should try to hold write-side lock
>>> then, if it's fail, the API should return EAGAIN so that CRIU
>>> can progress other processes and retry it after a while.
>>> Of course, it would make live-lock so that sys_softdirty might
>>> need another argument like "int block".
>>
>> And we need a flag to show SELF_SOFT_DIRTY or EXTERNAL_SOFT_DIRTY
>> and the flag will be protected by above lock. It could prevent mixed
>> case by self and external.
> 
> I realized it's not enough. Another idea is here.
> The intenion is followin as,
> 
> self softdirty VS self softdirty -> NOT exclusive
> self softdirty VS external softdirty -> exclusive
> external softdirty VS external softdirty-> excluisve

I think it might work for us. However, I have two comments to the
implementation, please see below.

> struct softdirty token {
>         u64 external;
>         u64 internal;
> };
> 
>        int sys_set_softdirty(pid_t pid, unsigned long start, size_t len,
>                                 struct softdirty *token); 
>        int sys_get_softdirty(pid_t pid, unsigned long start, size_t len, 
>                                 struct softdirty token, char *vec);

Can you please show an example how to use these two, I don't quite get how
can I do external soft-dirty tracking in atomic manner.

> 
> SYSCALL(set_softdirty, ..., token)
> {
>         struct task_struct *tsk = task_from_pid(pid);
>         mutex_lock(&mm->st_lock);
>         if (tsk == current)
>                 tsk->mm->token.internal++; 
>         else
>                 tsk->mm->token.external++;
>         token->external = mm->token.external;
>         token->internal = mm->token.internal;
>         mutex_unlock(&mm->st_lock);
>         ..
>         ..
> 
> }
> 
> SYSCALL(get_softdirty, ..., token, ...)
> {
>         struct task_struct *tsk = task_from_pid(pid);
>         mutex_lock(&mm->st_lock);
>         if (tsk == current) {
>                 if (tsk->mm->token.external != token.external) {
>                         mutex_unlock
>                         return -EAGAIN;
>                 }
>         } else {
>                 if (tsk->mm->token.external != token.external ||
>                     tsk->mm->token.internal != token.internal) {
>                         mutex_unlock;
>                         return -EAGAIN;
>                 }
>         }
>         mutex_unlock(&mm->st_lock);

Presumably the critical section should be longer, as if tokens match and we
release the lock and proceed with working on pagemap, the concurrent call
to set_softdirty can proceed and spoil the picture.

>         ...
> }
> 
> 
> 
> 
>>
>> -- 
>> Kind regards,
>> Minchan Kim
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
