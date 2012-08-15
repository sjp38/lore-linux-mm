Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id CFE946B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 20:24:17 -0400 (EDT)
Received: by obhx4 with SMTP id x4so1584021obh.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 17:24:16 -0700 (PDT)
Message-ID: <502AEC51.2010305@gmail.com>
Date: Wed, 15 Aug 2012 02:24:49 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/16] hashtable: introduce a small and naive hashtable
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com> <1344961490-4068-2-git-send-email-levinsasha928@gmail.com> <20120815092523.00a909ef@notabene.brown>
In-Reply-To: <20120815092523.00a909ef@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 08/15/2012 01:25 AM, NeilBrown wrote:
> On Tue, 14 Aug 2012 18:24:35 +0200 Sasha Levin <levinsasha928@gmail.com>
> wrote:
> 
> 
>> +static inline void hash_init_size(struct hlist_head *hashtable, int bits)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < HASH_SIZE(bits); i++)
>> +		INIT_HLIST_HEAD(hashtable + i);
>> +}
> 
> This seems like an inefficient way to do "memset(hashtable, 0, ...);".
> And in many cases it isn't needed as the hash table is static and initialised
> to zero.
> I note that in the SUNRPC/cache patch you call hash_init(), but in the lockd
> patch you don't.  You don't actually need to in either case.

Agreed that the code will run just fine if we wouldn't use hash_init().

> I realise that any optimisation here is for code that is only executed once
> per boot, so no big deal, and even the presence of extra code making the
> kernel bigger is unlikely to be an issue.  But I'd at least like to see
> consistency: Either use hash_init everywhere, even when not needed, or only
> use it where absolutely needed which might be no-where because static tables
> are already initialised, and dynamic tables can use GFP_ZERO.

This is a consistency problem. I didn't want to add a module_init() to modules that didn't have it just to get hash_init() in there.

I'll get it fixed.

> And if you keep hash_init_size I would rather see a memset(0)....

My concern with using a memset(0) is that I'm going to break layering.

The hashtable uses hlist. hlist provides us with an entire family of init functions which I'm supposed to use to initialize hlist heads.

So while a memset(0) will work perfectly here, I consider that cheating - it results in an uglier code that assumes to know about hlist internals, and will probably break as soon as someone tries to do something to hlist.

I can think of several alternatives here, and all of them involve changes to hlist instead of the hashtable:

 - Remove INIT_HLIST_HEAD()/HLIST_HEAD()/HLIST_HEAD_INIT() and introduce a CLEAR_HLIST instead, documenting that it's enough to memset(0) the hlist to initialize it properly.
 - Add a block initializer INIT_HLIST_HEADS() or something similar that would initialize an array of heads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
