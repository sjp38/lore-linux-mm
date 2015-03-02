Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 48D826B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 11:02:15 -0500 (EST)
Received: by wghl2 with SMTP id l2so34389408wgh.9
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 08:02:14 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cs8si23066856wjb.107.2015.03.02.08.02.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 08:02:12 -0800 (PST)
Message-ID: <54F48980.3090008@suse.cz>
Date: Mon, 02 Mar 2015 17:02:08 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2 1/3] mm: remove GFP_THISNODE
References: <alpine.DEB.2.10.1502251621010.10303@chino.kir.corp.google.com> <alpine.DEB.2.10.1502271415510.7225@chino.kir.corp.google.com> <54F469C1.9090601@suse.cz> <alpine.DEB.2.11.1503020944200.5540@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1503020944200.5540@gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Pravin Shelar <pshelar@nicira.com>, Jarno Rajahalme <jrajahalme@nicira.com>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, dev@openvswitch.org

On 03/02/2015 04:46 PM, Christoph Lameter wrote:
> On Mon, 2 Mar 2015, Vlastimil Babka wrote:
> 
>> So it would be IMHO better for longer-term maintainability to have the
>> relevant __GFP_THISNODE callers pass also __GFP_NO_KSWAPD to denote these
>> opportunistic allocation attempts, instead of having this subtle semantic
> 
> You are thinking about an opportunistic allocation attempt in SLAB?
> 
> AFAICT SLAB allocations should trigger reclaim.
> 

Well, let me quote your commit 952f3b51beb5:

--------
commit 952f3b51beb592f3f1de15adcdef802fc086ea91
Author: Christoph Lameter <clameter@sgi.com>
Date:   Wed Dec 6 20:33:26 2006 -0800

    [PATCH] GFP_THISNODE must not trigger global reclaim
    
    The intent of GFP_THISNODE is to make sure that an allocation occurs on a
    particular node.  If this is not possible then NULL needs to be returned so
    that the caller can choose what to do next on its own (the slab allocator
    depends on that).
    
    However, GFP_THISNODE currently triggers reclaim before returning a failure
    (GFP_THISNODE means GFP_NORETRY is set).  If we have over allocated a node
    then we will currently do some reclaim before returning NULL.  The caller
    may want memory from other nodes before reclaim should be triggered.  (If
    the caller wants reclaim then he can directly use __GFP_THISNODE instead).
    
    There is no flag to avoid reclaim in the page allocator and adding yet
    another GFP_xx flag would be difficult given that we are out of available
    flags.
    
    So just compare and see if all bits for GFP_THISNODE (__GFP_THISNODE,
    __GFP_NORETRY and __GFP_NOWARN) are set.  If so then we return NULL before
    waking up kswapd.
    
    Signed-off-by: Christoph Lameter <clameter@sgi.com>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5d123b3..dc8753b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1151,6 +1151,17 @@ restart:
        if (page)
                goto got_pg;
 
+       /*
+        * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
+        * __GFP_NOWARN set) should not cause reclaim since the subsystem
+        * (f.e. slab) using GFP_THISNODE may choose to trigger reclaim
+        * using a larger set of nodes after it has established that the
+        * allowed per node queues are empty and that nodes are
+        * over allocated.
+        */
+       if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+               goto nopage;
+
        for (z = zonelist->zones; *z; z++)
                wakeup_kswapd(*z, order);
--------

So it seems to me that *at least some* allocations in slab are supposed
to work like this? Of course it's possible that since 2006, more
allocation sites in slab started passing GFP_THISNODE without realizing
this semantics. In that case, such sites should be fixed. (I think David
already mentioned some in this thread?)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
