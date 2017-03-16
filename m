Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8963E6B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 01:30:15 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y17so73074447pgh.2
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:30:15 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id t11si2966437pfg.45.2017.03.15.22.30.13
        for <linux-mm@kvack.org>;
        Wed, 15 Mar 2017 22:30:14 -0700 (PDT)
Date: Thu, 16 Mar 2017 14:31:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: ZONE_NORMAL vs. ZONE_MOVABLE
Message-ID: <20170316053122.GA14701@js1304-P5Q-DELUXE>
References: <20170315091347.GA32626@dhcp22.suse.cz>
 <87shmedddm.fsf@vitty.brq.redhat.com>
 <20170315122914.GG32620@dhcp22.suse.cz>
 <87k27qd7m2.fsf@vitty.brq.redhat.com>
 <20170315131139.GK32620@dhcp22.suse.cz>
 <20170315163729.GR27056@redhat.com>
MIME-Version: 1.0
In-Reply-To: <20170315163729.GR27056@redhat.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, qiuxishi@huawei.com, toshi.kani@hpe.com, xieyisheng1@huawei.com, slaoub@gmail.com, Zhang Zhen <zhenzhang.zhang@huawei.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Andi Kleen <ak@linux.intel.com>

On Wed, Mar 15, 2017 at 05:37:29PM +0100, Andrea Arcangeli wrote:
> On Wed, Mar 15, 2017 at 02:11:40PM +0100, Michal Hocko wrote:
> > OK, I see now. I am afraid there is quite a lot of code which expects
> > that zones do not overlap. We can have holes in zones but not different
> > zones interleaving. Probably something which could be addressed but far
> > from trivial IMHO.
> > 
> > All that being said, I do not want to discourage you from experiments in
> > those areas. Just be prepared all those are far from trivial and
> > something for a long project ;)
> 
> This constraint was known for quite some time, so when I talked about
> this very constraint with Mel at least year LSF/MM he suggested sticky
> pageblocks would be superior to the current movable zone.
> 
> So instead of having a Movable zone, we could use the pageblocks but
> make it sticky-movable so they're only going to accept __GFP_MOVABLE
> allocations into them. It would be still a quite large change indeed
> but it looks simpler and with fewer drawbacks than trying to make the
> zone overlap.

Hello,

I don't follow up previous discussion so please let me know if I miss
something. I'd just like to mention about sticky pageblocks.

Before that, I'd like to say that a lot of code already deals with zone
overlap. Zone overlap exists for a long time although I don't know exact
history. IIRC, Mel fixed such a case before and compaction code has a
check for it. And, I added the overlap check to some pfn iterators which
doesn't have such a check for preparation of introducing a new zone,
ZONE_CMA, which has zone range overlap property. See following commits.

'ba6b097', '9d43f5a', 'a91c43c'.

Come to my main topic, I disagree that sticky pageblock would be
superior to the current separate zone approach. There is some reasons
about the objection to sticky movable pageblock in following link.

Sticky movable pageblock is conceptually same with MIGRATE_CMA and it
will cause many subtle issues like as MIGRATE_CMA did for CMA users.
MIGRATE_CMA introduces many hooks in various code path, and, to fix the
remaining issues, it needs more hooks. I don't think it is
maintainable approach. If you see following link which implements ZONE
approach, you can see that many hooks are removed in the end.

lkml.kernel.org/r/1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com

I don't know exact requirement on memory hotplug so it would be
possible that ZONE approach is not suitable for it. But, anyway, sticky
pageblock seems not to be a good solution to me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
