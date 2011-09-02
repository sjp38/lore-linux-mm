Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3776B016A
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 01:17:04 -0400 (EDT)
Received: by vxj3 with SMTP id 3so2552072vxj.14
        for <linux-mm@kvack.org>; Thu, 01 Sep 2011 22:17:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110901143333.51baf4ae.akpm@linux-foundation.org>
References: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
	<20110901143333.51baf4ae.akpm@linux-foundation.org>
Date: Fri, 2 Sep 2011 10:47:03 +0530
Message-ID: <CAFPAmTQbdhNgFNoP0RyS0E9Gm4djA-W_4JWwpWZ7U=XnTKR+cg@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of del_timer
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Fri, Sep 2, 2011 at 3:03 AM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Thu, =A01 Sep 2011 21:27:02 +0530
> Kautuk Consul <consul.kautuk@gmail.com> wrote:
>
>> This is important for SMP scenario, to check whether the timer
>> callback is executing on another CPU when we are deleting the
>> timer.
>>
>
> I don't see why?
>
>> index d6edf8d..754b35a 100644
>> --- a/mm/backing-dev.c
>> +++ b/mm/backing-dev.c
>> @@ -385,7 +385,7 @@ static int bdi_forker_thread(void *ptr)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* dirty data on the default backing_dev_i=
nfo
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wb_has_dirty_io(me) || !list_empty(&me->=
bdi->work_list)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&me->wakeup_timer);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer_sync(&me->wakeup_tim=
er);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wb_do_writeback(me, 0);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> It isn't a use-after-free fix: bdi_unregister() safely shoots down any
> running timer.
>

In the situation that we do a del_timer at the same time that the
wakeup_timer_fn is
executing on another CPU, there is one tiny possible problem:
1)  The wakeup_timer_fn will call wake_up_process on the bdi-default thread=
.
      This will set the bdi-default thread's state to TASK_RUNNING.
2)  However, the code in bdi_writeback_thread() sets the state of the
bdi-default process
    to TASK_INTERRUPTIBLE as it intends to sleep later.

If 2) happens before 1), then the bdi_forker_thread will not sleep
inside schedule as is the
intention of the bdi_forker_thread() code.

This protection is not achieved even by acquiring spinlocks before
setting the task->state
as the spinlock used in wakeup_timer_fn is &bdi->wb_lock whereas the code i=
n
bdi_forker_thread acquires &bdi_lock which is a different spin_lock.

Am I correct in concluding this ?

> Please completely explain what you believe the problem is here.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
