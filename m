Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id AA62D6B0069
	for <linux-mm@kvack.org>; Sun, 19 Aug 2012 12:07:31 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so2132030bkc.14
        for <linux-mm@kvack.org>; Sun, 19 Aug 2012 09:07:29 -0700 (PDT)
Message-ID: <50310F61.9030805@gmail.com>
Date: Sun, 19 Aug 2012 18:08:01 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 01/16] hashtable: introduce a small and naive hashtable
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com> <1345337550-24304-2-git-send-email-levinsasha928@gmail.com> <20120819131637.GA8272@Krystal>
In-Reply-To: <20120819131637.GA8272@Krystal>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 08/19/2012 03:16 PM, Mathieu Desnoyers wrote:
> * Sasha Levin (levinsasha928@gmail.com) wrote:
>> This hashtable implementation is using hlist buckets to provide a simple
>> hashtable to prevent it from getting reimplemented all over the kernel.
>>
>> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
>> ---
>>  include/linux/hashtable.h |  284 +++++++++++++++++++++++++++++++++++++++++++++
> [...]
> 
> Hi Sasha,
> 
> There are still a few API naming nits that I'd like to discuss:
> 
>> +
>> +/**
>> + * hash_for_each_size - iterate over a hashtable
>> + * @name: hashtable to iterate
>> + * @bits: bit count of hashing function of the hashtable
>> + * @bkt: integer to use as bucket loop cursor
>> + * @node: the &struct list_head to use as a loop cursor for each bucket
>> + * @obj: the type * to use as a loop cursor for each bucket
>> + * @member: the name of the hlist_node within the struct
>> + */
>> +#define hash_for_each_size(name, bits, bkt, node, obj, member)			\
> 
> What is the meaning of "for each size" ?
> 
> By looking at the implementation, I see that it takes an extra "bits"
> argument to specify the key width.
> 
> But in the other patches of this patchset, I cannot find a single user
> of the "*_size" API. If you do not typically expect users to specify
> this parameter by hand (thanks to use of HASH_BITS(name) in for_each
> functions that do not take the bits parameter), I would recommend to
> only expose hash_for_each() and similar defines, but n I'd ot the *_size
> variants.
> 
> So I recommend merging hash_for_each_size into hash_for_each (and
> doing similarly for other *_size variants). On the plus side, it will
> cut down the number of for_each macros from 12 down to 6, whiy och is more
> reasonable.

This is actually how the hashtable API was looking in the first place - without
the _size functions.

The story here is that when I've introduced the original API which used macro
magic to work out the size, one of the first comments was that there are several
dynamically allocated hashtables around the kernels, and all this macro magic
wouldn't work.

I've grepped around the code and indeed saw several places which k*alloc/vmalloc
their hashtable, so I agreed with that and happily went ahead to extend the API
to have _size functions.

When I started converting more kernel code to use this new API, I also converted
two modules which kmalloced the hashtable, but instead of using the _size API I
ended up removing the allocation completely because it was unnecessary and
wasteful. And this is why you don't see _size being used anywhere in any of the
patches.

Looking at the kernel code again, I see several places where removal of dynamic
allocation won't work (see 'new_tl_hash' in drivers/block/drbd/drbd_nl.c for
example).

So I'd rather leave it in at least until we finish converting, as I see several
places which will definitely need it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
