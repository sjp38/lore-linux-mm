Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id A9D0A6B0044
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 10:22:30 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so2929932pad.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 07:22:30 -0800 (PST)
Date: Tue, 4 Dec 2012 07:22:25 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 4/4] memcg: replace cgroup_lock with memcg specific
 memcg_lock
Message-ID: <20121204152225.GC3885@mtj.dyndns.org>
References: <1354282286-32278-1-git-send-email-glommer@parallels.com>
 <1354282286-32278-5-git-send-email-glommer@parallels.com>
 <20121203171532.GG17093@dhcp22.suse.cz>
 <50BDAD38.6030200@parallels.com>
 <20121204082316.GB31319@dhcp22.suse.cz>
 <50BDB4E3.4040107@parallels.com>
 <20121204084544.GC31319@dhcp22.suse.cz>
 <20121204145221.GA3885@mtj.dyndns.org>
 <20121204151420.GL31319@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121204151420.GL31319@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

Hello, Michal.

On Tue, Dec 04, 2012 at 04:14:20PM +0100, Michal Hocko wrote:
> OK, I read this as "generic helper doesn't make much sense". Then I
> would just ask. Does cgroup core really care whether we do
> list_empty test? Is this something that we have to care about in memcg
> and should fix? If yes then just try to do it as simple as possible.

The thing is, what does the test mean when it doesn't have proper
synchronization?  list_empty(&cgroup->children) doesn't really have a
precise meaning if you're not synchronized.  There could be cases
where such correct-most-of-the-time results are okay but depending on
stuff like that is a sure-fire way to subtle bugs.

So, my recommendation would be to bite the bullet and implement
properly synchronized on/offline state and teach the memcg iterator
about it so that memcg can definitively tell what's online and what's
not while holding memcg_mutex, and use such knowledge consistently.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
