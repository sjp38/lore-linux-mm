Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 32A936B0031
	for <linux-mm@kvack.org>; Thu, 30 Jan 2014 07:30:49 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id y10so6006801wgg.8
        for <linux-mm@kvack.org>; Thu, 30 Jan 2014 04:30:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw3si2905386wjb.23.2014.01.30.04.30.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Jan 2014 04:30:46 -0800 (PST)
Date: Thu, 30 Jan 2014 13:30:44 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/4] memcg: Low-limit reclaim
Message-ID: <20140130123044.GB13509@dhcp22.suse.cz>
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
 <xr93sis6obb5.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xr93sis6obb5.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Wed 29-01-14 11:08:46, Greg Thelen wrote:
[...]
> The series looks useful.  We (Google) have been using something similar.
> In practice such a low_limit (or memory guarantee), doesn't nest very
> well.
> 
> Example:
>   - parent_memcg: limit 500, low_limit 500, usage 500
>     1 privately charged non-reclaimable page (e.g. mlock, slab)
>   - child_memcg: limit 500, low_limit 500, usage 499

I am not sure this is a good example. Your setup basically say that no
single page should be reclaimed. I can imagine this might be useful in
some cases and I would like to allow it but it sounds too extreme (e.g.
a load which would start trashing heavily once the reclaim starts and it
makes more sense to start it again rather than crowl - think about some
mathematical simulation which might diverge).
 
> If a streaming file cache workload (e.g. sha1sum) starts gobbling up
> page cache it will lead to an oom kill instead of reclaiming. 

Does it make any sense to protect all of such memory although it is
easily reclaimable?

> One could
> argue that this is working as intended because child_memcg was promised
> 500 but can only get 499.  So child_memcg is oom killed rather than
> being forced to operate below its promised low limit.
> 
> This has led to various internal workarounds like:
> - don't charge any memory to interior tree nodes (e.g. parent_memcg);
>   only charge memory to cgroup leafs.  This gets tricky when dealing
>   with reparented memory inherited to parent from child during cgroup
>   deletion.

Do those need any protection at all?

> - don't set low_limit on non leafs (e.g. do not set low limit on
>   parent_memcg).  This constrains the cgroup layout a bit.  Some
>   customers want to purchase $MEM and setup their workload with a few
>   child cgroups.  A system daemon hands out $MEM by setting low_limit
>   for top-level containers (e.g. parent_memcg).  Thereafter such
>   customers are able to partition their workload with sub memcg below
>   child_memcg.  Example:
>      parent_memcg
>          \
>           child_memcg
>             /     \
>         server   backup

I think that the low_limit makes sense where you actually want to
protect something from reclaim. And backup sounds like a bad fit for
that.

>   Thereafter customers often want some weak isolation between server and
>   backup.  To avoid undesired oom kills the server/backup isolation is
>   provided with a softer memory guarantee (e.g. soft_limit).  The soft
>   limit acts like the low_limit until priority becomes desperate.

Johannes was already suggesting that the low_limit should allow for a
weaker semantic as well. I am not very much inclined to that but I can
leave with a knob which would say oom_on_lowlimit (on by default but
allowed to be set to 0). We would fallback to the full reclaim if
no groups turn out to be reclaimable.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
