Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id mB3KPIQG016029
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 12:25:18 -0800
Received: from an-out-0708.google.com (andd14.prod.google.com [10.100.30.14])
	by wpaz9.hot.corp.google.com with ESMTP id mB3KPGsI029973
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 12:25:17 -0800
Received: by an-out-0708.google.com with SMTP id d14so1530795and.0
        for <linux-mm@kvack.org>; Wed, 03 Dec 2008 12:25:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1228316620.6693.34.camel@lts-notebook>
References: <604427e00812022117x6538553w8ceb24e6fa7f3a30@mail.gmail.com>
	 <1228316620.6693.34.camel@lts-notebook>
Date: Wed, 3 Dec 2008 12:25:15 -0800
Message-ID: <604427e00812031225t773be1c4seae4e54d7fc0ff44@mail.gmail.com>
Subject: Re: [PATCH][V7]make get_user_pages interruptible
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Paul Menage <menage@google.com>, Rohit Seth <rohitseth@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 3, 2008 at 7:03 AM, Lee Schermerhorn
<Lee.Schermerhorn@hp.com> wrote:
> On Tue, 2008-12-02 at 21:17 -0800, Ying Han wrote:
>> From: Ying Han <yinghan@google.com>
>>
>> make get_user_pages interruptible
>> The initial implementation of checking TIF_MEMDIE covers the cases of OOM
>> killing. If the process has been OOM killed, the TIF_MEMDIE is set and it
>> return immediately. This patch includes:
>>
>> 1. add the case that the SIGKILL is sent by user processes. The process can
>> try to get_user_pages() unlimited memory even if a user process has sent a
>> SIGKILL to it(maybe a monitor find the process exceed its memory limit and
>> try to kill it). In the old implementation, the SIGKILL won't be handled
>> until the get_user_pages() returns.
>>
>> 2. change the return value to be ERESTARTSYS. It makes no sense to return
>> ENOMEM if the get_user_pages returned by getting a SIGKILL signal.
>> Considering the general convention for a system call interrupted by a
>> signal is ERESTARTNOSYS, so the current return value is consistant to that.
>>
>> Signed-off-by:        Paul Menage <menage@google.com>
>> Signed-off-by:        Ying Han <yinghan@google.com>
>>
> <snip>
>
> Couple of things:
>
> * I tested your previous patch [that was "just too ugly to live
> with" :)] overnight with my swap/unevictable-lru/mlocked-pages stress
> test on both x86_64 and ia64.  I replaced the two patches in mmotm
> 081201 with the "ugly one".  Both systems ran for ~16:40 [hh:mm] without
> error, before I stopped the tests.
thanks Lee and the "swap/unevictable-lru/mlocked-pages" tests is somewhere
i can access? just curious.

> * Your patch--bailing out of get_user_pages() when current has SIGKILL
> pending--breaks munlock on exit when SIGKILL is pending.  This results
> in freeing of mlocked pages [not so bad, I guess] and possibly leaving,
> e.g., shared library pages mlocked and unevictable after last VM_LOCKED
> vma is removed.  I noticed this because SIGKILL is how the test harness
> kills off the running tests.  I have a patch that fixes this.  The
> overnight runs included this patch.  I'll post it after rebasing and a
> quick retest [he says optimistically] on mmotm-081203.
sorry not get exactly what you mean it breaks the munlock. :-)

> Lee
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
