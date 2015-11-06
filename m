Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6548282F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 07:51:43 -0500 (EST)
Received: by wicll6 with SMTP id ll6so29503474wic.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 04:51:42 -0800 (PST)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id m79si731576wmg.42.2015.11.06.04.51.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 04:51:41 -0800 (PST)
Received: by wicll6 with SMTP id ll6so29503213wic.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 04:51:41 -0800 (PST)
Date: Fri, 6 Nov 2015 13:51:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151106125140.GI4390@dhcp22.suse.cz>
References: <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105.111609.1695015438589063316.davem@davemloft.net>
 <20151105162803.GD15111@dhcp22.suse.cz>
 <20151105223251.GA4427@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105223251.GA4427@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-11-15 17:32:51, Johannes Weiner wrote:
> On Thu, Nov 05, 2015 at 05:28:03PM +0100, Michal Hocko wrote:
[...]
> > Yes, that part is clear and Johannes made it clear that the kmem tcp
> > part is disabled by default. Or are you considering also all the slab
> > usage by the networking code as well?
> 
> Michal, there shouldn't be any tracking or accounting going on per
> default when you boot into a fresh system.
> 
> I removed all accounting and statistics on the system level in
> cgroupv2, so distribution kernels can compile-time enable a single,
> feature-complete CONFIG_MEMCG that provides a full memory controller
> while at the same time puts no overhead on users that don't benefit
> from mem control at all and just want to use the machine bare-metal.

Yes that part is clear and I am not disputing it _at all_. It is just
that changes are high that memory controller _will_ be enabled in a
typical distribution systems. E.g. systemd _is_ enabling all resource
controllers by default for some services with Delegate=yes option.

> This is completely doable. My new series does it for skmem, but I also
> want to retrofit the code to eliminate that current overhead for page
> cache, anonymous memory, slab memory and so forth.
> 
> This is the only sane way to make the memory controller powerful and
> generally useful without having to make unreasonable compromises with
> memory consumers. We shouldn't even be *having* the discussion about
> whether we should sacrifice the quality of our interface in order to
> compromise with a class of users that doesn't care about any of this
> in the first place.
> 
> So let's eliminate the cost for non-users, but make the memory
> controller feature-complete and useful--with reasonable cost,
> implementation, and interface--for our actual userbase.
> 
> Paying the necessary cost for a functionality you actually want is not
> the problem. Paying for something that doesn't benefit you is.

I completely agree that a reasonable cost for those who _want_ the
functionality. It hasn't been shown that people actually lack kmem
accounting in the wild from the past in general. E.g. kmem controller
is even not enabled in opensuse nor SLES kernels and I do not remember
there was huge push to enable it.

I do understand that you want to have an out-of-the-box isolation
behavior which I agree is a nice-to-have feature. Especially with
a larger penetration of containerized workloads. But my point still
holds. This is not something everybody wants to have. So have a
configuration and a boot time option to override is the most reasonable
way to go. You can clearly see that this is already demand from tcp
kmem extension because they really _care_ about every single cpu cycle
even though some part of the userspace happens to have memcg enabled.

The question about the configuration default is a different question
and we can discuss that because this is not an easy one to decide right
now IMHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
