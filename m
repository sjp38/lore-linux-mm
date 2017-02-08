Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0B1A6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 08:23:26 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id a15so5368803wrc.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 05:23:26 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id q68si2398792wmb.9.2017.02.08.05.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 05:23:25 -0800 (PST)
Date: Wed, 8 Feb 2017 14:23:19 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <20170208122612.wasq72hbj4nkh7y3@techsingularity.net>
Message-ID: <alpine.DEB.2.20.1702081419500.3536@nanos>
References: <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702081253590.3536@nanos> <20170208122612.wasq72hbj4nkh7y3@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 8 Feb 2017, Mel Gorman wrote:
> It may be worth noting that patches in Andrew's tree no longer disable
> interrupts in the per-cpu allocator and now per-cpu draining will
> be from workqueue context. The reasoning was due to the overhead of
> the page allocator with figures included. Interrupts will bypass the
> per-cpu allocator and use the irq-safe zone->lock to allocate from
> the core.  It'll collide with the RT patch. Primary patch of interest is
> http://www.ozlabs.org/~akpm/mmots/broken-out/mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch

Yeah, we'll sort that out once it hits Linus tree and we move RT forward.
Though I have once complaint right away:

+	preempt_enable_no_resched();

This is a nono, even in mainline. You effectively disable a preemption
point.

> The draining from workqueue context may be a problem for RT but one
> option would be to move the drain to only drain for high-order pages
> after direct reclaim combined with only draining for order-0 if
> __alloc_pages_may_oom is about to be called.

Why would the draining from workqueue context be an issue on RT?

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
