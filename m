Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C793D6B0068
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 17:46:07 -0400 (EDT)
Received: by dadi14 with SMTP id i14so4994209dad.14
        for <linux-mm@kvack.org>; Tue, 04 Sep 2012 14:46:07 -0700 (PDT)
Date: Tue, 4 Sep 2012 14:46:02 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 0/5] forced comounts for cgroups.
Message-ID: <20120904214602.GA9092@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1346768300-10282-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346768300-10282-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, ben@decadent.org.uk, a.p.zijlstra@chello.nl, pjt@google.com, lennart@poettering.net, kay.sievers@vrfy.org

Hello, Glauber.

On Tue, Sep 04, 2012 at 06:18:15PM +0400, Glauber Costa wrote:
> As we have been extensively discussing, the cost and pain points for cgroups
> come from many places. But at least one of those is the arbitrary nature of
> hierarchies. Many people, including at least Tejun and me would like this to go
> away altogether. Problem so far, is breaking compatiblity with existing setups
> 
> I am proposing here a default-n Kconfig option that will guarantee that the cpu
> cgroups (for now) will be comounted. I started with them because the
> cpu/cpuacct division is clearly the worst offender. Also, the default-n is here
> so distributions will have time to adapt: Forcing this flag to be on without
> userspace changes will just lead to cgroups failing to mount, which we don't
> want.
> 
> Although I've tested it and it works, I haven't compile-tested all possible
> config combinations. So this is mostly for your eyes. If this gets traction,
> I'll submit it properly, along with any changes that you might require.

As I said during the discussion, I'm skeptical about how useful this
is.  This can't nudge existing users in any meaningfully gradual way.
Kconfig doesn't make it any better.  It's still an abrupt behavior
change when seen from userland.

Also, I really don't see much point in enforcing this almost arbitrary
grouping of controllers.  It doesn't simplify anything and using
cpuacct in more granular way than cpu actually is one of the better
justified use of multiple hierarchies.  Also, what about memcg and
blkcg?  Do they *really* coincide?  Note that both blkcg and memcg
involve non-trivial overhead and blkcg is essentially broken
hierarchy-wise.

Currently, from userland visible behavior POV, the crazy parts are

1. The flat hierarchy thing.  This just should go away.

2. Orthogonal multiple hierarchies.

I think we agree that #1 should go away one way or the other.  I
*really* wanna get rid of #2 but am not sure how.  I'll give it
another stab once the writeback thing is resolved.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
