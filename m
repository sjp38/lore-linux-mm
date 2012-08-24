Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7D0A76B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 18:59:03 -0400 (EDT)
Received: by bkcjc3 with SMTP id jc3so859626bkc.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2012 15:59:01 -0700 (PDT)
Message-ID: <5038074D.300@gmail.com>
Date: Sat, 25 Aug 2012 00:59:25 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-2-git-send-email-levinsasha928@gmail.com> <20120822180138.GA19212@google.com> <50357840.5020201@gmail.com> <20120823200456.GD14962@google.com> <5037DA47.9010306@gmail.com> <20120824195941.GC21325@google.com> <5037E00B.6090606@gmail.com> <20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com> <20120824212348.GK21325@google.com>
In-Reply-To: <20120824212348.GK21325@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

>> Why do we need hash_head/hash_for_each_head()? I haven't stumbled on a place yet
>> that needed direct access to the bucket itself.
> 
> Because whole hash table walking is much less common and we can avoid
> another full set of iterators.

I don't agree. Out of 32 places which now use a hashtable iterator of some kind,
12 of them (38%) walk the entire table.

The thing is that usually data structures are indexable by more than one key, so
usually hashtables are fully walked in cold paths to look for different keys.

Take kernel/workqueue.c for example: There are 4 places which do a key lookup
(find_worker_executing_work()) and 3 places which fully walk the entire table
(for_each_busy_worker()).

>> This basically means 11 macros/functions that would let us have full
>> encapsulation and will make it very easy for future implementations to work with
>> this API instead of making up a new one. It's also not significantly (+~2-3)
>> more than the ones you listed.
> 
> I'm not sure whether full encapsulation is a good idea for trivial
> hashtable.  For higher level stuff, sure but at this level I think
> benefits coming from known obvious implementation can be larger.
> e.g. suppose the caller knows certain entries to be way colder than
> others and wants to put them at the end of the chain.

Thats the thing, the amount of things of things you can do with a given bucket
is very limited. You can't add entries to any point besides the head (without
walking the entire list).

Basically you can do only two things with a bucket:

 - Add something to it at a very specific place.
 - Walk it

So I don't understand whats the point in exposing the internal structure of the
hashtable if there's nothing significant that can be gained from it by the user.

> 
> So, I think implmenting the minimal set of helpers which reflect the
> underlying trivial implementation explicitly could actually be better
> even when discounting the reduced number of wrappers.
> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
