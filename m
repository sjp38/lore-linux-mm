Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C53B6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 03:48:59 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r141so23941405wmg.4
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 00:48:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y64si11317996wmy.110.2017.02.07.00.48.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 00:48:58 -0800 (PST)
Date: Tue, 7 Feb 2017 09:48:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207084855.GC5065@dhcp22.suse.cz>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon 06-02-17 22:05:30, Mel Gorman wrote:
> On Mon, Feb 06, 2017 at 08:13:35PM +0100, Dmitry Vyukov wrote:
> > On Mon, Jan 30, 2017 at 4:48 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> > > On Sun, Jan 29, 2017 at 6:22 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> > >> On 29.1.2017 13:44, Dmitry Vyukov wrote:
> > >>> Hello,
> > >>>
> > >>> I've got the following deadlock report while running syzkaller fuzzer
> > >>> on f37208bc3c9c2f811460ef264909dfbc7f605a60:
> > >>>
> > >>> [ INFO: possible circular locking dependency detected ]
> > >>> 4.10.0-rc5-next-20170125 #1 Not tainted
> > >>> -------------------------------------------------------
> > >>> syz-executor3/14255 is trying to acquire lock:
> > >>>  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff814271c7>]
> > >>> get_online_cpus+0x37/0x90 kernel/cpu.c:239
> > >>>
> > >>> but task is already holding lock:
> > >>>  (pcpu_alloc_mutex){+.+.+.}, at: [<ffffffff81937fee>]
> > >>> pcpu_alloc+0xbfe/0x1290 mm/percpu.c:897
> > >>>
> > >>> which lock already depends on the new lock.
> > >>
> > >> I suspect the dependency comes from recent changes in drain_all_pages(). They
> > >> were later redone (for other reasons, but nice to have another validation) in
> > >> the mmots patch [1], which AFAICS is not yet in mmotm and thus linux-next. Could
> > >> you try if it helps?
> > >
> > > It happened only once on linux-next, so I can't verify the fix. But I
> > > will watch out for other occurrences.
> > 
> > Unfortunately it does not seem to help.
> 
> I'm a little stuck on how to best handle this. get_online_cpus() can
> halt forever if the hotplug operation is holding the mutex when calling
> pcpu_alloc. One option would be to add a try_get_online_cpus() helper which
> trylocks the mutex. However, given that drain is so unlikely to actually
> make that make a difference when racing against parallel allocations,
> I think this should be acceptable.
> 
> Any objections?
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3b93879990fd..a3192447e906 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3432,7 +3432,17 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
>  	 */
>  	if (!page && !drained) {
>  		unreserve_highatomic_pageblock(ac, false);
> -		drain_all_pages(NULL);
> +
> +		/*
> +		 * Only drain from contexts allocating for user allocations.
> +		 * Kernel allocations could be holding a CPU hotplug-related
> +		 * mutex, particularly hot-add allocating per-cpu structures
> +		 * while hotplug-related mutex's are held which would prevent
> +		 * get_online_cpus ever returning.
> +		 */
> +		if (gfp_mask & __GFP_HARDWALL)
> +			drain_all_pages(NULL);
> +

This wouldn't work AFAICS. If you look at the lockdep splat, the path
which reverses the locking order (takes pcpu_alloc_mutex prior to
cpu_hotplug.lock is bpf_array_alloc_percpu which is GFP_USER and thus
__GFP_HARDWALL.

I believe we shouldn't pull any dependency on the hotplug locks inside
the allocator. This is just too fragile! Can we simply drop the
get_online_cpus()? Why do we need it, anyway? Say we are racing with the
cpu offlining. I have to check the code but my impression was that WQ
code will ignore the cpu requested by the work item when the cpu is
going offline. If the offline happens while the worker function already
executes then it has to wait as we run with preemption disabled so we
should be safe here. Or am I missing something obvious?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
