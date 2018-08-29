Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4E36B4D57
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 15:34:08 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q26-v6so5591196qtj.14
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 12:34:08 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r53-v6si4657649qvj.122.2018.08.29.12.34.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 12:34:06 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180829010228.GE1572@dastard>
From: Waiman Long <longman@redhat.com>
Message-ID: <6e2999b3-e93f-2138-6ceb-4f24712f419f@redhat.com>
Date: Wed, 29 Aug 2018 15:34:05 -0400
MIME-Version: 1.0
In-Reply-To: <20180829010228.GE1572@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 08/28/2018 09:02 PM, Dave Chinner wrote:
> On Tue, Aug 28, 2018 at 01:19:40PM -0400, Waiman Long wrote:
>> For negative dentries that are accessed once and never used again, the=
y
>> should be removed first before other dentries when shrinker is running=
=2E
>> This is done by putting negative dentries at the head of the LRU list
>> instead at the tail.
>>
>> A new DCACHE_NEW_NEGATIVE flag is now added to a negative dentry when =
it
>> is initially created. When such a dentry is added to the LRU, it will =
be
>> added to the head so that it will be the first to go when a shrinker i=
s
>> running if it is never accessed again (DCACHE_REFERENCED bit not set).=

>> The flag is cleared after the LRU list addition.
> This exposes internal LRU list functionality to callers. I carefully
> hid what end of the list was the most or least recent from
> subsystems interacting with LRUs precisely because "head" and "tail"
> are completely confusing when interacting with a LRU.
>
> LRUs are about tracking relative object age, not heads and tails.
>
> IOWs, "track this object as most recently used", not "add this
> object to the list tail". The opposite is "track this object is
> least recently used", not "add object at head of list".
>
> IOWs, the interface should be list_lru_add_oldest() or maybe
> list_lru_add_least_recent() to indicate that these objects are
> considered to be the oldest and therefore prime immediate reclaim
> candidates.

Good point. I will use age as function name instead.

> Which points out a problem. That the most recent negative dentry
> will be the first to be reclaimed. That's not LRU behaviour, and
> prevents a working set of negative dentries from being retained
> when the shrinker rotates through the dentries in LRU order. i.e.
> this patch turns the LRU into a MRU list for negative dentries.
>
> And then there's shrinker behaviour. What happens if the shrinker
> isolate callback returns LRU_ROTATE on a negative dentry? It gets
> moved to the most recent end of the list, so it won't have an
> attempt to reclaim it again until it's tried to reclaim all the real
> dentries. IOWs, it goes back to behaving like LRUs are supposed to
> behaving.
>
> IOWs, reclaim behaviour of negative dentries will be
> highly unpredictable, it will not easily retain a working set, nor
> will the working set it does retain be predictable or easy to eject
> from memory when the workload changes.
>
> Is this the behavour what we want for negative dentries?

I am aware that the behavior is not strictly LRU for negative dentries.
This is a compromise for using one LRU list for 2 different classes of
dentries. The basic idea is that negative dentries that are used only
once will go first irrespective of their age.

> Perhaps a second internal LRU list in the list_lru for "immediate
> reclaim" objects would be a better solution. i.e. similar to the
> active/inactive lists used for prioritising the working set iover
> single use pages in page reclaim. negative dentries go onto the
> immediate list, real dentries go on the existing list. Both are LRU,
> and the shrinker operates on the immediate list first. When we
> rotate referenced negative dentries on the immediate list, promote
> them to the active list with all the real dentries so they age out
> with the rest of the working set. That way single use negative
> dentries get removed in LRU order in preference to the working set
> of real dentries.
>
> Being able to make changes to the list implementation easily was one
> of the reasons I hid the implementation of the list_lru from the
> interface callers use....
>
> [...]

I have thought about using 2 lists for dentries. That will require much
more extensive changes to the code and hence much more testing will be
needed to verify their correctness. That is the main reason why I try to
avoid doing that.

As you have suggested, we could implement this 2-level LRU list in the
list_lru API. But it is used by other subsystems as well. Extensive
change like that will have similar issue in term of testing and
verification effort.

>> @@ -430,8 +424,20 @@ static void d_lru_add(struct dentry *dentry)
>>  	D_FLAG_VERIFY(dentry, 0);
>>  	dentry->d_flags |=3D DCACHE_LRU_LIST;
>>  	this_cpu_inc(nr_dentry_unused);
>> +	if (d_is_negative(dentry)) {
>> +		__neg_dentry_inc(dentry);
> /me notes this patch now open codes this, like suggested in the
> previous patch.
>
>> +		if (dentry->d_flags & DCACHE_NEW_NEGATIVE) {
>> +			/*
>> +			 * Add the negative dentry to the head once, it
>> +			 * will be added to the tail next time.
>> +			 */
>> +			WARN_ON_ONCE(!list_lru_add_head(
>> +				&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
>> +			dentry->d_flags &=3D ~DCACHE_NEW_NEGATIVE;
>> +			return;
>> +		}
>> +	}
>>  	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_l=
ru));
>> -	neg_dentry_inc(dentry);
>>  }
>> =20
>>  static void d_lru_del(struct dentry *dentry)
>> @@ -2620,6 +2626,9 @@ static inline void __d_add(struct dentry *dentry=
, struct inode *inode)
>>  		__d_set_inode_and_type(dentry, inode, add_flags);
>>  		raw_write_seqcount_end(&dentry->d_seq);
>>  		fsnotify_update_flags(dentry);
>> +	} else {
>> +		/* It is a negative dentry, add it to LRU head initially. */
>> +		dentry->d_flags |=3D DCACHE_NEW_NEGATIVE;
> Comments about LRU behaviour should not be put anywhere but in the
> lru code. Otherwise it ends up stale and wrong, assuming it is
> correct to start with....
>

I will document all that in the LRU code.

>>  	}
>>  	__d_rehash(dentry);
>>  	if (dir)
>> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
>> index df942e5..03a1918 100644
>> --- a/include/linux/dcache.h
>> +++ b/include/linux/dcache.h
>> @@ -214,6 +214,7 @@ struct dentry_operations {
>>  #define DCACHE_FALLTHRU			0x01000000 /* Fall through to lower layer *=
/
>>  #define DCACHE_ENCRYPTED_WITH_KEY	0x02000000 /* dir is encrypted with=
 a valid key */
>>  #define DCACHE_OP_REAL			0x04000000
>> +#define DCACHE_NEW_NEGATIVE		0x08000000 /* New negative dentry */
>> =20
>>  #define DCACHE_PAR_LOOKUP		0x10000000 /* being looked up (with parent=
 locked shared) */
>>  #define DCACHE_DENTRY_CURSOR		0x20000000
>> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
>> index aa5efd9..bfac057 100644
>> --- a/include/linux/list_lru.h
>> +++ b/include/linux/list_lru.h
>> @@ -90,6 +90,23 @@ int __list_lru_init(struct list_lru *lru, bool memc=
g_aware,
>>  bool list_lru_add(struct list_lru *lru, struct list_head *item);
>> =20
>>  /**
>> + * list_lru_add_head: add an element to the lru list's head
>> + * @list_lru: the lru pointer
>> + * @item: the item to be added.
>> + *
>> + * This is similar to list_lru_add(). The only difference is the loca=
tion
>> + * where the new item will be added. The list_lru_add() function will=
 add
>> + * the new item to the tail as it is the most recently used one. The
>> + * list_lru_add_head() will add the new item into the head so that it=

>> + * will the first to go if a shrinker is running. So this function sh=
ould
>> + * only be used for less important item that can be the first to go i=
f
>> + * the system is under memory pressure.
> As mentioned above, this API needs reference object ages, not
> internal list ordering and shrinker implementation details.

Sure. Thanks for the suggestion.

Cheers,
Longman
