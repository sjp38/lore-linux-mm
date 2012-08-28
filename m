Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 417AA6B0098
	for <linux-mm@kvack.org>; Tue, 28 Aug 2012 06:11:51 -0400 (EDT)
Date: Tue, 28 Aug 2012 06:11:48 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive
	hashtable
Message-ID: <20120828101148.GA21683@Krystal>
References: <5037DA47.9010306@gmail.com> <20120824195941.GC21325@google.com> <5037E00B.6090606@gmail.com> <20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com> <20120824212348.GK21325@google.com> <5038074D.300@gmail.com> <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal> <503C95E4.3010000@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <503C95E4.3010000@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> On 08/25/2012 06:24 AM, Mathieu Desnoyers wrote:
> > * Tejun Heo (tj@kernel.org) wrote:
> >> Hello,
> >>
> >> On Sat, Aug 25, 2012 at 12:59:25AM +0200, Sasha Levin wrote:
> >>> Thats the thing, the amount of things of things you can do with a given bucket
> >>> is very limited. You can't add entries to any point besides the head (without
> >>> walking the entire list).
> >>
> >> Kinda my point.  We already have all the hlist*() interface to deal
> >> with such cases.  Having something which is evidently the trivial
> >> hlist hashtable and advertises as such in the interface can be
> >> helpful.  I think we need that more than we need anything fancy.
> >>
> >> Heh, this is a debate about which one is less insignificant.  I can
> >> see your point.  I'd really like to hear what others think on this.
> >>
> >> Guys, do we want something which is evidently trivial hlist hashtable
> >> which can use hlist_*() API directly or do we want something better
> >> encapsulated?
> > 
> > My 2 cents, FWIW: I think this specific effort should target a trivially
> > understandable API and implementation, for use-cases where one would be
> > tempted to reimplement his own trivial hash table anyway. So here
> > exposing hlist internals, with which kernel developers are already
> > familiar, seems like a good approach in my opinion, because hiding stuff
> > behind new abstraction might make the target users go away.
> > 
> > Then, as we see the need, we can eventually merge a more elaborate hash
> > table with poneys and whatnot, but I would expect that the trivial hash
> > table implementation would still be useful. There are of course very
> > compelling reasons to use a more featureful hash table: automatic
> > resize, RT-aware updates, scalable updates, etc... but I see a purpose
> > for a trivial implementation. Its primary strong points being:
> > 
> > - it's trivially understandable, so anyone how want to be really sure
> >   they won't end up debugging the hash table instead of their
> >   work-in-progress code can have a full understanding of it,
> > - it has few dependencies, which makes it easier to understand and
> >   easier to use in some contexts (e.g. early boot).
> > 
> > So I'm in favor of not overdoing the abstraction for this trivial hash
> > table, and honestly I would rather prefer that this trivial hash table
> > stays trivial. A more elaborate hash table should probably come as a
> > separate API.
> > 
> > Thanks,
> > 
> > Mathieu
> > 
> 
> Alright, let's keep it simple then.
> 
> I do want to keep the hash_for_each[rcu,safe] family though.

Just a thought: if the API offered by the simple hash table focus on
providing a mechanism to find the hash bucket to which belongs the hash
chain containing the key looked up, and then expects the user to use the
hlist API to iterate on the chain (with or without the hlist _rcu
variant), then it might seem consistent that a helper providing
iteration over the entire table would actually just provide iteration on
all buckets, and let the user call the hlist for each iterator for each
node within the bucket, e.g.:

struct hlist_head *head;
struct hlist_node *pos;

hash_for_each_bucket(ht, head) {
        hlist_for_each(pos, head) {
                ...
        }
}

That way you only have to provide one single macro
(hash_for_each_bucket), and rely on the already existing:

- hlist_for_each_entry
- hlist_for_each_safe
- hlist_for_each_entry_rcu
- hlist_for_each_safe_rcu
  .....

and various flavors that can appear in the future without duplicating
this API. So you won't even have to create _rcu, _safe, nor _safe_rcu
versions of the hash_for_each_bucket macro.

Thoughts ?

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
