Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58AE36B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:43:44 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id m35so2789566oik.7
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 05:43:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q206si1263119oia.488.2017.11.30.05.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 05:43:43 -0800 (PST)
Subject: Re: [PATCH] list_lru: Prefetch neighboring list entries before
 acquiring lock
References: <1511965054-6328-1-git-send-email-longman@redhat.com>
 <20171130005301.GA2679@bbox>
From: Waiman Long <longman@redhat.com>
Message-ID: <414f9020-aba5-eef1-b689-36307dbdcfed@redhat.com>
Date: Thu, 30 Nov 2017 08:43:41 -0500
MIME-Version: 1.0
In-Reply-To: <20171130005301.GA2679@bbox>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/29/2017 07:53 PM, Minchan Kim wrote:
> Hello,
>
> On Wed, Nov 29, 2017 at 09:17:34AM -0500, Waiman Long wrote:
>> The list_lru_del() function removes the given item from the LRU list.
>> The operation looks simple, but it involves writing into the cacheline=
s
>> of the two neighboring list entries in order to get the deletion done.=

>> That can take a while if the cachelines aren't there yet, thus
>> prolonging the lock hold time.
>>
>> To reduce the lock hold time, the cachelines of the two neighboring
>> list entries are now prefetched before acquiring the list_lru_node's
>> lock.
>>
>> Using a multi-threaded test program that created a large number
>> of dentries and then killed them, the execution time was reduced
>> from 38.5s to 36.6s after applying the patch on a 2-socket 36-core
>> 72-thread x86-64 system.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
>> ---
>>  mm/list_lru.c | 10 +++++++++-
>>  1 file changed, 9 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/list_lru.c b/mm/list_lru.c
>> index f141f0c..65aae44 100644
>> --- a/mm/list_lru.c
>> +++ b/mm/list_lru.c
>> @@ -132,8 +132,16 @@ bool list_lru_del(struct list_lru *lru, struct li=
st_head *item)
>>  	struct list_lru_node *nlru =3D &lru->node[nid];
>>  	struct list_lru_one *l;
>> =20
>> +	/*
>> +	 * Prefetch the neighboring list entries to reduce lock hold time.
>> +	 */
>> +	if (unlikely(list_empty(item)))
>> +		return false;
>> +	prefetchw(item->prev);
>> +	prefetchw(item->next);
>> +
> A question:
>
> A few month ago, I had a chance to measure prefetch effect with my test=
ing
> workload. For the clarification, it's not list_lru_del but list travers=
e
> stuff so it might be similar.
>
> With my experiment at that time, it was really hard to find best place =
to
> add prefetchw. Sometimes, it was too eariler or late so the effect was
> not good, even worse on some cases.
>
> Also, the performance was different with each machine although my testi=
ng
> machines was just two. ;-)
>
> So my question is what's a rule of thumb to add prefetch command?
> Like your code, putting prefetch right before touching?
>
> I'm really wonder what's the rule to make every arch/machines happy
> with prefetch.

I add the prefetchw() before spin_lock() because the latency of the
lockinig operation can be highly variable. There will have high latency
when the lock is contended. With the prefetch, lock hold time will be
reduced. In turn, it helps to reduce the amount of lock contention as
well. If there is no lock contention, the prefetch won't help.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
