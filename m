Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 92CFC4402ED
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:35:14 -0500 (EST)
Received: by wmww144 with SMTP id w144so78895524wmw.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:35:14 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id x67si7243138wmx.8.2015.11.25.09.35.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 09:35:13 -0800 (PST)
Received: by wmec201 with SMTP id c201so79892312wme.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:35:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
References: <20150913185940.GA25369@htj.duckdns.org> <55FEC685.5010404@oracle.com>
 <20150921200141.GH13263@mtj.duckdns.org> <20151125144354.GB17308@twins.programming.kicks-ass.net>
 <20151125150207.GM11639@twins.programming.kicks-ass.net> <CAPAsAGwa9-7UBUnhysfek3kyWKMgaUJRwtDPEqas1rKwkeTtoA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 25 Nov 2015 18:34:53 +0100
Message-ID: <CACT4Y+aWTOaTsSNBYB0F7Y8Ku9o6tF4LYGa+f5EeWGjvK9nn4w@mail.gmail.com>
Subject: Re: [PATCH 1/2] memcg: flatten task_struct->memcg_oom
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, vdavydov@parallels.com, kernel-team@fb.com

On Wed, Nov 25, 2015 at 4:31 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> 2015-11-25 18:02 GMT+03:00 Peter Zijlstra <peterz@infradead.org>:
>> On Wed, Nov 25, 2015 at 03:43:54PM +0100, Peter Zijlstra wrote:
>>> On Mon, Sep 21, 2015 at 04:01:41PM -0400, Tejun Heo wrote:
>>> > So, the only way the patch could have caused the above is if someone
>>> > who isn't the task itself is writing to the bitfields while the task
>>> > is running.  Looking through the fields, ->sched_reset_on_fork seems a
>>> > bit suspicious.  __sched_setscheduler() looks like it can modify the
>>> > bit while the target task is running.  Peter, am I misreading the
>>> > code?
>>>
>>> Nope, that's quite possible. Looks like we need to break up those
>>> bitfields a bit. All the scheduler ones should be serialized by
>>> scheduler locks, but the others are fair game.
>>
>> Maybe something like so; but my brain is a complete mess today.
>>
>> ---
>>  include/linux/sched.h | 11 ++++++-----
>>  1 file changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index f425aac63317..b474e0f05327 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1455,14 +1455,15 @@ struct task_struct {
>>         /* Used for emulating ABI behavior of previous Linux versions */
>>         unsigned int personality;
>>
>> -       unsigned in_execve:1;   /* Tell the LSMs that the process is doing an
>> -                                * execve */
>> -       unsigned in_iowait:1;
>> -
>> -       /* Revert to default priority/policy when forking */
>> +       /* scheduler bits, serialized by scheduler locks */
>>         unsigned sched_reset_on_fork:1;
>>         unsigned sched_contributes_to_load:1;
>>         unsigned sched_migrated:1;
>> +       unsigned __padding_sched:29;
>
> AFAIK the order of bit fields is implementation defined, so GCC could
> sort all these bits as it wants.
> You could use unnamed zero-widht bit-field to force padding:
>
>          unsigned :0; //force aligment to the next boundary.
>
>> +
>> +       /* unserialized, strictly 'current' */
>> +       unsigned in_execve:1; /* bit to tell LSMs we're in execve */
>> +       unsigned in_iowait:1;
>>  #ifdef CONFIG_MEMCG
>>         unsigned memcg_may_oom:1;
>>  #endif
>>

I've gathered some evidence that in my case the guilty bit is
sched_reset_on_fork:
https://groups.google.com/d/msg/syzkaller/o8VqvYNEu_I/I0pXGx79DQAJ

This patch should help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
