Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id A76886B007D
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:58:07 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so4184355pbb.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 07:58:07 -0700 (PDT)
Date: Thu, 27 Sep 2012 07:58:02 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 04/13] kmem accounting basic infrastructure
Message-ID: <20120927145802.GC4251@mtj.dyndns.org>
References: <50634FC9.4090609@parallels.com>
 <20120926193417.GJ12544@google.com>
 <50635B9D.8020205@parallels.com>
 <20120926195648.GA20342@google.com>
 <50635F46.7000700@parallels.com>
 <20120926201629.GB20342@google.com>
 <50637298.2090904@parallels.com>
 <20120927120806.GA29104@dhcp22.suse.cz>
 <20120927143300.GA4251@mtj.dyndns.org>
 <20120927144307.GH3429@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120927144307.GH3429@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello, Mel.

On Thu, Sep 27, 2012 at 03:43:07PM +0100, Mel Gorman wrote:
> > I'm not too convinced.  First of all, the overhead added by kmemcg
> > isn't big. 
> 
> Really?
> 
> If kmemcg was globally accounted then every __GFP_KMEMCG allocation in
> the page allocator potentially ends up down in
> __memcg_kmem_newpage_charge which
> 
> 1. takes RCU read lock
> 2. looks up cgroup from task
> 3. takes a reference count
> 4. memcg_charge_kmem -> __mem_cgroup_try_charge
> 5. release reference count
> 
> That's a *LOT* of work to incur for cgroups that do not care about kernel
> accounting. This is why I thought it was reasonable that the kmem accounting
> not be global.

But that happens only when pages enter and leave slab and if it still
is significant, we can try to further optimize charging.  Given that
this is only for cases where memcg is already in use and we provide a
switch to disable it globally, I really don't think this warrants
implementing fully hierarchy configuration.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
