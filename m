Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 794116B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 01:47:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A4CCE3EE0B6
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:47:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 88E5545DE5D
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:47:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FF4245DE59
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:47:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DFBF1DB804E
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:47:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 131BA1DB804F
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:47:37 +0900 (JST)
Message-ID: <4F9A327A.6050409@jp.fujitsu.com>
Date: Fri, 27 Apr 2012 14:45:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/7 v2] memcg: prevent failure in pre_destroy()
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

This is a v2 patch for preventing failure in memcg->pre_destroy().
With this patch, ->pre_destroy() will never return error code and
users will not see warning at rmdir(). And this work will simplify
memcg->pre_destroy(), largely.

This patch is based on linux-next + hugetlb memory control patches.

I post this as RFC because I'll have vacation in the next week and
hugetlb patches are not visible in linux-next yet.
So, I'm not in hurry. Please review when you have time.

I'll rebase this onto memcg-devel in the next post.
== BTW, memory cgroup's github is here == 
git://github.com/mstsxfx/memcg-devel.git

Since v1, Whole patch designs are changed. In this version, I didn't
remove ->pre_destroy() but make it succeed always. There are no
asynchronous operation and no big patches. But this introduces
2 changes to cgroup core.

After this series, if use_hierarchy==0, all resources will be moved
to root cgroup at rmdir() or force_empty().

Brief patch conents are

0001 : my version of compile-fix for linux-next, Aneesh will post his own version.
0002 : fix error code in hugetlb_force_memcg_empty
0003 : add res_counter_uncharge_until()
0004 : use res_counter_uncharge_until() at move_parent()
0005 : move charges to root cgroup at rmdir, if use_hierarchy=0
0006 : clean up mem_cgroup_move_account()
0007 : cgroup : avoid attaching task to cgroup where ->pre_destroy() is running.
0008 : cgroup : avoid creating a new cgroup under a cgroup where ->pre_destroy() is running.
0009 : remove -EINTR from memcg->pre_destroy().

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
