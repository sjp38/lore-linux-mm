Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 5CCC36B00E8
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 03:16:23 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 01BDF3EE0BD
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:16:22 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D6FB245DEAD
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:16:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A94E645DEB3
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:16:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3094E1DB8040
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:16:21 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE98A1DB803B
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 16:16:20 +0900 (JST)
Message-ID: <4F8E69D8.4070102@jp.fujitsu.com>
Date: Wed, 18 Apr 2012 16:14:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/7] memcg: divide force_empty into 2 functions, avoid
 memory reclaim at rmdir
References: <4F86B9BE.8000105@jp.fujitsu.com> <4F86BC71.9070403@jp.fujitsu.com> <CALWz4iwYX4r5dJmcKFuc+zj_rjMB76dtpbvArdzySF+dyxMohg@mail.gmail.com>
In-Reply-To: <CALWz4iwYX4r5dJmcKFuc+zj_rjMB76dtpbvArdzySF+dyxMohg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>

(2012/04/18 2:29), Ying Han wrote:

> On Thu, Apr 12, 2012 at 4:28 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> Now, at rmdir, memory cgroup's charge will be moved to
>>  - parent if use_hierarchy=1
>>  - root   if use_hierarchy=0
>>
>> Then, we don't have to have memory reclaim code at destroying memcg.
>>
>> This patch divides force_empty to 2 functions as
>>
>>  - memory_cgroup_recharge() ... try to move all charges to ancestors.
>>  - memory_cgroup_force_empty().. try to reclaim all memory.
>>
>> After this patch, memory.force_empty will _not_ move charges to ancestors
>> but just reclaim all pages. (This meets documenation.)
> 
> Not sure why it matches the documentation:
> "
> memory.force_empty>---->------- # trigger forced move charge to parent
> "

I missed this...

> 
> and
> "
>   # echo 0 > memory.force_empty
> 
>   Almost all pages tracked by this memory cgroup will be unmapped and freed.
>   Some pages cannot be freed because they are locked or in-use. Such pages are
>   moved to parent and this cgroup will be empty. This may return -EBUSY if
>   VM is too busy to free/move all pages immediately.
> "
> 


The 1st feature is "will be unmapped and freed".

I'll update Documentation. Thank you.

-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
