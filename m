Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54CA46B0253
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 16:32:18 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id z75so2219922wrc.5
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 13:32:18 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id b18si1346284edh.47.2017.11.17.13.32.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Nov 2017 13:32:16 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 695C798BDA
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 21:32:16 +0000 (UTC)
Date: Fri, 17 Nov 2017 21:32:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171117213206.eekbiiexygig7466@techsingularity.net>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
 <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
 <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz>
 <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
 <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz>
 <20171116100633.moui6zu33ctzpjsf@techsingularity.net>
 <CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com, Steve Sistare <steven.sistare@oracle.com>

On Fri, Nov 17, 2017 at 01:19:56PM -0500, Pavel Tatashin wrote:
> On Thu, Nov 16, 2017 at 5:06 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> > 4. Put a check into the page allocator slowpath that triggers serialised
> >    init if the system is booting and an allocation is about to fail. It
> >    would be such a cold path that it would never be noticable although it
> >    would leave dead code in the kernel image once boot had completed
> 
> Hi Mel,
> 

Hi Pavel,

> The forth approach is the best as it is seamless for admins and
> engineers, it will also work on any system configuration with any
> parameters without any special involvement.
> 

A lack of involvement from admins is indeed desirable. For example,
while I might concede on using a disable-everything-switch, I would not
be happy to introduce a switch that specified how much memory per node
to initialise.

For the forth approach, I really would be only thinking of a blunt
"initialise everything instead of going OOM". I was wary of making things
too complicated and I worried about some side-effects I'll cover later.

> This approach will also address the following problem:
> reset_deferred_meminit() has some assumptions about how much memory we
> will need beforehand may break periodically as kernel requirements
> change. For, instance, I recently reduced amount of memory system hash
> tables take on large machines [1], so the comment in that function is
> already outdated:
>         /*
>          * Initialise at least 2G of a node but also take into account that
>          * two large system hashes that can take up 1GB for 0.25TB/node.
>          */
> 

True, that could be updated although I would not necessarily alter the
value to minimise the memory requirements either. I would simply make
the comment a bit more general. More on this in a bit;

> With this approach we could always init a very small amount of struct
> pages, and allow the rest to be initialized on demand as boot requires
> until deferred struct pages are initialized. Since, having deferred
> pages feature assumes that the machine is large, there is no drawback
> of having some extra byte of dead code, especially that all the checks
> can be permanently switched of via static branches once deferred init
> is complete.
> 

This is where I fear there may be dragons. If we minimse the number of
struct pages and initialise serially as necessary, there is a danger that
we'll allocate remote memory in cases where local memory would have done
because a remote node had enough memory. To offset that risk, it would be
necessary at boot-time to force allocations from local node where possible
and initialise more memory as necessary. That starts getting complicated
because we'd need to adjust gfp-flags in the fast path with init-and-retry
logic in the slow path and that could be a constant penalty. We could offset
that in the fast path by using static branches but it's getting more and
more complex for what is a minor optimisation -- shorter boot times on
large machines where userspace itself could take a *long* time to get up
and running (think database reading in 1TB of data from disk as it warms up).

> The second benefit that this approach may bring is the following: it
> may enable to add a new feature which would initialize struct pages on
> demand later, when needed by applications. This feature would be
> configurable or enabled via kernel parameter (not sure which is
> better).
> 
> if (allocation is failing)
>   if (uninit struct pages available)
>     init enought to finish alloc
> 

There is a hidden hazard with this as well -- benchmarking. Early in the
lifetime of the system, it's going to be slower because we're initialising
memory while measuring performance when previously no such work would be
necessary. While it's somewhat of a corner-case, it's still real and it would
generate reports. For example, I got burned once by a "regression" that was
due to ext4's lazy_init feature because IO benchmarks appeared slower when in
reality, it was only due to a fresh filesystem initialising. It was necessary
to turn off the feature at mkfs time to get accurate measurements. I think
the same could happen with memory and we'd have to special case some things.

We'd want to be *very* sure there was a substantial benefit to the
complexity. For benchmarking a system, we'd also need to be able to turn
it off.

> Again, once all pages are initialized, the checks will be turned off
> via static branching, so I think the code can be shared.
> 
> Here is the rationale for this feature:
> 
> Each physical machine may run a very large number of linux containers.
> Steve Sistare (CCed), recently studied how much memory each instance
> of clear container is taking, and it turns out to be about 125 MB,
> when containers are booted with 2G of memory and 1 CPU. Out of those
> 125 MB, 32 MB is consumed by struct page array as we use 64-bytes per
> page. Admins tend to be protective in the amount of memory that is
> configured, therefore they may over-commit the amount of memory that
> is actually required by the container. So, by allowing struct pages to
> be initialized only on demand, we can save around 25% of the memory
> that is consumed by fresh instance of container. Now, that struct
> pages are not zeroed during boot [2], and if we will implement the
> forth option, we can get closer to implementing a complete on demand
> struct page initialization.
> 
> I can volunteer to work on these projects.
> 

I accept the potential for packing more containers into the system but While
I commend the work you've done so far, I'd be wary and warn you of going
too far down this path. I wouldn't NAK patches going in this direction as
long as they would eventually be behind static branches but I don't feel
it's the most urgent problem to work on either. This is why, even if I took
the fourth option, that it would be a blunt "init everything if we're going
OOM" approach.  However, that is my opinion and it's partially based on a
lack of sensible use cases. I suspect you have better justification that
would be included in changelogs.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
