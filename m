Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A95BF6B00F7
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 07:19:34 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CD8CE3EE0BB
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:19:32 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD73245DE5B
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:19:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F7B645DE59
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:19:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E83B1DB8057
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:19:32 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 344361DB804B
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 20:19:32 +0900 (JST)
Message-ID: <4F86B9BE.8000105@jp.fujitsu.com>
Date: Thu, 12 Apr 2012 20:17:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v1 0/7] memcg remove pre_destroy
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In recent discussion, Tejun Heo, cgroup maintainer, has a plan to remove
->pre_destroy(). And now, in cgroup tree, pre_destroy() failure cause WARNING.

By pre_destroy(), rmdir of cgroup can return -EBUSY or some error.
It makes cgroup complicated and unstable. I said O.K. to remove it and
this patch is modification for memcg.

One of problem in current implementation is that memcg moves all charges to
parent in pre_destroy(). At doing so, if use_hierarchy=0, pre_destroy() may
hit parent's limit and may return -EBUSY. To fix this problem, this patch
changes behavior of rmdir() as

 - if use_hierarchy=0, all remaining charges will go to root cgroup.
 - if use_hierarchy=1, all remaining charges will go to the parent.

By this, rmdir failure will not be caused by parent's limitation. And
I think this meets meaning of use_hierarchy.

This series does
  - add above change of behavior
  - use workqueue to move all pages to parent
  - remove unnecessary codes.

I'm sorry if my reply is delayed, I'm not sure I can have enough time in
this weekend. Any comments are welcomed.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
