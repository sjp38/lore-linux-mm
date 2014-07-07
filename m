Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id D91166B0036
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 10:26:26 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id q59so4505680wes.40
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 07:26:26 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ni12si41458232wic.49.2014.07.07.07.25.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 07:25:45 -0700 (PDT)
Date: Mon, 7 Jul 2014 10:25:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 0/8] memcg: reparent kmem on css offline
Message-ID: <20140707142506.GB1149@cmpxchg.org>
References: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1404733720.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Vladimir,

On Mon, Jul 07, 2014 at 04:00:05PM +0400, Vladimir Davydov wrote:
> Hi,
> 
> This patch set introduces re-parenting of kmem charges on memcg css
> offline. The idea lying behind it is very simple - instead of pointing
> from kmem objects (kmem caches, non-slab kmem pages) directly to the
> memcg which they are charged against, we make them point to a proxy
> object, mem_cgroup_kmem_context, which, in turn, points to the memcg
> which it belongs to. As a result on memcg offline, it's enough to only
> re-parent the memcg's mem_cgroup_kmem_context.

The motivation for this was to clear out all references to a memcg by
the time it's offlined, so that the unreachable css can be freed soon.

However, recent cgroup core changes further disconnected the css from
the cgroup object itself, so it's no longer as urgent to free the css.

In addition, Tejun made offlined css iterable and split css_tryget()
and css_tryget_online(), which would allow memcg to pin the css until
the last charge is gone while continuing to iterate and reclaim it on
hierarchical pressure, even after it was offlined.

This would obviate the need for reparenting as a whole, not just kmem
pages, but even remaining page cache.  Michal already obsoleted the
force_empty knob that reparents as a fallback, and whether the cache
pages are in the parent or in a ghost css after cgroup deletion does
not make a real difference from a user point of view, they still get
reclaimed when the parent experiences pressure.

You could then reap dead slab caches as part of the regular per-memcg
slab scanning in reclaim, without having to resort to auxiliary lists,
vmpressure events etc.

I think it would save us a lot of code and complexity.  You want
per-memcg slab scanning *anyway*, all we'd have to change in the
existing code would be to pin the css until the LRUs and kmem caches
are truly empty, and switch mem_cgroup_iter() to css_tryget().

Would this make sense to you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
