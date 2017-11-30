Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4920D6B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 22:42:04 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id e2so3785632qti.3
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:42:04 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s72si1568863qka.75.2017.11.29.19.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 19:42:03 -0800 (PST)
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id vAU3g1wr028380
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:42:01 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id vAU3g0Zj019246
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:42:01 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id vAU3g0o4031274
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:42:00 GMT
Received: by mail-ot0-f182.google.com with SMTP id v21so5024109oth.6
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 19:42:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171117213206.eekbiiexygig7466@techsingularity.net>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz> <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz> <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz> <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
 <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz> <20171116100633.moui6zu33ctzpjsf@techsingularity.net>
 <CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com> <20171117213206.eekbiiexygig7466@techsingularity.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 29 Nov 2017 22:41:59 -0500
Message-ID: <CAOAebxtK=pc+-hpAOtu0GG446F5+t_5xsa_j+p7KAL6HtMc9Qg@mail.gmail.com>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com, Steve Sistare <steven.sistare@oracle.com>

Hi Mel,

Thank you very much for your feedback, my replies below:

> A lack of involvement from admins is indeed desirable. For example,
> while I might concede on using a disable-everything-switch, I would not
> be happy to introduce a switch that specified how much memory per node
> to initialise.
>
> For the forth approach, I really would be only thinking of a blunt
> "initialise everything instead of going OOM". I was wary of making things
> too complicated and I worried about some side-effects I'll cover later.

I see, I misunderstood your suggestion. Switching to serial
initialization when OOM works, however, boot time becomes
unpredictable, with some configurations boot is fast with others it is
slow. All of that depends on whether predictions in
reset_deferred_meminit() were good or not which is not easy to debug
for users. Also, overtime predictions in reset_deferred_meminit() can
become very off, and I do not think that we want to continuously
adjust this function.

>> With this approach we could always init a very small amount of struct
>> pages, and allow the rest to be initialized on demand as boot requires
>> until deferred struct pages are initialized. Since, having deferred
>> pages feature assumes that the machine is large, there is no drawback
>> of having some extra byte of dead code, especially that all the checks
>> can be permanently switched of via static branches once deferred init
>> is complete.
>>
>
> This is where I fear there may be dragons. If we minimse the number of
> struct pages and initialise serially as necessary, there is a danger that
> we'll allocate remote memory in cases where local memory would have done
> because a remote node had enough memory.

True, but is not what we have now has the same issue as well? If one
node is gets out of memory we start using memory from another node,
before deferred pages are initialized?

 To offset that risk, it would be
> necessary at boot-time to force allocations from local node where possible
> and initialise more memory as necessary. That starts getting complicated
> because we'd need to adjust gfp-flags in the fast path with init-and-retry
> logic in the slow path and that could be a constant penalty. We could offset
> that in the fast path by using static branches

I will try to implement this, and see how complicated the patch will
be, if it gets too complicated for the problem I am trying to solve we
can return to one of your suggestions.

I was thinking to do something like this:

Start with every small amount of initialized pages in every node.
If allocation fails, initialize enough struct pages to cover this
particular allocation with struct pages rounded up to section size but
in every single node.

> but it's getting more and
> more complex for what is a minor optimisation -- shorter boot times on
> large machines where userspace itself could take a *long* time to get up
> and running (think database reading in 1TB of data from disk as it warms up).

On M6-32 with 32T [1] of memory it saves over 4 minutes of boot time,
and this is on SPARC with 8K pages, on x86 it would be around of 8
minutes because of twice as many pages. This feature improves
availability for larger machines quite a bit. Overtime, systems are
growing, so I expect this feature to become a default configuration in
the next several years on server configs.

>
>> The second benefit that this approach may bring is the following: it
>> may enable to add a new feature which would initialize struct pages on
>> demand later, when needed by applications. This feature would be
>> configurable or enabled via kernel parameter (not sure which is
>> better).
>>
>> if (allocation is failing)
>>   if (uninit struct pages available)
>>     init enought to finish alloc
>>
>
> There is a hidden hazard with this as well -- benchmarking. Early in the
> lifetime of the system, it's going to be slower because we're initialising
> memory while measuring performance when previously no such work would be
> necessary. While it's somewhat of a corner-case, it's still real and it would
> generate reports. For example, I got burned once by a "regression" that was
> due to ext4's lazy_init feature because IO benchmarks appeared slower when in
> reality, it was only due to a fresh filesystem initialising. It was necessary
> to turn off the feature at mkfs time to get accurate measurements. I think
> the same could happen with memory and we'd have to special case some things.
>
> We'd want to be *very* sure there was a substantial benefit to the
> complexity. For benchmarking a system, we'd also need to be able to turn
> it off.
>
>> Again, once all pages are initialized, the checks will be turned off
>> via static branching, so I think the code can be shared.
>>
>> Here is the rationale for this feature:
>>
>> Each physical machine may run a very large number of linux containers.
>> Steve Sistare (CCed), recently studied how much memory each instance
>> of clear container is taking, and it turns out to be about 125 MB,
>> when containers are booted with 2G of memory and 1 CPU. Out of those
>> 125 MB, 32 MB is consumed by struct page array as we use 64-bytes per
>> page. Admins tend to be protective in the amount of memory that is
>> configured, therefore they may over-commit the amount of memory that
>> is actually required by the container. So, by allowing struct pages to
>> be initialized only on demand, we can save around 25% of the memory
>> that is consumed by fresh instance of container. Now, that struct
>> pages are not zeroed during boot [2], and if we will implement the
>> forth option, we can get closer to implementing a complete on demand
>> struct page initialization.
>>
>> I can volunteer to work on these projects.
>>
>
> I accept the potential for packing more containers into the system but While
> I commend the work you've done so far, I'd be wary and warn you of going
> too far down this path. I wouldn't NAK patches going in this direction as
> long as they would eventually be behind static branches but I don't feel
> it's the most urgent problem to work on either. This is why, even if I took
> the fourth option, that it would be a blunt "init everything if we're going
> OOM" approach.  However, that is my opinion and it's partially based on a
> lack of sensible use cases. I suspect you have better justification that
> would be included in changelogs.

Thank you for providing your opinion. I agree, the benefit of on
demand page initialization after boot must considerably outweigh the
extra complexity and potential slow down. At the moment I do not see
it as a critical issue, so I won't be working on this 2nd proposal.

[1] http://www.oracle.com/technetwork/server-storage/sun-sparc-enterprise/documentation/o13-066-sparc-m6-32-architecture-2016053.pdf

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
