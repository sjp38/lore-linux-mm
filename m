Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2476B0256
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 09:50:00 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so32253838wic.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:49:59 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id v1si25059853wja.21.2015.10.23.06.49.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Oct 2015 06:49:59 -0700 (PDT)
Received: by wicfx6 with SMTP id fx6so32253311wic.1
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:49:59 -0700 (PDT)
Date: Fri, 23 Oct 2015 15:49:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] mm: vmscan: report vmpressure at the level of
 reclaim activity
Message-ID: <20151023134957.GC15375@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-8-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445487696-21545-8-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 22-10-15 00:21:35, Johannes Weiner wrote:
> The vmpressure metric is based on reclaim efficiency, which in turn is
> an attribute of the LRU. However, vmpressure events are currently
> reported at the source of pressure rather than at the reclaim level.
> 
> Switch the reporting to the reclaim level to allow finer-grained
> analysis of which memcg is having trouble reclaiming its pages.

I can see how this can be useful.
 
> As far as memory.pressure_level interface semantics go, events are
> escalated up the hierarchy until a listener is found, so this won't
> affect existing users that listen at higher levels.

This is true but the parent will not see cumulative events anymore.
One memcg might be fighting and barely reclaim anything so it would
report high pressure while other would be doing just fine. The parent
will just see conflicting events in a short time period and cannot match
them the source memcg. This sounds really confusing. Even more confusing
than the current semantic which allows the same behavior under certain
configurations.

I dunno, have to think about it some more. Maybe we need to rethink the
way how the pressure is signaled. If we want the breakdown of the
particular memcgs then we should be able to identify them for this to be
useful.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
