Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9C382F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 17:33:05 -0500 (EST)
Received: by wmll128 with SMTP id l128so26362529wml.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 14:33:04 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 71si394401wmm.27.2015.11.05.14.33.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 14:33:03 -0800 (PST)
Date: Thu, 5 Nov 2015 17:32:51 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151105223251.GA4427@cmpxchg.org>
References: <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105.111609.1695015438589063316.davem@davemloft.net>
 <20151105162803.GD15111@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105162803.GD15111@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 05, 2015 at 05:28:03PM +0100, Michal Hocko wrote:
> On Thu 05-11-15 11:16:09, David S. Miller wrote:
> > From: Michal Hocko <mhocko@kernel.org>
> > Date: Thu, 5 Nov 2015 15:40:02 +0100
> > 
> > > On Wed 04-11-15 14:50:37, Johannes Weiner wrote:
> > > [...]
> > >> Because it goes without saying that once the cgroupv2 interface is
> > >> released, and people use it in production, there is no way we can then
> > >> *add* dentry cache, inode cache, and others to memory.current. That
> > >> would be an unacceptable change in interface behavior.
> > > 
> > > They would still have to _enable_ the config option _explicitly_. make
> > > oldconfig wouldn't change it silently for them. I do not think
> > > it is an unacceptable change of behavior if the config is changed
> > > explicitly.
> > 
> > Every user is going to get this config option when they update their
> > distibution kernel or whatever.
> > 
> > Then they will all wonder why their networking performance went down.
> > 
> > This is why I do not want the networking accounting bits on by default
> > even if the kconfig option is enabled.  They must be off by default
> > and guarded by a static branch so the cost is exactly zero.
> 
> Yes, that part is clear and Johannes made it clear that the kmem tcp
> part is disabled by default. Or are you considering also all the slab
> usage by the networking code as well?

Michal, there shouldn't be any tracking or accounting going on per
default when you boot into a fresh system.

I removed all accounting and statistics on the system level in
cgroupv2, so distribution kernels can compile-time enable a single,
feature-complete CONFIG_MEMCG that provides a full memory controller
while at the same time puts no overhead on users that don't benefit
from mem control at all and just want to use the machine bare-metal.

This is completely doable. My new series does it for skmem, but I also
want to retrofit the code to eliminate that current overhead for page
cache, anonymous memory, slab memory and so forth.

This is the only sane way to make the memory controller powerful and
generally useful without having to make unreasonable compromises with
memory consumers. We shouldn't even be *having* the discussion about
whether we should sacrifice the quality of our interface in order to
compromise with a class of users that doesn't care about any of this
in the first place.

So let's eliminate the cost for non-users, but make the memory
controller feature-complete and useful--with reasonable cost,
implementation, and interface--for our actual userbase.

Paying the necessary cost for a functionality you actually want is not
the problem. Paying for something that doesn't benefit you is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
