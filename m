Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 7C85D6B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 20:46:27 -0400 (EDT)
Received: by obhx4 with SMTP id x4so1612603obh.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 17:46:26 -0700 (PDT)
Message-ID: <502AF184.4010907@gmail.com>
Date: Wed, 15 Aug 2012 02:47:00 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/16] user_ns: use new hashtable implementation
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com> <1344961490-4068-3-git-send-email-levinsasha928@gmail.com> <87txw5hw0s.fsf@xmission.com>
In-Reply-To: <87txw5hw0s.fsf@xmission.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 08/15/2012 01:52 AM, Eric W. Biederman wrote:
> Sasha Levin <levinsasha928@gmail.com> writes:
> 
>> Switch user_ns to use the new hashtable implementation. This reduces the amount of
>> generic unrelated code in user_ns.
> 
> Two concerns here.
> 1) When adding a new entry you recompute the hash where previously that
>    was not done.  I believe that will slow down adding of new entries.

I figured that the price for the extra hashing isn't significant since hash_32
is just a multiplication and a shift.

I'll modify the code to calculate the key just once.

> 2) Using hash_32 for uids is an interesting choice.  hash_32 discards
>    the low bits.  Last I checked for uids the low bits were the bits
>    that were most likely to be different and had the most entropy.
> 
>    I'm not certain how multiplying by the GOLDEN_RATION_PRIME_32 will
>    affect things but I would be surprised if it shifted all of the
>    randomness from the low bits to the high bits.

"Is hash_* good enough for our purpose?" - I was actually surprised that no one
raised that question during the RFC and assumed it was because everybody agreed
that it's indeed good enough.

I can offer the following: I'll write a small module that will hash 1...10000
into a hashtable which uses 7 bits (just like user_ns) and post the distribution
we'll get.

If the results of the above will be satisfactory we can avoid the discussion
about which hash function we should really be using. If not, I guess now is a
good time for that :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
