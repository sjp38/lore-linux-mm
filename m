Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id E8AE96B0044
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 11:35:09 -0400 (EDT)
Date: Tue, 9 Oct 2012 17:35:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v4 08/14] res_counter: return amount of charges after
 res_counter_uncharge
Message-ID: <20121009153506.GD7655@dhcp22.suse.cz>
References: <1349690780-15988-1-git-send-email-glommer@parallels.com>
 <1349690780-15988-9-git-send-email-glommer@parallels.com>
 <20121009150845.GC7655@dhcp22.suse.cz>
 <50743F71.7090409@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50743F71.7090409@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>

On Tue 09-10-12 19:14:57, Glauber Costa wrote:
> On 10/09/2012 07:08 PM, Michal Hocko wrote:
> > As I have already mentioned in my previous feedback this is cetainly not
> > atomic as you the lock protects only one group in the hierarchy. How is
> > the return value from this function supposed to be used?
> 
> So, I tried to make that clearer in the updated changelog.
> 
> Only the value of the base memcg (the one passed to the function) is
> returned, and it is atomic, in the sense that it has the same semantics
> as the atomic variables: If 2 threads uncharge 4k each from a 8 k
> counter, a subsequent read can return 0 for both. The return value here
> will guarantee that only one sees the drop to 0.
> 
> This is used in the patch "kmem_accounting lifecycle management" to be
> sure that only one process will call mem_cgroup_put() in the memcg
> structure.

Yes, you are using res_counter_uncharge and its semantic makes sense.
I was refering to res_counter_uncharge_until (you removed that context
from my reply) because that one can race resulting that nobody sees 0
even though that parents get down to 0 as a result:
	 A
	 |
	 B
	/ \
      C(x)  D(y)

D and C uncharge everything.

CPU0				CPU1
ret += uncharge(D) [0]		ret += uncharge(C) [0]
ret += uncharge(B) [x-from C]
				ret += uncharge(B) [0]
				ret += uncharge(A) [y-from D]
ret += uncharge(A) [0]

ret == x			ret == y
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
