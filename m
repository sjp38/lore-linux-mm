Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 68E6B6B0069
	for <linux-mm@kvack.org>; Sun, 19 Aug 2012 09:16:40 -0400 (EDT)
Date: Sun, 19 Aug 2012 09:16:37 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v2 01/16] hashtable: introduce a small and naive
	hashtable
Message-ID: <20120819131637.GA8272@Krystal>
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com> <1345337550-24304-2-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345337550-24304-2-git-send-email-levinsasha928@gmail.com>
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
>  include/linux/hashtable.h |  284 +++++++++++++++++++++++++++++++++++++++++++++
[...]

Hi Sasha,

There are still a few API naming nits that I'd like to discuss:

> +
> +/**
> + * hash_for_each_size - iterate over a hashtable
> + * @name: hashtable to iterate
> + * @bits: bit count of hashing function of the hashtable
> + * @bkt: integer to use as bucket loop cursor
> + * @node: the &struct list_head to use as a loop cursor for each bucket
> + * @obj: the type * to use as a loop cursor for each bucket
> + * @member: the name of the hlist_node within the struct
> + */
> +#define hash_for_each_size(name, bits, bkt, node, obj, member)			\

What is the meaning of "for each size" ?

By looking at the implementation, I see that it takes an extra "bits"
argument to specify the key width.

But in the other patches of this patchset, I cannot find a single user
of the "*_size" API. If you do not typically expect users to specify
this parameter by hand (thanks to use of HASH_BITS(name) in for_each
functions that do not take the bits parameter), I would recommend to
only expose hash_for_each() and similar defines, but not the *_size
variants.

So I recommend merging hash_for_each_size into hash_for_each (and
doing similarly for other *_size variants). On the plus side, it will
cut down the number of for_each macros from 12 down to 6, which is more
reasonable.


> +	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)				\
> +		hlist_for_each_entry(obj, node, &name[bkt], member)
> +
> +/**
> + * hash_for_each - iterate over a hashtable
> + * @name: hashtable to iterate
> + * @bkt: integer to use as bucket loop cursor
> + * @node: the &struct list_head to use as a loop cursor for each bucket
> + * @obj: the type * to use as a loop cursor for each bucket
> + * @member: the name of the hlist_node within the struct
> + */
> +#define hash_for_each(name, bkt, node, obj, member)				\
> +	hash_for_each_size(name, HASH_BITS(name), bkt, node, obj, member)
> +

[...]

> +/**
> + * hash_for_each_possible - iterate over all possible objects for a given key
> + * @name: hashtable to iterate
> + * @obj: the type * to use as a loop cursor for each bucket
> + * @bits: bit count of hashing function of the hashtable
> + * @node: the &struct list_head to use as a loop cursor for each bucket
> + * @member: the name of the hlist_node within the struct
> + * @key: the key of the objects to iterate over
> + */
> +#define hash_for_each_possible_size(name, obj, bits, node, member, key)		\
> +	hlist_for_each_entry(obj, node,	&name[hash_min(key, bits)], member)

Second point: "for_each_possible" does not express the iteration scope.
Citing WordNet: "possible adj 1: capable of happening or existing;" --
which has nothing to do with iteration on duplicate keys within a hash
table.

I would recommend to rename "possible" to "duplicate", e.g.:

  hash_for_each_duplicate()

which clearly says what is the scope of this iteration: duplicate keys.

Thanks,

Mathieu

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
