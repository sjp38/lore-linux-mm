Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 8DC5D8D0003
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 15:12:03 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id c4so2862184qae.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 12:12:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
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
	<CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
	<alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
Date: Tue, 30 Oct 2012 12:12:02 -0700
Message-ID: <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com>
Subject: Re: zram OOM behavior
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Mon, Oct 29, 2012 at 10:41 PM, David Rientjes <rientjes@google.com> wrote:
> On Mon, 29 Oct 2012, Luigi Semenzato wrote:
>
>> However, now there is something that worries me more.  The trace of
>> the thread with TIF_MEMDIE set shows that it has executed most of
>> do_exit() and appears to be waiting to be reaped.  From my reading of
>> the code, this implies that task->exit_state should be non-zero, which
>> means that select_bad_process should have skipped that thread, which
>> means that we cannot be in the deadlock situation, and my experiments
>> are not consistent.
>>
>
> Yeah, this is what I was referring to earlier, select_bad_process() will
> not consider the thread for which you posted a stack trace for oom kill,
> so it's not deferring because of it.  There are either other thread(s)
> that have been oom killed and have not yet release their memory or the oom
> killer is never being called.

Thanks.  I now have better information on what's happening.

The "culprit" is not the OOM-killed process (the one with TIF_MEMDIE
set).  It's another process that's exiting for some other reason.

select_bad_process() checks for thread->exit_state at the beginning,
and skips processes that are exiting.  But later it checks for
p->flags & PF_EXITING, and can return -1 in that case (and it does for
me).

It turns out that do_exit() does a lot of things between setting the
thread->flags PF_EXITING bit (in exit_signals()) and setting
thread->exit_state to non-zero (in exit_notify()).  Some of those
things apparently need memory.  I caught one process responsible for
the PTR_ERR(-1) while it was doing this:

[  191.859358] VC manager      R running      0  2388   1108 0x00000104
[  191.859377] err_ptr_count = 45623
[  191.859384]  e0611b1c 00200086 f5608000 815ecd20 815ecd20 a0a9ebc3
0000002c f67cfd20
[  191.859407]  f430a060 81191c34 e0611aec 81196d79 4168ef20 00000001
e1302400 e130264c
[  191.859428]  e1302400 e0611af4 813b71d5 e0611b00 810b42f1 e1302400
e0611b0c 810b430e
[  191.859450] Call Trace:
[  191.859465]  [<81191c34>] ? __delay+0xe/0x10
[  191.859478]  [<81196d79>] ? do_raw_spin_lock+0xa2/0xf3
[  191.859491]  [<813b71d5>] ? _raw_spin_unlock+0xd/0xf
[  191.859504]  [<810b42f1>] ? put_super+0x26/0x29
[  191.859515]  [<810b430e>] ? drop_super+0x1a/0x1d
[  191.859527]  [<8104512d>] __cond_resched+0x1b/0x2b
[  191.859537]  [<813b67a7>] _cond_resched+0x18/0x21
[  191.859549]  [<81093940>] shrink_slab+0x224/0x22f
[  191.859562]  [<81095a96>] try_to_free_pages+0x1b7/0x2e6
[  191.859574]  [<8108df2a>] __alloc_pages_nodemask+0x40a/0x61f
[  191.859588]  [<810a9dbe>] read_swap_cache_async+0x4a/0xcf
[  191.859600]  [<810a9ea4>] swapin_readahead+0x61/0x8d
[  191.859612]  [<8109fff4>] handle_pte_fault+0x310/0x5fb
[  191.859624]  [<810a0420>] handle_mm_fault+0xae/0xbd
[  191.859637]  [<8101d0f9>] do_page_fault+0x265/0x284
[  191.859648]  [<8104aa17>] ? dequeue_entity+0x236/0x252
[  191.859660]  [<8101ce94>] ? vmalloc_sync_all+0xa/0xa
[  191.859672]  [<813b7887>] error_code+0x67/0x6c
[  191.859683]  [<81191d21>] ? __get_user_4+0x11/0x17
[  191.859695]  [<81059f28>] ? exit_robust_list+0x30/0x105
[  191.859707]  [<813b71b0>] ? _raw_spin_unlock_irq+0xd/0x10
[  191.859718]  [<810446d5>] ? finish_task_switch+0x53/0x89
[  191.859730]  [<8102351d>] mm_release+0x1d/0xc3
[  191.859740]  [<81026ce9>] exit_mm+0x1d/0xe9
[  191.859750]  [<81032b87>] ? exit_signals+0x57/0x10a
[  191.859760]  [<81028082>] do_exit+0x19b/0x640
[  191.859770]  [<81058598>] ? futex_wait_queue_me+0xaa/0xbe
[  191.859781]  [<81030bbf>] ? recalc_sigpending_tsk+0x51/0x5c
[  191.859793]  [<81030beb>] ? recalc_sigpending+0x17/0x3e
[  191.859803]  [<81028752>] do_group_exit+0x63/0x86
[  191.859813]  [<81032b19>] get_signal_to_deliver+0x434/0x44b
[  191.859825]  [<81001e01>] do_signal+0x37/0x4fe
[  191.859837]  [<81048eed>] ? set_next_entity+0x36/0x9d
[  191.859850]  [<81050d8e>] ? timekeeping_get_ns+0x11/0x55
[  191.859861]  [<8105a754>] ? sys_futex+0xcb/0xdb
[  191.859871]  [<810024a7>] do_notify_resume+0x26/0x65
[  191.859883]  [<813b73a5>] work_notifysig+0xa/0x11
[  191.859893] Kernel panic - not syncing: too many ERR_PTR

I don't know why mm_release() would page fault, but it looks like it does.

So the OOM killer will not kill other processes because it thinks a
process is exiting, which will free up memory.  But the exiting
process needs memory to continue exiting --> deadlock.  Sounds
plausible?

OK, now someone is going to fix this, right? :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
