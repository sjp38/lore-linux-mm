Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id DCA1F6B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 13:49:23 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so536089qcq.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 10:49:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
References: <CAA25o9TmsnR3T+CLk5LeRmXv3s8b719KrSU6C919cAu0YMKPkA@mail.gmail.com>
	<20121015144412.GA2173@barrios>
	<CAA25o9R53oJajrzrWcLSAXcjAd45oQ4U+gJ3Mq=bthD3HGRaFA@mail.gmail.com>
	<20121016061854.GB3934@barrios>
	<CAA25o9R5OYSMZ=Rs2qy9rPk3U9yaGLLXVB60Yncqvmf3Y_Xbvg@mail.gmail.com>
Date: Fri, 19 Oct 2012 10:49:22 -0700
Message-ID: <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>

I found the source, and maybe the cause, of the problem I am
experiencing when running out of memory with zram enabled.  It may be
a known problem.  The OOM killer doesn't find any killable process
because select_bad_process() keeps returning -1 here:

    /*
     * This task already has access to memory reserves and is
     * being killed. Don't allow any other task access to the
     * memory reserve.
     *
     * Note: this may have a chance of deadlock if it gets
     * blocked waiting for another task which itself is waiting
     * for memory. Is there a better alternative?
     */
    if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
        if (unlikely(frozen(p)))
            __thaw_task(p);
        if (!force_kill)
            return ERR_PTR(-1UL);
    }

select_bad_process() is called by out_of_memory() in __alloc_page_may_oom().

If this is the problem, I'd love to hear about solutions!

<BEGIN SHAMELESS PLUG>
if we can get this to work, it will help keep the cost of laptops down!
http://www.google.com/intl/en/chrome/devices/
<END SHAMELESS PLUG>

P.S. Chromebooks are sweet things for kernel debugging because they
boot so quickly (5-10s depending on the model).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
