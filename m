Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 468856B0069
	for <linux-mm@kvack.org>; Sun, 19 Aug 2012 12:17:14 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so2133241bkc.14
        for <linux-mm@kvack.org>; Sun, 19 Aug 2012 09:17:12 -0700 (PDT)
Message-ID: <503111A8.5030703@gmail.com>
Date: Sun, 19 Aug 2012 18:17:44 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 01/16] hashtable: introduce a small and naive hashtable
References: <1345337550-24304-1-git-send-email-levinsasha928@gmail.com> <1345337550-24304-2-git-send-email-levinsasha928@gmail.com> <20120819131637.GA8272@Krystal> <20120819141641.GA9082@Krystal>
In-Reply-To: <20120819141641.GA9082@Krystal>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 08/19/2012 04:16 PM, Mathieu Desnoyers wrote:
> * Mathieu Desnoyers (mathieu.desnoyers@efficios.com) wrote:
>> * Sasha Levin (levinsasha928@gmail.com) wrote:
> [...]
>>> +/**
>>> + * hash_for_each_possible - iterate over all possible objects for a given key
>>> + * @name: hashtable to iterate
>>> + * @obj: the type * to use as a loop cursor for each bucket
>>> + * @bits: bit count of hashing function of the hashtable
>>> + * @node: the &struct list_head to use as a loop cursor for each bucket
>>> + * @member: the name of the hlist_node within the struct
>>> + * @key: the key of the objects to iterate over
>>> + */
>>> +#define hash_for_each_possible_size(name, obj, bits, node, member, key)		\
>>> +	hlist_for_each_entry(obj, node,	&name[hash_min(key, bits)], member)
>>
>> Second point: "for_each_possible" does not express the iteration scope.
>> Citing WordNet: "possible adj 1: capable of happening or existing;" --
>> which has nothing to do with iteration on duplicate keys within a hash
>> table.
>>
>> I would recommend to rename "possible" to "duplicate", e.g.:
>>
>>   hash_for_each_duplicate()
>>
>> which clearly says what is the scope of this iteration: duplicate keys.
> 
> OK, about this part: I now see that you iterate over all objects within
> the same hash chain. I guess the description "iterate over all possible
> objects for a given key" is misleading: it's not all objects with a
> given key, but rather all objects hashing to the same bucket.
> 
> I understand that you don't want to build knowledge of the key
> comparison function in the iterator (which makes sense for a simple hash
> table).
> 
> By the way, the comment "@obj: the type * to use as a loop cursor for
> each bucket" is also misleading: it's a loop cursor for each entry,
> since you iterate on all nodes within single bucket. Same for "@node:
> the &struct list_head to use as a loop cursor for each bucket".
> 
> So with these documentation changes applied, hash_for_each_possible
> starts to make more sense, because it refers to entries that can
> _possibly_ be a match (or not). Other options would be
> hash_chain_for_each() or hash_bucket_for_each().

I'd rather avoid starting to use chain/bucket since they're not used anywhere
else (I've tried keeping internal hashing/bucketing opaque to the user).

Otherwise makes sense, I'll improve the documentation as suggested. Thanks!

> Thanks,
> 
> Mathieu
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
