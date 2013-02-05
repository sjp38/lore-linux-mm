Return-Path: <owner-linux-mm@kvack.org>
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH V2 0/2] mm: hotplug: implement non-movable version of get_user_pages() to kill long-time pin pages
Date: Tue, 5 Feb 2013 17:21:51 +0800
Message-Id: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk
Cc: khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>

Currently get_user_pages() always tries to allocate pages from movable zone,
as discussed in thread https://lkml.org/lkml/2012/11/29/69, in some case users
of get_user_pages() is easy to pin user pages for a long time(for now we found
that pages pinned as aio ring pages is such case), which is fatal for memory
hotplug/remove framework.

So the 1st patch introduces a new library function called
get_user_pages_non_movable() to pin pages only from zone non-movable in memory.
It's a wrapper of get_user_pages() but it makes sure that all pages come from
non-movable zone via additional page migration.

The 2nd patch gets around the aio ring pages can't be migrated bug caused by
get_user_pages() via using the new function. It only works when configed with
CONFIG_MEMORY_HOTREMOVE, otherwise it falls back to use the old version of
get_user_pages().

---
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
 include/linux/mm.h     |    3 ++
 include/linux/mmzone.h |    4 ++
 mm/memory.c            |   83 ++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_isolation.c    |    5 +++
 5 files changed, 97 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
