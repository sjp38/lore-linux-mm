Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id A796A6B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 17:49:14 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc8so830017pbc.18
        for <linux-mm@kvack.org>; Tue, 04 Jun 2013 14:49:13 -0700 (PDT)
Date: Tue, 4 Jun 2013 14:49:10 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130604214910.GL14916@htj.dyndns.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604214050.GP15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604214050.GP15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hello, Johannes.

On Tue, Jun 04, 2013 at 05:40:50PM -0400, Johannes Weiner wrote:
> We might pin them indefinitely.  In a hierarchy with hundreds of
> groups that is short by 10M of memory, we only reclaim from a couple
> of groups before we stop and leave the iterator pointing somewhere in
> the hierarchy.  Until the next reclaimer comes along, which might be a
> split second later or three days later.
> 
> There is a reclaim iterator for every memcg (since every memcg
> represents a hierarchy), so we could pin a lot of csss for an
> indefinite amount of time.

As long as it's bound by the actual number of memcgs in the system and
dead cgroups don't pin any other resources, I don't think pinning css
and thus memcg struct itself is something we need to worry about.
Especially not at the cost of this weak referencing thing.  If the
large number of unused but pinned css's actually is a problem (which I
seriously doubt), we can implement a trivial timer based cache
expiration which can be extremely coarse - ie. each iterator just
keeps the last time stamp it was used and cleanup runs every ten mins
or whatever.  It'll be like twenty lines of completely obvious code.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
