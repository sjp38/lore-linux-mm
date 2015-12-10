Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id C2BB36B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 11:12:15 -0500 (EST)
Received: by wmec201 with SMTP id c201so31611468wme.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:12:15 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id 197si20372147wmx.76.2015.12.10.08.12.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 08:12:14 -0800 (PST)
Received: by mail-wm0-f46.google.com with SMTP id w144so30558649wmw.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 08:12:14 -0800 (PST)
Date: Thu, 10 Dec 2015 17:12:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: memcontrol: reign in CONFIG space madness
Message-ID: <20151210161212.GB11778@dhcp22.suse.cz>
References: <20151209203004.GA5820@cmpxchg.org>
 <20151210134031.GN19496@dhcp22.suse.cz>
 <20151210150650.GA1431@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210150650.GA1431@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 10-12-15 10:06:50, Johannes Weiner wrote:
> On Thu, Dec 10, 2015 at 02:40:31PM +0100, Michal Hocko wrote:
> > On Wed 09-12-15 15:30:04, Johannes Weiner wrote:
> > > Hey guys,
> > > 
> > > there has been quite a bit of trouble that stems from dividing our
> > > CONFIG space and having to provide real code and dummy functions
> > > correctly in all possible combinations. This is amplified by having
> > > the legacy mode and the cgroup2 mode in the same file sharing code.
> > > 
> > > The socket memory and kmem accounting series is a nightmare in that
> > > respect, and I'm still in the process of sorting it out. But no matter
> > > what the outcome there is going to be, what do you think about getting
> > > rid of the CONFIG_MEMCG[_LEGACY]_KMEM and CONFIG_INET stuff?
> > 
> > The code size difference after your recent patches is indeed not that
> > large but that is only because huge part of the kmem code is enabled by
> > default now. I have raised this in the reply to the respective patch.
> > This is ~8K of the code 1K for data. I do understand your reasoning
> > about the complications but this is quite a lot of code. CONFIG_INET
> > ifdefs are probably pointless - they do not add really much and most
> > configs will have it by default. The core for KMEM seems to be a
> > different thing to me. Maybe we can reorganize the code to make the
> > maintenance easier and still allow to enable KMEM accounting separately
> > for kernel size savy users?
> 
> Look, if kernel size savvy users care THAT much about TWO pages then
> they must absolutely LOVE me for having eliminated page_cgroup and
> saving them THOUSANDS of pages, and deleted hundreds of lines of code
> and static data in memcontrol.c ever since I started working on it.

They surely do! And I appreciate that very much as well!

> Yet this has been the only point you have been bringing up this entire
> time: the cost I'm putting on users with all this in both memory and
> cpu cycles.

This is quite an unfair statement, don't you think? I have been
reviewing all those changes as deeply as I could and many of them were
highly non trivial so it took quite some time. I've raised concerns
I had on the way. That doesn't compare to the time you have spent on
that of course but I think that reducing all my review feedback to a
single thing is really unfair.

> When I have just made all hotpaths and accounting in memcg
> completely lockless. And when cgroup2 is going to be a FRACTION of the
> original memcg code, data size, and runtime cost, even INCLUDING the
> entirety of the kmem accounting.
> 
> There is no perspective to your criticism.

This is what we call a review process. Raise concerns and deal with
them. My review hasn't implied this would be a show stopper or block
those change to get merged. I was merely asking whether we can keep
the code size with a _reasonable_ maintenance burden. If the answer is
no then I can live with that even when I might not like that fact. That
has been reflected by a lack of my acked-by.

> So let's just say I'm going to cash some of that credit I built up in
> order to get to v2 as fast as possible, without having to spend days
> engineering a solution to save two damn pages in legacy code, okay?

You sound as if you had to overrule a nack which sounds like over
reacting because this is not the case.
 
> And if you DO care so much about cost for legacy users beyond this, I
> think it's time for you to put your money where your mouth is and
> start sending patches that save those users memory and cpu cycles,
> instead of constantly demanding this from people who work on making
> this whole thing much leaner, faster, and cleaner for EVERYBODY.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
