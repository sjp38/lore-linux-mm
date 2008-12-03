Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id mB33vi7v029449
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 19:57:45 -0800
Received: from an-out-0708.google.com (andd14.prod.google.com [10.100.30.14])
	by spaceape11.eur.corp.google.com with ESMTP id mB33vgu4027564
	for <linux-mm@kvack.org>; Tue, 2 Dec 2008 19:57:42 -0800
Received: by an-out-0708.google.com with SMTP id d14so1359889and.0
        for <linux-mm@kvack.org>; Tue, 02 Dec 2008 19:57:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081203111440.1D35.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <604427e00812021130t1aad58a8j7474258ae33e15a4@mail.gmail.com>
	 <20081203111440.1D35.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Tue, 2 Dec 2008 19:57:41 -0800
Message-ID: <604427e00812021957m44549252k21e1b617ba9e78c3@mail.gmail.com>
Subject: Re: [PATCH][V6]make get_user_pages interruptible
From: Ying Han <yinghan@google.com>
Content-Type: multipart/alternative; boundary=00504502ccae1c9985045d1c729e
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

--00504502ccae1c9985045d1c729e
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On Tue, Dec 2, 2008 at 6:24 PM, KOSAKI Motohiro <
kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi!
>
> Sorry for too late review.
> In general, I like this patch. but ...
>
>
>> changelog
>> [v6] replace the sigkill_pending() with fatal_signal_pending()
>>       add the check for cases current != tsk
>>
>> From: Ying Han <yinghan@google.com>
>>
>> make get_user_pages interruptible
>> The initial implementation of checking TIF_MEMDIE covers the cases of OOM
>> killing. If the process has been OOM killed, the TIF_MEMDIE is set and it
>> return immediately. This patch includes:
>>
>> 1. add the case that the SIGKILL is sent by user processes. The process
can
>> try to get_user_pages() unlimited memory even if a user process has sent
a
>> SIGKILL to it(maybe a monitor find the process exceed its memory limit
and
>> try to kill it). In the old implementation, the SIGKILL won't be handled
>> until the get_user_pages() returns.
>>
>> 2. change the return value to be ERESTARTSYS. It makes no sense to return
>> ENOMEM if the get_user_pages returned by getting a SIGKILL signal.
>> Considering the general convention for a system call interrupted by a
>> signal is ERESTARTNOSYS, so the current return value is consistant to
that.
>
> this description explain why fatal_signal_pending(current) is needed.
> but doesn't explain why fatal_signal_pending(tsk) is needed.
There were couple of discussions about adding the fatal_signal_pending(tsk)
in the previous
versions of this patch, and the reason i added on is to cover the case when
the current!=tsk
and the caller calls get_user_pages() on behalf of tsk, and we want to
interrupt in this case
as well. if that sounds a reasonable, i will added in the patch description.
>
> more unfortunately, this patch break kernel compatibility.
> To read /proc file invoke calling get_user_page().
> however, "man 2 read" doesn't describe ERESTARTSYS.
yeah, that seems to be right..
>
> IOW, this patch can break /proc reading user application.
>
> May I ask why fatal_signal_pending(tsk) is needed ?
> at least, you need to cc to linux-api@vger.kernel.org IMHO.
all the problems seems to be caused by the fatal_signal_pending(tsk),
i can either make the change like
if (fatal_signal_pending(tsk))
   return i ? i : EINTR

or remove the check for fatal_signal_pending(tsk) which is mainly used in
the case you mentioned above. Afterward, the intial point of the patch is to
avoid proccess hanging in the mlock (for example) under memory
pressure while it has SIGKILL pending. Now sounds to me the second option is
better. any comments?

--Ying
>
> Am I talking about pointless?
thanks for comments. :-)
>
>
>
>> Signed-off-by:        Paul Menage <menage@google.com>
>> Signed-off-by:        Ying Han <yinghan@google.com>
>>
>> mm/memory.c                   |   13 ++-
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 164951c..049a4f1 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -1218,12 +1218,15 @@ int __get_user_pages(struct task_struct *tsk,
struct m
>>                       struct page *page;
>>
>>                       /*
>> -                      * If tsk is ooming, cut off its access to large
memory
>> -                      * allocations. It has a pending SIGKILL, but it
can't
>> -                      * be processed until returning to user space.
>> +                      * If we have a pending SIGKILL, don't keep
>> +                      * allocating memory. We check both current
>> +                      * and tsk to cover the cases where current
>> +                      * is allocating pages on behalf of tsk.
>>                        */
>> -                     if (unlikely(test_tsk_thread_flag(tsk,
TIF_MEMDIE)))
>> -                             return i ? i : -ENOMEM;
>> +                     if (unlikely(fatal_signal_pending(current) ||
>> +                             ((current != tsk) &&
>> +                             fatal_signal_pending(tsk))))
>> +                             return i ? i : -ERESTARTSYS;
>>
>>                       if (write)
>>                               foll_flags |= FOLL_WRITE;
>
>
>
>
>

--00504502ccae1c9985045d1c729e
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<br><br>On Tue, Dec 2, 2008 at 6:24 PM, KOSAKI Motohiro &lt;<a href="mailto:kosaki.motohiro@jp.fujitsu.com">kosaki.motohiro@jp.fujitsu.com</a>&gt; wrote:<br>&gt; Hi!<br>&gt;<br>&gt; Sorry for too late review.<br>&gt; In general, I like this patch. but ...<br>
&gt;<br>&gt;<br>&gt;&gt; changelog<br>&gt;&gt; [v6] replace the sigkill_pending() with fatal_signal_pending()<br>&gt;&gt; &nbsp; &nbsp; &nbsp; add the check for cases current != tsk<br>&gt;&gt;<br>&gt;&gt; From: Ying Han &lt;<a href="mailto:yinghan@google.com">yinghan@google.com</a>&gt;<br>
&gt;&gt;<br>&gt;&gt; make get_user_pages interruptible<br>&gt;&gt; The initial implementation of checking TIF_MEMDIE covers the cases of OOM<br>&gt;&gt; killing. If the process has been OOM killed, the TIF_MEMDIE is set and it<br>
&gt;&gt; return immediately. This patch includes:<br>&gt;&gt;<br>&gt;&gt; 1. add the case that the SIGKILL is sent by user processes. The process can<br>&gt;&gt; try to get_user_pages() unlimited memory even if a user process has sent a<br>
&gt;&gt; SIGKILL to it(maybe a monitor find the process exceed its memory limit and<br>&gt;&gt; try to kill it). In the old implementation, the SIGKILL won&#39;t be handled<br>&gt;&gt; until the get_user_pages() returns.<br>
&gt;&gt;<br>&gt;&gt; 2. change the return value to be ERESTARTSYS. It makes no sense to return<br>&gt;&gt; ENOMEM if the get_user_pages returned by getting a SIGKILL signal.<br>&gt;&gt; Considering the general convention for a system call interrupted by a<br>
&gt;&gt; signal is ERESTARTNOSYS, so the current return value is consistant to that.<br>&gt;<br>&gt; this description explain why fatal_signal_pending(current) is needed.<br>&gt; but doesn&#39;t explain why fatal_signal_pending(tsk) is needed.<br>
There were couple of discussions about adding the fatal_signal_pending(tsk) in the previous<br>versions of this patch, and the reason i added on is to cover the case when the current!=tsk<br>and the caller calls get_user_pages() on behalf of tsk, and we want to interrupt in this case<br>
as well. if that sounds a reasonable, i will added in the patch description.<br>&gt;<br>&gt; more unfortunately, this patch break kernel compatibility.<br>&gt; To read /proc file invoke calling get_user_page().<br>&gt; however, &quot;man 2 read&quot; doesn&#39;t describe ERESTARTSYS.<br>
yeah, that seems to be right..<br>&gt;<br>&gt; IOW, this patch can break /proc reading user application.<br>&gt;<br>&gt; May I ask why fatal_signal_pending(tsk) is needed ?<br>&gt; at least, you need to cc to <a href="mailto:linux-api@vger.kernel.org">linux-api@vger.kernel.org</a> IMHO.<br>
all the problems seems to be caused by the fatal_signal_pending(tsk),<br>i can either make the change like<br>if (fatal_signal_pending(tsk))<br> &nbsp; &nbsp;return i ? i : EINTR<br><br>or remove the check for fatal_signal_pending(tsk) which is mainly used in the case you mentioned above. Afterward, the intial point of the patch is to avoid proccess hanging in the mlock (for example) under memory<br>
pressure while it has SIGKILL pending. Now sounds to me the second option is better. any comments?<br><br>--Ying<br>&gt;<br>&gt; Am I talking about pointless?<br>thanks for comments. :-)<br>&gt;<br>&gt;<br>&gt;<br>&gt;&gt; Signed-off-by: &nbsp; &nbsp; &nbsp; &nbsp;Paul Menage &lt;<a href="mailto:menage@google.com">menage@google.com</a>&gt;<br>
&gt;&gt; Signed-off-by: &nbsp; &nbsp; &nbsp; &nbsp;Ying Han &lt;<a href="mailto:yinghan@google.com">yinghan@google.com</a>&gt;<br>&gt;&gt;<br>&gt;&gt; mm/memory.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; 13 ++-<br>&gt;&gt;<br>&gt;&gt; diff --git a/mm/memory.c b/mm/memory.c<br>
&gt;&gt; index 164951c..049a4f1 100644<br>&gt;&gt; --- a/mm/memory.c<br>&gt;&gt; +++ b/mm/memory.c<br>&gt;&gt; @@ -1218,12 +1218,15 @@ int __get_user_pages(struct task_struct *tsk, struct m<br>&gt;&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; struct page *page;<br>
&gt;&gt;<br>&gt;&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /*<br>&gt;&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* If tsk is ooming, cut off its access to large memory<br>&gt;&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* allocations. It has a pending SIGKILL, but it can&#39;t<br>
&gt;&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* be processed until returning to user space.<br>&gt;&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* If we have a pending SIGKILL, don&#39;t keep<br>&gt;&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* allocating memory. We check both current<br>
&gt;&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* and tsk to cover the cases where current<br>&gt;&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* is allocating pages on behalf of tsk.<br>&gt;&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*/<br>&gt;&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE)))<br>
&gt;&gt; - &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return i ? i : -ENOMEM;<br>&gt;&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (unlikely(fatal_signal_pending(current) ||<br>&gt;&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ((current != tsk) &amp;&amp;<br>&gt;&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; fatal_signal_pending(tsk))))<br>
&gt;&gt; + &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return i ? i : -ERESTARTSYS;<br>&gt;&gt;<br>&gt;&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (write)<br>&gt;&gt; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; foll_flags |= FOLL_WRITE;<br>&gt;<br>&gt;<br>&gt;<br>&gt;<br>
&gt;<br><br>

--00504502ccae1c9985045d1c729e--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
