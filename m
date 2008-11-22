Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id mAM0h2GM014088
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 16:43:03 -0800
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by wpaz17.hot.corp.google.com with ESMTP id mAM0h0JO028505
	for <linux-mm@kvack.org>; Fri, 21 Nov 2008 16:43:01 -0800
Received: by rv-out-0708.google.com with SMTP id b17so1174002rvf.38
        for <linux-mm@kvack.org>; Fri, 21 Nov 2008 16:43:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
References: <604427e00811211605j20fd00bby1bac86b4cc3c380b@mail.gmail.com>
	 <alpine.DEB.2.00.0811211618160.20523@chino.kir.corp.google.com>
Date: Fri, 21 Nov 2008 16:43:00 -0800
Message-ID: <604427e00811211643w52d77197nc0d4e5e711d68933@mail.gmail.com>
Subject: Re: [PATCH][V2] Make get_user_pages interruptible
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 21, 2008 at 4:21 PM, David Rientjes <rientjes@google.com> wrote:
> On Fri, 21 Nov 2008, Ying Han wrote:
>
>> Signed-off-by:        Paul Menage <menage@google.com>
>>                     Ying Han <yinghan@google.com>
>>
>
> That should be:
>
> Signed-off-by: Paul Menage <menage@google.com>
> Signed-off-by: Ying Han <yinghan@google.com>
>
> and the first signed-off line is usually indicative of who wrote the
> original change.  If Paul wrote this code, please add:
>
> From: Paul Menage <menage@google.com>
>
> as the first line of the email so that the proper authorship gets
> attributed in the commit.
thanks for your info. fixed.
>
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index b483f39..f9c6a8a 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1790,6 +1790,7 @@ extern void sched_dead(struct task_struct *p);
>>  extern int in_group_p(gid_t);
>>  extern int in_egroup_p(gid_t);
>>
>> +extern int sigkill_pending(struct task_struct *tsk);
>>  extern void proc_caches_init(void);
>>  extern void flush_signals(struct task_struct *);
>>  extern void ignore_signals(struct task_struct *);
>
> Interesting way around your email client's line truncation.
>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 164951c..5d3db5e 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1218,12 +1218,11 @@ int __get_user_pages(struct task_struct *tsk, struct m
>>                       struct page *page;
>>
>>                       /*
>> -                      * If tsk is ooming, cut off its access to large memory
>> -                      * allocations. It has a pending SIGKILL, but it can't
>> -                      * be processed until returning to user space.
>> +                      * If we have a pending SIGKILL, don't keep
>> +                      * allocating memory.
>>                        */
>> -                     if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))
>> -                             return i ? i : -ENOMEM;
>> +                     if (sigkill_pending(current))
>> +                             return i ? i : -ERESTARTSYS;
>>
>>                       if (write)
>>                               foll_flags |= FOLL_WRITE;
>>
>
> We previously tested tsk for TIF_MEMDIE and not current (in fact, nothing
> in __get_user_pages() operates on current).  So why are we introducing
> this check on current and not tsk?
   Initially, the patch is merely to cause a process stuck in mlock to
honour a pending sigkill. And in mlock case, tsk==current.

>
> Do we want to avoid branch prediction now because there's data suggesting
> tsk will be SIGKILL'd more frequently in this path other than by the oom
> killer?
>
any specific example?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
