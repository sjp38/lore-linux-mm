Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 360146B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 15:46:52 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so824882bkc.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 12:46:50 -0700 (PDT)
Message-ID: <5037DA47.9010306@gmail.com>
Date: Fri, 24 Aug 2012 21:47:19 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-2-git-send-email-levinsasha928@gmail.com> <20120822180138.GA19212@google.com> <50357840.5020201@gmail.com> <20120823200456.GD14962@google.com>
In-Reply-To: <20120823200456.GD14962@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 08/23/2012 10:04 PM, Tejun Heo wrote:
> Hello, Sasha.
> 
> On Thu, Aug 23, 2012 at 02:24:32AM +0200, Sasha Levin wrote:
>>> I think the almost trivial nature of hlist hashtables makes this a bit
>>> tricky and I'm not very sure but having this combinatory explosion is
>>> a bit dazzling when the same functionality can be achieved by simply
>>> combining operations which are already defined and named considering
>>> hashtable.  I'm not feeling too strong about this tho.  What do others
>>> think?
>>
>> I'm thinking that this hashtable API will have 2 purposes: First, it would
>> prevent the excessive duplication of hashtable implementations all around the code.
>>
>> Second, it will allow more easily interchangeable hashtable implementations to
>> find their way into the kernel. There are several maintainers who would be happy
>> to see dynamically sized RCU hashtable, and I'm guessing that several more
>> variants could be added based on needs in specific modules.
>>
>> The second reason is why several things you've mentioned look the way they are:
>>
>>  - No DEFINE_HASHTABLE(): I wanted to force the use of hash_init() since
>> initialization for other hashtables may be more complicated than the static
>> initialization for this implementation, which means that any place that used
>> DEFINE_HASHTABLE() and didn't do hash_init() will be buggy.
> 
> I think this is problematic.  It looks exactly like other existing
> DEFINE macros yet what its semantics is different.  I don't think
> that's a good idea.

I can switch that to be DECLARE_HASHTABLE() if the issue is semantics.

>> I'm actually tempted in hiding hlist completely from hashtable users, probably
>> by simply defining a hash_head/hash_node on top of the hlist_ counterparts.
> 
> I think that it would be best to keep this one simple & obvious, which
> already has enough in-kernel users to justify its existence.  There
> are significant benefits in being trivially understandable and
> expectable.  If we want more advanced ones - say resizing, hybrid or
> what not, let's make that a separate one.  No need to complicate the
> common straight-forward case for that.
> 
> So, I think it would be best to keep this one as straight-forward and
> trivial as possible.  Helper macros to help its users are fine but
> let's please not go for full encapsulation.

What if we cut off the dynamic allocated (but not resizable) hashtable out for
the moment, and focus on the most common statically allocated hashtable case?

The benefits would be:

 - Getting rid of all the _size() macros, which will make the amount of helpers
here reasonable.
 - Dynamically allocated hashtable can be easily added as a separate
implementation using the same API. We already have some of those in the kernel...
 - When that's ready, I feel it's a shame to lose full encapsulation just due to
hash_hashed().


Thanks,
Sasha

> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
