Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 07E8C6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 14:31:50 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so2037363wgg.8
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 11:31:50 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cd8si26409619wjc.103.2014.10.15.11.31.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Oct 2014 11:31:49 -0700 (PDT)
Date: Wed, 15 Oct 2014 14:31:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/5] mm: memcontrol: convert reclaim iterator to simple
 css refcounting
Message-ID: <20141015183137.GA6442@phnom.home.cmpxchg.org>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
 <1413303637-23862-2-git-send-email-hannes@cmpxchg.org>
 <20141015150256.GF23547@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141015150256.GF23547@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 15, 2014 at 05:02:56PM +0200, Michal Hocko wrote:
> On Tue 14-10-14 12:20:33, Johannes Weiner wrote:
> > The memcg reclaim iterators use a complicated weak reference scheme to
> > prevent pinning cgroups indefinitely in the absence of memory pressure.
> > 
> > However, during the ongoing cgroup core rework, css lifetime has been
> > decoupled such that a pinned css no longer interferes with removal of
> > the user-visible cgroup, and all this complexity is now unnecessary.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/memcontrol.c | 250 +++++++++++++++++---------------------------------------
> >  1 file changed, 76 insertions(+), 174 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index b62972c80055..67dabe8b0aa6 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> [...]
> > +		do {
> > +			pos = ACCESS_ONCE(iter->position);
> > +			/*
> > +			 * A racing update may change the position and
> > +			 * put the last reference, hence css_tryget(),
> > +			 * or retry to see the updated position.
> > +			 */
> > +		} while (pos && !css_tryget(&pos->css));
> > +	}
> [...]
> > +	if (reclaim) {
> > +		if (cmpxchg(&iter->position, pos, memcg) == pos && memcg)
> > +			css_get(&memcg->css);
> > +
> > +		if (pos)
> > +			css_put(&pos->css);
> 
> This looks like a reference leak. css_put pairs with the above
> css_tryget but no css_put pairs with css_get for the cached one. We
> need:
> ---
> From 2810937ec6c16afc0bf924e761ff8305bd478a42 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 15 Oct 2014 16:26:22 +0200
> Subject: [PATCH] 
>  mm-memcontrol-convert-reclaim-iterator-to-simple-css-refcounting-fix
> 
> Make sure that the cached reference is always released.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

You're right, thanks for catching that.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
