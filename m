Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id AF0936B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 13:20:53 -0500 (EST)
Received: by wmww144 with SMTP id w144so116457876wmw.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 10:20:53 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s139si21091628wmd.7.2015.11.23.10.20.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 10:20:52 -0800 (PST)
Date: Mon, 23 Nov 2015 13:20:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 09/14] net: tcp_memcontrol: simplify linkage between
 socket and page counter
Message-ID: <20151123182037.GE13000@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-10-git-send-email-hannes@cmpxchg.org>
 <20151120124216.GD31308@esperanza>
 <20151120185648.GC5623@cmpxchg.org>
 <20151123093646.GA29014@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151123093646.GA29014@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 23, 2015 at 12:36:46PM +0300, Vladimir Davydov wrote:
> On Fri, Nov 20, 2015 at 01:56:48PM -0500, Johannes Weiner wrote:
> > I actually had all this at first, but then wondered if it makes more
> > sense to keep the legacy code in isolation. Don't you think it would
> > be easier to keep track of what's v1 and what's v2 if we keep the
> > legacy stuff physically separate as much as possible? In particular I
> > found that 'tcp_mem.' marker really useful while working on the code.
> > 
> > In the same vein, tcp_memcontrol.c doesn't really hurt anybody and I'd
> > expect it to remain mostly unopened and unchanged in the future. But
> > if we merge it into memcontrol.c, that code will likely be in the way
> > and we'd have to make it explicit somehow that this is not actually
> > part of the new memory controller anymore.
> > 
> > What do you think?
> 
> There isn't much code left in tcp_memcontrol.c, and not all of it is
> legacy. We still want to call tcp_init_cgroup and tcp_destroy_cgroup
> from memcontrol.c - in fact, it's the only call site, so I think we'd
> better keep these functions there. Apart from init/destroy, there is
> only stuff for handling legacy files, which is relatively small and
> isolated. We can just put it along with memsw and kmem legacy files in
> the end of memcontrol.c adding a comment that it's legacy. Personally,
> I'd find the code easier to follow then, because currently the logic
> behind the ACTIVE flag as well as memcg->tcp_mem init/use/destroy turns
> out to be scattered between two files in different subsystems for no
> apparent reason now, as it does not need tcp_prot any more. Besides,
> this would allow us to accurately reuse the ACTIVE flag in init/destroy
> for inc/dec static branch and probably in sock_update_memcg instead of
> sprinkling cgroup_subsys_on_dfl all over the place, which would make the
> code a bit cleaner IMO (in fact, that's why I proposed to drop ACTIVATED
> bit and replace cg_proto->flags with ->active bool).

As far as I can see, all of tcp_memcontrol.c is legacy, including the
init and destroy functions. We only call them to set up the legacy
tcp_mem state and do legacy jump-label maintenance. Delete it all and
the unified hierarchy controller would still work. So I don't really
see the benefits of consolidating it, and more risk of convoluting.

That being said, if you care strongly about it and see opportunities
to cut down code and make things more readable, please feel free to
turn the flags -> bool patch into a followup series and I'll be happy
to review it.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
