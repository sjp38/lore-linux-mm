Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3082803D0
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 08:29:11 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so321285088pgb.14
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 05:29:11 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0138.outbound.protection.outlook.com. [104.47.0.138])
        by mx.google.com with ESMTPS id s12si9328774plj.541.2017.08.22.05.29.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Aug 2017 05:29:09 -0700 (PDT)
Subject: [PATCH 0/3] Make count list_lru_one::nr_items lockless
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 22 Aug 2017 15:29:08 +0300
Message-ID: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ktkhai@virtuozzo.com, vdavydov.dev@gmail.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org

This series aims to improve scalability of list_lru shrinking
and to make list_lru_count_one() working more effective.

On RHEL7 3.10 kernel I observe high system time usage and time
spent in super_cache_count() during slab shrinking:

0,94%  mysqld         [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
0,57%  mysqld         [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
0,51%  mysqld         [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
0,32%  mysqld         [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
0,32%  mysqld         [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2

(percentage of all node time; collected via $perf record --call-graph fp -j k -a).
It's an example, how the processes traces look like. And many processes spend time
in the above.

There is a node with many containers (more, than 200), and (as it's usually happen)
containers have no free memory (cache is actively used). Since shrink_slab() iterates
all superblocks, and it happens frequently, the shrink scales badly, and node spends
in sys more than 90% of time.

The patchset makes list_lru_count_one() lockless via RCU technics. Patch [1/3]
adds a new rcu field to struct list_lru_memcg and makes functions account its
size during allocations. Patch [2/3] makes list_lru_node::memcg_lrus RCU-protected
and RCU-accessible. Patch [3/3] removes the lock and adds rcu read protection
into __list_lru_count_one().

---

Kirill Tkhai (3):
      mm: Add rcu field to struct list_lru_memcg
      mm: Make list_lru_node::memcg_lrus RCU protected
      mm: Count list_lru_one::nr_items lockless


 include/linux/list_lru.h |    3 +-
 mm/list_lru.c            |   77 ++++++++++++++++++++++++++++++----------------
 2 files changed, 53 insertions(+), 27 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
