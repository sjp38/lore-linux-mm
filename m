Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF5048E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 07:20:41 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id t22-v6so1774967lji.14
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 04:20:41 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id q5-v6si75650981lji.207.2019.01.09.04.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 04:20:39 -0800 (PST)
Content-Transfer-Encoding: 7bit
Subject: [PATCH RFC 0/3] mm: Reduce IO by improving algorithm of memcg
 pagecache pages eviction
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Wed, 09 Jan 2019 15:20:18 +0300
Message-ID: <154703479840.32690.6504699919905946726.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hannes@cmpxchg.org, josef@toxicpanda.com, jack@suse.cz, hughd@google.com, ktkhai@virtuozzo.com, darrick.wong@oracle.com, mhocko@suse.com, aryabinin@virtuozzo.com, guro@fb.com, mgorman@techsingularity.net, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On nodes without memory overcommit, it's common a situation,
when memcg exceeds its limit and pages from pagecache are
shrinked on reclaim, while node has a lot of free memory.
Further access to the pages requires real device IO, while
IO causes time delays, worse powerusage, worse throughput
for other users of the device, etc.

Cleancache is not a good solution for this problem, since
it implies copying of page on every cleancache_put_page()
and cleancache_get_page(). Also, it requires introduction
of internal per-cleancache_ops data structures to manage
cached pages and their inodes relationships, which again
introduces overhead.

This patchset introduces another solution. It introduces
a new scheme for evicting memcg pages:

  1)__remove_mapping() uncharges unmapped page memcg
    and leaves page in pagecache on memcg reclaim;

  2)putback_lru_page() places page into root_mem_cgroup
    list, since its memcg is NULL. Page may be evicted
    on global reclaim (and this will be easily, as
    page is not mapped, so shrinker will shrink it
    with 100% probability of success);

  3)pagecache_get_page() charges page into memcg of
    a task, which takes it first.

Below is small test, which shows profit of the patchset.

Create memcg with limit 20M (exact value does not matter much):
  $ mkdir /sys/fs/cgroup/memory/ct
  $ echo 20M > /sys/fs/cgroup/memory/ct/memory.limit_in_bytes
  $ echo $$ > /sys/fs/cgroup/memory/ct/tasks

Then twice read 1GB file:
  $ time cat file_1gb > /dev/null

Before (2 iterations):
  1)0.01user 0.82system 0:11.16elapsed 7%CPU
  2)0.01user 0.91system 0:11.16elapsed 8%CPU

After (2 iterations):
  1)0.01user 0.57system 0:11.31elapsed 5%CPU
  2)0.00user 0.28system 0:00.28elapsed 100%CPU

With the patch set applied, we have file pages are cached
during the second read, so the result is 39 times faster.

This may be useful for slow disks, NFS, nodes without
overcommit by memory, in case of two memcg access the same
files, etc.

---

Kirill Tkhai (3):
      mm: Uncharge and keep page in pagecache on memcg reclaim
      mm: Recharge page memcg on first get from pagecache
      mm: Pass FGP_NOWAIT in generic_file_buffered_read and enable ext4


 fs/ext4/inode.c         |    1 +
 include/linux/pagemap.h |    1 +
 mm/filemap.c            |   38 ++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c             |   22 ++++++++++++++++++----
 4 files changed, 56 insertions(+), 6 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
