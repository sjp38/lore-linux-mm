Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 9DA236B006E
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 18:52:16 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so5001784pbb.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 15:52:15 -0700 (PDT)
Date: Mon, 29 Oct 2012 15:52:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210291542110.22995@chino.kir.corp.google.com>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com> <20121015144412.GA2173@barrios> <CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com> <20121016061854.GB3934@barrios> <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
 <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com> <20121022235321.GK13817@bbox> <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
 <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 29 Oct 2012, Luigi Semenzato wrote:

> It looks like it's the final call to schedule() in do_exit():
> 
>    0x81028520 <+1593>: call   0x813b68a0 <schedule>
>    0x81028525 <+1598>: ud2a
> 
> (gdb) l *do_exit+0x63e
> 0x81028525 is in do_exit
> (/home/semenzato/trunk/src/third_party/kernel/files/kernel/exit.c:1069).
> 1064
> 1065 /* causes final put_task_struct in finish_task_switch(). */
> 1066 tsk->state = TASK_DEAD;
> 1067 tsk->flags |= PF_NOFREEZE; /* tell freezer to ignore us */
> 1068 schedule();
> 1069 BUG();
> 1070 /* Avoid "noreturn function does return".  */
> 1071 for (;;)
> 1072 cpu_relax(); /* For when BUG is null */
> 1073 }
> 

You're using an older kernel since the code you quoted from the oom killer 
hasn't had the per-memcg oom kill rewrite.  There's logic that is called 
from select_bad_process() that should exclude this thread from being 
considered and deferred since it has a non-zero task->exit_thread, i.e. in 
oom_scan_process_thread():

	if (task->exit_state)
		return OOM_SCAN_CONTINUE;

And that's called from both the global oom killer and memcg oom killer.  
So I'm thinking you're either running on an older kernel or there is no 
oom condition at the time this is captured.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
