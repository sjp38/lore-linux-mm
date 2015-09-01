Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 222BD6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 05:25:43 -0400 (EDT)
Received: by lbvd4 with SMTP id d4so39004266lbv.3
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 02:25:42 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id z4si15888860lbk.72.2015.09.01.02.25.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 02:25:41 -0700 (PDT)
Date: Tue, 1 Sep 2015 12:25:20 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150901092520.GA21226@esperanza>
References: <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831134335.GB2271@mtj.duckdns.org>
 <20150831143007.GA13814@esperanza>
 <20150831143939.GC2271@mtj.duckdns.org>
 <20150831151814.GC13814@esperanza>
 <20150831154756.GE2271@mtj.duckdns.org>
 <20150831165131.GD15420@esperanza>
 <20150831170309.GF2271@mtj.duckdns.org>
 <20150831192612.GE15420@esperanza>
 <alpine.DEB.2.11.1508311521040.30405@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1508311521040.30405@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 31, 2015 at 03:22:22PM -0500, Christoph Lameter wrote:
> On Mon, 31 Aug 2015, Vladimir Davydov wrote:
> 
> > I totally agree that we should strive to make a kmem user feel roughly
> > the same in memcg as if it were running on a host with equal amount of
> > RAM. There are two ways to achieve that:
> >
> >  1. Make the API functions, i.e. kmalloc and friends, behave inside
> >     memcg roughly the same way as they do in the root cgroup.
> >  2. Make the internal memcg functions, i.e. try_charge and friends,
> >     behave roughly the same way as alloc_pages.
> >
> > I find way 1 more flexible, because we don't have to blindly follow
> > heuristics used on global memory reclaim and therefore have more
> > opportunities to achieve the same goal.
> 
> The heuristics need to integrate well if its in a cgroup or not. In
> general make use of cgroups as transparent as possible to the rest of the
> code.

Half of kmem accounting implementation resides in SLAB/SLUB. We can't
just make use of cgroups there transparent. For the rest of the code
using kmalloc, cgroups are transparent.

Indeed, we can make memcg_charge_slab behave exactly like alloc_pages,
we can even put it to alloc_pages (where it used to be), but why if the
only user of memcg_charge_slab is SLAB/SLUB core?

I think we'd have more space to manoeuvre if we just taught SLAB/SLUB to
use memcg_charge_slab wisely (as it used to until recently), because
memcg charge/reclaim is quite different from global alloc/reclaim:

 - it isn't aware of NUMA nodes, so trying to charge w/o __GFP_WAIT
   while inspecting nodes, like in case of SLAB, is meaningless

 - it isn't aware of high order page allocations, so trying to charge
   w/o __GFP_WAIT while trying optimistically to get a high order page,
   like in case of SLUB, is meaningless too

 - it can always let a high prio allocation go unaccounted, so IMO there
   is no point in introducing emergency reserves (__GFP_MEMALLOC
   handling)

 - it can always charge a GFP_NOWAIT allocation even if it exceeds the
   limit, issuing direct reclaim when a GFP_KERNEL allocation comes or
   from a task work, because there is no risk of depleting memory
   reserves; so it isn't obvious to me whether we really need an aync
   thread handling memcg reclaim like kswapd

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
