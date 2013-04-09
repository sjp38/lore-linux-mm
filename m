Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 8C7D56B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:51:59 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D6AE53EE0C8
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:51:57 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B6B8645DEBE
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:51:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D2BF45DEB6
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:51:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 761571DB8043
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:51:57 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 22B711DB803E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:51:57 +0900 (JST)
Message-ID: <5163823B.4020109@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 11:51:39 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/12] memcg, kmem: fix reference count handling on the
 error path
References: <5162648B.9070802@huawei.com> <516264D6.3090100@huawei.com>
In-Reply-To: <516264D6.3090100@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2013/04/08 15:33), Li Zefan wrote:
> From: Michal Hocko <mhocko@suse.cz>
> 
> mem_cgroup_css_online calls mem_cgroup_put if memcg_init_kmem
> fails. This is not correct because only memcg_propagate_kmem takes an
> additional reference while mem_cgroup_sockets_init is allowed to fail as
> well (although no current implementation fails) but it doesn't take any
> reference. This all suggests that it should be memcg_propagate_kmem that
> should clean up after itself so this patch moves mem_cgroup_put over
> there.
> 
> Unfortunately this is not that easy (as pointed out by Li Zefan) because
> memcg_kmem_mark_dead marks the group dead (KMEM_ACCOUNTED_DEAD) if it
> is marked active (KMEM_ACCOUNTED_ACTIVE) which is the case even if
> memcg_propagate_kmem fails so the additional reference is dropped in
> that case in kmem_cgroup_destroy which means that the reference would be
> dropped two times.
> 
> The easiest way then would be to simply remove mem_cgrroup_put from
> mem_cgroup_css_online and rely on kmem_cgroup_destroy doing the right
> thing.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Cc: <stable@vger.kernel.org> # 3.8.x

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
