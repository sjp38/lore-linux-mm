Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 423D06B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 10:07:06 -0500 (EST)
Received: by lbpu9 with SMTP id u9so46413925lbp.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:07:05 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j67si7974026lfd.82.2015.12.10.07.07.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 07:07:03 -0800 (PST)
Date: Thu, 10 Dec 2015 10:06:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] mm: memcontrol: reign in CONFIG space madness
Message-ID: <20151210150650.GA1431@cmpxchg.org>
References: <20151209203004.GA5820@cmpxchg.org>
 <20151210134031.GN19496@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210134031.GN19496@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Dec 10, 2015 at 02:40:31PM +0100, Michal Hocko wrote:
> On Wed 09-12-15 15:30:04, Johannes Weiner wrote:
> > Hey guys,
> > 
> > there has been quite a bit of trouble that stems from dividing our
> > CONFIG space and having to provide real code and dummy functions
> > correctly in all possible combinations. This is amplified by having
> > the legacy mode and the cgroup2 mode in the same file sharing code.
> > 
> > The socket memory and kmem accounting series is a nightmare in that
> > respect, and I'm still in the process of sorting it out. But no matter
> > what the outcome there is going to be, what do you think about getting
> > rid of the CONFIG_MEMCG[_LEGACY]_KMEM and CONFIG_INET stuff?
> 
> The code size difference after your recent patches is indeed not that
> large but that is only because huge part of the kmem code is enabled by
> default now. I have raised this in the reply to the respective patch.
> This is ~8K of the code 1K for data. I do understand your reasoning
> about the complications but this is quite a lot of code. CONFIG_INET
> ifdefs are probably pointless - they do not add really much and most
> configs will have it by default. The core for KMEM seems to be a
> different thing to me. Maybe we can reorganize the code to make the
> maintenance easier and still allow to enable KMEM accounting separately
> for kernel size savy users?

Look, if kernel size savvy users care THAT much about TWO pages then
they must absolutely LOVE me for having eliminated page_cgroup and
saving them THOUSANDS of pages, and deleted hundreds of lines of code
and static data in memcontrol.c ever since I started working on it.

Yet this has been the only point you have been bringing up this entire
time: the cost I'm putting on users with all this in both memory and
cpu cycles. When I have just made all hotpaths and accounting in memcg
completely lockless. And when cgroup2 is going to be a FRACTION of the
original memcg code, data size, and runtime cost, even INCLUDING the
entirety of the kmem accounting.

There is no perspective to your criticism.

So let's just say I'm going to cash some of that credit I built up in
order to get to v2 as fast as possible, without having to spend days
engineering a solution to save two damn pages in legacy code, okay?

And if you DO care so much about cost for legacy users beyond this, I
think it's time for you to put your money where your mouth is and
start sending patches that save those users memory and cpu cycles,
instead of constantly demanding this from people who work on making
this whole thing much leaner, faster, and cleaner for EVERYBODY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
