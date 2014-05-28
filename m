Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE486B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 11:54:23 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id bs8so4110143wib.0
        for <linux-mm@kvack.org>; Wed, 28 May 2014 08:54:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w1si32975353wjz.45.2014.05.28.08.54.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 08:54:17 -0700 (PDT)
Date: Wed, 28 May 2014 17:54:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140528155414.GN9895@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140528121023.GA10735@dhcp22.suse.cz>
 <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140528152854.GG2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed 28-05-14 11:28:54, Johannes Weiner wrote:
> On Wed, May 28, 2014 at 04:21:44PM +0200, Michal Hocko wrote:
> > On Wed 28-05-14 09:49:05, Johannes Weiner wrote:
> > > On Wed, May 28, 2014 at 02:10:23PM +0200, Michal Hocko wrote:
[...]
> > > > My main motivation for the weaker model is that it is hard to see all
> > > > the corner case right now and once we hit them I would like to see a
> > > > graceful fallback rather than fatal action like OOM killer. Besides that
> > > > the usaceses I am mostly interested in are OK with fallback when the
> > > > alternative would be OOM killer. I also feel that introducing a knob
> > > > with a weaker semantic which can be made stronger later is a sensible
> > > > way to go.
> > > 
> > > We can't make it stronger, but we can make it weaker. 
> > 
> > Why cannot we make it stronger by a knob/configuration option?
> 
> Why can't we make it weaker by a knob?

I haven't said we couldn't.

> Why should we design the default for unforeseeable cornercases
> rather than make the default make sense for existing cases and give
> cornercases a fallback once they show up?

Sure we can do that but it would be little bit lame IMO. We are
promising something and once we find out it doesn't work we will make
it weaker to workaround that.

Besides that the default should reflect the usecases, no? Do we have any
use case for the hard guarantee?

> > > Stronger is the simpler definition, it's simpler code,
> > 
> > The code is not really that much simpler. The one you have posted will
> > not work I am afraid. I haven't tested it yet but I remember I had to do
> > some tweaks to the reclaim path to not end up in an endless loop in the
> > direct reclaim (http://marc.info/?l=linux-mm&m=138677140828678&w=2 and
> > http://marc.info/?l=linux-mm&m=138677141328682&w=2).
> 
> That's just a result of do_try_to_free_pages being stupid and using
> its own zonelist loop to check reclaimability by duplicating all the
> checks instead of properly using returned state of shrink_zones().
> Something that would be worth fixing regardless of memcg guarantees.
> 
> Or maybe we could add the guaranteed lru pages to sc->nr_scanned.

Fixes might be different than what I was proposing previously. I was
merely pointing out that removing the retry loop is not sufficient.

> > > your usecases are fine with it,
> > 
> > my usecases do not overcommit low_limit on the available memory, so far
> > so good, but once we hit a corner cases when limits are set properly but
> > we end up not being able to reclaim anybody in a zone then OOM sounds
> > too brutal.
> 
> What cornercases?

I have mentioned a case where NUMA placement and specific node bindings
interfering with other allocators can end up in unreclaimable zones.
While you might disagree about the setup I have seen different things
done out there.

Besides that the reclaim logic is complex enough and history thought me
that little buggers are hidden at places where you do not expect them.

So call me a chicken but I would sleep calmer if we start weaker and add
an additional guarantees later when somebody really insists on rseeing
an OOM rather than get reclaimed.
The proposed counter can tell us more how good we are at not touching
groups with the limit and we can eventually debug those corner cases
without affecting the loads too much.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
