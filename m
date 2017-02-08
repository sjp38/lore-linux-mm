Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43E126B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 07:26:14 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so32525317wjb.7
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 04:26:14 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id n54si8935635wrn.247.2017.02.08.04.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 04:26:13 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id AB20A1C19A9
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 12:26:12 +0000 (GMT)
Date: Wed, 8 Feb 2017 12:26:12 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170208122612.wasq72hbj4nkh7y3@techsingularity.net>
References: <20170207123708.GO5065@dhcp22.suse.cz>
 <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
 <20170207141911.GR5065@dhcp22.suse.cz>
 <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net>
 <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org>
 <alpine.DEB.2.20.1702072319200.8117@nanos>
 <20170208073527.GA5686@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702081253590.3536@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1702081253590.3536@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Feb 08, 2017 at 01:02:07PM +0100, Thomas Gleixner wrote:
> On Wed, 8 Feb 2017, Michal Hocko wrote:
> > On Tue 07-02-17 23:25:17, Thomas Gleixner wrote:
> > > On Tue, 7 Feb 2017, Christoph Lameter wrote:
> > > > On Tue, 7 Feb 2017, Michal Hocko wrote:
> > > > 
> > > > > I am always nervous when seeing hotplug locks being used in low level
> > > > > code. It has bitten us several times already and those deadlocks are
> > > > > quite hard to spot when reviewing the code and very rare to hit so they
> > > > > tend to live for a long time.
> > > > 
> > > > Yep. Hotplug events are pretty significant. Using stop_machine_XXXX() etc
> > > > would be advisable and that would avoid the taking of locks and get rid of all the
> > > > ocmplexity, reduce the code size and make the overall system much more
> > > > reliable.
> > > 
> > > Huch? stop_machine() is horrible and heavy weight. Don't go there, there
> > > must be simpler solutions than that.
> > 
> > Absolutely agreed. We are in the page allocator path so using the
> > stop_machine* is just ridiculous. And, in fact, there is a much simpler
> > solution [1]
> > 
> > [1] http://lkml.kernel.org/r/20170207201950.20482-1-mhocko@kernel.org
> 
> Well, yes. It's simple, but from an RT point of view I really don't like
> it as we have to fix it up again.
> 
> On RT we solved the problem of the page allocator differently which allows
> us to do drain_all_pages() from the caller CPU as a side effect. That's
> interesting not only for RT, it's also interesting for NOHZ FULL scenarios
> because you don't inflict the work on the other CPUs.
> 
> https://git.kernel.org/cgit/linux/kernel/git/rt/linux-rt-devel.git/commit/?h=linux-4.9.y-rt-rebase&id=d577a017da694e29a06af057c517f2a7051eb305
> 

It may be worth noting that patches in Andrew's tree no longer disable
interrupts in the per-cpu allocator and now per-cpu draining will
be from workqueue context. The reasoning was due to the overhead of
the page allocator with figures included. Interrupts will bypass the
per-cpu allocator and use the irq-safe zone->lock to allocate from
the core.  It'll collide with the RT patch. Primary patch of interest is
http://www.ozlabs.org/~akpm/mmots/broken-out/mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch

The draining from workqueue context may be a problem for RT but one
option would be to move the drain to only drain for high-order pages
after direct reclaim combined with only draining for order-0 if
__alloc_pages_may_oom is about to be called.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
