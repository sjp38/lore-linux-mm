Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id AFBAB6B005A
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:54:15 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so5117870iak.14
        for <linux-mm@kvack.org>; Mon, 29 Oct 2012 08:54:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121029130736.GF11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-10-git-send-email-levinsasha928@gmail.com>
 <20121029124655.GD11733@Krystal> <20121029130736.GF11733@Krystal>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 29 Oct 2012 11:53:54 -0400
Message-ID: <CA+1xoqfxgB+8BybPpf+jwT-ObfGPxnbKvkz1MUMuJuR8NDSNaw@mail.gmail.com>
Subject: Re: [PATCH v7 10/16] dlm: use new hashtable implementation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Mon, Oct 29, 2012 at 9:07 AM, Mathieu Desnoyers
<mathieu.desnoyers@efficios.com> wrote:
> * Mathieu Desnoyers (mathieu.desnoyers@efficios.com) wrote:
>> * Sasha Levin (levinsasha928@gmail.com) wrote:
>> [...]
>> > @@ -158,34 +159,21 @@ static int dlm_allow_conn;
>> >  static struct workqueue_struct *recv_workqueue;
>> >  static struct workqueue_struct *send_workqueue;
>> >
>> > -static struct hlist_head connection_hash[CONN_HASH_SIZE];
>> > +static struct hlist_head connection_hash[CONN_HASH_BITS];
>> >  static DEFINE_MUTEX(connections_lock);
>> >  static struct kmem_cache *con_cache;
>> >
>> >  static void process_recv_sockets(struct work_struct *work);
>> >  static void process_send_sockets(struct work_struct *work);
>> >
>> > -
>> > -/* This is deliberately very simple because most clusters have simple
>> > -   sequential nodeids, so we should be able to go straight to a connection
>> > -   struct in the array */
>> > -static inline int nodeid_hash(int nodeid)
>> > -{
>> > -   return nodeid & (CONN_HASH_SIZE-1);
>> > -}
>>
>> There is one thing I dislike about this change: you remove a useful
>> comment. It's good to be informed of the reason why a direct mapping
>> "value -> hash" without any dispersion function is preferred here.

Yes, I've removed the comment because it's no longer true with the patch :)

> And now that I come to think of it: you're changing the behavior : you
> will now use a dispersion function on the key, which goes against the
> intent expressed in this comment.

The comment gave us the information that nodeids are mostly
sequential, we no longer need to rely on that.

> It might be good to change hash_add(), hash_add_rcu(),
> hash_for_each_possible*() key parameter for a "hash" parameter, and let
> the caller provide the hash value computed by the function they like as
> parameter, rather than enforcing hash_32/hash_64.

Why? We already proved that hash_32() is more than enough as a hashing
function, why complicate things?

Even doing hash_32() on top of another hash is probably a good idea to
keep things simple.

Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
