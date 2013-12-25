Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id E07AD6B0036
	for <linux-mm@kvack.org>; Wed, 25 Dec 2013 14:07:53 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id k19so25919780igc.1
        for <linux-mm@kvack.org>; Wed, 25 Dec 2013 11:07:53 -0800 (PST)
Date: Wed, 25 Dec 2013 13:07:47 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [RFC PATCH 0/3] Change how we determine when to hand out THPs
Message-ID: <20131225190747.GB195633@sgi.com>
References: <20131212180037.GA134240@sgi.com> <20131213214437.6fdbf7f2.akpm@linux-foundation.org> <20131216171214.GA15663@sgi.com> <20131216175111.GD21218@redhat.com> <20131217162006.GH18680@sgi.com> <20131217175500.GB5441@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217175500.GB5441@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

On Tue, Dec 17, 2013 at 06:55:00PM +0100, Andrea Arcangeli wrote:
> On Tue, Dec 17, 2013 at 10:20:07AM -0600, Alex Thorlton wrote:
> > This message in particular:
> > 
> > https://lkml.org/lkml/2013/8/2/697
> 
> I think adding a prctl (or similar) inherited by child to turn off THP
> would be a fine addition to the current madvise. So you can then run
> any static app under a wrapper like "THP_disable ./whatever"
> 
> The idea is, if the software is maintained, madvise allows for
> finegrined optimization, if the software is legacy proprietary
> statically linked (or if it already uses LD_PRELOAD for other things),
> prctl takes care of that in a more coarse way (but still per-app).

That sounds fine.  I'll dig up the old patches that I wrote a while back
to enable this, and get them cleaned up and rebased to the latest kernel
version for people to review.

> > The thread I mention above originally proposed a per-process switch to
> > disable THP without the use of madvise, but it was not very well 
> > received.  I'm more than willing to revisit that idea, and possibly
> 
> I think you provided enough explanation of why it is needed (static
> binaries, proprietary apps, annoyance of LD_PRELOAD that may collide
> with other LD_PRELOAD in proprietary apps whatever), so I think a
> prctl is reasonable addition to the madvise.
> 
> We also have an madvise to turn on THP selectively on embedded that
> may boot with enabled=madvise to be sure not to waste any memory
> because of THP. But the prctl to selectively enable doesn't make too
> much sense, as one has to selectively enabled in a finegrined way to
> be sure not to cause any memory waste. So I think a NOHUGEPAGE prctl
> would be enough.
> 
> > meld the two (a per-process threshold, instead of a big-hammer on-off
> > swtich).  Let me know if that seems preferable to this idea and we can
> > discuss.
> 
> The per-process threshold would be much bigger patch, I think starting
> with the big-hammer on-off is preferable as it is much simpler and it
> should be more than enough to take care of the rare corner cases,
> while leaving the other workloads unaffected (modulo the cacheline to
> check the task or mm flags) running at max speed.

Agreed.  While I still would like to explore the threshold idea further,
I'm all for putting in a simpler fix to our current problem that will
leave default behavior unaffected.
 
> To evaluate the threshold solution, a variety of benchmarks of a
> multitude of apps would be necessary first, to see the effect it has
> on the non-corner cases. Adding the big-hammer on-off prctl instead is
> a black and white design solution that won't require black magic
> settings.
> 
> Ideally if we add a threshold later it won't require any more
> cacheline accesses, as the threshold would also need to be per-task or
> per-mm so the runtime cost of the prctl would be zero then and it
> could then become a benchmarking tweak even if we add the per-app
> threshold later.
>
> About creating heuristics to automatically detect the ideal value of
> the big-hammer per-app on/off switch (or even harder the ideal value
> of the per-app threshold), I think it's not going to happen because
> there are too few corner cases and it wouldn't be worth the cost of it
> (the cost would be significant no matter how implemented).

I see where you're coming from here.  If we do decide to move further
with implementing a threshold solution in the future, I think the best
idea is to have it default to 1, which would maintain current behavior
and leave the non-corner cases unaffected.

Thanks for your suggestions!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
