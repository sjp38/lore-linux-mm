Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 1FFAE6B0123
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 19:29:44 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B80513EE081
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 08:29:42 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A285045DE50
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 08:29:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 825C745DD78
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 08:29:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 74E6B1DB803A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 08:29:42 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D0C01DB803E
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 08:29:42 +0900 (JST)
Message-ID: <4FE3ADDD.9060908@jp.fujitsu.com>
Date: Fri, 22 Jun 2012 08:27:25 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3][0/6] memcg: prevent -ENOMEM in pre_destroy()
References: <4FACDED0.3020400@jp.fujitsu.com> <20120621202043.GD4642@google.com>
In-Reply-To: <20120621202043.GD4642@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>




(2012/06/22 5:20), Tejun Heo wrote:
> On Fri, May 11, 2012 at 06:41:36PM +0900, KAMEZAWA Hiroyuki wrote:
>> Hi, here is v3 based on memcg-devel tree.
>> git://github.com/mstsxfx/memcg-devel.git
>>
>> This patch series is for avoiding -ENOMEM at calling pre_destroy()
>> which is called at rmdir(). After this patch, charges will be moved
>> to root (if use_hierarchy==0) or parent (if use_hierarchy==1), and
>> we'll not see -ENOMEM in rmdir() of cgroup.
>>
>> v2 included some other patches than ones for handling -ENOMEM problem,
>> but I divided it. I'd like to post others in different series, later.
>> No logical changes in general, maybe v3 is cleaner than v2.
>>
>> 0001 ....fix error code in memcg-hugetlb
>> 0002 ....add res_counter_uncharge_until
>> 0003 ....use res_counter_uncharge_until in memcg
>> 0004 ....move charges to root is use_hierarchy==0
>> 0005 ....cleanup for mem_cgroup_move_account()
>> 0006 ....remove warning of res_counter_uncharge_nofail (from Costa's slub accounting series).
>
> KAME, how is this progressing?  Is it stuck on anything?
>

I think I finished 80% of works and patches are in -mm stack now.
They'll be visible in -next, soon.

Remaining 20% of work is based on a modification to cgroup layer

How do you think this patch ? (This patch is not tested yet...so
may have troubles...) I think callers of pre_destory() is not so many...

==
 From a28db946f91f3509d25779e8c5db249506cc4b07 Mon Sep 17 00:00:00 2001
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 22 Jun 2012 08:38:38 +0900
Subject: [PATCH] cgroup: keep cgroup_mutex() while calling ->pre_destroy()

In past, memcg's pre_destroy() was verrry slow because of the possibility
of page reclaiming in it. So, cgroup_mutex() was released before calling
pre_destroy() callbacks. Now, it's enough fast. memcg just scans the list
and move pages to other cgroup, no memory reclaim happens.
Then, we can keep cgroup_mutex() there.

By holding looks, we can avoid following cases
    1. new task is attached while rmdir().
    2. new child cgroup is created while rmdir()
    3. new task is attached to cgroup and removed from cgroup before
       checking css's count. So, ->destroy() will be called even if
       some trashes by the task remains

(3. is terrible case...even if I think it will not happen in real world..)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
  kernel/cgroup.c |    3 +--
  1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index caff6a1..a5b6df1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4171,7 +4171,6 @@ again:
  		mutex_unlock(&cgroup_mutex);
  		return -EBUSY;
  	}
-	mutex_unlock(&cgroup_mutex);
  
  	/*
  	 * In general, subsystem has no css->refcnt after pre_destroy(). But
@@ -4190,11 +4189,11 @@ again:
  	 */
  	ret = cgroup_call_pre_destroy(cgrp);
  	if (ret) {
+		mutex_unlock(&cgroup_mutex);
  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
  		return ret;
  	}
  
-	mutex_lock(&cgroup_mutex);
  	parent = cgrp->parent;
  	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
-- 
1.7.4.1













--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
