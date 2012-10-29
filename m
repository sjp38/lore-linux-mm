Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 6BFFB6B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 07:29:11 -0400 (EDT)
Date: Mon, 29 Oct 2012 07:29:08 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 01/16] hashtable: introduce a small and naive
	hashtable
Message-ID: <20121029112907.GA9115@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> This hashtable implementation is using hlist buckets to provide a simple
> hashtable to prevent it from getting reimplemented all over the kernel.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
> 
> Sorry for the long delay, I was busy with a bunch of personal things.
> 
> Changes since v6:
> 
>  - Use macros that point to internal static inline functions instead of
>  implementing everything as a macro.
>  - Rebase on latest -next.
>  - Resending the enter patch series on request.
>  - Break early from hash_empty() if found to be non-empty.
>  - DECLARE_HASHTABLE/DEFINE_HASHTABLE.
> 
> 
>  include/linux/hashtable.h | 193 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 193 insertions(+)
>  create mode 100644 include/linux/hashtable.h
> 
> diff --git a/include/linux/hashtable.h b/include/linux/hashtable.h
> new file mode 100644
> index 0000000..1fb8c97
> --- /dev/null
> +++ b/include/linux/hashtable.h
> @@ -0,0 +1,193 @@
> +/*
> + * Statically sized hash table implementation
> + * (C) 2012  Sasha Levin <levinsasha928@gmail.com>
> + */
> +
> +#ifndef _LINUX_HASHTABLE_H
> +#define _LINUX_HASHTABLE_H
> +
> +#include <linux/list.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/hash.h>
> +#include <linux/rculist.h>
> +
> +#define DEFINE_HASHTABLE(name, bits)						\
> +	struct hlist_head name[1 << bits] =					\
> +			{ [0 ... ((1 << bits) - 1)] = HLIST_HEAD_INIT }

Although it's unlikely that someone would use this with a binary
operator with lower precedence than "<<" (see e.g.
http://www.swansontec.com/sopc.html) as "bits", lack of parenthesis
around "bits" would be unexpected by the caller, and could introduce
bugs. Please review all macros with the precedence table in mind, and
ask yourself if lack of parenthesis could introduce a subtle bug.

> +
> +#define DECLARE_HASHTABLE(name, bits)                                   	\
> +	struct hlist_head name[1 << (bits)]

Here, you have parenthesis around "bits", but not above (inconsistency).

> +
> +#define HASH_SIZE(name) (ARRAY_SIZE(name))
> +#define HASH_BITS(name) ilog2(HASH_SIZE(name))
> +
> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
> +#define hash_min(val, bits)							\
> +({										\
> +	sizeof(val) <= 4 ?							\
> +	hash_32(val, bits) :							\
> +	hash_long(val, bits);							\
> +})
> +
> +static inline void __hash_init(struct hlist_head *ht, int sz)

int -> unsigned int.

> +{
> +	int i;

int -> unsigned int.

> +
> +	for (i = 0; i < sz; i++)
> +		INIT_HLIST_HEAD(&ht[sz]);

ouch. How did this work ? Has it been tested at all ?

sz -> i


> +}
> +
> +/**
> + * hash_init - initialize a hash table
> + * @hashtable: hashtable to be initialized
> + *
> + * Calculates the size of the hashtable from the given parameter, otherwise
> + * same as hash_init_size.
> + *
> + * This has to be a macro since HASH_BITS() will not work on pointers since
> + * it calculates the size during preprocessing.
> + */
> +#define hash_init(hashtable) __hash_init(hashtable, HASH_SIZE(hashtable))
> +
> +/**
> + * hash_add - add an object to a hashtable
> + * @hashtable: hashtable to add to
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add(hashtable, node, key)						\
> +	hlist_add_head(node, &hashtable[hash_min(key, HASH_BITS(hashtable))]);

extra ";" at the end to remove.

> +
> +/**
> + * hash_add_rcu - add an object to a rcu enabled hashtable
> + * @hashtable: hashtable to add to
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add_rcu(hashtable, node, key)					\
> +	hlist_add_head_rcu(node, &hashtable[hash_min(key, HASH_BITS(hashtable))]);

extra ";" at the end to remove.

> +
> +/**
> + * hash_hashed - check whether an object is in any hashtable
> + * @node: the &struct hlist_node of the object to be checked
> + */
> +#define hash_hashed(node) (!hlist_unhashed(node))

Please use a static inline for this instead of a macro.

> +
> +static inline bool __hash_empty(struct hlist_head *ht, int sz)

int -> unsigned int.

> +{
> +	int i;

int -> unsigned int.

> +
> +	for (i = 0; i < sz; i++)
> +		if (!hlist_empty(&ht[i]))
> +			return false;
> +
> +	return true;
> +}
> +
> +/**
> + * hash_empty - check whether a hashtable is empty
> + * @hashtable: hashtable to check
> + *
> + * This has to be a macro since HASH_BITS() will not work on pointers since
> + * it calculates the size during preprocessing.
> + */
> +#define hash_empty(hashtable) __hash_empty(hashtable, HASH_SIZE(hashtable))
> +
> +/**
> + * hash_del - remove an object from a hashtable
> + * @node: &struct hlist_node of the object to remove
> + */
> +static inline void hash_del(struct hlist_node *node)
> +{
> +	hlist_del_init(node);
> +}
> +
> +/**
> + * hash_del_rcu - remove an object from a rcu enabled hashtable
> + * @node: &struct hlist_node of the object to remove
> + */
> +static inline void hash_del_rcu(struct hlist_node *node)
> +{
> +	hlist_del_init_rcu(node);
> +}
> +
> +/**
> + * hash_for_each - iterate over a hashtable
> + * @name: hashtable to iterate
> + * @bkt: integer to use as bucket loop cursor
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @obj: the type * to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + */
> +#define hash_for_each(name, bkt, node, obj, member)				\
> +	for (bkt = 0, node = NULL; node == NULL && bkt < HASH_SIZE(name); bkt++)\

if "bkt" happens to be a dereferenced pointer (unary operator '*'), we
get into a situation where "*blah" has higher precedence than "=",
higher than "<", but lower than "++". Any thoughts on fixing this ?

> +		hlist_for_each_entry(obj, node, &name[bkt], member)
> +
> +/**
> + * hash_for_each_rcu - iterate over a rcu enabled hashtable
> + * @name: hashtable to iterate
> + * @bkt: integer to use as bucket loop cursor
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @obj: the type * to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + */
> +#define hash_for_each_rcu(name, bkt, node, obj, member)				\
> +	for (bkt = 0, node = NULL; node == NULL && bkt < HASH_SIZE(name); bkt++)\

Same comment as above about "bkt".

> +		hlist_for_each_entry_rcu(obj, node, &name[bkt], member)
> +
> +/**
> + * hash_for_each_safe - iterate over a hashtable safe against removal of
> + * hash entry
> + * @name: hashtable to iterate
> + * @bkt: integer to use as bucket loop cursor
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @tmp: a &struct used for temporary storage
> + * @obj: the type * to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + */
> +#define hash_for_each_safe(name, bkt, node, tmp, obj, member)			\
> +	for (bkt = 0, node = NULL; node == NULL && bkt < HASH_SIZE(name); bkt++)\

Same comment as above about "bkt".

Thanks,

Mathieu

> +		hlist_for_each_entry_safe(obj, node, tmp, &name[bkt], member)
> +
> +/**
> + * hash_for_each_possible - iterate over all possible objects hashing to the
> + * same bucket
> + * @name: hashtable to iterate
> + * @obj: the type * to use as a loop cursor for each entry
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + * @key: the key of the objects to iterate over
> + */
> +#define hash_for_each_possible(name, obj, node, member, key)			\
> +	hlist_for_each_entry(obj, node,	&name[hash_min(key, HASH_BITS(name))], member)
> +
> +/**
> + * hash_for_each_possible_rcu - iterate over all possible objects hashing to the
> + * same bucket in an rcu enabled hashtable
> + * in a rcu enabled hashtable
> + * @name: hashtable to iterate
> + * @obj: the type * to use as a loop cursor for each entry
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @member: the name of the hlist_node within the struct
> + * @key: the key of the objects to iterate over
> + */
> +#define hash_for_each_possible_rcu(name, obj, node, member, key)		\
> +	hlist_for_each_entry_rcu(obj, node, &name[hash_min(key, HASH_BITS(name))], member)
> +
> +/**
> + * hash_for_each_possible_safe - iterate over all possible objects hashing to the
> + * same bucket safe against removals
> + * @name: hashtable to iterate
> + * @obj: the type * to use as a loop cursor for each entry
> + * @node: the &struct list_head to use as a loop cursor for each entry
> + * @tmp: a &struct used for temporary storage
> + * @member: the name of the hlist_node within the struct
> + * @key: the key of the objects to iterate over
> + */
> +#define hash_for_each_possible_safe(name, obj, node, tmp, member, key)		\
> +	hlist_for_each_entry_safe(obj, node, tmp,				\
> +		&name[hash_min(key, HASH_BITS(name))], member)
> +
> +
> +#endif
> -- 
> 1.7.12.4
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
