Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 326A56B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 16:53:18 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so839734bkc.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 13:53:16 -0700 (PDT)
Message-ID: <5037E9D9.9000605@gmail.com>
Date: Fri, 24 Aug 2012 22:53:45 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-2-git-send-email-levinsasha928@gmail.com> <20120822180138.GA19212@google.com> <50357840.5020201@gmail.com> <20120823200456.GD14962@google.com> <5037DA47.9010306@gmail.com> <20120824195941.GC21325@google.com> <5037E00B.6090606@gmail.com> <20120824203332.GF21325@google.com>
In-Reply-To: <20120824203332.GF21325@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 08/24/2012 10:33 PM, Tejun Heo wrote:
> Hello, Sasha.
> 
> On Fri, Aug 24, 2012 at 10:11:55PM +0200, Sasha Levin wrote:
>>> If this implementation is about the common trivial case, why not just
>>> have the usual DECLARE/DEFINE_HASHTABLE() combination?
>>
>> When we add the dynamic non-resizable support, how would DEFINE_HASHTABLE() look?
> 
> Hmmm?  DECLARE/DEFINE are usually for static ones.

Yup, but we could be using the same API for dynamic non-resizable and static if
we go with the DECLARE/hash_init. We could switch between them (and other
implementations) without having to change the code.

>>> I don't know.  If we stick to the static (or even !resize dymaic)
>>> straight-forward hash - and we need something like that - I don't see
>>> what the full encapsulation buys us other than a lot of trivial
>>> wrappers.
>>
>> Which macros do you consider as trivial within the current API?
>>
>> Basically this entire thing could be reduced to DEFINE/DECLARE_HASHTABLE and
>> get_bucket(), but it would make the life of anyone who wants a slightly
>> different hashtable a hell.
> 
> Wouldn't the following be enough to get most of the benefits?
> 
> * DECLARE/DEFINE
> * hash_head()
> * hash_for_each_head()
> * hash_add*()
> * hash_for_each_possible*()
 * hash_for_each*() ?


Why do we need hash_head/hash_for_each_head()? I haven't stumbled on a place yet
that needed direct access to the bucket itself.

Consider the following list:

 - DECLARE
 - hash_init
 - hash_add
 - hash_del
 - hash_hashed
 - hash_for_each_[rcu, safe]
 - hash_for_each_possible[rcu, safe]

This basically means 11 macros/functions that would let us have full
encapsulation and will make it very easy for future implementations to work with
this API instead of making up a new one. It's also not significantly (+~2-3)
more than the ones you listed.

>> I think that right now the only real trivial wrapper is hash_hashed(), and I
>> think it's a price worth paying to have a single hashtable API instead of
>> fragmenting it when more implementations come along.
> 
> I'm not objecting strongly against full encapsulation but having this
> many thin wrappers makes me scratch my head.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
