Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4EE766B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 08:19:27 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so1773743eek.16
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 05:19:26 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id x44si8086365eep.300.2014.04.24.05.19.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 05:19:25 -0700 (PDT)
Date: Thu, 24 Apr 2014 08:19:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: remove hierarchy restrictions for
 swappiness and oom_control
Message-ID: <20140424121917.GB4107@cmpxchg.org>
References: <1397682798-22906-1-git-send-email-hannes@cmpxchg.org>
 <20140418113611.GA7568@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140418113611.GA7568@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Apr 18, 2014 at 01:36:11PM +0200, Michal Hocko wrote:
> On Wed 16-04-14 17:13:18, Johannes Weiner wrote:
> > Per-memcg swappiness and oom killing can currently not be tweaked on a
> > memcg that is part of a hierarchy, but not the root of that hierarchy.
> > Users have complained that they can't configure this when they turned
> > on hierarchy mode.  In fact, with hierarchy mode becoming the default,
> > this restriction disables the tunables entirely.
> 
> Except when we would handle the first level under root differently,
> which is ugly.
> 
> > But there is no good reason for this restriction. 
> 
> I had a patch for this somewhere on the think_more pile. I wasn't
> particularly happy about the semantic so I haven't posted it.
> 
> > The settings for
> > swappiness and OOM killing are taken from whatever memcg whose limit
> > triggered reclaim and OOM invocation, regardless of its position in
> > the hierarchy tree.
> 
> This is OK for the OOM knob because the memory pressure cannot be
> handled at that level in hierarchy and that is where the OOM happens.
> 
> I am not so sure about the swappiness though. The swappiness tells us
> how to proportionally scan anon vs. file LRUs and those are per-memcg,
> not per-hierarchy (unlike the charge) so it makes sense to use it
> per-memcg IMO.
> 
> Besides that using the reclaim target value might be quite confusing.
> Say, somebody wants to prevent from swapping in a certain group and
> yet the pages find their way to swap depending on where the reclaim is
> triggered from.
> Another thing would be that setting swappiness on an unlimited group has
> no effect although I would argue it makes some sense in configuration
> when parent is controlled by somebody else. I would like to tell how
> to reclaim me when I cannot say how much memory I can have. 
> 
> It is true that we have a different behavior for the global reclaim
> already but I am not entirely happy about that. Having a different
> behavior for the global vs. limit reclaims just calls for troubles and
> should be avoided as much as possible.
> 
> So let's think what is the best semantic before we merge this. I would
> be more inclined for using per-memcg swappiness all the time (root using
> the global knob) for all reclaims.

Yeah, we've always used the triggering group's swappiness value but at
the same time forced the whole hierarchy to have the same setting as
the root.

I don't really feel strongly about this.  If you prefer the per-memcg
swappiness I can send a followup patch - or you can.

> > Allow setting swappiness on any group.  The knob on the root memcg
> > already reads the global VM swappiness, make it writable as well.
> 
> I am OK with the change but I think we should discuss the semantic
> first.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
