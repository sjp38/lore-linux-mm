Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2524E6B0069
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:03:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u63so31096313wmu.0
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:03:35 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id j21si9234129wrb.212.2017.02.08.06.03.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 06:03:33 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 37EC898E8E
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 14:03:33 +0000 (UTC)
Date: Wed, 8 Feb 2017 14:03:32 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170208140332.syic3peyfavd3kl6@techsingularity.net>
References: <20170207141911.GR5065@dhcp22.suse.cz>
 <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net>
 <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org>
 <alpine.DEB.2.20.1702072319200.8117@nanos>
 <20170208073527.GA5686@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702081253590.3536@nanos>
 <20170208122612.wasq72hbj4nkh7y3@techsingularity.net>
 <alpine.DEB.2.20.1702081419500.3536@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1702081419500.3536@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Feb 08, 2017 at 02:23:19PM +0100, Thomas Gleixner wrote:
> On Wed, 8 Feb 2017, Mel Gorman wrote:
> > It may be worth noting that patches in Andrew's tree no longer disable
> > interrupts in the per-cpu allocator and now per-cpu draining will
> > be from workqueue context. The reasoning was due to the overhead of
> > the page allocator with figures included. Interrupts will bypass the
> > per-cpu allocator and use the irq-safe zone->lock to allocate from
> > the core.  It'll collide with the RT patch. Primary patch of interest is
> > http://www.ozlabs.org/~akpm/mmots/broken-out/mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
> 
> Yeah, we'll sort that out once it hits Linus tree and we move RT forward.
> Though I have once complaint right away:
> 
> +	preempt_enable_no_resched();
> 
> This is a nono, even in mainline. You effectively disable a preemption
> point.
> 

This came up during review on whether it should or shouldn't be a preemption
point. Initially it was preempt_enable() but a preemption point didn't
exist before, the reviewer pushed for it and as it was the allocator fast
path that was unlikely to need a reschedule or preempt, I made the change.

I can alter it before it hits mainline if you say RT is going to have an
issue with it.

> > The draining from workqueue context may be a problem for RT but one
> > option would be to move the drain to only drain for high-order pages
> > after direct reclaim combined with only draining for order-0 if
> > __alloc_pages_may_oom is about to be called.
> 
> Why would the draining from workqueue context be an issue on RT?
> 

It probably isn't. The latency of the operation is likely longer than an IPI
was but given the context it occurs in, I severely doubted it mattered. I
couldn't think of a reason why it would matter to RT but there was no harm
double checking.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
