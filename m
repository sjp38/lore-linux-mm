Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 716F36B00B5
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 14:23:35 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so13720209pbb.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 11:23:34 -0700 (PDT)
Date: Tue, 31 Jul 2012 11:23:30 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Message-ID: <20120731182330.GD21292@google.com>
References: <1343757920-19713-1-git-send-email-levinsasha928@gmail.com>
 <1343757920-19713-2-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343757920-19713-2-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

Hello, Sasha.

On Tue, Jul 31, 2012 at 08:05:17PM +0200, Sasha Levin wrote:
> +#define HASH_INIT(name)							\
> +({									\
> +	int __i;							\
> +	for (__i = 0 ; __i < HASH_SIZE(name) ; __i++)			\
> +		INIT_HLIST_HEAD(&name[__i]);				\
> +})

Why use macro?

> +#define HASH_ADD(name, obj, key)					\
> +	hlist_add_head(obj, &name[					\
> +		hash_long((unsigned long)key, HASH_BITS(name))]);

Ditto.

> +#define HASH_GET(name, key, type, member, cmp_fn)			\
> +({									\
> +	struct hlist_node *__node;					\
> +	typeof(key) __key = key;					\
> +	type *__obj = NULL;						\
> +	hlist_for_each_entry(__obj, __node, &name[			\
> +			hash_long((unsigned long) __key,		\
> +			HASH_BITS(name))], member)			\
> +		if (cmp_fn(__obj, __key))				\
> +			break;						\
> +	__obj;								\
> +})

Wouldn't it be simpler to have something like the following

	hash_for_each_possible_match(pos, hash, key)

and let the caller handle the actual comparison?  Callbacks often are
painful to use and I don't think the above dancing buys much.

> +#define HASH_DEL(obj, member)						\
> +	hlist_del(&obj->member)

@obj is struct hlist_node in HASH_ADD and the containing type here?
Most in-kernel generic data containers implement just the container
itself and let the caller handle the conversions between container
node and the containing object.  I think it would better not to
deviate from that.

> +#define HASH_FOR_EACH(bkt, node, name, obj, member)			\
> +	for (bkt = 0; bkt < HASH_SIZE(name); bkt++)			\
> +		hlist_for_each_entry(obj, node, &name[i], member)

Why in caps?  Most for_each macros are in lower case.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
