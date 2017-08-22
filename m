Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B35312803D0
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 08:29:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u191so154835831pgc.13
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 05:29:35 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00127.outbound.protection.outlook.com. [40.107.0.127])
        by mx.google.com with ESMTPS id f30si1283920plj.726.2017.08.22.05.29.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Aug 2017 05:29:34 -0700 (PDT)
Subject: [PATCH 3/3] mm: Count list_lru_one::nr_items lockless
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 22 Aug 2017 15:29:35 +0300
Message-ID: <150340497499.3845.3045559119569209195.stgit@localhost.localdomain>
In-Reply-To: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
References: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ktkhai@virtuozzo.com, vdavydov.dev@gmail.com, aryabinin@virtuozzo.com, akpm@linux-foundation.org

During the reclaiming slab of a memcg, shrink_slab iterates
over all registered shrinkers in the system, and tries to count
and consume objects related to the cgroup. In case of memory
pressure, this behaves bad: I observe high system time and
time spent in list_lru_count_one() for many processes on RHEL7
kernel (collected via $perf record --call-graph fp -j k -a):

0,50%  nixstatsagent  [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
0,26%  nixstatsagent  [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
0,23%  nixstatsagent  [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
0,15%  nixstatsagent  [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
0,15%  nixstatsagent  [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2

0,94%  mysqld         [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
0,57%  mysqld         [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
0,51%  mysqld         [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
0,32%  mysqld         [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
0,32%  mysqld         [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2

0,73%  sshd           [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
0,35%  sshd           [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
0,32%  sshd           [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
0,21%  sshd           [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
0,21%  sshd           [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2

This patch aims to make super_cache_count() more effective. It
makes __list_lru_count_one() count nr_items lockless to minimize
overhead introducing by locking operation, and to make parallel
reclaims more scalable.

The lock won't be taken on shrinker::count_objects(),
it would be taken only for the real shrink by the thread,
who realizes it.

https://jira.sw.ru/browse/PSBM-69296

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 mm/list_lru.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/list_lru.c b/mm/list_lru.c
index 2db3cdadb577..8d1d2db5f4fb 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -177,10 +177,10 @@ static unsigned long __list_lru_count_one(struct list_lru *lru,
 	struct list_lru_one *l;
 	unsigned long count;
 
-	spin_lock(&nlru->lock);
+	rcu_read_lock();
 	l = list_lru_from_memcg_idx(nlru, memcg_idx);
 	count = l->nr_items;
-	spin_unlock(&nlru->lock);
+	rcu_read_unlock();
 
 	return count;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
