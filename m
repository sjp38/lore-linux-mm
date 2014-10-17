Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3126F6B006E
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 04:40:32 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so416569pab.40
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 01:40:31 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ao2si638483pad.52.2014.10.17.01.40.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Oct 2014 01:40:31 -0700 (PDT)
Date: Fri, 17 Oct 2014 10:40:11 +0200
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 4/5] mm: memcontrol: continue cache reclaim from offlined
 groups
Message-ID: <20141017084011.GC5641@esperanza>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
 <1413303637-23862-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1413303637-23862-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 14, 2014 at 12:20:36PM -0400, Johannes Weiner wrote:
> On cgroup deletion, outstanding page cache charges are moved to the
> parent group so that they're not lost and can be reclaimed during
> pressure on/inside said parent.  But this reparenting is fairly tricky
> and its synchroneous nature has led to several lock-ups in the past.
> 
> Since css iterators now also include offlined css, memcg iterators can
> be changed to include offlined children during reclaim of a group, and
> leftover cache can just stay put.
> 
> There is a slight change of behavior in that charges of deleted groups
> no longer show up as local charges in the parent.  But they are still
> included in the parent's hierarchical statistics.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 218 +-------------------------------------------------------
>  1 file changed, 1 insertion(+), 217 deletions(-)

I do like the stats :-) However, as I've already mentioned, on big
machines we can end up with hundred of thousands of dead css's.
Iterating over all of them during reclaim may result in noticeable lags.
One day we'll have to do something about that I guess.

Another issue is that AFAICT currently we can't have more than 64K
cgroups due to the MEM_CGROUP_ID_MAX limit. The limit exists, because we
use css ids for tagging swap entries and we don't want to spend too much
memory on this. May be, we should simply use the mem_cgroup pointer
instead of the css id?

OTOH, the reparenting code looks really ugly. And we can't easily
reparent swap and kmem. So I think it's a reasonable change.

Acked-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
