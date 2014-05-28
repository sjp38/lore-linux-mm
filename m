Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1713F6B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 09:50:02 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id c11so5816412lbj.38
        for <linux-mm@kvack.org>; Wed, 28 May 2014 06:50:02 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id co10si13841735wib.42.2014.05.28.06.49.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 28 May 2014 06:49:42 -0700 (PDT)
Date: Wed, 28 May 2014 09:49:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140528134905.GF2878@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140528121023.GA10735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140528121023.GA10735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed, May 28, 2014 at 02:10:23PM +0200, Michal Hocko wrote:
> Hi Andrew, Johannes,
> 
> On Mon 28-04-14 14:26:41, Michal Hocko wrote:
> > This patchset introduces such low limit that is functionally similar
> > to a minimum guarantee. Memcgs which are under their lowlimit are not
> > considered eligible for the reclaim (both global and hardlimit) unless
> > all groups under the reclaimed hierarchy are below the low limit when
> > all of them are considered eligible.
> > 
> > The previous version of the patchset posted as a RFC
> > (http://marc.info/?l=linux-mm&m=138677140628677&w=2) suggested a
> > hard guarantee without any fallback. More discussions led me to
> > reconsidering the default behavior and come up a more relaxed one. The
> > hard requirement can be added later based on a use case which really
> > requires. It would be controlled by memory.reclaim_flags knob which
> > would specify whether to OOM or fallback (default) when all groups are
> > bellow low limit.
> 
> It seems that we are not in a full agreement about the default behavior
> yet. Johannes seems to be more for hard guarantee while I would like to
> see the weaker approach first and move to the stronger model later.
> Johannes, is this absolutely no-go for you? Do you think it is seriously
> handicapping the semantic of the new knob?

Well we certainly can't start OOMing where we previously didn't,
that's called a regression and automatically limits our options.

Any unexpected OOMs will be much more acceptable from a new feature
than from configuration that previously "worked" and then stopped.

> My main motivation for the weaker model is that it is hard to see all
> the corner case right now and once we hit them I would like to see a
> graceful fallback rather than fatal action like OOM killer. Besides that
> the usaceses I am mostly interested in are OK with fallback when the
> alternative would be OOM killer. I also feel that introducing a knob
> with a weaker semantic which can be made stronger later is a sensible
> way to go.

We can't make it stronger, but we can make it weaker.  Stronger is the
simpler definition, it's simpler code, your usecases are fine with it,
Greg and I prefer it too.  I don't even know what we are arguing about
here.

Patch applies on top of mmots.

---
