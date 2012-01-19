Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id CE72B6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:47:12 -0500 (EST)
Received: by ggnk5 with SMTP id k5so356662ggn.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 12:47:12 -0800 (PST)
Date: Thu, 19 Jan 2012 12:46:56 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] memcg: restore ss->id_lock to spinlock, using RCU for
 next
In-Reply-To: <1326979818.2249.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.LSU.2.00.1201191235330.29542@eggly.anvils>
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils> <1326958401.1113.22.camel@edumazet-laptop> <CAOS58YO585NYMLtmJv3f9vVdadFqoWF+Y5vZ6Va=2qHELuePJA@mail.gmail.com> <1326979818.2249.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1945244502-1327006025=:29542"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1945244502-1327006025=:29542
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 19 Jan 2012, Eric Dumazet wrote:
> Le jeudi 19 janvier 2012 =C3=A0 04:28 -0800, Tejun Heo a =C3=A9crit :
> > Hello,
> >=20
> > On Wed, Jan 18, 2012 at 11:33 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > > Interesting, but should be a patch on its own.
> >=20
> > Yeap, agreed.

Okay, in that case I'd better split into three (idr, revert, remove lock).
I'll send those three in a moment.  I've also slipped an RCU comment from
idr_find into idr_get_next, and put the Acks in all three.

> >=20
> > > Maybe other idr users can benefit from your idea as well, if patch is
> > > labeled  "idr: allow idr_get_next() from rcu_read_lock" or something.=
=2E.
> > >
> > > I suggest introducing idr_get_next_rcu() helper to make the check abo=
ut
> > > rcu cleaner.
> > >
> > > idr_get_next_rcu(...)
> > > {
> > >        WARN_ON_ONCE(!rcu_read_lock_held());
> > >        return idr_get_next(...);
> > > }
> >=20
> > Hmmm... I don't know. Does having a separate set of interface help
> > much?  It's easy to avoid/miss the test by using the other one.  If we
> > really worry about it, maybe indicating which locking is to be used
> > during init is better? We can remember the lockdep map and trigger
> > WARN_ON_ONCE() if neither the lock or RCU read lock is held.
>=20
>=20
> There is a rcu_dereference_raw(ptr) in idr_get_next()
>=20
> This could be changed to rcu_dereference_check(ptr, condition) to get
> lockdep support for free :)
>=20
> [ condition would be the appropriate
> lockdep_is_held(&the_lock_protecting_my_idr) or 'I use the rcu variant'
> and I hold rcu_read_lock ]
>=20
> This would need to add a 'condition' parameter to idr_gen_next(), but we
> have very few users in kernel at this moment.

idr_get_next() was introduced for memcg, and has only one other user
user in the tree (drivers/mtd/mtdcore.c, which uses a mutex to lock it).
With the RCU fix, idr_get_next() becomes very much like idr_find().
I'll leave any fiddling with their interfaces to you guys.

Hugh
--8323584-1945244502-1327006025=:29542--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
