Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id D2F516B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:18:51 -0400 (EDT)
Date: Wed, 31 Oct 2012 16:24:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram OOM behavior
Message-ID: <20121031072446.GS15767@bbox>
References: <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
 <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
 <20121030001809.GL15767@bbox>
 <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
 <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
 <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com>
 <20121031005738.GM15767@bbox>
 <CAA25o9QhkQfZi+UVOjj0JBkNo8Vmt22ATUP25LFqkS-cDoq85Q@mail.gmail.com>
 <20121031012720.GO15767@bbox>
 <CAA25o9QRr-wBHG0uY8UOOumUq_Er4shnmLWaXh3voY=1pvvWkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9QRr-wBHG0uY8UOOumUq_Er4shnmLWaXh3voY=1pvvWkA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>, Mandeep Baines <msb@google.com>

On Tue, Oct 30, 2012 at 08:49:26PM -0700, Luigi Semenzato wrote:
> On Tue, Oct 30, 2012 at 6:27 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Tue, Oct 30, 2012 at 06:06:56PM -0700, Luigi Semenzato wrote:
> >> On Tue, Oct 30, 2012 at 5:57 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> > Hi Luigi,
> >> >
> >> > On Tue, Oct 30, 2012 at 12:12:02PM -0700, Luigi Semenzato wrote:
> >> >> On Mon, Oct 29, 2012 at 10:41 PM, David Rientjes <rientjes@google.com> wrote:
> >> >> > On Mon, 29 Oct 2012, Luigi Semenzato wrote:
> >> >> >
> >> >> >> However, now there is something that worries me more.  The trace of
> >> >> >> the thread with TIF_MEMDIE set shows that it has executed most of
> >> >> >> do_exit() and appears to be waiting to be reaped.  From my reading of
> >> >> >> the code, this implies that task->exit_state should be non-zero, which
> >> >> >> means that select_bad_process should have skipped that thread, which
> >> >> >> means that we cannot be in the deadlock situation, and my experiments
> >> >> >> are not consistent.
> >> >> >>
> >> >> >
> >> >> > Yeah, this is what I was referring to earlier, select_bad_process() will
> >> >> > not consider the thread for which you posted a stack trace for oom kill,
> >> >> > so it's not deferring because of it.  There are either other thread(s)
> >> >> > that have been oom killed and have not yet release their memory or the oom
> >> >> > killer is never being called.
> >> >>
> >> >> Thanks.  I now have better information on what's happening.
> >> >>
> >> >> The "culprit" is not the OOM-killed process (the one with TIF_MEMDIE
> >> >> set).  It's another process that's exiting for some other reason.
> >> >>
> >> >> select_bad_process() checks for thread->exit_state at the beginning,
> >> >> and skips processes that are exiting.  But later it checks for
> >> >> p->flags & PF_EXITING, and can return -1 in that case (and it does for
> >> >> me).
> >> >>
> >> >> It turns out that do_exit() does a lot of things between setting the
> >> >> thread->flags PF_EXITING bit (in exit_signals()) and setting
> >> >> thread->exit_state to non-zero (in exit_notify()).  Some of those
> >> >> things apparently need memory.  I caught one process responsible for
> >> >> the PTR_ERR(-1) while it was doing this:
> >> >>
> >> >> [  191.859358] VC manager      R running      0  2388   1108 0x00000104
> >> >> [  191.859377] err_ptr_count = 45623
> >> >> [  191.859384]  e0611b1c 00200086 f5608000 815ecd20 815ecd20 a0a9ebc3
> >> >> 0000002c f67cfd20
> >> >> [  191.859407]  f430a060 81191c34 e0611aec 81196d79 4168ef20 00000001
> >> >> e1302400 e130264c
> >> >> [  191.859428]  e1302400 e0611af4 813b71d5 e0611b00 810b42f1 e1302400
> >> >> e0611b0c 810b430e
> >> >> [  191.859450] Call Trace:
> >> >> [  191.859465]  [<81191c34>] ? __delay+0xe/0x10
> >> >> [  191.859478]  [<81196d79>] ? do_raw_spin_lock+0xa2/0xf3
> >> >> [  191.859491]  [<813b71d5>] ? _raw_spin_unlock+0xd/0xf
> >> >> [  191.859504]  [<810b42f1>] ? put_super+0x26/0x29
> >> >> [  191.859515]  [<810b430e>] ? drop_super+0x1a/0x1d
> >> >> [  191.859527]  [<8104512d>] __cond_resched+0x1b/0x2b
> >> >> [  191.859537]  [<813b67a7>] _cond_resched+0x18/0x21
> >> >> [  191.859549]  [<81093940>] shrink_slab+0x224/0x22f
> >> >> [  191.859562]  [<81095a96>] try_to_free_pages+0x1b7/0x2e6
> >> >> [  191.859574]  [<8108df2a>] __alloc_pages_nodemask+0x40a/0x61f
> >> >> [  191.859588]  [<810a9dbe>] read_swap_cache_async+0x4a/0xcf
> >> >> [  191.859600]  [<810a9ea4>] swapin_readahead+0x61/0x8d
> >> >> [  191.859612]  [<8109fff4>] handle_pte_fault+0x310/0x5fb
> >> >> [  191.859624]  [<810a0420>] handle_mm_fault+0xae/0xbd
> >> >> [  191.859637]  [<8101d0f9>] do_page_fault+0x265/0x284
> >> >> [  191.859648]  [<8104aa17>] ? dequeue_entity+0x236/0x252
> >> >> [  191.859660]  [<8101ce94>] ? vmalloc_sync_all+0xa/0xa
> >> >> [  191.859672]  [<813b7887>] error_code+0x67/0x6c
> >> >> [  191.859683]  [<81191d21>] ? __get_user_4+0x11/0x17
> >> >> [  191.859695]  [<81059f28>] ? exit_robust_list+0x30/0x105
> >> >> [  191.859707]  [<813b71b0>] ? _raw_spin_unlock_irq+0xd/0x10
> >> >> [  191.859718]  [<810446d5>] ? finish_task_switch+0x53/0x89
> >> >> [  191.859730]  [<8102351d>] mm_release+0x1d/0xc3
> >> >> [  191.859740]  [<81026ce9>] exit_mm+0x1d/0xe9
> >> >> [  191.859750]  [<81032b87>] ? exit_signals+0x57/0x10a
> >> >> [  191.859760]  [<81028082>] do_exit+0x19b/0x640
> >> >> [  191.859770]  [<81058598>] ? futex_wait_queue_me+0xaa/0xbe
> >> >> [  191.859781]  [<81030bbf>] ? recalc_sigpending_tsk+0x51/0x5c
> >> >> [  191.859793]  [<81030beb>] ? recalc_sigpending+0x17/0x3e
> >> >> [  191.859803]  [<81028752>] do_group_exit+0x63/0x86
> >> >> [  191.859813]  [<81032b19>] get_signal_to_deliver+0x434/0x44b
> >> >> [  191.859825]  [<81001e01>] do_signal+0x37/0x4fe
> >> >> [  191.859837]  [<81048eed>] ? set_next_entity+0x36/0x9d
> >> >> [  191.859850]  [<81050d8e>] ? timekeeping_get_ns+0x11/0x55
> >> >> [  191.859861]  [<8105a754>] ? sys_futex+0xcb/0xdb
> >> >> [  191.859871]  [<810024a7>] do_notify_resume+0x26/0x65
> >> >> [  191.859883]  [<813b73a5>] work_notifysig+0xa/0x11
> >> >> [  191.859893] Kernel panic - not syncing: too many ERR_PTR
> >> >>
> >> >> I don't know why mm_release() would page fault, but it looks like it does.
> >> >>
> >> >> So the OOM killer will not kill other processes because it thinks a
> >> >> process is exiting, which will free up memory.  But the exiting
> >> >> process needs memory to continue exiting --> deadlock.  Sounds
> >> >> plausible?
> >> >
> >> > It sounds right in your kernel but principal problem is min_filelist_kbytes patch.
> >> > If normal exited process in exit path requires a page and there is no free page
> >> > any more, it ends up going to OOM path after try to reclaim memory several time.
> >> > Then,
> >> > In select_bad_process,
> >> >
> >> >         if (task->flags & PF_EXITING) {
> >> >                if (task == current)             <== true
> >> >                         return OOM_SCAN_SELECT;
> >> > In oom_kill_process,
> >> >
> >> >         if (p->flags & PF_EXITING)
> >> >                 set_tsk_thread_flag(p, TIF_MEMDIE);
> >> >
> >> > At last, normal exited process would get a free page.
> >> >
> >> > But in your kernel, it seems not because I guess did_some_progress in
> >> > __alloc_pages_direct_reclaim is never 0. The why it is never 0 is
> >> > do_try_to_free_pages's all_unreclaimable can't do his role by your
> >> > min_filelist_kbytes. It makes __alloc_pages_slowpath's looping forever.
> >> >
> >> > Sounds plausible?
> >>
> >> Thank you Minchan, it does sound plausible, but I have little
> >> experience with this and it will take some work to confirm.
> >
> > No problem :)
> >
> >>
> >> I looked at the patch pretty carefully once, and I had the impression
> >> its effect could be fully analyzed by logical reasoning. I will check
> >> this again tomorrow, perhaps I can run some experiments.  I am adding
> >> Mandeep who wrote the patch.
> >>
> >> However, we have worse problems if we don't use that patch.  Without
> >> the patch, and either with or without compressed swap, the same load
> >> causes horrible thrashing, with the system appearing to hang for
> >> minutes.  If we don't use that patch, do you have any suggestion on
> >> how to improve the code thrash situation?
> >
> > As I said, the motivation of the patch is good for embedded system but
> > patch's implementation is kinda buggy. I will have a look and post if
> > I'm luck to get a time.
> >
> > BTW, a question.
> >
> > How do you find proper value for min_filelist_kbytes?
> > Just experiment with several trial?
> >
> > Thanks.
> 
> Yes.  Mandeep can give more detail, but, as I understand this, the
> value we use (50 Mb) was based on experimentation.  It helps that at
> the moment we run Chrome OS on a relatively uniform set of devices,
> with either 2 or 4 GB of RAM, no swap, binaries stored on SSD (for
> backing store of text pages), and the same load (the Chrome browser).
> 

AFAIRC, I recommended mem_notify instead of hacky patch when Mandeep submitted
at the beginning. Does it have any problem?
AFAIK, mem_notify had a problem to notify too late so OOM kill still happens.
Recently, Anton have been tried new low memory notifier and It should solve 
same problem and then it's thing you need.
https://patchwork.kernel.org/patch/1625251/

Of course, there are further steps to merge it but I think you can help us
with some experiments and input your voice to meet Chrome OS's goal.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
