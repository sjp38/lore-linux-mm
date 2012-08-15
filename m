Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E03EE6B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 23:13:25 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
	<1344961490-4068-3-git-send-email-levinsasha928@gmail.com>
	<87txw5hw0s.fsf@xmission.com> <502AF184.4010907@gmail.com>
	<87393phshy.fsf@xmission.com> <502AFCD5.6070104@gmail.com>
Date: Tue, 14 Aug 2012 20:13:01 -0700
In-Reply-To: <502AFCD5.6070104@gmail.com> (Sasha Levin's message of "Wed, 15
	Aug 2012 03:35:17 +0200")
Message-ID: <87obmchmpu.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 02/16] user_ns: use new hashtable implementation
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

Sasha Levin <levinsasha928@gmail.com> writes:

> On 08/15/2012 03:08 AM, Eric W. Biederman wrote:
>>> I can offer the following: I'll write a small module that will hash 1...10000
>>> > into a hashtable which uses 7 bits (just like user_ns) and post the distribution
>>> > we'll get.
>> That won't hurt.  I think 1-100 then 1000-1100 may actually be more
>> representative.  Not that I would mind seeing the larger range.
>> Especially since I am in the process of encouraging the use of more
>> uids.
>> 
>
> Alrighty, the results are in (numbers are objects in bucket):
>
> For the 0...10000 range:
>
> Average: 78.125
> Std dev: 1.4197704151
> Min: 75
> Max: 80
>
>
> For the 1...100 range:
>
> Average: 0.78125
> Std dev: 0.5164613088
> Min: 0
> Max: 2
>
>
> For the 1000...1100 range:
>
> Average: 0.7890625
> Std dev: 0.4964812206
> Min: 0
> Max: 2
>
>
> Looks like hash_32 is pretty good with small numbers.

Yes hash_32 seems reasonable for the uid hash.   With those long hash
chains I wouldn't like to be on a machine with 10,000 processes with
each with a different uid, and a processes calling setuid in the fast
path.

The uid hash that we are playing with is one that I sort of wish that
the hash table could grow in size, so that we could scale up better.

Aw well.  Most of the time we only have a very small number of uids
in play, so it doesn't matter at this point.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
