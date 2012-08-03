Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2805D6B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 13:15:21 -0400 (EDT)
Received: by yhr47 with SMTP id 47so1324796yhr.14
        for <linux-mm@kvack.org>; Fri, 03 Aug 2012 10:15:20 -0700 (PDT)
Date: Fri, 3 Aug 2012 10:15:15 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
Message-ID: <20120803171515.GH15477@google.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
 <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org

Hello, Sasha.

On Fri, Aug 03, 2012 at 04:23:02PM +0200, Sasha Levin wrote:
> +#define DEFINE_STATIC_HASHTABLE(n, b)					\
> +	static struct hash_table n = { .bits = (b),			\
> +		.buckets = { [0 ... ((1 << (b)) - 1)] = HLIST_HEAD_INIT } }

What does this "static" mean?

> +#define DEFINE_HASHTABLE(n, b)						\
> +	union {								\
> +		struct hash_table n;					\
> +		struct {						\
> +			size_t bits;					\
> +			struct hlist_head buckets[1 << (b)];		\
> +		} __##n ;						\
> +	};

Is this supposed to be embedded in struct definition?  If so, the name
is rather misleading as DEFINE_* is supposed to define and initialize
stand-alone constructs.  Also, for struct members, simply putting hash
entries after struct hash_table should work.

Wouldn't using DEFINE_HASHTABLE() for the first macro and
DEFINE_HASHTABLE_MEMBER() for the latter be better?

> +#define HASH_BITS(name) ((name)->bits)
> +#define HASH_SIZE(name) (1 << (HASH_BITS(name)))
> +
> +__attribute__ ((unused))

Are we using __attribute__((unused)) for functions defined in headers
instead of static inline now?  If so, why? 

> +static void hash_init(struct hash_table *ht, size_t bits)
> +{
> +	size_t i;

I would prefer int here but no biggie.

> +	ht->bits = bits;
> +	for (i = 0; i < (1 << bits); i++)
> +		INIT_HLIST_HEAD(&ht->buckets[i]);
> +}
> +
> +static void hash_add(struct hash_table *ht, struct hlist_node *node, long key)
> +{
> +	hlist_add_head(node,
> +		&ht->buckets[hash_long((unsigned long)key, HASH_BITS(ht))]);
> +}
> +
> +
> +#define hash_get(name, key, type, member, cmp_fn)			\
> +({									\
> +	struct hlist_node *__node;					\
> +	typeof(key) __key = key;					\
> +	type *__obj = NULL;						\
> +	hlist_for_each_entry(__obj, __node, &(name)->buckets[		\
> +			hash_long((unsigned long) __key,		\
> +			HASH_BITS(name))], member)			\
> +		if (cmp_fn(__obj, __key))				\
> +			break;						\
> +	__obj;								\
> +})

As opposed to using hash_for_each_possible(), how much difference does
this make?  Is it really worthwhile?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
