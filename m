Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 759596B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 13:56:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u23so14901125pgo.4
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 10:56:04 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si418830plg.704.2017.10.24.10.56.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 10:56:03 -0700 (PDT)
Date: Tue, 24 Oct 2017 19:55:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171024175558.uxqtxwhjgu6ceadk@dhcp22.suse.cz>
References: <20171010091430.giflzlayvjblx5bu@dhcp22.suse.cz>
 <20171010141733.GB16710@cmpxchg.org>
 <20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz>
 <20171012190312.GA5075@cmpxchg.org>
 <20171013063555.pa7uco43mod7vrkn@dhcp22.suse.cz>
 <20171013070001.mglwdzdrqjt47clz@dhcp22.suse.cz>
 <20171013152421.yf76n7jui3z5bbn4@dhcp22.suse.cz>
 <20171024160637.GB32340@cmpxchg.org>
 <20171024162213.n6jrpz3t5pldkgxy@dhcp22.suse.cz>
 <20171024172330.GA3973@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024172330.GA3973@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue 24-10-17 13:23:30, Johannes Weiner wrote:
> On Tue, Oct 24, 2017 at 06:22:13PM +0200, Michal Hocko wrote:
[...]
> > What would prevent a runaway in case the only process in the memcg is
> > oom unkillable then?
> 
> In such a scenario, the page fault handler would busy-loop right now.
> 
> Disabling oom kills is a privileged operation with dire consequences
> if used incorrectly. You can panic the kernel with it. Why should the
> cgroup OOM killer implement protective semantics around this setting?
> Breaching the limit in such a setup is entirely acceptable.
> 
> Really, I think it's an enormous mistake to start modeling semantics
> based on the most contrived and non-sensical edge case configurations.
> Start the discussion with what is sane and what most users should
> optimally experience, and keep the cornercases simple.

I am not really seeing your concern about the semantic. The most
important property of the hard limit is to protect from runaways and
stop them if they happen. Users can use the softer variant (high limit)
if they are not afraid of those scenarios. It is not so insane to
imagine that a master task (which I can easily imagine would be oom
disabled) has a leak and runaway as a result. We are not talking only
about the page fault path. There are other allocation paths to consume a
lot of memory and spill over and break the isolation restriction. So it
makes much more sense to me to fail the allocation in such a situation
rather than allow the runaway to continue. Just consider that such a
situation shouldn't happen in the first place because there should
always be an eligible task to kill - who would own all the memory
otherwise?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
