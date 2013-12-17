Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6456B0038
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:20:00 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id e14so8716537iej.28
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:19:59 -0800 (PST)
Date: Tue, 17 Dec 2013 10:20:07 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [RFC PATCH 0/3] Change how we determine when to hand out THPs
Message-ID: <20131217162006.GH18680@sgi.com>
References: <20131212180037.GA134240@sgi.com>
 <20131213214437.6fdbf7f2.akpm@linux-foundation.org>
 <20131216171214.GA15663@sgi.com>
 <20131216175111.GD21218@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131216175111.GD21218@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

On Mon, Dec 16, 2013 at 06:51:11PM +0100, Andrea Arcangeli wrote:
> On Mon, Dec 16, 2013 at 11:12:15AM -0600, Alex Thorlton wrote:
> > As it stands right now, yes, since we're pulling a 512 page contiguous
> > chunk off the free list, everything from that chunk will reside on the
> > same node, but as I (stupidly) forgot to mention in my original e-mail,
> > one piece I have yet to add is the functionality to put the remaining
> > unfaulted pages from our chunk *back* on the free list after we give up
> > on handing out a THP.  Once this is in there, things will behave more
> > like they do when THP is turned completely off, i.e. pages will get
> > faulted in closer to the CPU that first referenced them once we give up
> > on handing out the THP.
> 
> The only problem is the additional complexity and the slowdown to the
> common cases that benefit from THP immediately.

Agreed.  I understand that jobs which perform well with the current
behavior will be adversely affected by the change.  My thinking here was
that we could at least reach a middle ground between jobs that don't
like THP, and jobs that perform well with it, allowing them both to run
without users having to use a malloc hook or something similar to
achieve that goal, especially considering some cases where malloc hooks
for madvise aren't an option.

> > Yes.  Due to the time it takes to search for the temporary THP, I'm sure
> > we won't get down to 76 secs, but hopefully we'll get close.  I'm also
> 
> Did you consider using MADV_NOHUGEPAGE?
> 
> Clearly this will disable it not just on NUMA, but NUMA vs non-NUMA
> the problem is pretty much the same. You may want to verify if your
> runs faster on non-NUMA too, with MADV_NOHUGEPAGE.
> 
> If every thread only touches 1 subpage of every hugepage mapped, the
> number of TLB misses will be lower with many 4k d-TLB than with fewer
> 2M d-TLB entries. The only benefit that remains from THP in such case
> is that the TLB miss is faster with THP and that's not always enough
> to offset the cost of the increased number of TLB misses.
> 
> But MADV_NOHUGEPAGE is made specifically to tune for those non common
> cases and if you know what the app is doing and you know the faster
> TLB miss is a win despite the fewer 2M TLB entries on non-NUMA, you
> could do:
> 
>       if (numnodes() > 1)
>       	 madvise(MADV_NOHUGEPAGE, ...);

Please see this thread where I discussed some of the problems we ran
into with madvise, also this touches on the per-process fix that you
mention below:

https://lkml.org/lkml/2013/8/2/671

This message in particular:

https://lkml.org/lkml/2013/8/2/697

> 
> > considering switching the linked list that stores the temporary THPs
> > over to an rbtree to make that search faster, just fyi.
> 
> Problem is that it'll be still slower than no change.
> 
> I'm certainly not against trying to make the kernel smarter to
> optimize for non common workloads, but if the default behavior shall
> not change and this is a tweak the admin should tune manually, I'd
> like an explanation of why the non privileged MADV_NOHUGEPAGE madvise
> is worse solution for this than a privileged tweak in sysfs that the
> root user may also forget if not careful.
> 
> The problem in all this, is that this is a tradeoff and depending on
> the app anything in between the settings "never" and "always" could be
> optimal.
> 
> The idea was just to map THP whenever possible by default to keep the
> kernel simpler and to gain the maximum performance from the faster TLB
> miss immediately (and hopefully offset those cases were the number of
> TLB misses doesn't decrease with THP enabled, like probably your app,
> and at the same time avoiding the need later for a THP collapsing
> event that requires TLB flushes and will add additional costs). For
> what is extreme and just wants THP off, I thought MADV_NOHUGEPAGE
> would be fine solution.
>
> I doubt we can change the default behavior, at the very least it would
> require lots of benchmarking and the only benchmarking I've seen here
> is for the corner case app which may actually run the fastest with
> MADV_NOHUGEPAGE than with a intermediate threshold.
> 
> If we instead we need an intermediate threshold less aggressive than
> MADV_NOHUGEPAGE, I think the tweaks should be per-process and not
> privileged, like MADV_NOHUGEPAGE. Because by definition of the
> tradeoff, every app could have its own preferred threshold. And like
> your app wants THP off, the majority still wants it on without
> intermediate steps. So with a system wide setting you can't make
> everyone happy unless you're like #osv in a VM running a single app.

The thread I mention above originally proposed a per-process switch to
disable THP without the use of madvise, but it was not very well 
received.  I'm more than willing to revisit that idea, and possibly
meld the two (a per-process threshold, instead of a big-hammer on-off
swtich).  Let me know if that seems preferable to this idea and we can
discuss.

Thanks for the input!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
