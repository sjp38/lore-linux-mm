Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 4FD706B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 18:48:09 -0500 (EST)
Date: Fri, 20 Jan 2012 15:48:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] idr: make idr_get_next() good for rcu_read_lock()
Message-Id: <20120120154807.c55c9ac7.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1201191247210.29542@eggly.anvils>
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
	<1326958401.1113.22.camel@edumazet-laptop>
	<CAOS58YO585NYMLtmJv3f9vVdadFqoWF+Y5vZ6Va=2qHELuePJA@mail.gmail.com>
	<1326979818.2249.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.LSU.2.00.1201191235330.29542@eggly.anvils>
	<alpine.LSU.2.00.1201191247210.29542@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Jan 2012 12:48:48 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Make one small adjustment to idr_get_next(): take the height from the
> top layer (stable under RCU) instead of from the root (unprotected by
> RCU), as idr_find() does: so that it can be used with RCU locking.
> Copied comment on RCU locking from idr_find().
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  lib/idr.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> --- 3.2.0+.orig/lib/idr.c	2012-01-04 15:55:44.000000000 -0800
> +++ 3.2.0+/lib/idr.c	2012-01-19 11:55:28.780206713 -0800
> @@ -595,8 +595,10 @@ EXPORT_SYMBOL(idr_for_each);
>   * Returns pointer to registered object with id, which is next number to
>   * given id. After being looked up, *@nextidp will be updated for the next
>   * iteration.
> + *
> + * This function can be called under rcu_read_lock(), given that the leaf
> + * pointers lifetimes are correctly managed.

Awkward comment.  It translates to "..., because the leaf pointers
lifetimes are correctly managed".

Is that what we really meant?  Or did we mean "..., provided the leaf
pointers lifetimes are correctly managed"?

Also, "pointers" should have been "pointer" or "pointer's"!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
