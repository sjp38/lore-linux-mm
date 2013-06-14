Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 865AA6B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 21:57:38 -0400 (EDT)
Message-ID: <51BA7794.2000305@huawei.com>
Date: Fri, 14 Jun 2013 09:53:24 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH v4 0/9] memcg: make memcg's life cycle the same as cgroup
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

Hi Andrew,

All the patches in this patchset has been acked by Michal and Kamezawa-san, and
it's ready to be merged into -mm.

I have another pending patchset that kills css_id, which depends on this one.


Changes since v3:
- rebased against mmotm 2013-06-06-16-19
- changed wmb() to smp_wmb() and moved it to memcg_kmem_mark_dead() and added
  more comment.

Changes since v2:

- rebased against 3.10-rc1
- collected some acks
- the two memcg bug fixes has been merged into mainline
- the cgroup core patch has been merged into mainline

Changes since v1:

- wrote better changelog and added acked-by and reviewed-by tags
- revised some comments as suggested by Michal
- added a wmb() in kmem_cgroup_css_offline(), pointed out by Michal
- fixed a bug which causes a css_put() never be called


Now memcg has its own refcnt, so when a cgroup is destroyed, the memcg can
still be alive. This patchset converts memcg to always use css_get/put, so
memcg will have the same life cycle as its corresponding cgroup.

The historical reason that memcg didn't use css_get in some cases, is that
cgroup couldn't be removed if there're still css refs. The situation has
changed so that rmdir a cgroup will succeed regardless css refs, but won't
be freed until css refs goes down to 0.

Since the introduction of kmemcg, the memcg refcnt handling grows even more
complicated. This patchset greately simplifies memcg's life cycle management.

Also, after those changes, we can convert memcg to use cgroup->id, and then
we can kill css_id.

Li Zefan (7):
  memcg: use css_get() in sock_update_memcg()
  memcg: don't use mem_cgroup_get() when creating a kmemcg cache
  memcg: use css_get/put when charging/uncharging kmem
  memcg: use css_get/put for swap memcg
  memcg: don't need to get a reference to the parent
  memcg: kill memcg refcnt
  memcg: don't need to free memcg via RCU or workqueue

Michal Hocko (2):
  Revert "memcg: avoid dangling reference count in creation failure."
  memcg, kmem: fix reference count handling on the error path

 mm/memcontrol.c | 208 +++++++++++++++++++++-----------------------------------
 1 file changed, 77 insertions(+), 131 deletions(-)

-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
