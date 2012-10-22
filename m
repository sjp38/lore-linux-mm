Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C427E6B0093
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 19:48:05 -0400 (EDT)
Date: Tue, 23 Oct 2012 08:53:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram OOM behavior
Message-ID: <20121022235321.GK13817@bbox>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
 <20121015144412.GA2173@barrios>
 <CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com>
 <20121016061854.GB3934@barrios>
 <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
 <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi, 

Sorry for late response. I was traveling at that time and still suffer from
training course I never want. :(

On Fri, Oct 19, 2012 at 10:49:22AM -0700, Luigi Semenzato wrote:
> I found the source, and maybe the cause, of the problem I am
> experiencing when running out of memory with zram enabled.  It may be
> a known problem.  The OOM killer doesn't find any killable process
> because select_bad_process() keeps returning -1 here:
> 
>     /*
>      * This task already has access to memory reserves and is
>      * being killed. Don't allow any other task access to the
>      * memory reserve.
>      *
>      * Note: this may have a chance of deadlock if it gets
>      * blocked waiting for another task which itself is waiting
>      * for memory. Is there a better alternative?
>      */
>     if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
>         if (unlikely(frozen(p)))
>             __thaw_task(p);
>         if (!force_kill)
>             return ERR_PTR(-1UL);
>     }
> 
> select_bad_process() is called by out_of_memory() in __alloc_page_may_oom().

I think it's not a zram problem but general problem of OOM killer.
Above code's intention is to prevent shortage of ememgency memory pool for avoding
deadlock. If we already killed any task and the task are in the middle of exiting,
OOM killer will wait for him to be exited. But the problem in here is that
killed task might wait any mutex which are held to another task which are
stuck for the memory allocation and can't use emergency memory pool. :(
It's a another deadlock, too. AFAIK, it's known problem and I'm not sure
OOM guys have a good idea. Cc'ed them.
I think one of solution is that if it takes some seconed(ex, 3 sec) after we already
kill some task but still looping with above code, we can allow accessing of
ememgency memory pool for another task. It may happen deadlock due to burn out memory
pool but otherwise, we still suffer from deadlock.

> 
> If this is the problem, I'd love to hear about solutions!
> 
> <BEGIN SHAMELESS PLUG>
> if we can get this to work, it will help keep the cost of laptops down!
> http://www.google.com/intl/en/chrome/devices/
> <END SHAMELESS PLUG>
> 
> P.S. Chromebooks are sweet things for kernel debugging because they
> boot so quickly (5-10s depending on the model).

But I think mainline kernel doesn't boot on that. :(

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
