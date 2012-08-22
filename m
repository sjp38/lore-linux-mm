Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id C04E36B0070
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 14:01:44 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1999736pbb.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:01:44 -0700 (PDT)
Date: Wed, 22 Aug 2012 11:01:38 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
 hashtable
Message-ID: <20120822180138.GA19212@google.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
 <1345602432-27673-2-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345602432-27673-2-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

Hello, Sasha.

On Wed, Aug 22, 2012 at 04:26:56AM +0200, Sasha Levin wrote:
> +#define DEFINE_HASHTABLE(name, bits)					\
> +	struct hlist_head name[HASH_SIZE(bits)];

Shouldn't this be something like the following?

#define DEFINE_HASHTABLE(name, bits)					\
	struct hlist_head name[HASH_SIZE(bits)] =			\
		{ [0 ... HASH_SIZE(bits) - 1] = HLIST_HEAD_INIT };

Also, given that the declaration isn't non-trivial, you'll probably
want a matching DECLARE_HASHTABLE() macro too.

> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
> +#define hash_min(val, bits) ((sizeof(val)==4) ? hash_32((val), (bits)) : hash_long((val), (bits)))

Why is the branching condition sizeof(val) == 4 instead of <= 4?
Also, no biggie but why isn't this macro in caps?

> +/**
> + * hash_add_size - add an object to a hashtable
> + * @hashtable: hashtable to add to
> + * @bits: bit count used for hashing
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add_size(hashtable, bits, node, key)				\
> +	hlist_add_head(node, &hashtable[hash_min(key, bits)]);
> +
> +/**
> + * hash_add - add an object to a hashtable
> + * @hashtable: hashtable to add to
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add(hashtable, node, key)						\
> +	hash_add_size(hashtable, HASH_BITS(hashtable), node, key)

It would be nice if the comments actually say something which can
differentiate the two.  Ditto for rcu variants.

> +/**
> + * hash_add_rcu_size - add an object to a rcu enabled hashtable
> + * @hashtable: hashtable to add to
> + * @bits: bit count used for hashing
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add_rcu_size(hashtable, bits, node, key)				\
> +	hlist_add_head_rcu(node, &hashtable[hash_min(key, bits)]);
> +
> +/**
> + * hash_add_rcu - add an object to a rcu enabled hashtable
> + * @hashtable: hashtable to add to
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add_rcu(hashtable, node, key)					\
> +	hash_add_rcu_size(hashtable, HASH_BITS(hashtable), node, key)

Or maybe we're better off with hash_head_size() and hash_head()?  I'll
expand on it later.  Please bear with me.

> +/**
> + * hash_hashed - check whether an object is in any hashtable
> + * @node: the &struct hlist_node of the object to be checked
> + */
> +#define hash_hashed(node) (!hlist_unhashed(node))

As the 'h' in hlist* stand for hash anyway and I think this type of
thin wrappers tend to obfuscate more than anything else.

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

If we do that, we can remove all these thin wrappers.

> +#define hash_for_each_size(name, bits, bkt, node, obj, member)			\
> +	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)				\
> +		hlist_for_each_entry(obj, node, &name[bkt], member)
..
> +#define hash_for_each(name, bkt, node, obj, member)				\
> +	hash_for_each_size(name, HASH_BITS(name), bkt, node, obj, member)
...
> +#define hash_for_each_rcu_size(name, bits, bkt, node, obj, member)		\
> +	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)				\
> +		hlist_for_each_entry_rcu(obj, node, &name[bkt], member)
...
> +#define hash_for_each_rcu(name, bkt, node, obj, member)				\
> +	hash_for_each_rcu_size(name, HASH_BITS(name), bkt, node, obj, member)
...
> +#define hash_for_each_safe_size(name, bits, bkt, node, tmp, obj, member)	\
> +	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)                     	\
> +		hlist_for_each_entry_safe(obj, node, tmp, &name[bkt], member)
...
> +#define hash_for_each_safe(name, bkt, node, tmp, obj, member)			\
> +	hash_for_each_safe_size(name, HASH_BITS(name), bkt, node,		\
> +				tmp, obj, member)
...
> +#define hash_for_each_possible_size(name, obj, bits, node, member, key)		\
> +	hlist_for_each_entry(obj, node,	&name[hash_min(key, bits)], member)
...
> +#define hash_for_each_possible(name, obj, node, member, key)			\
> +	hash_for_each_possible_size(name, obj, HASH_BITS(name), node, member, key)
...
> +#define hash_for_each_possible_rcu_size(name, obj, bits, node, member, key)	\
> +	hlist_for_each_entry_rcu(obj, node, &name[hash_min(key, bits)], member)
...
> +#define hash_for_each_possible_rcu(name, obj, node, member, key)		\
> +	hash_for_each_possible_rcu_size(name, obj, HASH_BITS(name),		\
...
> +#define hash_for_each_possible_safe_size(name, obj, bits, node, tmp, member, key)\
> +	hlist_for_each_entry_safe(obj, node, tmp,				\
> +		&name[hash_min(key, bits)], member)
...
> +#define hash_for_each_possible_safe(name, obj, node, tmp, member, key)		\
> +	hash_for_each_possible_safe_size(name, obj, HASH_BITS(name),		\

And also all these.  We'd only need hash_for_each_head() and
hash_head().  hash_for_each_possible*() could be nice for convenience,
I suppose.

I think the almost trivial nature of hlist hashtables makes this a bit
tricky and I'm not very sure but having this combinatory explosion is
a bit dazzling when the same functionality can be achieved by simply
combining operations which are already defined and named considering
hashtable.  I'm not feeling too strong about this tho.  What do others
think?

Also, can you please audit the comments on top of each macro?  They
have wrong names and don't differentiate the different variants very
well.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
