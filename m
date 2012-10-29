Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 279046B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 14:16:51 -0400 (EDT)
Date: Mon, 29 Oct 2012 14:16:48 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 15/16] openvswitch: use new hashtable implementation
Message-ID: <20121029181648.GB20796@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-15-git-send-email-levinsasha928@gmail.com> <20121029132931.GC16391@Krystal> <CA+1xoqfRGhPaBEVh228O5_295bWh8FmcyLSOwq8VE5Dm7i3JHg@mail.gmail.com> <20121029155957.GB18834@Krystal> <CA+1xoqcr5xmOkDfqL3P84CNdotOALOhiLRkJjsPCZzijSQUF6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+1xoqcr5xmOkDfqL3P84CNdotOALOhiLRkJjsPCZzijSQUF6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> On Mon, Oct 29, 2012 at 11:59 AM, Mathieu Desnoyers
> <mathieu.desnoyers@efficios.com> wrote:
> > * Sasha Levin (levinsasha928@gmail.com) wrote:
> >> Hi Mathieu,
> >>
> >> On Mon, Oct 29, 2012 at 9:29 AM, Mathieu Desnoyers
> >> <mathieu.desnoyers@efficios.com> wrote:
> >> > * Sasha Levin (levinsasha928@gmail.com) wrote:
> >> > [...]
> >> >> -static struct hlist_head *hash_bucket(struct net *net, const char *name)
> >> >> -{
> >> >> -     unsigned int hash = jhash(name, strlen(name), (unsigned long) net);
> >> >> -     return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
> >> >> -}
> >> >> -
> >> >>  /**
> >> >>   *   ovs_vport_locate - find a port that has already been created
> >> >>   *
> >> >> @@ -84,13 +76,12 @@ static struct hlist_head *hash_bucket(struct net *net, const char *name)
> >> >>   */
> >> >>  struct vport *ovs_vport_locate(struct net *net, const char *name)
> >> >>  {
> >> >> -     struct hlist_head *bucket = hash_bucket(net, name);
> >> >>       struct vport *vport;
> >> >>       struct hlist_node *node;
> >> >> +     int key = full_name_hash(name, strlen(name));
> >> >>
> >> >> -     hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
> >> >> -             if (!strcmp(name, vport->ops->get_name(vport)) &&
> >> >> -                 net_eq(ovs_dp_get_net(vport->dp), net))
> >> >> +     hash_for_each_possible_rcu(dev_table, vport, node, hash_node, key)
> >> >
> >> > Is applying hash_32() on top of full_name_hash() needed and expected ?
> >>
> >> Since this was pointed out in several of the patches, I'll answer it
> >> just once here.
> >>
> >> I've intentionally "allowed" double hashing with hash_32 to keep the
> >> code simple.
> >>
> >> hash_32() is pretty simple and gcc optimizes it to be almost nothing,
> >> so doing that costs us a multiplication and a shift. On the other
> >> hand, we benefit from keeping our code simple - how would we avoid
> >> doing this double hash? adding a different hashtable function for
> >> strings? or a new function for already hashed keys? I think we benefit
> >> a lot from having to mul/shr instead of adding extra lines of code
> >> here.
> >
> > This could be done, as I pointed out in another email within this
> > thread, by changing the "key" argument from add/for_each_possible to an
> > expected "hash" value, and let the caller invoke hash_32() if they want.
> > I doubt this would add a significant amount of complexity for users of
> > this API, but would allow much more flexibility to choose hash
> > functions.
> 
> Most callers do need to do the hashing though, so why add an
> additional step for all callers instead of doing another hash_32 for
> the ones that don't really need it?
> 
> Another question is why do you need flexibility? I think that
> simplicity wins over flexibility here.

I usually try to make things as simple as possible, but not simplistic
compared to the problem tackled. In this case, I would ask the following
question: by standardizing the hash function of all those pieces of
kernel infrastructure to "hash_32()", including submodules part of the
kernel network infrastructure, parts of the kernel that can be fed
values coming from user-space (through the VFS), how can you guarantee
that hash_32() won't be the cause of a DoS attack based on the fact that
this algorithm is a) known by an attacker, and b) does not have any
randomness. It's been a recent trend to perform DoS attacks on poorly
implemented hashing functions.

This is just one example in an attempt to show why different hash table
users may have different constraints: for a hash table entirely
populated by keys generated internally by the kernel, a random seed
might not be required, but for cases where values are fed by user-space
and from the NIC, I would argue that flexibility to implement a
randomizable hash function beats implementation simplicity any time.

And you could keep the basic use-case simple by providing hints to the
hash_32()/hash_64()/hash_ulong() helpers in comments.

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
