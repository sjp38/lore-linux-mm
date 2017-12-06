Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FCA76B049A
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 05:50:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so1861017wre.10
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 02:50:09 -0800 (PST)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id m22si2509548edj.259.2017.12.06.02.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 02:50:06 -0800 (PST)
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 156C61C3BC1
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 10:50:06 +0000 (GMT)
Date: Wed, 6 Dec 2017 10:50:01 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171206105000.4aefxr3uzvutulvb@techsingularity.net>
References: <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
 <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz>
 <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
 <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz>
 <20171116100633.moui6zu33ctzpjsf@techsingularity.net>
 <CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com>
 <20171117213206.eekbiiexygig7466@techsingularity.net>
 <CAOAebxtK=pc+-hpAOtu0GG446F5+t_5xsa_j+p7KAL6HtMc9Qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAOAebxtK=pc+-hpAOtu0GG446F5+t_5xsa_j+p7KAL6HtMc9Qg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com, Steve Sistare <steven.sistare@oracle.com>

On Wed, Nov 29, 2017 at 10:41:59PM -0500, Pavel Tatashin wrote:
> Hi Mel,
> 
> Thank you very much for your feedback, my replies below:
> 
> > A lack of involvement from admins is indeed desirable. For example,
> > while I might concede on using a disable-everything-switch, I would not
> > be happy to introduce a switch that specified how much memory per node
> > to initialise.
> >
> > For the forth approach, I really would be only thinking of a blunt
> > "initialise everything instead of going OOM". I was wary of making things
> > too complicated and I worried about some side-effects I'll cover later.
> 
> I see, I misunderstood your suggestion. Switching to serial
> initialization when OOM works, however, boot time becomes
> unpredictable, with some configurations boot is fast with others it is
> slow. All of that depends on whether predictions in
> reset_deferred_meminit() were good or not which is not easy to debug
> for users. Also, overtime predictions in reset_deferred_meminit() can
> become very off, and I do not think that we want to continuously
> adjust this function.
> 

You could increase the probabilty of a report by doing a WARN_ON_ONCE if
the serialised meminit is used.

> >> With this approach we could always init a very small amount of struct
> >> pages, and allow the rest to be initialized on demand as boot requires
> >> until deferred struct pages are initialized. Since, having deferred
> >> pages feature assumes that the machine is large, there is no drawback
> >> of having some extra byte of dead code, especially that all the checks
> >> can be permanently switched of via static branches once deferred init
> >> is complete.
> >>
> >
> > This is where I fear there may be dragons. If we minimse the number of
> > struct pages and initialise serially as necessary, there is a danger that
> > we'll allocate remote memory in cases where local memory would have done
> > because a remote node had enough memory.
> 
> True, but is not what we have now has the same issue as well? If one
> node is gets out of memory we start using memory from another node,
> before deferred pages are initialized?
> 

It's possible but I'm not aware of it happening currently.

>  To offset that risk, it would be
> > necessary at boot-time to force allocations from local node where possible
> > and initialise more memory as necessary. That starts getting complicated
> > because we'd need to adjust gfp-flags in the fast path with init-and-retry
> > logic in the slow path and that could be a constant penalty. We could offset
> > that in the fast path by using static branches
> 
> I will try to implement this, and see how complicated the patch will
> be, if it gets too complicated for the problem I am trying to solve we
> can return to one of your suggestions.
> 
> I was thinking to do something like this:
> 
> Start with every small amount of initialized pages in every node.
> If allocation fails, initialize enough struct pages to cover this
> particular allocation with struct pages rounded up to section size but
> in every single node.
> 

Ok, just make sure it's all in the slow paths of the allocator when the
alternative is to fail the allocation.

> > but it's getting more and
> > more complex for what is a minor optimisation -- shorter boot times on
> > large machines where userspace itself could take a *long* time to get up
> > and running (think database reading in 1TB of data from disk as it warms up).
> 
> On M6-32 with 32T [1] of memory it saves over 4 minutes of boot time,
> and this is on SPARC with 8K pages, on x86 it would be around of 8
> minutes because of twice as many pages. This feature improves
> availability for larger machines quite a bit. Overtime, systems are
> growing, so I expect this feature to become a default configuration in
> the next several years on server configs.
> 

Ok, when developing the series originally, I had no machine even close
to 32T of memory.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
