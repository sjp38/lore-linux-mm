Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0E736B02F3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 11:16:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v14so4811178wmf.6
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 08:16:35 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id w28si29815739edb.21.2017.06.05.08.16.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Jun 2017 08:16:34 -0700 (PDT)
Date: Mon, 5 Jun 2017 11:16:22 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/memcontrol: exclude @root from checks in
 mem_cgroup_low
Message-ID: <20170605151622.GB10679@cmpxchg.org>
References: <1496434412-21005-1-git-send-email-sean.j.christopherson@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496434412-21005-1-git-send-email-sean.j.christopherson@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: mhocko@kernel.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 02, 2017 at 01:13:32PM -0700, Sean Christopherson wrote:
> Make @root exclusive in mem_cgroup_low; it is never considered low
> when looked at directly and is not checked when traversing the tree.
> In effect, @root is handled identically to how root_mem_cgroup was
> previously handled by mem_cgroup_low.
> 
> If @root is not excluded from the checks, a cgroup underneath @root
> will never be considered low during targeted reclaim of @root, e.g.
> due to memory.current > memory.high, unless @root is misconfigured
> to have memory.low > memory.high.
> 
> Excluding @root enables using memory.low to prioritize memory usage
> between cgroups within a subtree of the hierarchy that is limited by
> memory.high or memory.max, e.g. when ROOT owns @root's controls but
> delegates the @root directory to a USER so that USER can create and
> administer children of @root.
> 
> For example, given cgroup A with children B and C:
> 
>     A
>    / \
>   B   C
> 
> and
> 
>   1. A/memory.current > A/memory.high
>   2. A/B/memory.current < A/B/memory.low
>   3. A/C/memory.current >= A/C/memory.low
> 
> As 'A' is high, i.e. triggers reclaim from 'A', and 'B' is low, we
> should reclaim from 'C' until 'A' is no longer high or until we can
> no longer reclaim from 'C'.  If 'A', i.e. @root, isn't excluded by
> mem_cgroup_low when reclaming from 'A', then 'B' won't be considered
> low and we will reclaim indiscriminately from both 'B' and 'C'.
> 
> Signed-off-by: Sean Christopherson <sean.j.christopherson@intel.com>

Good catch, thank you Sean.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
