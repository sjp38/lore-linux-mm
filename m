Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2E2B36B006C
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 19:23:38 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id c4so2198080qae.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 16:23:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210291542110.22995@chino.kir.corp.google.com>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
	<20121015144412.GA2173@barrios>
	<CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com>
	<20121016061854.GB3934@barrios>
	<CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
	<CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
	<20121022235321.GK13817@bbox>
	<alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
	<CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
	<alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
	<CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
	<alpine.DEB.2.00.1210291542110.22995@chino.kir.corp.google.com>
Date: Mon, 29 Oct 2012 16:23:36 -0700
Message-ID: <CAA25o9TXbJMxkq=Z6h4Viar1UAOkQ3jyJ0hk_Y9zikuwn-en7w@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, Oct 29, 2012 at 3:52 PM, David Rientjes <rientjes@google.com> wrote:
> On Mon, 29 Oct 2012, Luigi Semenzato wrote:
>
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
>
> You're using an older kernel since the code you quoted from the oom killer
> hasn't had the per-memcg oom kill rewrite.  There's logic that is called
> from select_bad_process() that should exclude this thread from being
> considered and deferred since it has a non-zero task->exit_thread, i.e. in
> oom_scan_process_thread():
>
>         if (task->exit_state)
>                 return OOM_SCAN_CONTINUE;
>
> And that's called from both the global oom killer and memcg oom killer.
> So I'm thinking you're either running on an older kernel or there is no
> oom condition at the time this is captured.

Very sorry, I never said that we're on kernel 3.4.0.

We are in a OOM-kill situation:

./arch/x86/include/asm/thread_info.h:91:#define TIF_MEMDIE 20

Bit 20 in the threadinfo flags is set:

> [96283.704390] chrome          x 815ecd20     0 16573   1112 0x00100104

So your suggestion would be to apply OOM-related patches from a later kernel?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
