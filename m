Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 471F36B0044
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 05:56:35 -0400 (EDT)
Received: by obhx4 with SMTP id x4so12298026obh.14
        for <linux-mm@kvack.org>; Tue, 28 Aug 2012 02:56:34 -0700 (PDT)
Message-ID: <503C95E4.3010000@gmail.com>
Date: Tue, 28 Aug 2012 11:56:52 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <50357840.5020201@gmail.com> <20120823200456.GD14962@google.com> <5037DA47.9010306@gmail.com> <20120824195941.GC21325@google.com> <5037E00B.6090606@gmail.com> <20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com> <20120824212348.GK21325@google.com> <5038074D.300@gmail.com> <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal>
In-Reply-To: <20120825042419.GA27240@Krystal>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 08/25/2012 06:24 AM, Mathieu Desnoyers wrote:
> * Tejun Heo (tj@kernel.org) wrote:
>> Hello,
>>
>> On Sat, Aug 25, 2012 at 12:59:25AM +0200, Sasha Levin wrote:
>>> Thats the thing, the amount of things of things you can do with a given bucket
>>> is very limited. You can't add entries to any point besides the head (without
>>> walking the entire list).
>>
>> Kinda my point.  We already have all the hlist*() interface to deal
>> with such cases.  Having something which is evidently the trivial
>> hlist hashtable and advertises as such in the interface can be
>> helpful.  I think we need that more than we need anything fancy.
>>
>> Heh, this is a debate about which one is less insignificant.  I can
>> see your point.  I'd really like to hear what others think on this.
>>
>> Guys, do we want something which is evidently trivial hlist hashtable
>> which can use hlist_*() API directly or do we want something better
>> encapsulated?
> 
> My 2 cents, FWIW: I think this specific effort should target a trivially
> understandable API and implementation, for use-cases where one would be
> tempted to reimplement his own trivial hash table anyway. So here
> exposing hlist internals, with which kernel developers are already
> familiar, seems like a good approach in my opinion, because hiding stuff
> behind new abstraction might make the target users go away.
> 
> Then, as we see the need, we can eventually merge a more elaborate hash
> table with poneys and whatnot, but I would expect that the trivial hash
> table implementation would still be useful. There are of course very
> compelling reasons to use a more featureful hash table: automatic
> resize, RT-aware updates, scalable updates, etc... but I see a purpose
> for a trivial implementation. Its primary strong points being:
> 
> - it's trivially understandable, so anyone how want to be really sure
>   they won't end up debugging the hash table instead of their
>   work-in-progress code can have a full understanding of it,
> - it has few dependencies, which makes it easier to understand and
>   easier to use in some contexts (e.g. early boot).
> 
> So I'm in favor of not overdoing the abstraction for this trivial hash
> table, and honestly I would rather prefer that this trivial hash table
> stays trivial. A more elaborate hash table should probably come as a
> separate API.
> 
> Thanks,
> 
> Mathieu
> 

Alright, let's keep it simple then.

I do want to keep the hash_for_each[rcu,safe] family though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
