Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 38E916B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:49:46 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id td3so68906897pab.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:49:46 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tl2si4451236pac.218.2016.03.11.03.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 03:49:45 -0800 (PST)
Date: Fri, 11 Mar 2016 14:49:34 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below
 usage
Message-ID: <20160311114934.GL1946@esperanza>
References: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
 <20160311083440.GI1946@esperanza>
 <20160311084238.GE27701@dhcp22.suse.cz>
 <20160311091303.GJ1946@esperanza>
 <20160311095309.GF27701@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160311095309.GF27701@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Mar 11, 2016 at 10:53:09AM +0100, Michal Hocko wrote:
> > OTOH memory.low and memory.high are perfect to be changed dynamically,
> > basing on containers' memory demand/pressure. A load manager might want
> > to reconfigure these knobs say every 5 seconds. Spawning a thread per
> > each container that often would look unnecessarily overcomplicated IMO.
> 
> The question however is whether we want to hide a potentially costly
> operation and have it unaccounted and hidden in the kworker context.

There's already mem_cgroup->high_work doing reclaim in an unaccounted
context quite often if tcp accounting is enabled. And there's kswapd.
memory.high knob is for the root only so it can't be abused by an
unprivileged user. Regarding a privileged user, e.g. load manager, it
can screw things up anyway, e.g. by configuring sum of memory.low to be
greater than total RAM on the host and hence driving kswapd mad.

> I mean fork() + write() doesn't sound terribly complicated to me to have
> a rather subtle behavior in the kernel.

It'd be just a dubious API IMHO. With memory.max everything's clear: it
tries to reclaim memory hard, may stall for several seconds, may invoke
OOM, but if it finishes successfully we have memory.current less than
memory.max. With this patch memory.high knob behaves rather strangely:
it might stall, but there's no guarantee you'll have memory.current less
than memory.high; moreover, according to the documentation it's OK to
have memory.current greater than memory.high, so what's the point in
calling synchronous reclaim blocking the caller?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
