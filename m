Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id D76096B0062
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 22:37:44 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8AF523EE0C2
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:37:42 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 731E745DE7E
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:37:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D5AC45DEA6
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:37:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D4631DB803C
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:37:42 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 009151DB8038
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 11:37:42 +0900 (JST)
Message-ID: <4FED1460.9080700@jp.fujitsu.com>
Date: Fri, 29 Jun 2012 11:35:12 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] add res_counter_usage_safe
References: <4FEC300A.7040209@jp.fujitsu.com> <4FEC3891.2000702@parallels.com>
In-Reply-To: <4FEC3891.2000702@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

(2012/06/28 19:57), Glauber Costa wrote:
> On 06/28/2012 02:20 PM, Kamezawa Hiroyuki wrote:
>> I think usage > limit means a sign of BUG. But, sometimes,
>> res_counter_charge_nofail() is very convenient. tcp_memcg uses it.
>> And I'd like to use it for helping page migration.
>>
>> This patch adds res_counter_usage_safe() which returns min(usage,limit).
>> By this we can use res_counter_charge_nofail() without breaking
>> user experience.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I totally agree.
> 
> It would be very nice to never go over limit, but truth is, sometimes
> we're forced too - for a limited time. In those circumstances, it is
> better to actually charge memcg, so the charges won't unbalance and
> disappear. Every work around proposed so far for those has been to
> basically add some form of "extra_charge" to the memcg, that would
> effectively charge to it, but not display it.
> 
> The good fix is in the display side.
> 
> We should just be careful to always have good justification for no_fail
> usage. It should be reserved to those situations where we really need
> it, but that's on us on future reviews.
> 
> For the idea:
> 
> Acked-by: Glauber Costa <glommer@parallels.com>
> 
> For the patch itself: I believe we can take the lock once in
> res_counter_usage_safe, and then read the value and the limit under it.
> 
> Calling res_counter_read_u64 two times seems not only wasteful but
> potentially wrong, since they can change under our nose.
> 
Thank you for comments.

I'll update the patch using that way.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
