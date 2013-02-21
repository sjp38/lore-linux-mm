Return-Path: <owner-linux-mm@kvack.org>
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH V3 0/2] mm: hotplug: implement non-movable version of get_user_pages() to kill long-time pin pages
Date: Thu, 21 Feb 2013 19:01:42 +0800
Message-Id: <1361444504-31888-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk
Cc: khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, tangchen@cn.fujitsu.com, guz.fnst@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

Currently get_user_pages() always tries to allocate pages from movable zone,
as discussed in thread https://lkml.org/lkml/2012/11/29/69, in some case users
of get_user_pages() is easy to pin user pages for a long time(for now we found
that pages pinned as aio ring pages is such case), which is fatal for memory
hotplug/remove framework.

So the 1st patch introduces a new library function called
get_user_pages_non_movable() to pin pages only from zone non-movable in memory.
It's a wrapper of get_user_pages() but it try its best to make sure that all
pages come from non-movable zone via additional page migration. While if
migration fails, it will keep the base functionality of get_user_pages().

The 2nd patch gets around the aio ring pages can't be migrated bug caused by
get_user_pages() via using the new function. It only works when configed with
CONFIG_MEMORY_HOTREMOVE, otherwise it falls back to use the old version of
get_user_pages().

---
ChangeLog v2->v3:
 Patch1:
 - Handle the hugepage and THP migration bug pointed out by Mel.
 - In response to the other review comments suggested by Mel.
 - Updated according to mm-tree.

 Patch2:
 - Updated according to mm-tree.

ChangeLog v1->v2:
 Patch1:
 - Fix the negative return value bug pointed out by Andrew and other
   suggestions pointed out by Andrew and Jeff.

 Patch2:
 - Kill the CONFIG_MEMORY_HOTREMOVE dependence suggested by Jeff.
---
Lin Feng (2):
  mm: hotplug: implement non-movable version of get_user_pages() called
    get_user_pages_non_movable()
  fs/aio.c: use get_user_pages_non_movable() to pin ring pages when
    support memory hotremove

 fs/aio.c               |    4 +-
 include/linux/mm.h     |   14 ++++++
 include/linux/mmzone.h |    4 ++
 mm/memory.c            |  103 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_isolation.c    |    8 ++++
 5 files changed, 131 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
