Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C17A6B0038
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 07:10:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id j6so169951749qkc.3
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 04:10:16 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id f133si20189708wmf.85.2016.08.16.04.10.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Aug 2016 04:10:15 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so15845721wme.0
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 04:10:15 -0700 (PDT)
Date: Tue, 16 Aug 2016 13:10:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: fix set pageblock migratetype in deferred struct
 page init
Message-ID: <20160816111012.GE17417@dhcp22.suse.cz>
References: <57A325CA.9050707@huawei.com>
 <57A3260F.4050709@huawei.com>
 <20160816084132.GA17417@dhcp22.suse.cz>
 <57B2D556.5030201@huawei.com>
 <20160816092345.GB17417@dhcp22.suse.cz>
 <e9b1213e-6d77-372f-d335-3b98a40378e8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e9b1213e-6d77-372f-d335-3b98a40378e8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 16-08-16 12:12:07, Vlastimil Babka wrote:
> On 08/16/2016 11:23 AM, Michal Hocko wrote:
> > On Tue 16-08-16 16:56:54, Xishi Qiu wrote:
> > > On 2016/8/16 16:41, Michal Hocko wrote:
> > > 
> > > > On Thu 04-08-16 19:25:03, Xishi Qiu wrote:
> > > > > MAX_ORDER_NR_PAGES is usually 4M, and a pageblock is usually 2M, so we only
> > > > > set one pageblock's migratetype in deferred_free_range() if pfn is aligned
> > > > > to MAX_ORDER_NR_PAGES.
> > > > 
> > > > Do I read the changelog correctly and the bug causes leaking unmovable
> > > > allocations into movable zones?
> > > 
> > > Hi Michal,
> > > 
> > > This bug will cause uninitialized migratetype, you can see from
> > > "cat /proc/pagetypeinfo", almost half blocks are Unmovable.
> > 
> > Please add that information to the changelog. Leaking unmovable
> > allocations to the movable zones defeats the whole purpose of the
> > movable zone so I guess we really want to mark this for stable.
> 
> Note that it's not as severe. Pageblock migratetype is just heuristic
> against fragmentation. It should not allow unmovable allocations from
> movable zones (although I can't find what really does govern it).

You are right! gfp_zone would disabllow movable zones from the zone
list. So we indeed cannot leak the unmovable allocation to the movable
zone and then this doesn't really sound all that important to bother
with stable backport. It would be really great to have this all in the
changelog. This code is far from straightforward so having some
assistance from the changelog is more than welcome.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
