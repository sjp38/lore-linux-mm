Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78EAB6B0038
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 12:31:51 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 72so5038743uaf.7
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:31:51 -0700 (PDT)
Received: from mail-vk0-x244.google.com (mail-vk0-x244.google.com. [2607:f8b0:400c:c05::244])
        by mx.google.com with ESMTPS id t11si746712uaa.39.2017.03.15.09.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 09:31:50 -0700 (PDT)
Received: by mail-vk0-x244.google.com with SMTP id r136so1523390vke.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:31:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170315073928.GA32620@dhcp22.suse.cz>
References: <20170307131751.24936-1-mhocko@kernel.org> <CADRPPNT9zyc_0sg0eoZEMbTQ+mCHAkmzmHW93zHaOuzpALtzrg@mail.gmail.com>
 <20170313095836.GI31518@dhcp22.suse.cz> <CADRPPNRE_fEKjdNmSAqEJBAFJ_xDmiJQJk=Hnc16ymC2z_z8jQ@mail.gmail.com>
 <20170315073928.GA32620@dhcp22.suse.cz>
From: Yang Li <pku.leo@gmail.com>
Date: Wed, 15 Mar 2017 11:31:49 -0500
Message-ID: <CADRPPNSN4eULYX1nG0_nir75bfB_c1EbmRTBiQGeOZ3ccORT_w@mail.gmail.com>
Subject: Re: [PATCH] mm: move pcp and lru-pcp drainging into single wq
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Li Yang <leoyang.li@nxp.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, Mar 15, 2017 at 2:39 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 14-03-17 18:07:38, Yang Li wrote:
>> On Mon, Mar 13, 2017 at 4:58 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Fri 10-03-17 17:31:56, Yang Li wrote:
>> >> On Tue, Mar 7, 2017 at 7:17 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> > From: Michal Hocko <mhocko@suse.com>
>> >> >
>> >> > We currently have 2 specific WQ_RECLAIM workqueues in the mm code.
>> >> > vmstat_wq for updating pcp stats and lru_add_drain_wq dedicated to drain
>> >> > per cpu lru caches. This seems more than necessary because both can run
>> >> > on a single WQ. Both do not block on locks requiring a memory allocation
>> >> > nor perform any allocations themselves. We will save one rescuer thread
>> >> > this way.
>> >> >
>> >> > On the other hand drain_all_pages() queues work on the system wq which
>> >> > doesn't have rescuer and so this depend on memory allocation (when all
>> >> > workers are stuck allocating and new ones cannot be created). This is
>> >> > not critical as there should be somebody invoking the OOM killer (e.g.
>> >> > the forking worker) and get the situation unstuck and eventually
>> >> > performs the draining. Quite annoying though. This worker should be
>> >> > using WQ_RECLAIM as well. We can reuse the same one as for lru draining
>> >> > and vmstat.
>> >> >
>> >> > Changes since v1
>> >> > - rename vmstat_wq to mm_percpu_wq - per Mel
>> >> > - make sure we are not trying to enqueue anything while the WQ hasn't
>> >> >   been intialized yet. This shouldn't happen because the initialization
>> >> >   is done from an init code but some init section might be triggering
>> >> >   those paths indirectly so just warn and skip the draining in that case
>> >> >   per Vlastimil
>> >>
>> >> So what's the plan if this really happens?  Shall we put the
>> >> initialization of the mm_percpu_wq earlier?
>> >
>> > yes
>> >
>> >> Or if it is really harmless we can probably remove the warnings.
>> >
>> > Yeah, it is harmless but if we can move it earlier then it would be
>> > prefferable to fix this.
>> >
>> >>
>> >> I'm seeing this on arm64 with a linux-next tree:
>> > [...]
>> >> [    0.279000] [<ffffff80081636bc>] drain_all_pages+0x244/0x25c
>> >> [    0.279065] [<ffffff80081c675c>] start_isolate_page_range+0x14c/0x1f0
>> >> [    0.279137] [<ffffff8008166a48>] alloc_contig_range+0xec/0x354
>> >> [    0.279203] [<ffffff80081c6c5c>] cma_alloc+0x100/0x1fc
>> >> [    0.279263] [<ffffff8008481714>] dma_alloc_from_contiguous+0x3c/0x44
>> >> [    0.279336] [<ffffff8008b25720>] atomic_pool_init+0x7c/0x208
>> >> [    0.279399] [<ffffff8008b258f0>] arm64_dma_init+0x44/0x4c
>> >> [    0.279461] [<ffffff8008083144>] do_one_initcall+0x38/0x128
>> >> [    0.279525] [<ffffff8008b20d30>] kernel_init_freeable+0x1a0/0x240
>> >> [    0.279596] [<ffffff8008807778>] kernel_init+0x10/0xfc
>> >> [    0.279654] [<ffffff8008082b70>] ret_from_fork+0x10/0x20
>> >
>> > The following should address this. I didn't get to test it yet though.
>> > ---
>> > diff --git a/include/linux/mm.h b/include/linux/mm.h
>> > index 21ee5503c702..8362dca071cb 100644
>> > --- a/include/linux/mm.h
>> > +++ b/include/linux/mm.h
>> > @@ -32,6 +32,8 @@ struct user_struct;
>> >  struct writeback_control;
>> >  struct bdi_writeback;
>> >
>> > +void init_mm_internals(void);
>> > +
>> >  #ifndef CONFIG_NEED_MULTIPLE_NODES     /* Don't use mapnrs, do it properly */
>> >  extern unsigned long max_mapnr;
>> >
>> > diff --git a/init/main.c b/init/main.c
>> > index 51aa8f336819..c72d35250e84 100644
>> > --- a/init/main.c
>> > +++ b/init/main.c
>> > @@ -1023,6 +1023,8 @@ static noinline void __init kernel_init_freeable(void)
>> >
>> >         workqueue_init();
>> >
>> > +       init_mm_internals();
>> > +
>> >         do_pre_smp_initcalls();
>> >         lockup_detector_init();
>> >
>> > diff --git a/mm/vmstat.c b/mm/vmstat.c
>> > index 4bbc775f9d08..d0871fc1aeca 100644
>> > --- a/mm/vmstat.c
>> > +++ b/mm/vmstat.c
>> > @@ -1762,7 +1762,7 @@ static int vmstat_cpu_dead(unsigned int cpu)
>> >
>> >  struct workqueue_struct *mm_percpu_wq;
>> >
>> > -static int __init setup_vmstat(void)
>> > +void __init init_mm_internals(void)
>> >  {
>> >         int ret __maybe_unused;
>> >
>> > @@ -1792,9 +1792,7 @@ static int __init setup_vmstat(void)
>> >         proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
>> >         proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
>> >  #endif
>> > -       return 0;
>> >  }
>> > -module_init(setup_vmstat)
>> >
>> >  #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
>>
>> I did a test on arm64.  This do fix the warnings.
>
> Thanks! Can I assume your
> Tested-by: Yang Li <pku.leo@gmail.com>

Sure.

Tested-by: Li Yang <pku.leo@gmail.com>

Regards,
Leo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
