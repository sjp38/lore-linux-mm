Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 37CB96B011D
	for <linux-mm@kvack.org>; Thu,  8 May 2014 17:40:25 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id r20so394155wiv.15
        for <linux-mm@kvack.org>; Thu, 08 May 2014 14:40:24 -0700 (PDT)
Received: from mail-we0-x22a.google.com (mail-we0-x22a.google.com [2a00:1450:400c:c03::22a])
        by mx.google.com with ESMTPS id vn1si820662wjc.185.2014.05.08.14.40.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 14:40:24 -0700 (PDT)
Received: by mail-we0-f170.google.com with SMTP id u57so3142775wes.29
        for <linux-mm@kvack.org>; Thu, 08 May 2014 14:40:23 -0700 (PDT)
Subject: Re: [BUG] kmemleak on __radix_tree_preload
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20140508175222.GM19914@cmpxchg.org>
Date: Thu, 8 May 2014 22:40:22 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <C810FC85-01F4-4301-A4AA-B85380D4F2FB@arm.com>
References: <20140501184112.GH23420@cmpxchg.org> <1399431488.13268.29.camel@kjgkr> <20140507113928.GB17253@arm.com> <1399540611.13268.45.camel@kjgkr> <20140508092646.GA17349@arm.com> <1399541860.13268.48.camel@kjgkr> <20140508102436.GC17344@arm.com> <20140508150026.GA8754@linux.vnet.ibm.com> <20140508152946.GA10470@localhost> <20140508155330.GE8754@linux.vnet.ibm.com> <20140508175222.GM19914@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Jaegeuk Kim <jaegeuk.kim@samsung.com>, "Linux Kernel, Mailing List" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 8 May 2014, at 18:52, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, May 08, 2014 at 08:53:30AM -0700, Paul E. McKenney wrote:
>> On Thu, May 08, 2014 at 04:29:48PM +0100, Catalin Marinas wrote:
>>> On Thu, May 08, 2014 at 04:00:27PM +0100, Paul E. McKenney wrote:
>>>> On Thu, May 08, 2014 at 11:24:36AM +0100, Catalin Marinas wrote:
>>>>> My summary so far:
>>>>>=20
>>>>> - radix_tree_node reported by kmemleak as it cannot find any trace =
of it
>>>>>  when scanning the memory
>>>>> - at allocation time, radix_tree_node is memzero'ed by
>>>>>  radix_tree_node_ctor(). Given that node->rcu_head.func =3D=3D
>>>>>  radix_tree_node_rcu_free, my guess is that radix_tree_node_free() =
has
>>>>>  been called
>=20
> The constructor is called once when the slab is initially allocated,
> not on every object allocation.  The user is expected to return
> objects in a pristine form or overwrite fields on reallocation, so
> it's possible that the RCU values are left over from the previous
> allocation.

You are right, I missed this one.

>>>>> - some time later, kmemleak still hasn't received any callback for
>>>>>  kmem_cache_free(node). Possibly radix_tree_node_rcu_free() hasn't =
been
>>>>>  called either since node->count is not NULL.
>>>>>=20
>>>>> For RCU queued objects, kmemleak should still track references to =
them
>>>>> via rcu_sched_state and rcu_head members. But even if this went =
wrong, I
>>>>> would expect the object to be freed eventually and kmemleak =
notified (so
>>>>> just a temporary leak report which doesn't seem to be the case =
here).

[=85]

>>>> Of course, if the value of node->count is preventing call_rcu() =
from
>>>> being invoked in the first place, then the needed grace period =
won't
>>>> start, much less finish.  ;-)
>>>=20
>>> Given the rcu_head.func value, my assumption is that call_rcu() has
>>> already been called.
>>=20
>> Fair point -- given that it is a union, you would expect this field =
to
>> be overwritten upon reuse.
>=20
> .parent is overwritten immediately on reuse, but .private_data is
> actually unlikely to be used during the lifetime of the node.
>=20
> This could explain why .rcu.head.next is NULL like parent, and
> .private_data/.rcu.head.func is untouched and retains RCU stuff: to me
> it doesn't look like the node is lost in RCU-freeing, rather it was
> previously RCU freed and then lost somewhere after reallocation.

This would be a simpler explanation, and even simpler to test, just
reset rcu_head.func in radix_tree_node_rcu_free() before being returned
to the slab allocator.

Does the negative count give us any clue? This one is reset before
freeing the object.

Thanks,

Catalin=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
