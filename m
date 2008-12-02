Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id mB2M0loR015766
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 14:00:47 -0800
Received: from yw-out-2324.google.com (ywb5.prod.google.com [10.192.2.5])
	by zps77.corp.google.com with ESMTP id mB2M0jLi003722
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 14:00:46 -0800
Received: by yw-out-2324.google.com with SMTP id 5so1364160ywb.53
        for <linux-mm@kvack.org>; Tue, 02 Dec 2008 14:00:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4935A7EC.2020708@cs.helsinki.fi>
References: <604427e00812021130t1aad58a8j7474258ae33e15a4@mail.gmail.com>
	 <4935A7EC.2020708@cs.helsinki.fi>
Date: Tue, 2 Dec 2008 14:00:45 -0800
Message-ID: <604427e00812021400w170cd1dbl6e5b8c3d18135013@mail.gmail.com>
Subject: Re: [PATCH][V6]make get_user_pages interruptible
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Oleg Nesterov <oleg@redhat.com>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 2, 2008 at 1:26 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> Ying Han wrote:
>>
>> changelog
>> [v6] replace the sigkill_pending() with fatal_signal_pending()
>>      add the check for cases current != tsk
>>
>> From: Ying Han <yinghan@google.com>
>>
>> make get_user_pages interruptible
>> The initial implementation of checking TIF_MEMDIE covers the cases of OOM
>> killing. If the process has been OOM killed, the TIF_MEMDIE is set and it
>> return immediately. This patch includes:
>>
>> 1. add the case that the SIGKILL is sent by user processes. The process
>> can
>> try to get_user_pages() unlimited memory even if a user process has sent a
>> SIGKILL to it(maybe a monitor find the process exceed its memory limit and
>> try to kill it). In the old implementation, the SIGKILL won't be handled
>> until the get_user_pages() returns.
>>
>> 2. change the return value to be ERESTARTSYS. It makes no sense to return
>> ENOMEM if the get_user_pages returned by getting a SIGKILL signal.
>> Considering the general convention for a system call interrupted by a
>> signal is ERESTARTNOSYS, so the current return value is consistant to
>> that.
>>
>> Signed-off-by:  Paul Menage <menage@google.com>
>> Signed-off-by:  Ying Han <yinghan@google.com>
>>
>> mm/memory.c                   |   13 ++-
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 164951c..049a4f1 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1218,12 +1218,15 @@ int __get_user_pages(struct task_struct *tsk,
>> struct m
>>                        struct page *page;
>>
>>                        /*
>> -                        * If tsk is ooming, cut off its access to large
>> memory
>> -                        * allocations. It has a pending SIGKILL, but it
>> can't
>> -                        * be processed until returning to user space.
>> +                        * If we have a pending SIGKILL, don't keep
>> +                        * allocating memory. We check both current
>> +                        * and tsk to cover the cases where current
>> +                        * is allocating pages on behalf of tsk.
>>                         */
>> -                       if (unlikely(test_tsk_thread_flag(tsk,
>> TIF_MEMDIE)))
>> -                               return i ? i : -ENOMEM;
>> +                       if (unlikely(fatal_signal_pending(current) ||
>> +                               ((current != tsk) &&
>
> Hmm, do we really need that extra check for current != tsk? If it's a must,
> then you probably want to do something like:
>
>  if (unlikely(fatal_signal_pending(current))
>      return i ? i : -ERESTARTSYS;
>  if (unlikely(current!= tsk && fatal_signal_pending(tsk))
>      return i ? i : - ERESTARTSYS;
>
> The current form seems just too ugly to live with.
>
>> +                               fatal_signal_pending(tsk))))
>> +                               return i ? i : -ERESTARTSYS;
>>
>>                        if (write)
>>                                foll_flags |= FOLL_WRITE;
>
>
hmm,  i was thinking since in most cases we have current==tsk, and we
don't want to do the doublecheck for fatal_signal_pending. Thanks
Pekka and i will post the fix as you suggested.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
