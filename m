Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 28B7B6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 02:28:32 -0500 (EST)
Message-ID: <4F17C6B7.5020606@cn.fujitsu.com>
Date: Thu, 19 Jan 2012 15:31:03 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: restore ss->id_lock to spinlock, using RCU for
 next
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hugh Dickins wrote:
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

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

> ---
> 
>  include/linux/cgroup.h |    2 +-
>  kernel/cgroup.c        |   19 +++++++++----------
>  lib/idr.c              |    4 ++--
>  3 files changed, 12 insertions(+), 13 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
