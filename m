Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 27AEE6B0286
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 11:23:00 -0500 (EST)
Received: by wmvv187 with SMTP id v187so286681641wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:22:59 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id hp9si4975605wjb.144.2015.11.18.08.22.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 08:22:58 -0800 (PST)
Received: by wmww144 with SMTP id w144so204270063wmw.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:22:58 -0800 (PST)
Date: Wed, 18 Nov 2015 17:22:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Message-ID: <20151118162256.GK19145@dhcp22.suse.cz>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
 <20151116155923.GH14116@dhcp22.suse.cz>
 <20151116181810.GB32544@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151116181810.GB32544@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 16-11-15 13:18:10, Johannes Weiner wrote:
> On Mon, Nov 16, 2015 at 04:59:25PM +0100, Michal Hocko wrote:
> > On Thu 12-11-15 18:41:32, Johannes Weiner wrote:
> > > Socket memory can be a significant share of overall memory consumed by
> > > common workloads. In order to provide reasonable resource isolation in
> > > the unified hierarchy, this type of memory needs to be included in the
> > > tracking/accounting of a cgroup under active memory resource control.
> > > 
> > > Overhead is only incurred when a non-root control group is created AND
> > > the memory controller is instructed to track and account the memory
> > > footprint of that group. cgroup.memory=nosocket can be specified on
> > > the boot commandline to override any runtime configuration and
> > > forcibly exclude socket memory from active memory resource control.
> > 
> > Do you have any numbers about the overhead?
> 
> Hm? Performance numbers make sense when you have a specific scenario
> and a theory on how to optimize the implementation for it.

The fact that there was a strong push to use static branches to put
the code out of line to reduce an overhead before the feature was
merged shows that people are sensitive to network performance and that
significant effort has been spent to eliminate it. My point was that you
are enabling the feature for all memcg users in unified hierarchy now
without having a performance impact overview which users can use
to judge whether to keep it enabled or disable before they start seeing
regressions or to make regression easier to track once it happens.

> What load would you test and what would be the baseline to compare it
> to?

It seems like netperf with a stream load running in a memcg with no
limits vs. in root memcg (and no other cgroups) should give at least a
hint about the runtime overhead, no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
