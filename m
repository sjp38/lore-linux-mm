Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C46796B002B
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 15:04:29 -0500 (EST)
Date: Fri, 9 Nov 2012 20:04:28 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v6 25/29] memcg/sl[au]b: shrink dead caches
In-Reply-To: <20121108112120.fc964c29.akpm@linux-foundation.org>
Message-ID: <0000013ae6c60609-b5de43f3-1454-4827-920b-75285fe0f8ed-000000@email.amazonses.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com> <1351771665-11076-26-git-send-email-glommer@parallels.com> <20121105164813.2eba5ecb.akpm@linux-foundation.org> <509A0A04.2030503@parallels.com> <20121106231627.3610c908.akpm@linux-foundation.org>
 <509A2849.9090509@parallels.com> <20121107144612.e822986f.akpm@linux-foundation.org> <0000013ae1050e6f-7f908e0b-720a-4e68-a275-e5086a4f5c74-000000@email.amazonses.com> <20121108112120.fc964c29.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Thu, 8 Nov 2012, Andrew Morton wrote:

> > kmem_cache_shrink is also used internally. Its simply releasing unused
> > cached objects.
>
> Only in slub.  It could be removed outright from the others and
> simplified in slub.

Both SLAB and SLUB must purge their queues before closing/destroying a
cache. There is not much code that can be eliminated.

> > Because the core cache shrinking needs the slab caches to free up memory
> > from inodes and dentries. We could call kmem_cache_shrink at the end of
> > the shrink passes in vmscan. The price would be that the caches would have
> > to be repopulated when new allocations occur.
>
> Well, the shrinker shouldn't strips away all the cache.  It will perform
> a partial trim, the magnitude of which increases with perceived
> external memory pressure.

The partial trim of the objects cached by SLAB is performed in 2 second
intervals from the cache reaper.

We are talking here about flushing all
the cached objects from the inode and dentry cache etc in vmscan right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
