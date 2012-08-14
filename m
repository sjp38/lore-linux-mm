Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 7552E6B005A
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 00:27:49 -0400 (EDT)
Received: by qafk30 with SMTP id k30so3391878qaf.14
        for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:27:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1344861970-9999-1-git-send-email-glommer@parallels.com>
References: <1344861970-9999-1-git-send-email-glommer@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 13 Aug 2012 21:27:27 -0700
Message-ID: <CAHH2K0bJumAy43BjP3XxfrZz6eMQFKzTY-dw26Aw17zFXehtfQ@mail.gmail.com>
Subject: Re: [PATCH] execute the whole memcg freeing in rcu callback
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Aug 13, 2012 at 5:46 AM, Glauber Costa <glommer@parallels.com> wrote:
> A lot of the initialization we do in mem_cgroup_create() is done with
> softirqs enabled. This include grabbing a css id, which holds
> &ss->id_lock->rlock, and the per-zone trees, which holds
> rtpz->lock->rlock. All of those signal to the lockdep mechanism that
> those locks can be used in SOFTIRQ-ON-W context. This means that the
> freeing of memcg structure must happen in a compatible context,
> otherwise we'll get a deadlock.
>
> The reference counting mechanism we use allows the memcg structure to be
> freed later and outlive the actual memcg destruction from the
> filesystem. However, we have little, if any, means to guarantee in which
> context the last memcg_put will happen. The best we can do is test it
> and try to make sure no invalid context releases are happening. But as
> we add more code to memcg, the possible interactions grow in number and
> expose more ways to get context conflicts.
>
> Context-related problems already appeared for static branches
> destruction, since their locking forced us to disable them from process
> context, which we could not always guarantee. Now that we're trying to
> add kmem controller, the possibilities of where the freeing can be
> triggered from just increases.
>
> Greg Thelen reported a bug with that patchset applied that would trigger
> if a task would hold a reference to a memcg through its kmem counter.
> This would mean that killing that task would eventually get us to
> __mem_cgroup_free() after dropping the last kernel page reference, in an
> invalid IN-SOFTIRQ-W.
>
> We already moved a part of the freeing to a worker thread to be
> context-safe for the static branches disabling. Although we could move
> the new offending part to such a place as well, I see no reason not
> to do it for the whole freeing action. I consider this to be the safe
> choice.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reported-by: Greg Thelen <gthelen@google.com>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Johannes Weiner <hannes@cmpxchg.org>

The problem I reported is fixed by this patch.  Thanks.

Tested-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
