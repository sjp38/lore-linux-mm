Date: Tue, 7 Oct 2008 08:48:34 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm, for adaptive dcache hash table sizing
Message-ID: <20081007064834.GA5959@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-netdev@vger.kernel.org
Cc: Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi,

I thought I should quickly bring this patch up to date and write it up
properly, because IMO it is still useful. I earlier had tried to turn the
algorithm into a library that could be plugged into with specific lookup
functions and such, but that got really nasty and also difficult to retain
a really light fastpath. I don't think it is too nasty to open-code it...

Describe the "Dynamic dynamic data structure" (DDDS) algorithm, and implement
adaptive dcache hash table sizing using DDDS.

The dcache hash size is increased to the next power of 2 if the number
of dentries exceeds the current size of the dcache hash table. It is decreased
in size if it is currently more than 3 times the number of dentries.

This might be a dumb thing to do. It also currently performs the hash resizing
check for each dentry insertion/deletion, and calls the resizing in-line from
there: that's bad, because resizing takes several RCU grace periods. Rather it
should kick off a thread to do the resizing, or even have a background worker
thread checking the sizes periodically and resizing if required.

With this algorithm, I can fit a whole kernel source and git tree in my dcache
hash table that is still 1/8th the size it would be before the patch. One
downside (other than the extra branches and derefs in the fastpath) is that
the hashtable uses vmalloc space. However, for NUMA that is actually a good
thing, and also there is a kernel boot parameter when you know the exact
size of the hash table you want, which allows linear memory use to be
retained.

I'm cc'ing netdev because Dave did express some interest in using this for
some networking hashes, and network guys in general are pretty cluey when it
comes to hashes and such ;)

---
 Documentation/RCU/ddds.txt |  161 +++++++++++++++++++
 fs/dcache.c                |  363 ++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 470 insertions(+), 54 deletions(-)

Index: linux-2.6/fs/dcache.c
===================================================================
--- linux-2.6.orig/fs/dcache.c
+++ linux-2.6/fs/dcache.c
@@ -32,13 +32,15 @@
 #include <linux/seqlock.h>
 #include <linux/swap.h>
 #include <linux/bootmem.h>
+#include <linux/seqlock.h>
+#include <linux/vmalloc.h>
 #include "internal.h"
 
 
 int sysctl_vfs_cache_pressure __read_mostly = 100;
 EXPORT_SYMBOL_GPL(sysctl_vfs_cache_pressure);
 
- __cacheline_aligned_in_smp DEFINE_SPINLOCK(dcache_lock);
+__cacheline_aligned_in_smp DEFINE_SPINLOCK(dcache_lock);
 __cacheline_aligned_in_smp DEFINE_SEQLOCK(rename_lock);
 
 EXPORT_SYMBOL(dcache_lock);
@@ -47,6 +49,8 @@ static struct kmem_cache *dentry_cache _
 
 #define DNAME_INLINE_LEN (sizeof(struct dentry)-offsetof(struct dentry,d_iname))
 
+#define MIN_DHASH_SIZE	(cache_line_size() / sizeof(struct hlist_head *))
+
 /*
  * This is the single most critical data structure when it comes
  * to the dcache: the hashtable for lookups. Somebody should try
@@ -54,13 +58,23 @@ static struct kmem_cache *dentry_cache _
  *
  * This hash-function tries to avoid losing too many bits of hash
  * information, yet avoid using a prime hash-size or similar.
+ *
+ * We dynamically resize the hash table using the DDDS algorithm described
+ * in Documentation/RCU/ddds.txt.
  */
-#define D_HASHBITS     d_hash_shift
-#define D_HASHMASK     d_hash_mask
+struct dcache_hash {
+	struct hlist_head *table;
+	unsigned int shift;
+	unsigned int mask;
+};
+
+static struct dcache_hash *d_hash_cur __read_mostly;
+static struct dcache_hash *d_hash_ins __read_mostly;
+static struct dcache_hash *d_hash_old __read_mostly;
+static DEFINE_MUTEX(d_hash_resize_mutex);
+static seqcount_t d_hash_resize_seq = SEQCNT_ZERO;
 
-static unsigned int d_hash_mask __read_mostly;
-static unsigned int d_hash_shift __read_mostly;
-static struct hlist_head *dentry_hashtable __read_mostly;
+static void dd_check_hash(void);
 
 /* Statistics gathering. */
 struct dentry_stat_t dentry_stat = {
@@ -176,6 +190,9 @@ static struct dentry *d_kill(struct dent
 	dentry_iput(dentry);
 	parent = dentry->d_parent;
 	d_free(dentry);
+
+	dd_check_hash();
+
 	return dentry == parent ? NULL : parent;
 }
 
@@ -705,6 +722,8 @@ out:
 	spin_lock(&dcache_lock);
 	dentry_stat.nr_dentry -= detached;
 	spin_unlock(&dcache_lock);
+
+	dd_check_hash();
 }
 
 /*
@@ -964,6 +983,8 @@ struct dentry *d_alloc(struct dentry * p
 	dentry_stat.nr_dentry++;
 	spin_unlock(&dcache_lock);
 
+	dd_check_hash();
+
 	return dentry;
 }
 
@@ -1102,12 +1123,12 @@ struct dentry * d_alloc_root(struct inod
 	return res;
 }
 
-static inline struct hlist_head *d_hash(struct dentry *parent,
-					unsigned long hash)
+static inline struct hlist_head *d_hash(struct dcache_hash *dh,
+				struct dentry *parent, unsigned long hash)
 {
 	hash += ((unsigned long) parent ^ GOLDEN_RATIO_PRIME) / L1_CACHE_BYTES;
-	hash = hash ^ ((hash ^ GOLDEN_RATIO_PRIME) >> D_HASHBITS);
-	return dentry_hashtable + (hash & D_HASHMASK);
+	hash = hash ^ ((hash ^ GOLDEN_RATIO_PRIME) >> dh->shift);
+	return dh->table + (hash & dh->mask);
 }
 
 /**
@@ -1365,18 +1386,18 @@ struct dentry * d_lookup(struct dentry *
 	return dentry;
 }
 
-struct dentry * __d_lookup(struct dentry * parent, struct qstr * name)
+static struct dentry * __d_lookup_table(struct dcache_hash *dh,
+			struct dentry * parent, struct qstr * name)
 {
 	unsigned int len = name->len;
 	unsigned int hash = name->hash;
 	const unsigned char *str = name->name;
-	struct hlist_head *head = d_hash(parent,hash);
+	struct hlist_head *head;
 	struct dentry *found = NULL;
 	struct hlist_node *node;
 	struct dentry *dentry;
 
-	rcu_read_lock();
-	
+	head = d_hash(dh, parent, hash);
 	hlist_for_each_entry_rcu(dentry, node, head, d_hash) {
 		struct qstr *qstr;
 
@@ -1421,11 +1442,49 @@ struct dentry * __d_lookup(struct dentry
 next:
 		spin_unlock(&dentry->d_lock);
  	}
- 	rcu_read_unlock();
 
  	return found;
 }
 
+/* __d_lookup slowpath when dcache hashtable resize is in progress */
+static noinline struct dentry * __d_lookup_resize(struct dcache_hash *cur,
+			struct dcache_hash *old,
+			struct dentry * parent, struct qstr * name)
+{
+	unsigned seq;
+
+	do {
+		struct dentry *dentry;
+
+		seq = read_seqcount_begin(&d_hash_resize_seq);
+		dentry = __d_lookup_table(cur, parent, name);
+		if (dentry)
+			return dentry;
+		dentry = __d_lookup_table(old, parent, name);
+		if (dentry)
+			return dentry;
+	} while (read_seqcount_retry(&d_hash_resize_seq, seq));
+
+	return NULL;
+}
+
+struct dentry * __d_lookup(struct dentry * parent, struct qstr * name)
+{
+	struct dentry *dentry;
+	struct dcache_hash *cur, *old;
+
+	rcu_read_lock();
+	cur = d_hash_cur;
+	old = d_hash_old;
+	if (unlikely(old))
+		dentry = __d_lookup_resize(cur, old, parent, name);
+	else
+		dentry = __d_lookup_table(cur, parent, name);
+	rcu_read_unlock();
+
+	return dentry;
+}
+
 /**
  * d_hash_and_lookup - hash the qstr then search for a dentry
  * @dir: Directory to search in
@@ -1452,6 +1511,46 @@ out:
 	return dentry;
 }
 
+static int d_validate_table(struct dcache_hash *dh,
+		struct dentry *dentry, struct dentry *dparent)
+{
+	struct hlist_head *base;
+	struct hlist_node *lhp;
+
+	base = d_hash(dh, dparent, dentry->d_name.hash);
+	hlist_for_each(lhp, base) {
+		/* hlist_for_each_entry_rcu() not required for d_hash list
+		 * as it is parsed under dcache_lock
+		 */
+		if (dentry == hlist_entry(lhp, struct dentry, d_hash)) {
+			__dget_locked(dentry);
+			return 1;
+		}
+	}
+	return 0;
+}
+
+/* __d_lookup slowpath when dcache hashtable resize is in progress */
+static noinline int d_validate_resize(struct dcache_hash *cur,
+			struct dcache_hash *old,
+			struct dentry *dentry, struct dentry *dparent)
+{
+	unsigned seq;
+
+	do {
+		int ret;
+
+		seq = read_seqcount_begin(&d_hash_resize_seq);
+		ret = d_validate_table(cur, dentry, dparent);
+		if (ret)
+			return ret;
+		ret = d_validate_table(old, dentry, dparent);
+		if (ret)
+			return ret;
+	} while (read_seqcount_retry(&d_hash_resize_seq, seq));
+
+	return 0;
+}
 /**
  * d_validate - verify dentry provided from insecure source
  * @dentry: The dentry alleged to be valid child of @dparent
@@ -1466,8 +1565,8 @@ out:
  
 int d_validate(struct dentry *dentry, struct dentry *dparent)
 {
-	struct hlist_head *base;
-	struct hlist_node *lhp;
+	struct dcache_hash *cur, *old;
+	int ret = 0;
 
 	/* Check whether the ptr might be valid at all.. */
 	if (!kmem_ptr_validate(dentry_cache, dentry))
@@ -1477,20 +1576,17 @@ int d_validate(struct dentry *dentry, st
 		goto out;
 
 	spin_lock(&dcache_lock);
-	base = d_hash(dparent, dentry->d_name.hash);
-	hlist_for_each(lhp,base) { 
-		/* hlist_for_each_entry_rcu() not required for d_hash list
-		 * as it is parsed under dcache_lock
-		 */
-		if (dentry == hlist_entry(lhp, struct dentry, d_hash)) {
-			__dget_locked(dentry);
-			spin_unlock(&dcache_lock);
-			return 1;
-		}
-	}
+	rcu_read_lock();
+	cur = d_hash_cur;
+	old = d_hash_old;
+	if (unlikely(old))
+		ret = d_validate_resize(cur, old, dentry, dparent);
+	else
+		ret = d_validate_table(cur, dentry, dparent);
+	rcu_read_unlock();
 	spin_unlock(&dcache_lock);
 out:
-	return 0;
+	return ret;
 }
 
 /*
@@ -1547,7 +1643,10 @@ static void __d_rehash(struct dentry * e
 
 static void _d_rehash(struct dentry * entry)
 {
-	__d_rehash(entry, d_hash(entry->d_parent, entry->d_name.hash));
+	rcu_read_lock();
+	__d_rehash(entry, d_hash(d_hash_ins, entry->d_parent,
+						entry->d_name.hash));
+	rcu_read_unlock();
 }
 
 /**
@@ -1665,8 +1764,10 @@ static void d_move_locked(struct dentry 
 	hlist_del_rcu(&dentry->d_hash);
 
 already_unhashed:
-	list = d_hash(target->d_parent, target->d_name.hash);
+	rcu_read_lock();
+	list = d_hash(d_hash_ins, target->d_parent, target->d_name.hash);
 	__d_rehash(dentry, list);
+	rcu_read_unlock();
 
 	/* Unhash the target: dput() will then get rid of it */
 	__d_drop(target);
@@ -2239,7 +2340,7 @@ ino_t find_inode_number(struct dentry *d
 	return ino;
 }
 
-static __initdata unsigned long dhash_entries;
+static unsigned long dhash_entries;
 static int __init set_dhash_entries(char *str)
 {
 	if (!str)
@@ -2249,34 +2350,197 @@ static int __init set_dhash_entries(char
 }
 __setup("dhash_entries=", set_dhash_entries);
 
+static struct dcache_hash *alloc_dhash(int size)
+{
+	struct dcache_hash *dh;
+	unsigned long bytes;
+	unsigned int shift;
+	int i;
+
+	shift = ilog2(size);
+	BUG_ON(size != 1UL << shift);
+	bytes = size * sizeof(struct hlist_head *);
+
+	dh = kmalloc(sizeof(struct dcache_hash), GFP_KERNEL);
+	if (!dh)
+		return NULL;
+
+	if (bytes <= PAGE_SIZE) {
+		dh->table = kmalloc(bytes, GFP_KERNEL);
+	} else {
+		dh->table = vmalloc(bytes);
+	}
+	if (!dh->table) {
+		kfree(dh);
+		return NULL;
+	}
+	dh->shift = shift;
+	dh->mask = size - 1;
+
+	for (i = 0; i < size; i++)
+		INIT_HLIST_HEAD(&dh->table[i]);
+
+        printk(KERN_INFO "Dentry cache hash table entries: %d (order: %d, %lu bytes)\n",
+               size,
+               shift - PAGE_SHIFT,
+               bytes);
+
+	return dh;
+}
+
+static void free_dhash(struct dcache_hash *dh)
+{
+	int size;
+	unsigned long bytes;
+
+	size = 1UL << dh->shift;
+	bytes = size * sizeof(struct hlist_head *);
+
+	if (bytes <= PAGE_SIZE) {
+		kfree(dh->table);
+	} else {
+		vfree(dh->table);
+	}
+
+	kfree(dh);
+}
+
+static void d_hash_move_table(struct dcache_hash *old, struct dcache_hash *new)
+{
+	unsigned long i, oldsize;
+
+	oldsize = 1UL << old->shift;
+	for (i = 0; i < oldsize; i++) {
+		struct hlist_head *head;
+
+		head = &old->table[i];
+		while (!hlist_empty(head)) {
+			struct dentry *entry;
+			struct hlist_head *newhead;
+
+			spin_lock(&dcache_lock);
+			/* don't get preempted a lookup when hold resize_seq */
+			preempt_disable();
+			write_seqcount_begin(&d_hash_resize_seq);
+			entry = hlist_entry(head->first, struct dentry, d_hash);
+
+			hlist_del_rcu(&entry->d_hash);
+
+			newhead = d_hash(new, entry->d_parent, entry->d_name.hash);
+			/*
+			 * A concurrent lookup on the old data structure may
+			 * now start traversing down the hash chain of the new
+			 * data structure and miss entries in the old data
+			 * structure. This is actually OK: concurrent lookups
+			 * are guaranteed to be in the slowpath at this point,
+			 * so they will retry the seqlock if they miss the
+			 * item they are looking for.
+			 */
+			hlist_add_head_rcu(&entry->d_hash, newhead);
+			write_seqcount_end(&d_hash_resize_seq);
+			preempt_enable();
+			spin_unlock(&dcache_lock);
+			cond_resched();
+			cpu_relax();
+		}
+	}
+}
+
+static void d_hash_resize(unsigned int size)
+{
+	struct dcache_hash *new, *old;
+
+	new = alloc_dhash(size);
+	if (!new)
+		return;
+
+	d_hash_old = d_hash_cur;
+	synchronize_rcu();
+	d_hash_cur = new;
+	synchronize_rcu();
+	d_hash_ins = new;
+	d_hash_move_table(d_hash_old, d_hash_cur);
+	synchronize_rcu();
+	old = d_hash_old;
+	d_hash_old = NULL;
+	synchronize_rcu();
+	free_dhash(old);
+}
+
+static void dd_check_hash(void)
+{
+	int size;
+	unsigned long newsize;
+	struct dcache_hash *dh;
+
+	if (dhash_entries)
+		return;
+
+again:
+	rcu_read_lock();
+	dh = d_hash_cur;
+	size = 1UL << dh->shift;
+	if (unlikely(size < dentry_stat.nr_dentry)) {
+		/* expand */
+		newsize = roundup_pow_of_two(dentry_stat.nr_dentry);
+	} else if (unlikely(size > (dentry_stat.nr_dentry * 3))) {
+		/* contract */
+		newsize = roundup_pow_of_two(dentry_stat.nr_dentry);
+		if (newsize < MIN_DHASH_SIZE)
+			newsize = MIN_DHASH_SIZE;
+	} else {
+		rcu_read_unlock();
+		return;
+	}
+	rcu_read_unlock();
+
+	if (system_state != SYSTEM_RUNNING) /* RCU unavailable */
+		return;
+
+	if (!mutex_trylock(&d_hash_resize_mutex))
+		return;
+
+	if (dh != d_hash_cur) {
+		/* recheck it, under lock */
+		mutex_unlock(&d_hash_resize_mutex);
+		goto again;
+	}
+
+	d_hash_resize(newsize);
+
+	mutex_unlock(&d_hash_resize_mutex);
+}
+
 static void __init dcache_init_early(void)
 {
-	int loop;
+	struct dcache_hash *dh;
+	int i;
 
 	/* If hashes are distributed across NUMA nodes, defer
 	 * hash allocation until vmalloc space is available.
 	 */
-	if (hashdist)
+	if (!dhash_entries)
 		return;
 
-	dentry_hashtable =
+	dh = alloc_bootmem(sizeof(struct dcache_hash));
+	dh->table =
 		alloc_large_system_hash("Dentry cache",
 					sizeof(struct hlist_head),
 					dhash_entries,
 					13,
 					HASH_EARLY,
-					&d_hash_shift,
-					&d_hash_mask,
+					&dh->shift,
+					&dh->mask,
 					0);
 
-	for (loop = 0; loop < (1 << d_hash_shift); loop++)
-		INIT_HLIST_HEAD(&dentry_hashtable[loop]);
+	for (i = 0; i < (1 << dh->shift); i++)
+		INIT_HLIST_HEAD(&dh->table[i]);
+
+	d_hash_cur = d_hash_ins = dh;
 }
 
 static void __init dcache_init(void)
 {
-	int loop;
-
 	/* 
 	 * A constructor could be added for stable state like the lists,
 	 * but it is probably not worth it because of the cache nature
@@ -2288,21 +2552,12 @@ static void __init dcache_init(void)
 	register_shrinker(&dcache_shrinker);
 
 	/* Hash may have been set up in dcache_init_early */
-	if (!hashdist)
+	if (dhash_entries)
 		return;
 
-	dentry_hashtable =
-		alloc_large_system_hash("Dentry cache",
-					sizeof(struct hlist_head),
-					dhash_entries,
-					13,
-					0,
-					&d_hash_shift,
-					&d_hash_mask,
-					0);
-
-	for (loop = 0; loop < (1 << d_hash_shift); loop++)
-		INIT_HLIST_HEAD(&dentry_hashtable[loop]);
+	d_hash_cur = d_hash_ins = alloc_dhash(MIN_DHASH_SIZE);
+	if (!d_hash_cur)
+		panic("Could not allocate dentry hash table");
 }
 
 /* SLAB cache for __getname() consumers */
Index: linux-2.6/Documentation/RCU/ddds.txt
===================================================================
--- /dev/null
+++ linux-2.6/Documentation/RCU/ddds.txt
@@ -0,0 +1,161 @@
+This describes a general algorithm for "dynamic dynamic data structures". In
+other words, the algorithm can switch from one type of dynamic data structure
+to another, with concurrent operations occurring on these data structures.
+For data structure users, the the algorithm is lockless, and overhead is
+minimal when there is no resize occurring, and reasonably small when there is
+a resize.
+
+If you implement DDDS algorithm in the kernel, please reference this file.
+If you find any bugs in this document, please update all other implementations
+in the kernel.
+
+The overhead to users while there is no resize in progress is at the very
+least a single extra load and predictable branch (to check if a resize is in
+progress). More commonly, it will also add a level of pointer indirection, as
+the data structure itself is now a data element of the DDD algorithm.
+
+DDD algorithm is as follows:
+
+We have a given data structure that we are operating on, this is pointed to by
+'cur', or current, data structure pointer; 'ins' is the pointer to be used
+when inserting new items, and should initially be set to 'cur'; and 'old' data
+structure pointer, which is NULL unless 'cur' is in the process of being
+replaced.
+
+Note: the data structure that the data structure pointer points to must contain
+all necessary information to perform operations on that data structure. For
+example, a hash table data structure would probably contain the table, the size
+of the table, and the method for obtaining a hash (if size or method are never
+changed, then they could be omitted from the data structure of course). For
+another example, if the algorithm were used to switch between a hash table and
+an rbtree, then each of those data structures should probably share a flag bit
+that can be used to differentiate between a hash table and the rbtree data
+structure.
+
+
+To look up a data item, perform the following:
+
+L1. Enter RCU read-side critical section (covering the whole lookup operation).
+
+L2. Load the 'old' pointer to O and the 'cur' pointer to C.
+
+L3. If O is not NULL, go to L6.
+
+L4. Perform data structure lookup with C.
+
+L5. Done (return result).
+
+L6. Perform data structure lookup with O. If successful, goto L5.
+
+L7. Perform data structure lookup with C. If successful, goto L5.
+
+L8. Done (return failure).
+
+
+To insert a data item, perform the following:
+
+I1. Enter RCU read-side critical section (covering the whole insert operation)
+
+I2. Load the 'ins' pointer to I.
+
+I3. Perform data structure insertion with I.
+
+
+To delete a data item X, perform the following:
+
+D1. Enter RCU read-side critical section (covering the whole delete opeation).
+
+D2. Determine the data structure where X is stored.
+
+D3. Delete X from that data structure.
+
+
+To replace the current data structure with another, perform the following:
+
+R1. Set 'old' to the value of 'cur' ('old' was NULL).
+
+R2. Wait for an RCU grace period (for example, by calling synchronize_rcu()).
+
+R3. Set 'cur' to the address of the new data structure.
+
+R4. Wait for an RCU grace period.
+
+R5. set 'ins' to the address of the new data structure.
+
+R6. Add the items from the old data structure into the new one. If they must
+    be deleted from the old data structure first, then the transfer must be
+    atomic with respect to L6 and L7.
+
+R7. After the old data structure is emptied, set the old pointer to NULL.
+
+R8. Wait for an RCU grace period.
+
+R9. The old data structure will no longer be referenced concurrently and may be
+    deallocated.
+
+
+To modify a data item in a way that assigns it a new key, it would be simplest
+to delete, then reinsert it, retaining any existing synchronisation that might
+be required to prevent lookups from losing it. Although it would be possible to
+come up with an algorithm that modifies the data item in place, ensuring the
+data item transfer operation (X to Y) will pick up the modified data.
+
+
+Notes:
+Steps L1, I1, D1 is required to retain a reference to the data structure
+pointers, and also to interact properly with the other RCU grace periods
+required in the data structure replacement algorithm.
+
+Step L2 should load 'old' and 'cur' each once, and use those values for all
+subsequent operations. This is because the pointers can change under us (even
+while inside an RCU read-side critical sectoin).
+
+Step L3 tests whether a concurrent update is occurring (between steps X and
+Y).
+
+Steps L6 and L7 should perform an atomic lookup with respect to the data
+structure transfer operations (step R6). If they weren't, then it might be
+possible to miss the data item between it getting added from the old and the
+new data structure. If inserting the data item to the new structure does not
+require it be deleted from the old structure, atomicity should be trivial.
+Otherwise, if the data structure lookups are idempotent, then a simple way to
+achieve this atomicity is by using a seqlock around the lookup operations
+(only required around the slowpath lookups L6 and L7), and take the seqlock
+over the transfer operation.
+
+Step D2 and D3 must be atomic with respect to the data item move operation R6.
+
+Step R1 sets the old pointer to the same as the cur pointer.
+
+After step R2, it will be guaranteed that that all concurrent lookup operations
+on the data structure will find old to be the value of cur (due to L1).
+
+Step R3 can then safely replace 'cur' with the new (empty) data structure,
+because all subsequent lookups will go into the slowpath lookup, which also
+checks the old data structure (above point, L3, L6).
+
+Step R4 ensures that all concurrent lookup operations on the data structure
+will find cur to be the new data structure (due to L1).
+
+Step R5 then allows concurrent updates to insert new items into the new data
+structure, which will then be found by any concurrent lookup (above point, L1).
+
+Step R6 likewise is allowed to insert items into the new data structure, as
+they will be found by concurrent lookups.
+
+Step R7 may then set old to be NULL, concurrent lookups will find all items in
+the new data structure, so they may now use the fastpath lookup (L4).
+
+After step R8, all concurrent lookups will find 'old' to be NULL (L1), thus
+there will be no concurrent references to the old data structure (L2, L3).
+Thus, the data structure can be deallocated (step R9).
+
+
+Note: while synchronize_rcu() is used here, call_rcu could be used instead
+in some situations.
+
+Note2: memory barriers are not needed in the read-side with this
+implementation.  Not even rcu_dereference when loading the potentially changing
+cur and old pointers: the write-side has gone through a synchronize_rcu()
+before making new data visible, which means the read-side must have gone
+through a quiescent state which is a full barrier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
