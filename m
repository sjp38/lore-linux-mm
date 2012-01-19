Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 22FDD6B005C
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 07:28:37 -0500 (EST)
Received: by wicr5 with SMTP id r5so6073124wic.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 04:28:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326958401.1113.22.camel@edumazet-laptop>
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
	<1326958401.1113.22.camel@edumazet-laptop>
Date: Thu, 19 Jan 2012 04:28:35 -0800
Message-ID: <CAOS58YO585NYMLtmJv3f9vVdadFqoWF+Y5vZ6Va=2qHELuePJA@mail.gmail.com>
Subject: Re: [PATCH] memcg: restore ss->id_lock to spinlock, using RCU for next
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Jan 18, 2012 at 11:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wro=
te:
> Interesting, but should be a patch on its own.

Yeap, agreed.

> Maybe other idr users can benefit from your idea as well, if patch is
> labeled =A0"idr: allow idr_get_next() from rcu_read_lock" or something...
>
> I suggest introducing idr_get_next_rcu() helper to make the check about
> rcu cleaner.
>
> idr_get_next_rcu(...)
> {
> =A0 =A0 =A0 =A0WARN_ON_ONCE(!rcu_read_lock_held());
> =A0 =A0 =A0 =A0return idr_get_next(...);
> }

Hmmm... I don't know. Does having a separate set of interface help
much?  It's easy to avoid/miss the test by using the other one.  If we
really worry about it, maybe indicating which locking is to be used
during init is better? We can remember the lockdep map and trigger
WARN_ON_ONCE() if neither the lock or RCU read lock is held.

Thanks.

--=20
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
