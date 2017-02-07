Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B8F736B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 04:43:02 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id ez4so24267568wjd.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 01:43:02 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id s42si4377813wrc.28.2017.02.07.01.43.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 01:43:01 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id E7F5B98C28
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 09:43:00 +0000 (UTC)
Date: Tue, 7 Feb 2017 09:43:00 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170207084855.GC5065@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 07, 2017 at 09:48:56AM +0100, Michal Hocko wrote:
> > +
> > +		/*
> > +		 * Only drain from contexts allocating for user allocations.
> > +		 * Kernel allocations could be holding a CPU hotplug-related
> > +		 * mutex, particularly hot-add allocating per-cpu structures
> > +		 * while hotplug-related mutex's are held which would prevent
> > +		 * get_online_cpus ever returning.
> > +		 */
> > +		if (gfp_mask & __GFP_HARDWALL)
> > +			drain_all_pages(NULL);
> > +
> 
> This wouldn't work AFAICS. If you look at the lockdep splat, the path
> which reverses the locking order (takes pcpu_alloc_mutex prior to
> cpu_hotplug.lock is bpf_array_alloc_percpu which is GFP_USER and thus
> __GFP_HARDWALL.
> 

You're right, I looked at the wrong caller.

> I believe we shouldn't pull any dependency on the hotplug locks inside
> the allocator. This is just too fragile! Can we simply drop the
> get_online_cpus()? Why do we need it, anyway?

To stop the CPU being queued going offline. Another alternative is bringing
back try_get_offline_cpus which Peter pointed out to be offline was removed
in commit 02ef3c4a2aae65a1632b27770bfea3f83ca06772 although it'd be a
shame for just this case.

> Say we are racing with the
> cpu offlining. I have to check the code but my impression was that WQ
> code will ignore the cpu requested by the work item when the cpu is
> going offline. If the offline happens while the worker function already
> executes then it has to wait as we run with preemption disabled so we
> should be safe here. Or am I missing something obvious?

It may be safe but I'd prefer to get confirmation from Tejun. If it happens
that a drain on a particular CPU gets missed in this path, it's not the
end of the world as the CPU offlining drains the pages in another path so
nothing gets lost.

It would also be acceptable if one CPU was drained twice because the
workqueue was unbound from a CPU being hot-removed and moved during a
hotplug operation.

If I'm reading this right, a hot-remove will set the pool POOL_DISASSOCIATED
and unbound. A workqueue queued for draining get migrated during hot-remove
and a drain operation will execute twice on a CPU -- one for what was
queued and a second time for the CPU it was migrated from. It should still
work with flush_work which doesn't appear to block forever if an item
got migrated to another workqueue. The actual drain workqueue function is
using the CPU ID it's currently running on so it shouldn't get confused.

Tejun, did I miss anything? Does a workqueue item queued on a CPU being
offline get unbound and a caller can still flush it safely? In this
specific case, it's ok that the workqueue item does not run on the CPU it
was queued on.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
