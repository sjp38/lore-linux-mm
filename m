Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2158B6B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 08:35:45 -0400 (EDT)
Received: by wgin8 with SMTP id n8so10017543wgi.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 05:35:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw1si2039092wib.15.2015.05.06.05.35.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 05:35:43 -0700 (PDT)
Date: Wed, 6 May 2015 14:35:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506123541.GK14550@dhcp22.suse.cz>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <20150506115941.GH14550@dhcp22.suse.cz>
 <20150506122431.GA29387@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150506122431.GA29387@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 06-05-15 15:24:31, Vladimir Davydov wrote:
> On Wed, May 06, 2015 at 01:59:41PM +0200, Michal Hocko wrote:
> > On Tue 05-05-15 12:45:42, Vladimir Davydov wrote:
> > > Not all kmem allocations should be accounted to memcg. The following
> > > patch gives an example when accounting of a certain type of allocations
> > > to memcg can effectively result in a memory leak.
> > 
> > > This patch adds the __GFP_NOACCOUNT flag which if passed to kmalloc
> > > and friends will force the allocation to go through the root
> > > cgroup. It will be used by the next patch.
> > 
> > The name of the flag is way too generic. It is not clear that the
> > accounting is KMEMCG related. __GFP_NO_KMEMCG sounds better?
> > 
> > I was going to suggest doing per-cache rather than gfp flag and that
> > would actually work just fine for the kmemleak as it uses its own cache
> > already. But the ida_simple_get would be trickier because it doesn't use
> > any special cache and more over only one user seem to have a problem so
> > this doesn't sound like a good fit.
> 
> I don't think making this flag per-cache is an option either, but for
> another reason - it would not be possible to merge such a kmem cache
> with caches without this flag set. As a result, total memory pressure
> would increase, even for setups without kmem-active memory cgroups,
> which does not sound acceptable to me.

I am not sure I see the performance implications here because kmem
accounted memcgs would have their copy of the cache anyway, no?
Anyway, I guess it would be good to document these reasons in the
changelog.
 
> > So I do not object to opt-out for kmemcg accounting but I really think
> > the name should be changed.
> 
> I named it __GFP_NOACCOUNT to match with __GFP_NOTRACK, which is a very
> specific flag too (kmemcheck),  nevertheless it has a rather generic
> name.

__GFP_NOTRACK is a bad name IMHO as well. One has to go and check the
comment to see this is kmemleak related.

> Anyways, what else apart from memcg can account kmem so that we have to
> mention KMEMCG in the flag name explicitly?

NOACCOUNT doesn't imply kmem at all so it is not clear who is in charge
of the accounting. I do not insist on __GFP_NO_KMEMCG of course but
it sounds quite specific about its meaning and scope.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
