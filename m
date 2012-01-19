Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id E57046B005A
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 08:30:22 -0500 (EST)
Received: by wicr5 with SMTP id r5so6133928wic.14
        for <linux-mm@kvack.org>; Thu, 19 Jan 2012 05:30:21 -0800 (PST)
Message-ID: <1326979818.2249.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Subject: Re: [PATCH] memcg: restore ss->id_lock to spinlock, using RCU for
 next
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Jan 2012 14:30:18 +0100
In-Reply-To: <CAOS58YO585NYMLtmJv3f9vVdadFqoWF+Y5vZ6Va=2qHELuePJA@mail.gmail.com>
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
	 <1326958401.1113.22.camel@edumazet-laptop>
	 <CAOS58YO585NYMLtmJv3f9vVdadFqoWF+Y5vZ6Va=2qHELuePJA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Le jeudi 19 janvier 2012 A  04:28 -0800, Tejun Heo a A(C)crit :
> Hello,
> 
> On Wed, Jan 18, 2012 at 11:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Interesting, but should be a patch on its own.
> 
> Yeap, agreed.
> 
> > Maybe other idr users can benefit from your idea as well, if patch is
> > labeled  "idr: allow idr_get_next() from rcu_read_lock" or something...
> >
> > I suggest introducing idr_get_next_rcu() helper to make the check about
> > rcu cleaner.
> >
> > idr_get_next_rcu(...)
> > {
> >        WARN_ON_ONCE(!rcu_read_lock_held());
> >        return idr_get_next(...);
> > }
> 
> Hmmm... I don't know. Does having a separate set of interface help
> much?  It's easy to avoid/miss the test by using the other one.  If we
> really worry about it, maybe indicating which locking is to be used
> during init is better? We can remember the lockdep map and trigger
> WARN_ON_ONCE() if neither the lock or RCU read lock is held.


There is a rcu_dereference_raw(ptr) in idr_get_next()

This could be changed to rcu_dereference_check(ptr, condition) to get
lockdep support for free :)

[ condition would be the appropriate
lockdep_is_held(&the_lock_protecting_my_idr) or 'I use the rcu variant'
and I hold rcu_read_lock ]

This would need to add a 'condition' parameter to idr_gen_next(), but we
have very few users in kernel at this moment.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
