Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9F1C6B026C
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:17:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d28so7508379pfe.2
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:17:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b26si6759177pgf.731.2017.10.09.11.17.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Oct 2017 11:17:56 -0700 (PDT)
Date: Mon, 9 Oct 2017 20:17:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171009181754.37svpqljub2goojr@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com>
 <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009180409.z3mpk3m7m75hjyfv@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009180409.z3mpk3m7m75hjyfv@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 09-10-17 20:04:09, Michal Hocko wrote:
> [CC Johannes - the thread starts
> http://lkml.kernel.org/r/20171005222144.123797-1-shakeelb@google.com]
> 
> On Mon 09-10-17 10:52:44, Greg Thelen wrote:
[...]
> > A few ideas on how to make it more flexible:
> > 
> > a) Go back to memcg oom killing within memcg charging.  This runs risk
> >    of oom killing while caller holds locks which oom victim selection or
> >    oom victim termination may need.  Google's been running this way for
> >    a while.

We can actually reopen this discussion now that the oom handling is
async due to the oom_reaper. At least for the v2 interface. I would have
to think about it much more but the primary concern for this patch was
whether we really need/want to charge short therm objects which do not
outlive a single syscall.
 
> > b) Have every syscall return do something similar to page fault handler:
> >    kmem allocations in oom memcg mark the current task as needing an oom
> >    check return NULL.  If marked oom, syscall exit would use
> >    mem_cgroup_oom_synchronize() before retrying the syscall.  Seems
> >    risky.  I doubt every syscall is compatible with such a restart.

yes, this is simply a no go

> > c) Overcharge kmem to oom memcg and queue an async memcg limit checker,
> >    which will oom kill if needed.

This is what we have max limit for.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
