Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 6C4C06B006E
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:03:50 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so196711pbb.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 23:03:49 -0700 (PDT)
Date: Mon, 22 Oct 2012 23:03:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <20121022235321.GK13817@bbox>
Message-ID: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com> <20121015144412.GA2173@barrios> <CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com> <20121016061854.GB3934@barrios> <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
 <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com> <20121022235321.GK13817@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, 23 Oct 2012, Minchan Kim wrote:

> > I found the source, and maybe the cause, of the problem I am
> > experiencing when running out of memory with zram enabled.  It may be
> > a known problem.  The OOM killer doesn't find any killable process
> > because select_bad_process() keeps returning -1 here:
> > 
> >     /*
> >      * This task already has access to memory reserves and is
> >      * being killed. Don't allow any other task access to the
> >      * memory reserve.
> >      *
> >      * Note: this may have a chance of deadlock if it gets
> >      * blocked waiting for another task which itself is waiting
> >      * for memory. Is there a better alternative?
> >      */
> >     if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> >         if (unlikely(frozen(p)))
> >             __thaw_task(p);
> >         if (!force_kill)
> >             return ERR_PTR(-1UL);
> >     }
> > 
> > select_bad_process() is called by out_of_memory() in __alloc_page_may_oom().
> 
> I think it's not a zram problem but general problem of OOM killer.
> Above code's intention is to prevent shortage of ememgency memory pool for avoding
> deadlock. If we already killed any task and the task are in the middle of exiting,
> OOM killer will wait for him to be exited. But the problem in here is that
> killed task might wait any mutex which are held to another task which are
> stuck for the memory allocation and can't use emergency memory pool. :(

Yeah, there's always a problem if an oom killed process cannot exit 
because it's waiting for some other eligible process.  This doesn't 
normally happen for anything sharing the same mm, though, because we try 
to kill anything sharing the same mm when we select a process for oom kill 
and if those killed threads happen to call into the oom killer they 
silently get TIF_MEMDIE so they may exit as well.  This addressed earlier 
problems we had with things waiting on mm->mmap_sem in the exit path.

If the oom killed process cannot exit because it's waiting on another 
eligible process that does not share the mm, then we'll potentially 
livelock unless you do echo f > /proc/sysrq-trigger manually or turn on 
/proc/sys/vm/oom_kill_allocating_task.

> I think one of solution is that if it takes some seconed(ex, 3 sec) after we already
> kill some task but still looping with above code, we can allow accessing of
> ememgency memory pool for another task. It may happen deadlock due to burn out memory
> pool but otherwise, we still suffer from deadlock.
> 

The problem there is that if the time limit expires (we used 10 seconds 
before internally, we don't do it at all anymore) and there are no more 
eligible threads that you unnecessarily panic, or open yourself up to a 
complete depletion of memory reserves whereas not even the oom killer can 
help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
