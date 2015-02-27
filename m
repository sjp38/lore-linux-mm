Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id D1E286B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 17:03:44 -0500 (EST)
Received: by iecrl12 with SMTP id rl12so34523283iec.2
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:03:44 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id o11si5334715icp.68.2015.02.27.14.03.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 14:03:44 -0800 (PST)
Received: by igbhl2 with SMTP id hl2so4098343igb.3
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 14:03:44 -0800 (PST)
Date: Fri, 27 Feb 2015 14:03:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm: remove GFP_THISNODE
In-Reply-To: <54F01E02.1090007@suse.cz>
Message-ID: <alpine.DEB.2.10.1502271335520.4718@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <54EED9A7.5010505@suse.cz> <alpine.DEB.2.10.1502261902580.24302@chino.kir.corp.google.com> <54F01E02.1090007@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, dev@openvswitch.org

On Fri, 27 Feb 2015, Vlastimil Babka wrote:

> Oh, right. I missed the new trigger. My sanity and career is saved!
> 

Haha.

> Well, no... the flags are still a mess. Aren't GFP_TRANSHUGE | __GFP_THISNODE
> allocations still problematic after this patch and 2/2? Those do include
> __GFP_WAIT (unless !defrag). So with only patch 2/2 without 1/2 they would match
> GFP_THISNODE and bail out (not good for khugepaged at least...).

With both patches: if __GFP_WAIT isn't set, either for page fault or 
khugepaged, then we always exit immediately from __alloc_pages_slowpath(): 
we can't try reclaim or compaction.  If __GFP_WAIT is set, then the new 
conditional fails, and the slowpath proceeds as we want it to with a 
zonelist that only includes local nodes because __GFP_THISNODE is set for 
node_zonelist() in alloc_pages_exact_node().  Those are the only zones 
that get_page_from_freelist() gets to iterate over.

With only this patch: we still have the problem that is fixed with the 
second patch, thp is preferred on the node of choice but can be allocated 
from any other node for fallback because the allocations lack 
__GFP_THISNODE.

> With both
> patches they won't bail out and __GFP_NO_KSWAPD will prevent most of the stuff
> described above, including clearing ALLOC_CPUSET.

Yeah, ALLOC_CPUSET is never cleared for thp allocations because atomic == 
false for thp, regardless of this series.

> But __cpuset_node_allowed()
> will allow it to allocate anywhere anyway thanks to the newly passed
> __GFP_THISNODE, which would be a regression of what b104a35d32 fixed... unless
> I'm missing something else that prevents it, which wouldn't surprise me at all.
> 
> There's this outdated comment:
> 
>  * The __GFP_THISNODE placement logic is really handled elsewhere,
>  * by forcibly using a zonelist starting at a specified node, and by
>  * (in get_page_from_freelist()) refusing to consider the zones for
>  * any node on the zonelist except the first.  By the time any such
>  * calls get to this routine, we should just shut up and say 'yes'.
> 
> AFAIK the __GFP_THISNODE zonelist contains *only* zones from the single node and
> there's no other "refusing".

Yes, __cpuset_node_allowed() is never called for a zone from any other 
node when __GFP_THISNODE is passed because of node_zonelist().  It's 
pointless to iterate over those zones since the allocation wants to fail 
instead of allocate on them.

Do you see any issues with either patch 1/2 or patch 2/2 besides the 
s/GFP_TRANSHUGE/GFP_THISNODE/ that is necessary on the changelog?

> And I don't really see why __GFP_THISNODE should
> have this exception, it feels to me like "well we shouldn't reach this but we
> are not sure, so let's play it safe". So maybe we could just remove this
> exception? I don't think any other user of __GFP_THISNODE | __GFP_WAIT user
> relies on this allowed memset violation?
> 

Since this function was written, there were other callers to 
cpuset_{node,zone}_allowed_{soft,hard}wall() that may have required it.  I 
looked at all the current callers of cpuset_zone_allowed() and they don't 
appear to need this "exception" (slub calls node_zonelist() itself for the 
iteration and slab never calls it for __GFP_THISNODE).  So, yeah, I think 
it can be removed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
