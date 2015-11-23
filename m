Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 91C1C6B0254
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 04:37:07 -0500 (EST)
Received: by pacej9 with SMTP id ej9so185970285pac.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 01:37:07 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pt7si18672151pbb.8.2015.11.23.01.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 01:37:06 -0800 (PST)
Date: Mon, 23 Nov 2015 12:36:46 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 09/14] net: tcp_memcontrol: simplify linkage between
 socket and page counter
Message-ID: <20151123093646.GA29014@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-10-git-send-email-hannes@cmpxchg.org>
 <20151120124216.GD31308@esperanza>
 <20151120185648.GC5623@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151120185648.GC5623@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Nov 20, 2015 at 01:56:48PM -0500, Johannes Weiner wrote:
> On Fri, Nov 20, 2015 at 03:42:16PM +0300, Vladimir Davydov wrote:
> > On Thu, Nov 12, 2015 at 06:41:28PM -0500, Johannes Weiner wrote:
> > > There won't be any separate counters for socket memory consumed by
> > > protocols other than TCP in the future. Remove the indirection and
> > 
> > I really want to believe you're right. And with vmpressure propagation
> > implemented properly you are likely to be right.
> > 
> > However, we might still want to account other socket protos to
> > memcg->memory in the unified hierarchy, e.g. UDP, or SCTP, or whatever
> > else. Adding new consumers should be trivial, but it will break the
> > legacy usecase, where only TCP sockets are supposed to be accounted.
> > What about adding a check to sock_update_memcg() so that it would enable
> > accounting only for TCP sockets in case legacy hierarchy is used?
> 
> Yup, I was thinking the same thing. But we can cross that bridge when
> we come to it and are actually adding further packet types.

Fair enough.

> 
> > For the same reason, I think we'd better rename memcg->tcp_mem to
> > something like memcg->sk_mem or we can even drop the cg_proto struct
> > altogether embedding its fields directly to mem_cgroup struct.
> > 
> > Also, I don't see any reason to have tcp_memcontrol.c file. It's tiny
> > and with this patch it does not depend on tcp code any more. Let's move
> > it to memcontrol.c?
> 
> I actually had all this at first, but then wondered if it makes more
> sense to keep the legacy code in isolation. Don't you think it would
> be easier to keep track of what's v1 and what's v2 if we keep the
> legacy stuff physically separate as much as possible? In particular I
> found that 'tcp_mem.' marker really useful while working on the code.
> 
> In the same vein, tcp_memcontrol.c doesn't really hurt anybody and I'd
> expect it to remain mostly unopened and unchanged in the future. But
> if we merge it into memcontrol.c, that code will likely be in the way
> and we'd have to make it explicit somehow that this is not actually
> part of the new memory controller anymore.
> 
> What do you think?

There isn't much code left in tcp_memcontrol.c, and not all of it is
legacy. We still want to call tcp_init_cgroup and tcp_destroy_cgroup
from memcontrol.c - in fact, it's the only call site, so I think we'd
better keep these functions there. Apart from init/destroy, there is
only stuff for handling legacy files, which is relatively small and
isolated. We can just put it along with memsw and kmem legacy files in
the end of memcontrol.c adding a comment that it's legacy. Personally,
I'd find the code easier to follow then, because currently the logic
behind the ACTIVE flag as well as memcg->tcp_mem init/use/destroy turns
out to be scattered between two files in different subsystems for no
apparent reason now, as it does not need tcp_prot any more. Besides,
this would allow us to accurately reuse the ACTIVE flag in init/destroy
for inc/dec static branch and probably in sock_update_memcg instead of
sprinkling cgroup_subsys_on_dfl all over the place, which would make the
code a bit cleaner IMO (in fact, that's why I proposed to drop ACTIVATED
bit and replace cg_proto->flags with ->active bool).

Regarding, tcp_mem marker, well, currently it's OK, because we don't
account anything but TCP sockets, but when it changes (and I'm pretty
sure it will), we'll have to rename it anyway. For now, I'm OK with
leaving it as is though.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
