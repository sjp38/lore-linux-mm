Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 540B26B0062
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 07:00:03 -0400 (EDT)
Message-ID: <4FEC3891.2000702@parallels.com>
Date: Thu, 28 Jun 2012 14:57:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] add res_counter_usage_safe
References: <4FEC300A.7040209@jp.fujitsu.com>
In-Reply-To: <4FEC300A.7040209@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On 06/28/2012 02:20 PM, Kamezawa Hiroyuki wrote:
> I think usage > limit means a sign of BUG. But, sometimes,
> res_counter_charge_nofail() is very convenient. tcp_memcg uses it.
> And I'd like to use it for helping page migration.
> 
> This patch adds res_counter_usage_safe() which returns min(usage,limit).
> By this we can use res_counter_charge_nofail() without breaking
> user experience.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I totally agree.

It would be very nice to never go over limit, but truth is, sometimes
we're forced too - for a limited time. In those circumstances, it is
better to actually charge memcg, so the charges won't unbalance and
disappear. Every work around proposed so far for those has been to
basically add some form of "extra_charge" to the memcg, that would
effectively charge to it, but not display it.

The good fix is in the display side.

We should just be careful to always have good justification for no_fail
usage. It should be reserved to those situations where we really need
it, but that's on us on future reviews.

For the idea:

Acked-by: Glauber Costa <glommer@parallels.com>

For the patch itself: I believe we can take the lock once in
res_counter_usage_safe, and then read the value and the limit under it.

Calling res_counter_read_u64 two times seems not only wasteful but
potentially wrong, since they can change under our nose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
