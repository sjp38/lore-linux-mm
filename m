Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8B28A82F65
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 12:56:34 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so123461656wic.0
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 09:56:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ek5si24231134wid.33.2015.10.26.09.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 09:56:33 -0700 (PDT)
Date: Mon, 26 Oct 2015 12:56:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151026165619.GB2214@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
 <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151023.065957.1690815054807881760.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Oct 23, 2015 at 06:59:57AM -0700, David Miller wrote:
> From: Michal Hocko <mhocko@kernel.org>
> Date: Fri, 23 Oct 2015 15:19:56 +0200
> 
> > On Thu 22-10-15 00:21:33, Johannes Weiner wrote:
> >> Socket memory can be a significant share of overall memory consumed by
> >> common workloads. In order to provide reasonable resource isolation
> >> out-of-the-box in the unified hierarchy, this type of memory needs to
> >> be accounted and tracked per default in the memory controller.
> > 
> > What about users who do not want to pay an additional overhead for the
> > accounting? How can they disable it?
> 
> Yeah, this really cannot pass.
> 
> This extra overhead will be seen by %99.9999 of users, since entities
> (especially distributions) just flip on all of these config options by
> default.

Okay, there are several layers to this issue.

If you boot a machine with a CONFIG_MEMCG distribution kernel and
don't create any cgroups, I agree there shouldn't be any overhead.

I already sent a patch to generally remove memory accounting on the
system or root level. I can easily update this patch here to not have
any socket buffer accounting overhead for systems that don't actively
use cgroups. Would you be okay with a branch on sk->sk_memcg in the
network accounting path? I'd leave that NULL on the system level then.

Then there is of course the case when you create cgroups for process
organization but don't care about memory accounting. Systemd comes to
mind. Or even if you create cgroups to track other resources like CPU
but don't care about memory. The unified hierarchy no longer enables
controllers on new cgroups per default, so unless you create a cgroup
and specifically tell it to account and track memory, you won't have
the socket memory accounting overhead, either.

Then there is the third case, where you create a control group to
specifically manage and limit the memory consumption of a workload. In
that scenario, a major memory consumer like socket buffers, which can
easily grow until OOM, should definitely be included in the tracking
in order to properly contain both untrusted (possibly malicious) and
trusted (possibly buggy) workloads. This is not a hole we can
reasonbly leave unpatched for general purpose resource management.

Now you could argue that there might exist specialized workloads that
need to account anonymous pages and page cache, but not socket memory
buffers. Or any other combination of pick-and-choose consumers. But
honestly, nowadays all our paths are lockless, and the counting is an
atomic-add-return with a per-cpu batch cache. I don't think there is a
compelling case for an elaborate interface to make individual memory
consumers configurable inside the memory controller.

So in summary, would you be okay with this patch if networking only
called into the memory controller when you explicitely create a cgroup
AND tell it to track the memory footprint of the workload in it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
