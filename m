Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE536B0389
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 09:11:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u9so4836621wme.6
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 06:11:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l185si461385wml.12.2017.03.15.06.11.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 15 Mar 2017 06:11:44 -0700 (PDT)
Date: Wed, 15 Mar 2017 14:11:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: ZONE_NORMAL vs. ZONE_MOVABLE
Message-ID: <20170315131139.GK32620@dhcp22.suse.cz>
References: <20170315091347.GA32626@dhcp22.suse.cz>
 <87shmedddm.fsf@vitty.brq.redhat.com>
 <20170315122914.GG32620@dhcp22.suse.cz>
 <87k27qd7m2.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k27qd7m2.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, iamjoonsoo.kim@lge.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Andi Kleen <ak@linux.intel.com>

On Wed 15-03-17 13:53:09, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Wed 15-03-17 11:48:37, Vitaly Kuznetsov wrote:
[...]
> >> What actually stops us from having the following approach:
> >> 1) Everything is added to MOVABLE
> >> 2) When we're out of memory for kernel allocations in NORMAL we 'harvest'
> >> the first MOVABLE block and 'convert' it to NORMAL. It may happen that
> >> there is no free pages in this block but it was MOVABLE which means we
> >> can move all allocations somewhere else.
> >> 3) Freeing the whole 128mb memblock takes time but we don't need to wait
> >> till it finishes, we just need to satisfy the currently pending
> >> allocation and we can continue moving everything else in the background.
> >
> > Although it sounds like a good idea at first sight there are many tiny
> > details which will make it much more complicated. First of all, how
> > do we know that the lowmem (resp. all zones normal zones) are under
> > pressure to reduce the movable zone? Getting OOM for ~__GFP_MOVABLE
> > request? Isn't that too late already?
> 
> Yes, I was basically thinking about OOM handling. It can also be a sort
> of watermark-based decision.
> 
> >  Sync migration at that state might
> > be really non trivial (pages might be dirty, pinned etc...).
> 
> Non-trivial, yes, but we already have the code to move all allocations
> away from MOVABLE block when we try to offline it, we can probably
> leverage it.

Sure, I am not saying this is impossible. I am just saying there are
many subtle details to be solved.

> 
> >  What about
> > user expectation to hotremove that memory later, should we just break
> > it?  How do we inflate movable zone back?
> 
> I think that it's OK to leave this block non-offlineable for future. As
> Andrea already pointed out it is not practical to try to guarantee we
> can unplug everything we plugged in, we're talking about 'best effort'
> service here anyway.

Well, my understanding of movable zone is closer to a requirement than a
best effort thing. You have to sacrifice a lot - higher memory pressure
to other zones with resulting perfomance conseqences, potential
latencies to access remote memory when the data (locks etc.) are on a
remote non-movable node. It would be really bad to find out that all
that was in vain just because the lowmem pressure has stolen your
movable memory.
 
> >> An alternative approach would be to have lists of memblocks which
> >> constitute ZONE_NORMAL and ZONE_MOVABLE instead of a simple 'NORMAL
> >> before MOVABLE' rule we have now but I'm not sure this is a viable
> >> approach with the current code base.
> >
> > I am not sure I understand.
> 
> Now we have 
> 
> [Normal][Normal][Normal][Movable][Movable][Movable]
> 
> we could have
> [Normal][Normal][Movable][Normal][Movable][Normal]
> 
> so when new block comes in we make a decision to which zone we want to
> online it (based on memory usage in these zones) and zone becomes a list
> of memblocks which constitute it, not a simple [from..to] range.

OK, I see now. I am afraid there is quite a lot of code which expects
that zones do not overlap. We can have holes in zones but not different
zones interleaving. Probably something which could be addressed but far
from trivial IMHO.

All that being said, I do not want to discourage you from experiments in
those areas. Just be prepared all those are far from trivial and
something for a long project ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
