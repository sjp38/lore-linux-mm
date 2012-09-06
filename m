Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id AB14F6B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 11:49:18 -0400 (EDT)
Received: by eeke49 with SMTP id e49so927738eek.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 08:49:17 -0700 (PDT)
Message-ID: <5048C615.4070204@gmail.com>
Date: Thu, 06 Sep 2012 17:49:41 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal> <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal> <20120828230050.GA3337@Krystal> <1346772948.27919.9.camel@gandalf.local.home> <50462C99.5000007@redhat.com> <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal> <5048AAF6.5090101@gmail.com> <20120906145545.GA17332@leaf>
In-Reply-To: <20120906145545.GA17332@leaf>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Pedro Alves <palves@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 09/06/2012 04:55 PM, Josh Triplett wrote:
> On Thu, Sep 06, 2012 at 03:53:58PM +0200, Sasha Levin wrote:
>> On 09/04/2012 07:01 PM, Mathieu Desnoyers wrote:
>>>> #define do_for_each_ftrace_rec(pg, rec)                                          \
>>>>>         for (pg = ftrace_pages_start, rec = &pg->records[pg->index];             \
>>>>>              pg && rec == &pg->records[pg->index];                               \
>>>>>              pg = pg->next)                                                      \
>>>>>           for (rec = pg->records; rec < &pg->records[pg->index]; rec++)
>>> Maybe in some cases there might be ways to combine the two loops into
>>> one ? I'm not seeing exactly how to do it for this one, but it should
>>> not be impossible. If the inner loop condition can be moved to the outer
>>> loop, and if we use (blah ? loop1_conf : loop2_cond) to test for
>>> different conditions depending on the context, and do the same for the
>>> 3rd argument of the for() loop. The details elude me for now though, so
>>> maybe it's complete non-sense ;)
>>>
>>> It might not be that useful for do_for_each_ftrace_rec, but if we can do
>>> it for the hash table iterator, it might be worth it.
>>
>> So I think that for the hash iterator it might actually be simpler.
>>
>> My solution to making 'break' work in the iterator is:A code like that doesn
>>
>> 	for (bkt = 0, node = NULL; bkt < HASH_SIZE(name) && node == NULL; bkt++)
>> 		hlist_for_each_entry(obj, node, &name[bkt], member)
>>
>> We initialize our node loop cursor with NULL in the external loop, and the
>> external loop will have a new condition to loop while that cursor is NULL.
>>
>> My logic is that we can only 'break' when we are iterating over an object in the
>> internal loop. If we're iterating over an object in that loop then 'node != NULL'.
>>
>> This way, if we broke from within the internal loop, the external loop will see
>> node as not NULL, and so it will stop looping itself. On the other hand, if the
>> internal loop has actually ended, then node will be NULL, and the outer loop
>> will keep running.
>>
>> Is there anything I've missed?
> 
> Looks reasonable.  However, it would break (or rather, not break) on
> code like this:
> 
> 	hash_for_each_entry(...) {
> 		if (...) {
> 			foo(node);
> 			node = NULL;
> 			break;
> 		}
> 	}
> 
> Hiding the double loop still seems error-prone.

I think that that code doesn't make sense. The users of hlist_for_each_* aren't
supposed to be changing the loop cursor.

We have three options here:

 1. Stuff everything into a single for(). While not too difficult, it will make
the readability of the code difficult as it will force us to abandon using
hlist_for_each_* macros.

 2. Over-complicate everything, and check for 'node == NULL && obj &&
obj->member.next == NULL' instead. That one will fail only if the user has
specifically set the object as the last object in the list and the node as NULL.

 3. Use 2 loops which might not work properly if the user does something odd,
with a big fat warning above them.


To sum it up, I'd rather go with 3 and let anyone who does things he shouldn't
be doing break.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
