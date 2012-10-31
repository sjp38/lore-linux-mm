Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id B08736B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 17:40:24 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id c11so1448491qad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 14:40:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com>
References: <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
	<20121022235321.GK13817@bbox>
	<alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
	<CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
	<alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
	<CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
	<20121030001809.GL15767@bbox>
	<CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
	<alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
	<CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com>
	<20121031005738.GM15767@bbox>
	<alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com>
Date: Wed, 31 Oct 2012 14:40:23 -0700
Message-ID: <CAA25o9Q4iPHDocZi3fgPn_Mu+3io5TGi9RzcONWyUCgiEFQ2FQ@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

Thanks so much for your help.  There are two issues: one is what we
(Chrome OS) should do, the other is what should be done for ToT linux.

The fix(es) you propose are harder to understand than mine, and put
additional special conditions in code that is already rife with them.
My fix, instead, removes one such special condition.  It can, in
principle, cause processes to be OOM-killed unnecessarily, but what's
the likelihood that it will happen?  We don't actually see it happen,
and it matters  little to us if it happens.

I would be more than happy to try one of your fixes, but not likely to
implement it.

On Wed, Oct 31, 2012 at 11:54 AM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 31 Oct 2012, Minchan Kim wrote:
>
>> It sounds right in your kernel but principal problem is min_filelist_kbytes patch.
>> If normal exited process in exit path requires a page and there is no free page
>> any more, it ends up going to OOM path after try to reclaim memory several time.
>> Then,
>> In select_bad_process,
>>
>>         if (task->flags & PF_EXITING) {
>>                if (task == current)             <== true
>>                         return OOM_SCAN_SELECT;
>> In oom_kill_process,
>>
>>         if (p->flags & PF_EXITING)
>>                 set_tsk_thread_flag(p, TIF_MEMDIE);
>>
>> At last, normal exited process would get a free page.
>>
>
> select_bad_process() won't actually select the process for oom kill,
> though, if there are other PF_EXITING threads other than current.  So if
> multiple threads are page faulting on tsk->robust_list, then no thread
> ends up getting killed.  The temporary workaround would be to do a kill -9
> so that the logic in out_of_memory() could immediately give such threads
> access to memory reserves so the page fault will succeed.

When we discover the thread in such state, it's already in do_exit()
and it's waiting for the page fault to complete.  Will it wait
forever, or timeout and retry?  Is it acceptable, and sufficient, to
change task->exit_code on the fly?  If not, what else?  It is quite
difficult to analyze that code.

>  The real fix
> would be to audit all possible cases in between setting
> tsk->flags |= PF_EXITING and tsk->mm = NULL that could cause a memory
> allocation and make exemptions for them in oom_scan_process_thread().

I think I probably slightly disagree with this.  It's an extra step in
the direction of unmaintainability.  Wouldn't it be better to disallow
a thread from making allocations in that section, fix all the places
where it does, and panic to catch missed occurrences or new ones?

Otherwise the OOM module will have to know additional details about
what threads are doing, or threads will have to maintain that state
(task->exiting_but_may_still_allocate = 1).  Isn't there already too
much of this stuff going on?

Thanks again!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
