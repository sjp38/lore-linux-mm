Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 528F76B0087
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 17:09:16 -0500 (EST)
Date: Fri, 30 Nov 2012 09:09:14 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC, PATCH 00/19] Numa aware LRU lists and shrinkers
Message-ID: <20121129220914.GE6434@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <m24nk8grlr.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m24nk8grlr.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: glommer@parallels.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Thu, Nov 29, 2012 at 11:02:24AM -0800, Andi Kleen wrote:
> Dave Chinner <david@fromorbit.com> writes:
> >
> > Comments, thoughts and flames all welcome.
> 
> Doing the reclaim per CPU sounds like a big change in the VM balance. 

It's per node, not per CPU. And AFAICT, it hasn't changed the
balance of page cache vs inode/dentry caches under general, global
workloads at all.

> Doesn't this invalidate some zone reclaim mode settings?

No, because zone reclaim is per-node and the shrinkers now can
reclaim just from a single node. i.e. the behaviour is now better
suited to the aims of zone reclaim which is to free memory from a
single, targetted node. Indeed, I removed a hack in the zone reclaim
code that sprayed slab reclaim across the entire machine until
sufficient objects had been freed from the target node....

> How did you validate all this?

fakenuma setups, various workloads that generate even dentry/slab
cache loadings across all nodes, adding page cache pressure on a
single node, watching slab reclaim from a single node. that sort of
thing.

I haven't really done any performance testing other than "not
obviously slower". There's no point optimising anything before
there's any sort of agreement as to whether this is the right
approach to take or not....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
