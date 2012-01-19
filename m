Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id E20046B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 02:00:00 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1FE1A3EE0C3
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:59:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0578A45DE58
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:59:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CC56C45DE52
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:59:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF8221DB803B
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:59:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E18B1DB8040
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:59:58 +0900 (JST)
Date: Thu, 19 Jan 2012 15:58:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: restore ss->id_lock to spinlock, using RCU for
 next
Message-Id: <20120119155839.ad57620c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 18 Jan 2012 22:05:12 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Commit c1e2ee2dc436 "memcg: replace ss->id_lock with a rwlock" has
> now been seen to cause the unfair behavior we should have expected
> from converting a spinlock to an rwlock: softlockup in cgroup_mkdir(),
> whose get_new_cssid() is waiting for the wlock, while there are 19
> tasks using the rlock in css_get_next() to get on with their memcg
> workload (in an artificial test, admittedly).  Yet lib/idr.c was
> made suitable for RCU way back.
> 
> 1. Revert that commit, restoring ss->id_lock to a spinlock.
> 
> 2. Make one small adjustment to idr_get_next(): take the height from
> the top layer (stable under RCU) instead of from the root (unprotected
> by RCU), as idr_find() does.
> 
> 3. Remove lock and unlock around css_get_next()'s call to idr_get_next():
> memcg iterators (only users of css_get_next) already did rcu_read_lock(),
> and comment demands that, but add a WARN_ON_ONCE to make sure of it.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you ! This seems much better.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
