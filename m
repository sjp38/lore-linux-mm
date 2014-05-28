Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB9C6B0036
	for <linux-mm@kvack.org>; Wed, 28 May 2014 08:10:39 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id pv20so7186385lab.41
        for <linux-mm@kvack.org>; Wed, 28 May 2014 05:10:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez4si13210717wib.65.2014.05.28.05.10.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 05:10:31 -0700 (PDT)
Date: Wed, 28 May 2014 14:10:23 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140528121023.GA10735@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

Hi Andrew, Johannes,

On Mon 28-04-14 14:26:41, Michal Hocko wrote:
> This patchset introduces such low limit that is functionally similar
> to a minimum guarantee. Memcgs which are under their lowlimit are not
> considered eligible for the reclaim (both global and hardlimit) unless
> all groups under the reclaimed hierarchy are below the low limit when
> all of them are considered eligible.
> 
> The previous version of the patchset posted as a RFC
> (http://marc.info/?l=linux-mm&m=138677140628677&w=2) suggested a
> hard guarantee without any fallback. More discussions led me to
> reconsidering the default behavior and come up a more relaxed one. The
> hard requirement can be added later based on a use case which really
> requires. It would be controlled by memory.reclaim_flags knob which
> would specify whether to OOM or fallback (default) when all groups are
> bellow low limit.

It seems that we are not in a full agreement about the default behavior
yet. Johannes seems to be more for hard guarantee while I would like to
see the weaker approach first and move to the stronger model later.
Johannes, is this absolutely no-go for you? Do you think it is seriously
handicapping the semantic of the new knob?

My main motivation for the weaker model is that it is hard to see all
the corner case right now and once we hit them I would like to see a
graceful fallback rather than fatal action like OOM killer. Besides that
the usaceses I am mostly interested in are OK with fallback when the
alternative would be OOM killer. I also feel that introducing a knob
with a weaker semantic which can be made stronger later is a sensible
way to go.

It would be helpful to have a counter which would tell us how many times
the lowlimit was breached if we go with the weaker semantic.  I guess we
have touched that already but I haven't posted any patch yet.  So here
it goes.
---
