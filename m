Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 43DA06B0072
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 23:07:56 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 897993EE0AE
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:07:54 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 73A9045DE4D
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:07:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C4BC45DD78
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:07:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 511E21DB803A
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:07:54 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A4A81DB802C
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 13:07:54 +0900 (JST)
Message-ID: <50B830F8.2010908@jp.fujitsu.com>
Date: Fri, 30 Nov 2012 13:07:20 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2 3/6] memcg: rework mem_cgroup_iter to use cgroup iterators
References: <1353955671-14385-1-git-send-email-mhocko@suse.cz> <1353955671-14385-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1353955671-14385-4-git-send-email-mhocko@suse.cz>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

(2012/11/27 3:47), Michal Hocko wrote:
> mem_cgroup_iter curently relies on css->id when walking down a group
> hierarchy tree. This is really awkward because the tree walk depends on
> the groups creation ordering. The only guarantee is that a parent node
> is visited before its children.
> Example
>   1) mkdir -p a a/d a/b/c
>   2) mkdir -a a/b/c a/d
> Will create the same trees but the tree walks will be different:
>   1) a, d, b, c
>   2) a, b, c, d
> 
> 574bd9f7 (cgroup: implement generic child / descendant walk macros) has
> introduced generic cgroup tree walkers which provide either pre-order
> or post-order tree walk. This patch converts css->id based iteration
> to pre-order tree walk to keep the semantic with the original iterator
> where parent is always visited before its subtree.
> 
> cgroup_for_each_descendant_pre suggests using post_create and
> pre_destroy for proper synchronization with groups addidition resp.
> removal. This implementation doesn't use those because a new memory
> cgroup is fully initialized in mem_cgroup_create and css reference
> counting enforces that the group is alive for both the last seen cgroup
> and the found one resp. it signals that the group is dead and it should
> be skipped.
> 
> If the reclaim cookie is used we need to store the last visited group
> into the iterator so we have to be careful that it doesn't disappear in
> the mean time. Elevated reference count on the css keeps it alive even
> though the group have been removed (parked waiting for the last dput so
> that it can be freed).
> 
> V2
> - use css_{get,put} for iter->last_visited rather than
>    mem_cgroup_{get,put} because it is stronger wrt. cgroup life cycle
> - cgroup_next_descendant_pre expects NULL pos for the first iterartion
>    otherwise it might loop endlessly for intermediate node without any
>    children.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
