Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB156B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:49:17 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so2719804eek.21
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:49:16 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e48si18202635eeh.197.2013.12.11.01.49.16
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 01:49:16 -0800 (PST)
Date: Wed, 11 Dec 2013 09:49:12 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20131211094912.GX11295@suse.de>
References: <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
 <20131204054533.GZ3556@cmpxchg.org>
 <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
 <20131205025026.GA26777@htj.dyndns.org>
 <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
 <20131206190105.GE13373@htj.dyndns.org>
 <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com>
 <20131210215037.GB9143@htj.dyndns.org>
 <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, Dec 10, 2013 at 03:55:48PM -0800, David Rientjes wrote:
> > Okay, are you saying that userland OOM handlers will be able to dip
> > into kernel reserve memory?  Maybe I'm mistaken but you realize that
> > that reserve is there to make things like task exits work under OOM
> > conditions, right?  The only way userland OOM handlers as you describe
> > would work would be creating a separate reserve for them.
> > 
> 
> Yes, PF_OOM_HANDLER processes would be able to allocate this amount as 
> specified by memory.oom_reserve_in_bytes below the per-zone watermarks and 
> the amount of reserves can already be controlled via min_free_kbytes, 
> which we already increase internally for thp.

THP increased min_free_kbytes for external fragmentation control as
it reduces the amount of mixing of the different migrate types within
pageblocks. It was not about reserves, increasing reserves was just the
most straight forward way of handling the problem.

This dicussion is closer to swap-over-network than to anything
THP did. Swap-over-network takes care to only allocate memory for
reserves if it the allocation was required for swapping and reject
all other allocation requests to the extent they can get throttled in
throttle_direct_reclaim. Once allocated from reserves for swapping,
care is taken that the allocations are not leaked to other users (e.g.
is_obj_pfmemalloc checks in slab).

It does not look like PF_OOM_HANDLER takes the same sort of care. Even
if it did, it's not quite the same. swap-over-network allocates from the
zone reserves *only* the memory required to writeback the pages. It can
be slow but it'll make forward progress. A userspace process with special
privileges could allocate any amount of memory for any reason so it would
need a pre-configured and limited reserve on top of the zone reserves or
run the risk of livelock.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
