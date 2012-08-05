Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 461766B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 13:13:01 -0400 (EDT)
Date: Sun, 5 Aug 2012 13:12:57 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [RFC v2 6/7] tracepoint: use new hashtable implementation
Message-ID: <20120805171257.GB22267@Krystal>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com> <1344003788-1417-7-git-send-email-levinsasha928@gmail.com> <1344126994.27983.116.camel@gandalf.stny.rr.com> <20120805163114.GA21768@Krystal> <501EA749.9060400@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <501EA749.9060400@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Sasha Levin (levinsasha928@gmail.com) wrote:
[...]
> > Other than that, it looks good!
> >=20
> > Thanks!
> >=20
> > Mathieu
> >=20
>=20
> Thanks for the review Mathieu!

No problem! By the way, if you want to have a look at another hash table
API for ideas, here is the RCU lock-free hash table API, within the
Userspace RCU tree:

=66rom git://git.lttng.org/userspace-rcu.git
branch: master
API: urcu/rculfhash.h
core code: rculfhash.c
hash table index memory management:
        rculfhash-mm-chunk.c, rculfhash-mm-mmap.c, rculfhash-mm-order.c

The git tree is down today due to electrical maintenance, so I am
appending the hash table API below.


#ifndef _URCU_RCULFHASH_H
#define _URCU_RCULFHASH_H

/*
 * urcu/rculfhash.h
 *
 * Userspace RCU library - Lock-Free RCU Hash Table
 *
 * Copyright 2011 - Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
 * Copyright 2011 - Lai Jiangshan <laijs@cn.fujitsu.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301=
 USA
 *
 * Include this file _after_ including your URCU flavor.
 */

#include <stdint.h>
#include <urcu/compiler.h>
#include <urcu-call-rcu.h>
#include <urcu-flavor.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
 * cds_lfht_node: Contains the next pointers and reverse-hash
 * value required for lookup and traversal of the hash table.
 *
 * struct cds_lfht_node should be aligned on 8-bytes boundaries because
 * the three lower bits are used as flags. It is worth noting that the
 * information contained within these three bits could be represented on
 * two bits by re-using the same bit for REMOVAL_OWNER_FLAG and
 * BUCKET_FLAG. This can be done if we ensure that no iterator nor
 * updater check the BUCKET_FLAG after it detects that the REMOVED_FLAG
 * is set. Given the minimum size of struct cds_lfht_node is 8 bytes on
 * 32-bit architectures, we choose to go for simplicity and reserve
 * three bits.
 *
 * struct cds_lfht_node can be embedded into a structure (as a field).
 * caa_container_of() can be used to get the structure from the struct
 * cds_lfht_node after a lookup.
 *
 * The structure which embeds it typically holds the key (or key-value
 * pair) of the object. The caller code is responsible for calculation
 * of the hash value for cds_lfht APIs.
 */
struct cds_lfht_node {
	struct cds_lfht_node *next;	/* ptr | REMOVAL_OWNER_FLAG | BUCKET_FLAG | RE=
MOVED_FLAG */
	unsigned long reverse_hash;
} __attribute__((aligned(8)));

/* cds_lfht_iter: Used to track state while traversing a hash chain. */
struct cds_lfht_iter {
	struct cds_lfht_node *node, *next;
};

static inline
struct cds_lfht_node *cds_lfht_iter_get_node(struct cds_lfht_iter *iter)
{
	return iter->node;
}

struct cds_lfht;

/*
 * Caution !
 * Ensure reader and writer threads are registered as urcu readers.
 */

typedef int (*cds_lfht_match_fct)(struct cds_lfht_node *node, const void *k=
ey);

/*
 * cds_lfht_node_init - initialize a hash table node
 * @node: the node to initialize.
 *
 * This function is kept to be eventually used for debugging purposes
 * (detection of memory corruption).
 */
static inline
void cds_lfht_node_init(struct cds_lfht_node *node)
{
}

/*
 * Hash table creation flags.
 */
enum {
	CDS_LFHT_AUTO_RESIZE =3D (1U << 0),
	CDS_LFHT_ACCOUNTING =3D (1U << 1),
};

struct cds_lfht_mm_type {
	struct cds_lfht *(*alloc_cds_lfht)(unsigned long min_nr_alloc_buckets,
			unsigned long max_nr_buckets);
	void (*alloc_bucket_table)(struct cds_lfht *ht, unsigned long order);
	void (*free_bucket_table)(struct cds_lfht *ht, unsigned long order);
	struct cds_lfht_node *(*bucket_at)(struct cds_lfht *ht,
			unsigned long index);
};

extern const struct cds_lfht_mm_type cds_lfht_mm_order;
extern const struct cds_lfht_mm_type cds_lfht_mm_chunk;
extern const struct cds_lfht_mm_type cds_lfht_mm_mmap;

/*
 * _cds_lfht_new - API used by cds_lfht_new wrapper. Do not use directly.
 */
struct cds_lfht *_cds_lfht_new(unsigned long init_size,
			unsigned long min_nr_alloc_buckets,
			unsigned long max_nr_buckets,
			int flags,
			const struct cds_lfht_mm_type *mm,
			const struct rcu_flavor_struct *flavor,
			pthread_attr_t *attr);

/*
 * cds_lfht_new - allocate a hash table.
 * @init_size: number of buckets to allocate initially. Must be power of tw=
o.
 * @min_nr_alloc_buckets: the minimum number of allocated buckets.
 *                        (must be power of two)
 * @max_nr_buckets: the maximum number of hash table buckets allowed.
 *                  (must be power of two)
 * @flags: hash table creation flags (can be combined with bitwise or: '|').
 *           0: no flags.
 *           CDS_LFHT_AUTO_RESIZE: automatically resize hash table.
 *           CDS_LFHT_ACCOUNTING: count the number of node addition
 *                                and removal in the table
 * @attr: optional resize worker thread attributes. NULL for default.
 *
 * Return NULL on error.
 * Note: the RCU flavor must be already included before the hash table head=
er.
 *
 * The programmer is responsible for ensuring that resize operation has a
 * priority equal to hash table updater threads. It should be performed by
 * specifying the appropriate priority in the pthread "attr" argument, and,
 * for CDS_LFHT_AUTO_RESIZE, by ensuring that call_rcu worker threads also =
have
 * this priority level. Having lower priority for call_rcu and resize threa=
ds
 * does not pose any correctness issue, but the resize operations could be
 * starved by updates, thus leading to long hash table bucket chains.
 * Threads calling cds_lfht_new are NOT required to be registered RCU
 * read-side threads. It can be called very early. (e.g. before RCU is
 * initialized)
 */
static inline
struct cds_lfht *cds_lfht_new(unsigned long init_size,
			unsigned long min_nr_alloc_buckets,
			unsigned long max_nr_buckets,
			int flags,
			pthread_attr_t *attr)
{
	return _cds_lfht_new(init_size, min_nr_alloc_buckets, max_nr_buckets,
			flags, NULL, &rcu_flavor, attr);
}

/*
 * cds_lfht_destroy - destroy a hash table.
 * @ht: the hash table to destroy.
 * @attr: (output) resize worker thread attributes, as received by cds_lfht=
_new.
 *        The caller will typically want to free this pointer if dynamically
 *        allocated. The attr point can be NULL if the caller does not
 *        need to be informed of the value passed to cds_lfht_new().
 *
 * Return 0 on success, negative error value on error.
 * Threads calling this API need to be registered RCU read-side threads.
 */
int cds_lfht_destroy(struct cds_lfht *ht, pthread_attr_t **attr);

/*
 * cds_lfht_count_nodes - count the number of nodes in the hash table.
 * @ht: the hash table.
 * @split_count_before: sample the node count split-counter before traversa=
l.
 * @count: traverse the hash table, count the number of nodes observed.
 * @split_count_after: sample the node count split-counter after traversal.
 *
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 */
void cds_lfht_count_nodes(struct cds_lfht *ht,
		long *split_count_before,
		unsigned long *count,
		long *split_count_after);

/*
 * cds_lfht_lookup - lookup a node by key.
 * @ht: the hash table.
 * @hash: the key hash.
 * @match: the key match function.
 * @key: the current node key.
 * @iter: node, if found (output). *iter->node set to NULL if not found.
 *
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * This function acts as a rcu_dereference() to read the node pointer.
 */
void cds_lfht_lookup(struct cds_lfht *ht, unsigned long hash,
		cds_lfht_match_fct match, const void *key,
		struct cds_lfht_iter *iter);

/*
 * cds_lfht_next_duplicate - get the next item with same key, after iterato=
r.
 * @ht: the hash table.
 * @match: the key match function.
 * @key: the current node key.
 * @iter: input: current iterator.
 *        output: node, if found. *iter->node set to NULL if not found.
 *
 * Uses an iterator initialized by a lookup or traversal. Important: the
 * iterator _needs_ to be initialized before calling
 * cds_lfht_next_duplicate.
 * Sets *iter-node to the following node with same key.
 * Sets *iter->node to NULL if no following node exists with same key.
 * RCU read-side lock must be held across cds_lfht_lookup and
 * cds_lfht_next calls, and also between cds_lfht_next calls using the
 * node returned by a previous cds_lfht_next.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * This function acts as a rcu_dereference() to read the node pointer.
 */
void cds_lfht_next_duplicate(struct cds_lfht *ht,
		cds_lfht_match_fct match, const void *key,
		struct cds_lfht_iter *iter);

/*
 * cds_lfht_first - get the first node in the table.
 * @ht: the hash table.
 * @iter: First node, if exists (output). *iter->node set to NULL if not fo=
und.
 *
 * Output in "*iter". *iter->node set to NULL if table is empty.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * This function acts as a rcu_dereference() to read the node pointer.
 */
void cds_lfht_first(struct cds_lfht *ht, struct cds_lfht_iter *iter);

/*
 * cds_lfht_next - get the next node in the table.
 * @ht: the hash table.
 * @iter: input: current iterator.
 *        output: next node, if exists. *iter->node set to NULL if not foun=
d.
 *
 * Input/Output in "*iter". *iter->node set to NULL if *iter was
 * pointing to the last table node.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * This function acts as a rcu_dereference() to read the node pointer.
 */
void cds_lfht_next(struct cds_lfht *ht, struct cds_lfht_iter *iter);

/*
 * cds_lfht_add - add a node to the hash table.
 * @ht: the hash table.
 * @hash: the key hash.
 * @node: the node to add.
 *
 * This function supports adding redundant keys into the table.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * This function issues a full memory barrier before and after its
 * atomic commit.
 */
void cds_lfht_add(struct cds_lfht *ht, unsigned long hash,
		struct cds_lfht_node *node);

/*
 * cds_lfht_add_unique - add a node to hash table, if key is not present.
 * @ht: the hash table.
 * @hash: the node's hash.
 * @match: the key match function.
 * @key: the node's key.
 * @node: the node to try adding.
 *
 * Return the node added upon success.
 * Return the unique node already present upon failure. If
 * cds_lfht_add_unique fails, the node passed as parameter should be
 * freed by the caller. In this case, the caller does NOT need to wait
 * for a grace period before freeing the node.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 *
 * The semantic of this function is that if only this function is used
 * to add keys into the table, no duplicated keys should ever be
 * observable in the table. The same guarantee apply for combination of
 * add_unique and add_replace (see below).
 *
 * Upon success, this function issues a full memory barrier before and
 * after its atomic commit. Upon failure, this function acts like a
 * simple lookup operation: it acts as a rcu_dereference() to read the
 * node pointer. The failure case does not guarantee any other memory
 * barrier.
 */
struct cds_lfht_node *cds_lfht_add_unique(struct cds_lfht *ht,
		unsigned long hash,
		cds_lfht_match_fct match,
		const void *key,
		struct cds_lfht_node *node);

/*
 * cds_lfht_add_replace - replace or add a node within hash table.
 * @ht: the hash table.
 * @hash: the node's hash.
 * @match: the key match function.
 * @key: the node's key.
 * @node: the node to add.
 *
 * Return the node replaced upon success. If no node matching the key
 * was present, return NULL, which also means the operation succeeded.
 * This replacement operation should never fail.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * After successful replacement, a grace period must be waited for before
 * freeing the memory reserved for the returned node.
 *
 * The semantic of replacement vs lookups and traversals is the
 * following: if lookups and traversals are performed between a key
 * unique insertion and its removal, we guarantee that the lookups and
 * traversals will always find exactly one instance of the key if it is
 * replaced concurrently with the lookups.
 *
 * Providing this semantic allows us to ensure that replacement-only
 * schemes will never generate duplicated keys. It also allows us to
 * guarantee that a combination of add_replace and add_unique updates
 * will never generate duplicated keys.
 *
 * This function issues a full memory barrier before and after its
 * atomic commit.
 */
struct cds_lfht_node *cds_lfht_add_replace(struct cds_lfht *ht,
		unsigned long hash,
		cds_lfht_match_fct match,
		const void *key,
		struct cds_lfht_node *node);

/*
 * cds_lfht_replace - replace a node pointed to by iter within hash table.
 * @ht: the hash table.
 * @old_iter: the iterator position of the node to replace.
 * @hash: the node's hash.
 * @match: the key match function.
 * @key: the node's key.
 * @new_node: the new node to use as replacement.
 *
 * Return 0 if replacement is successful, negative value otherwise.
 * Replacing a NULL old node or an already removed node will fail with
 * -ENOENT.
 * If the hash or value of the node to replace and the new node differ,
 * this function returns -EINVAL without proceeding to the replacement.
 * Old node can be looked up with cds_lfht_lookup and cds_lfht_next.
 * RCU read-side lock must be held between lookup and replacement.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * After successful replacement, a grace period must be waited for before
 * freeing the memory reserved for the old node (which can be accessed
 * with cds_lfht_iter_get_node).
 *
 * The semantic of replacement vs lookups is the same as
 * cds_lfht_add_replace().
 *
 * Upon success, this function issues a full memory barrier before and
 * after its atomic commit. Upon failure, this function does not issue
 * any memory barrier.
 */
int cds_lfht_replace(struct cds_lfht *ht,
		struct cds_lfht_iter *old_iter,
		unsigned long hash,
		cds_lfht_match_fct match,
		const void *key,
		struct cds_lfht_node *new_node);

/*
 * cds_lfht_del - remove node pointed to by iterator from hash table.
 * @ht: the hash table.
 * @node: the node to delete.
 *
 * Return 0 if the node is successfully removed, negative value
 * otherwise.
 * Deleting a NULL node or an already removed node will fail with a
 * negative value.
 * Node can be looked up with cds_lfht_lookup and cds_lfht_next,
 * followed by use of cds_lfht_iter_get_node.
 * RCU read-side lock must be held between lookup and removal.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * After successful removal, a grace period must be waited for before
 * freeing the memory reserved for old node (which can be accessed with
 * cds_lfht_iter_get_node).
 * Upon success, this function issues a full memory barrier before and
 * after its atomic commit. Upon failure, this function does not issue
 * any memory barrier.
 */
int cds_lfht_del(struct cds_lfht *ht, struct cds_lfht_node *node);

/*
 * cds_lfht_is_node_deleted - query whether a node is removed from hash tab=
le.
 *
 * Return non-zero if the node is deleted from the hash table, 0
 * otherwise.
 * Node can be looked up with cds_lfht_lookup and cds_lfht_next,
 * followed by use of cds_lfht_iter_get_node.
 * RCU read-side lock must be held between lookup and call to this
 * function.
 * Call with rcu_read_lock held.
 * Threads calling this API need to be registered RCU read-side threads.
 * This function does not issue any memory barrier.
 */
int cds_lfht_is_node_deleted(struct cds_lfht_node *node);

/*
 * cds_lfht_resize - Force a hash table resize
 * @ht: the hash table.
 * @new_size: update to this hash table size.
 *
 * Threads calling this API need to be registered RCU read-side threads.
 * This function does not (necessarily) issue memory barriers.
 */
void cds_lfht_resize(struct cds_lfht *ht, unsigned long new_size);

/*
 * Note: it is safe to perform element removal (del), replacement, or
 * any hash table update operation during any of the following hash
 * table traversals.
 * These functions act as rcu_dereference() to read the node pointers.
 */
#define cds_lfht_for_each(ht, iter, node)				\
	for (cds_lfht_first(ht, iter),					\
			node =3D cds_lfht_iter_get_node(iter);		\
		node !=3D NULL;						\
		cds_lfht_next(ht, iter),				\
			node =3D cds_lfht_iter_get_node(iter))

#define cds_lfht_for_each_duplicate(ht, hash, match, key, iter, node)	\
	for (cds_lfht_lookup(ht, hash, match, key, iter),		\
			node =3D cds_lfht_iter_get_node(iter);		\
		node !=3D NULL;						\
		cds_lfht_next_duplicate(ht, match, key, iter),		\
			node =3D cds_lfht_iter_get_node(iter))

#define cds_lfht_for_each_entry(ht, iter, pos, member)			\
	for (cds_lfht_first(ht, iter),					\
			pos =3D caa_container_of(cds_lfht_iter_get_node(iter), \
					__typeof__(*(pos)), member);	\
		&(pos)->member !=3D NULL;					\
		cds_lfht_next(ht, iter),				\
			pos =3D caa_container_of(cds_lfht_iter_get_node(iter), \
					__typeof__(*(pos)), member))

#define cds_lfht_for_each_entry_duplicate(ht, hash, match, key,		\
				iter, pos, member)			\
	for (cds_lfht_lookup(ht, hash, match, key, iter),		\
			pos =3D caa_container_of(cds_lfht_iter_get_node(iter), \
					__typeof__(*(pos)), member);	\
		&(pos)->member !=3D NULL;					\
		cds_lfht_next_duplicate(ht, match, key, iter),		\
			pos =3D caa_container_of(cds_lfht_iter_get_node(iter), \
					__typeof__(*(pos)), member))

#ifdef __cplusplus
}
#endif

#endif /* _URCU_RCULFHASH_H */




--=20
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
