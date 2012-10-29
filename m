Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D67206B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 14:26:46 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so3734648qcq.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:26:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
	<20121015144412.GA2173@barrios>
	<CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com>
	<20121016061854.GB3934@barrios>
	<CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
	<CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
	<20121022235321.GK13817@bbox>
	<alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
Date: Mon, 29 Oct 2012 11:26:45 -0700
Message-ID: <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

I managed to get the stack trace for the process that refuses to die.
I am not sure it's due to the deadlock described in earlier messages.
I will investigate further.

[96283.704390] chrome          x 815ecd20     0 16573   1112 0x00100104
[96283.704405]  c107fe34 00200046 f57ae000 815ecd20 815ecd20 ec0b645a
0000578f f67cfd20
[96283.704427]  d0a9a9a0 c107fdf8 81037be5 f5bdf1e8 f6021800 00000000
c107fe04 00200202
[96283.704449]  c107fe0c 00200202 f5bdf1b0 c107fe24 8117ddb1 00200202
f5bdf1b0 f5bdf1b8
[96283.704471] Call Trace:
[96283.704484]  [<81037be5>] ? queue_work_on+0x2d/0x39
[96283.704497]  [<8117ddb1>] ? put_io_context+0x52/0x6a
[96283.704510]  [<813b68f6>] schedule+0x56/0x58
[96283.704520]  [<81028525>] do_exit+0x63e/0x640
[96283.704530]  [<81028752>] do_group_exit+0x63/0x86
[96283.704541]  [<81032b19>] get_signal_to_deliver+0x434/0x44b
[96283.704554]  [<81001e01>] do_signal+0x37/0x4fe
[96283.704564]  [<8103e31d>] ? update_rmtp+0x67/0x67
[96283.704585]  [<8105622a>] ? clockevents_program_event+0xea/0x108
[96283.704599]  [<81050d92>] ? timekeeping_get_ns+0x11/0x55
[96283.704610]  [<8105a758>] ? sys_futex+0xcb/0xdb
[96283.704620]  [<810024a7>] do_notify_resume+0x26/0x65
[96283.704632]  [<813b7305>] work_notifysig+0xa/0x11
[96283.704644]  [<813b0000>] ? coretemp_cpu_callback+0x88/0x179

On Mon, Oct 22, 2012 at 11:03 PM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 23 Oct 2012, Minchan Kim wrote:
>
>> > I found the source, and maybe the cause, of the problem I am
>> > experiencing when running out of memory with zram enabled.  It may be
>> > a known problem.  The OOM killer doesn't find any killable process
>> > because select_bad_process() keeps returning -1 here:
>> >
>> >     /*
>> >      * This task already has access to memory reserves and is
>> >      * being killed. Don't allow any other task access to the
>> >      * memory reserve.
>> >      *
>> >      * Note: this may have a chance of deadlock if it gets
>> >      * blocked waiting for another task which itself is waiting
>> >      * for memory. Is there a better alternative?
>> >      */
>> >     if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
>> >         if (unlikely(frozen(p)))
>> >             __thaw_task(p);
>> >         if (!force_kill)
>> >             return ERR_PTR(-1UL);
>> >     }
>> >
>> > select_bad_process() is called by out_of_memory() in __alloc_page_may_oom().
>>
>> I think it's not a zram problem but general problem of OOM killer.
>> Above code's intention is to prevent shortage of ememgency memory pool for avoding
>> deadlock. If we already killed any task and the task are in the middle of exiting,
>> OOM killer will wait for him to be exited. But the problem in here is that
>> killed task might wait any mutex which are held to another task which are
>> stuck for the memory allocation and can't use emergency memory pool. :(
>
> Yeah, there's always a problem if an oom killed process cannot exit
> because it's waiting for some other eligible process.  This doesn't
> normally happen for anything sharing the same mm, though, because we try
> to kill anything sharing the same mm when we select a process for oom kill
> and if those killed threads happen to call into the oom killer they
> silently get TIF_MEMDIE so they may exit as well.  This addressed earlier
> problems we had with things waiting on mm->mmap_sem in the exit path.
>
> If the oom killed process cannot exit because it's waiting on another
> eligible process that does not share the mm, then we'll potentially
> livelock unless you do echo f > /proc/sysrq-trigger manually or turn on
> /proc/sys/vm/oom_kill_allocating_task.
>
>> I think one of solution is that if it takes some seconed(ex, 3 sec) after we already
>> kill some task but still looping with above code, we can allow accessing of
>> ememgency memory pool for another task. It may happen deadlock due to burn out memory
>> pool but otherwise, we still suffer from deadlock.
>>
>
> The problem there is that if the time limit expires (we used 10 seconds
> before internally, we don't do it at all anymore) and there are no more
> eligible threads that you unnecessarily panic, or open yourself up to a
> complete depletion of memory reserves whereas not even the oom killer can
> help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
