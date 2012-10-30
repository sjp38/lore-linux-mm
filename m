Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 4E6256B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 20:45:18 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so7179408vbk.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 17:45:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121030001809.GL15767@bbox>
References: <20121015144412.GA2173@barrios>
	<CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com>
	<20121016061854.GB3934@barrios>
	<CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
	<CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
	<20121022235321.GK13817@bbox>
	<alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
	<CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
	<alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
	<CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
	<20121030001809.GL15767@bbox>
Date: Mon, 29 Oct 2012 17:45:16 -0700
Message-ID: <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Oct 29, 2012 at 5:18 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Mon, Oct 29, 2012 at 03:36:38PM -0700, Luigi Semenzato wrote:
>> On Mon, Oct 29, 2012 at 12:00 PM, David Rientjes <rientjes@google.com> wrote:
>> > On Mon, 29 Oct 2012, Luigi Semenzato wrote:
>> >
>> >> I managed to get the stack trace for the process that refuses to die.
>> >> I am not sure it's due to the deadlock described in earlier messages.
>> >> I will investigate further.
>> >>
>> >> [96283.704390] chrome          x 815ecd20     0 16573   1112 0x00100104
>> >> [96283.704405]  c107fe34 00200046 f57ae000 815ecd20 815ecd20 ec0b645a
>> >> 0000578f f67cfd20
>> >> [96283.704427]  d0a9a9a0 c107fdf8 81037be5 f5bdf1e8 f6021800 00000000
>> >> c107fe04 00200202
>> >> [96283.704449]  c107fe0c 00200202 f5bdf1b0 c107fe24 8117ddb1 00200202
>> >> f5bdf1b0 f5bdf1b8
>> >> [96283.704471] Call Trace:
>> >> [96283.704484]  [<81037be5>] ? queue_work_on+0x2d/0x39
>> >> [96283.704497]  [<8117ddb1>] ? put_io_context+0x52/0x6a
>> >> [96283.704510]  [<813b68f6>] schedule+0x56/0x58
>> >> [96283.704520]  [<81028525>] do_exit+0x63e/0x640
>> >
>> > Could you find out where this happens to be in the function?  If you
>> > enable CONFIG_DEBUG_INFO, you should be able to use gdb on vmlinux and
>> > find out with l *do_exit+0x63e.
>>
>> It looks like it's the final call to schedule() in do_exit():
>>
>>    0x81028520 <+1593>: call   0x813b68a0 <schedule>
>>    0x81028525 <+1598>: ud2a
>>
>> (gdb) l *do_exit+0x63e
>> 0x81028525 is in do_exit
>> (/home/semenzato/trunk/src/third_party/kernel/files/kernel/exit.c:1069).
>> 1064
>> 1065 /* causes final put_task_struct in finish_task_switch(). */
>> 1066 tsk->state = TASK_DEAD;
>> 1067 tsk->flags |= PF_NOFREEZE; /* tell freezer to ignore us */
>> 1068 schedule();
>> 1069 BUG();
>> 1070 /* Avoid "noreturn function does return".  */
>> 1071 for (;;)
>> 1072 cpu_relax(); /* For when BUG is null */
>> 1073 }
>>
>> Here's a theory: the thread exits fine, but the next scheduled thread
>> tries to allocate memory before or during finish_task_switch(), so the
>> dead thread is never cleaned up completely and is still considered
>> alive by the OOM killer.
>
> If next thread tries to allocate memory, he will enter direct reclaim path
> and there are some scheduling points in there so exit thread should be
> destroyed. :( In your previous mail, you said many processes are stuck at
> shrink_slab which already includes cond_resched. I can't see any problem.
> Hmm, Could you post entire debug log after you capture sysrq+t several time
> when hang happens?

Thank you so much for your continued assistance.

I have been using preserved memory to get the log, and sysrq+T
overflows the buffer (there are a few dozen processes).  To get the
trace for the process with TIF_MEMDIE set, I had to modify the sysrq+T
code so that it prints only that process.

To get a full trace of all processes I will have to open the device
and attach a debug header, so it will take some time.  What are we
looking for, though?  I see many processes running in shrink_slab(),
but they are not "stuck" there, they are just spending a lot of time
in there.

However, now there is something that worries me more.  The trace of
the thread with TIF_MEMDIE set shows that it has executed most of
do_exit() and appears to be waiting to be reaped.  From my reading of
the code, this implies that task->exit_state should be non-zero, which
means that select_bad_process should have skipped that thread, which
means that we cannot be in the deadlock situation, and my experiments
are not consistent.

I will add better instrumentation and report later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
