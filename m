Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D801F6B04FD
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:26:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g13so12805863pfm.15
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 05:26:12 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40113.outbound.protection.outlook.com. [40.107.4.113])
        by mx.google.com with ESMTPS id w23si1005922pfk.103.2017.08.23.05.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 05:26:10 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: Count list_lru_one::nr_items lockless
References: <150340381428.3845.6099251634440472539.stgit@localhost.localdomain>
 <150340497499.3845.3045559119569209195.stgit@localhost.localdomain>
 <20170822194725.ik3xwxu67wcthisb@esperanza>
 <b1600bca-32cc-e285-8589-778999584d5a@virtuozzo.com>
 <20170823082712.tw6qtyllctn25puq@esperanza>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <6f4a624d-047f-6455-d8fa-e9e73871df03@virtuozzo.com>
Date: Wed, 23 Aug 2017 15:26:12 +0300
MIME-Version: 1.0
In-Reply-To: <20170823082712.tw6qtyllctn25puq@esperanza>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: apolyakov@beget.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aryabinin@virtuozzo.com, akpm@linux-foundation.org

On 23.08.2017 11:27, Vladimir Davydov wrote:
> On Wed, Aug 23, 2017 at 11:00:56AM +0300, Kirill Tkhai wrote:
>> On 22.08.2017 22:47, Vladimir Davydov wrote:
>>> On Tue, Aug 22, 2017 at 03:29:35PM +0300, Kirill Tkhai wrote:
>>>> During the reclaiming slab of a memcg, shrink_slab iterates
>>>> over all registered shrinkers in the system, and tries to count
>>>> and consume objects related to the cgroup. In case of memory
>>>> pressure, this behaves bad: I observe high system time and
>>>> time spent in list_lru_count_one() for many processes on RHEL7
>>>> kernel (collected via $perf record --call-graph fp -j k -a):
>>>>
>>>> 0,50%  nixstatsagent  [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
>>>> 0,26%  nixstatsagent  [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
>>>> 0,23%  nixstatsagent  [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
>>>> 0,15%  nixstatsagent  [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
>>>> 0,15%  nixstatsagent  [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
>>>>
>>>> 0,94%  mysqld         [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
>>>> 0,57%  mysqld         [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
>>>> 0,51%  mysqld         [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
>>>> 0,32%  mysqld         [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
>>>> 0,32%  mysqld         [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
>>>>
>>>> 0,73%  sshd           [kernel.vmlinux]  [k] _raw_spin_lock                [k] _raw_spin_lock
>>>> 0,35%  sshd           [kernel.vmlinux]  [k] shrink_slab                   [k] shrink_slab
>>>> 0,32%  sshd           [kernel.vmlinux]  [k] super_cache_count             [k] super_cache_count
>>>> 0,21%  sshd           [kernel.vmlinux]  [k] __list_lru_count_one.isra.2   [k] _raw_spin_lock
>>>> 0,21%  sshd           [kernel.vmlinux]  [k] list_lru_count_one            [k] __list_lru_count_one.isra.2
>>>
>>> It would be nice to see how this is improved by this patch.
>>> Can you try to record the traces on the vanilla kernel with
>>> and without this patch?
>>
>> Sadly, the talk is about a production node, and it's impossible to use vanila kernel there.
> 
> I see :-( Then maybe you could try to come up with a contrived test?

I've tried and I'm not sure I'm able to reproduce on my test 8-cpu node the situation like I saw on production node
via a test. Maybe you have an idea how to measure that?

I've changed the places, you commented, and the merged patch is below.
How are you about it?

[PATCH]mm: Make count list_lru_one::nr_items lockless
    
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

This patch aims to make super_cache_count() (and other functions,
which count LRU nr_items) more effective.
It allows list_lru_node::memcg_lrus to be RCU-accessed, and makes
__list_lru_count_one() count nr_items lockless to minimize
overhead introduced by locking operation, and to make parallel
reclaims more scalable.
    
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/list_lru.h |  3 ++-
 mm/list_lru.c            | 59 ++++++++++++++++++++++++++++++------------------
 2 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index fa7fd03cb5f9..a55258100e40 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -31,6 +31,7 @@ struct list_lru_one {
 };
 
 struct list_lru_memcg {
+	struct rcu_head		rcu;
 	/* array of per cgroup lists, indexed by memcg_cache_id */
 	struct list_lru_one	*lru[0];
 };
@@ -42,7 +43,7 @@ struct list_lru_node {
 	struct list_lru_one	lru;
 #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
 	/* for cgroup aware lrus points to per cgroup lists, otherwise NULL */
-	struct list_lru_memcg	*memcg_lrus;
+	struct list_lru_memcg	__rcu *memcg_lrus;
 #endif
 	long nr_items;
 } ____cacheline_aligned_in_smp;
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 7a40fa2be858..9fdb24818dae 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -52,14 +52,15 @@ static inline bool list_lru_memcg_aware(struct list_lru *lru)
 static inline struct list_lru_one *
 list_lru_from_memcg_idx(struct list_lru_node *nlru, int idx)
 {
+	struct list_lru_memcg *memcg_lrus;
 	/*
-	 * The lock protects the array of per cgroup lists from relocation
-	 * (see memcg_update_list_lru_node).
+	 * Either lock or RCU protects the array of per cgroup lists
+	 * from relocation (see memcg_update_list_lru_node).
 	 */
-	lockdep_assert_held(&nlru->lock);
-	if (nlru->memcg_lrus && idx >= 0)
-		return nlru->memcg_lrus->lru[idx];
-
+	memcg_lrus = rcu_dereference_check(nlru->memcg_lrus,
+					   lockdep_is_held(&nlru->lock));
+	if (memcg_lrus && idx >= 0)
+		return memcg_lrus->lru[idx];
 	return &nlru->lru;
 }
 
@@ -168,10 +169,10 @@ static unsigned long __list_lru_count_one(struct list_lru *lru,
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
@@ -323,24 +324,33 @@ static int __memcg_init_list_lru_node(struct list_lru_memcg *memcg_lrus,
 
 static int memcg_init_list_lru_node(struct list_lru_node *nlru)
 {
+	struct list_lru_memcg *memcg_lrus;
 	int size = memcg_nr_cache_ids;
 
-	nlru->memcg_lrus = kmalloc(size * sizeof(void *), GFP_KERNEL);
-	if (!nlru->memcg_lrus)
+	memcg_lrus = kmalloc(sizeof(*memcg_lrus) +
+			     size * sizeof(void *), GFP_KERNEL);
+	if (!memcg_lrus)
 		return -ENOMEM;
 
-	if (__memcg_init_list_lru_node(nlru->memcg_lrus, 0, size)) {
-		kfree(nlru->memcg_lrus);
+	if (__memcg_init_list_lru_node(memcg_lrus, 0, size)) {
+		kfree(memcg_lrus);
 		return -ENOMEM;
 	}
+	RCU_INIT_POINTER(nlru->memcg_lrus, memcg_lrus);
 
 	return 0;
 }
 
 static void memcg_destroy_list_lru_node(struct list_lru_node *nlru)
 {
-	__memcg_destroy_list_lru_node(nlru->memcg_lrus, 0, memcg_nr_cache_ids);
-	kfree(nlru->memcg_lrus);
+	struct list_lru_memcg *memcg_lrus;
+	/*
+	 * This is called when shrinker has already been unregistered,
+	 * and nobody can use it. So, there is no need to use kfree_rcu().
+	 */
+	memcg_lrus = rcu_dereference_protected(nlru->memcg_lrus, true);
+	__memcg_destroy_list_lru_node(memcg_lrus, 0, memcg_nr_cache_ids);
+	kfree(memcg_lrus);
 }
 
 static int memcg_update_list_lru_node(struct list_lru_node *nlru,
@@ -350,8 +360,9 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
 
 	BUG_ON(old_size > new_size);
 
-	old = nlru->memcg_lrus;
-	new = kmalloc(new_size * sizeof(void *), GFP_KERNEL);
+	old = rcu_dereference_protected(nlru->memcg_lrus,
+					lockdep_is_held(&list_lrus_mutex));
+	new = kmalloc(sizeof(*new) + new_size * sizeof(void *), GFP_KERNEL);
 	if (!new)
 		return -ENOMEM;
 
@@ -360,29 +371,33 @@ static int memcg_update_list_lru_node(struct list_lru_node *nlru,
 		return -ENOMEM;
 	}
 
-	memcpy(new, old, old_size * sizeof(void *));
+	memcpy(&new->lru, &old->lru, old_size * sizeof(void *));
 
 	/*
-	 * The lock guarantees that we won't race with a reader
-	 * (see list_lru_from_memcg_idx).
+	 * The locking below allows readers that hold nlru->lock avoid taking
+	 * rcu_read_lock (see list_lru_from_memcg_idx).
 	 *
 	 * Since list_lru_{add,del} may be called under an IRQ-safe lock,
 	 * we have to use IRQ-safe primitives here to avoid deadlock.
 	 */
 	spin_lock_irq(&nlru->lock);
-	nlru->memcg_lrus = new;
+	rcu_assign_pointer(nlru->memcg_lrus, new);
 	spin_unlock_irq(&nlru->lock);
 
-	kfree(old);
+	kfree_rcu(old, rcu);
 	return 0;
 }
 
 static void memcg_cancel_update_list_lru_node(struct list_lru_node *nlru,
 					      int old_size, int new_size)
 {
+	struct list_lru_memcg *memcg_lrus;
+
+	memcg_lrus = rcu_dereference_protected(nlru->memcg_lrus,
+					       lockdep_is_held(&list_lrus_mutex));
 	/* do not bother shrinking the array back to the old size, because we
 	 * cannot handle allocation failures here */
-	__memcg_destroy_list_lru_node(nlru->memcg_lrus, old_size, new_size);
+	__memcg_destroy_list_lru_node(memcg_lrus, old_size, new_size);
 }
 
 static int memcg_init_list_lru(struct list_lru *lru, bool memcg_aware)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
