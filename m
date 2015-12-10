Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 622736B0257
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 09:00:26 -0500 (EST)
Received: by wmec201 with SMTP id c201so26052685wme.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 06:00:26 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g2si18985061wjb.166.2015.12.10.06.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 06:00:25 -0800 (PST)
Date: Thu, 10 Dec 2015 09:00:12 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/8] mm: memcontrol: move kmem accounting code to
 CONFIG_MEMCG
Message-ID: <20151210140012.GA21987@cmpxchg.org>
References: <1449599665-18047-1-git-send-email-hannes@cmpxchg.org>
 <1449599665-18047-7-git-send-email-hannes@cmpxchg.org>
 <20151210131718.GL19496@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151210131718.GL19496@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Dec 10, 2015 at 02:17:18PM +0100, Michal Hocko wrote:
> On Tue 08-12-15 13:34:23, Johannes Weiner wrote:
> > The cgroup2 memory controller will account important in-kernel memory
> > consumers per default. Move all necessary components to CONFIG_MEMCG.
> 
> Hmm, that bloats the kernel also for users who are not using cgroup2
> and have CONFIG_MEMCG_KMEM disabled.

Huh? The clock is ticking for them. We'll keep the original cgroup
interface around for backwards compatibility as long as we think there
are activer users, but this is not the time to microoptimize v1. A
slight increase to kernel size is unfortunate, but I don't think this
could be considered a regression in the sense that it breaks anything.

I'm more concerned with cgroup2 users having to pay the excessive cost
of v1-only features, like the entire soft limit implementation, charge
migration, which also has its fangs in VM hotpaths, the eventfd stuff,
arbitrarily-configurable usage thresholds. That's a *ton* of code. If
you want to tackle kernel bloat, grouping this stuff all together and
slapping a CONFIG_MEMCG_LEGACY around it would be a real step forward.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
