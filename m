Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D05476B0253
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:51:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id d28so7103342pfe.1
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 23:51:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u82si193097pgb.607.2017.10.12.23.51.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 23:51:55 -0700 (PDT)
Date: Fri, 13 Oct 2017 08:51:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171013065150.dzesflih5ot2z3px@dhcp22.suse.cz>
References: <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009202613.GA15027@cmpxchg.org>
 <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
 <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
 <20171012190312.GA5075@cmpxchg.org>
 <xr937evzyl5p.fsf@gthelen.svl.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr937evzyl5p.fsf@gthelen.svl.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu 12-10-17 16:57:22, Greg Thelen wrote:
[...]
> Overcharging kmem with deferred reconciliation sounds good to me.
> 
> A few comments (not reasons to avoid this):
> 
> 1) If a task is moved between memcg it seems possible to overcharge
>    multiple oom memcg for different kmem/user allocations.
>    mem_cgroup_oom_synchronize() would see at most one oom memcg in
>    current->memcg_in_oom.  Thus it'd only reconcile a single memcg.  But
>    that seems pretty rare and the next charge to any of the other memcg
>    would reconcile them.

This is a general problem for the cgroup v2 memcg oom handling. 

> 2) if a kernel thread charges kmem on behalf of a client mm then there
>    is no good place to call mem_cgroup_oom_synchronize(), short of
>    launching a work item in mem_cgroup_oom().  I don't we have anything
>    like that yet.  So nothing to worry about.

If we do invoke the OOM killer from the charge path, it shouldn't be a
problem.

> 3) it's debatable if mem_cgroup_oom_synchronize() should first attempt
>    reclaim before killing.  But that's a whole 'nother thread.

Again, this shouldn't be an issue if we invoke the oom killer from the
charge path.

> 4) overcharging with deferred reconciliation could also be used for user
>    pages.  But I haven't looked at the code long enough to know if this
>    would be a net win.

It would solve g-u-p issues failing with ENOMEM unexpectedly just
because of memcg charge failure.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
