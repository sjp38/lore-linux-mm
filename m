Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 8D0546B0070
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 02:33:43 -0400 (EDT)
Message-ID: <5162648B.9070802@huawei.com>
Date: Mon, 8 Apr 2013 14:32:43 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 0/12][V2] memcg: make memcg's life cycle the same as cgroup
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

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

This patchset is based on linux-next but with "memcg: debugging facility to access dangling memcgs."
excluded.

The first 4 patches are bug fixes that should go into 3.9, and the rest are
for 3.10. The extra patch 13/12 is for the dangling memcg debugging patch.

You'll see 2 small conflicts when you apply that debugging patch on top
of this patchset. Just move memcg_dangling_add() to mem_cgroup_css_offline()
and move memcg_dangling_free() to mem_cggroup_css_free().

Li Zefan (10):
      memcg: take reference before releasing rcu_read_lock
      memcg: avoid accessing memcg after releasing reference
      memcg: use css_get() in sock_update_memcg()
      memcg: don't use mem_cgroup_get() when creating a kmemcg cache
      memcg: use css_get/put when charging/uncharging kmem
      memcg: use css_get/put for swap memcg
      cgroup: make sure parent won't be destroyed before its children
      memcg: don't need to get a reference to the parent
      memcg: kill memcg refcnt
      memcg: don't need to free memcg via RCU or workqueue

Michal Hocko (2):
      Revert "memcg: avoid dangling reference count in creation failure."
      memcg, kmem: fix reference count handling on the error path

---
 kernel/cgroup.c |  10 +++
 mm/memcontrol.c | 267 ++++++++++++++++++++++++++++------------------------------------------
 2 files changed, 116 insertions(+), 161 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
