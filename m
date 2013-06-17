Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 21C096B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 10:27:19 -0400 (EDT)
Date: Mon, 17 Jun 2013 16:27:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] slub: Avoid direct compaction if possible
Message-ID: <20130617142715.GB8853@dhcp22.suse.cz>
References: <51BB1802.8050108@yandex-team.ru>
 <0000013f4319cb46-a5a3de58-1207-4037-ae39-574b58135ea2-000000@email.amazonses.com>
 <alpine.DEB.2.02.1306141322490.17237@chino.kir.corp.google.com>
 <51BF024F.2080609@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51BF024F.2080609@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@gentwo.org>, penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, mgorman@suse.de, glommer@parallels.com, hannes@cmpxchg.org, minchan@kernel.org, jiang.liu@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 17-06-13 16:34:23, Roman Gushchin wrote:
> On 15.06.2013 00:26, David Rientjes wrote:
> >On Fri, 14 Jun 2013, Christoph Lameter wrote:
> >
> >>>It's possible to avoid such problems (or at least to make them less probable)
> >>>by avoiding direct compaction. If it's not possible to allocate a contiguous
> >>>page without compaction, slub will fall back to order 0 page(s). In this case
> >>>kswapd will be woken to perform asynchronous compaction. So, slub can return
> >>>to default order allocations as soon as memory will be de-fragmented.
> >>
> >>Sounds like a good idea. Do you have some numbers to show the effect of
> >>this patch?
> >>
> >
> >I'm surprised you like this patch, it basically makes slub allocations to
> >be atomic and doesn't try memory compaction nor reclaim.  Asynchronous
> >compaction certainly isn't aggressive enough to mimick the effects of the
> >old lumpy reclaim that would have resulted in less fragmented memory.  If
> >slub is the only thing that is doing high-order allocations, it will start
> >falling back to the smallest page order much much more often.
> >
> >I agree that this doesn't seem like a slub issue at all but rather a page
> >allocator issue; if we have many simultaneous thp faults at the same time
> >and /sys/kernel/mm/transparent_hugepage/defrag is "always" then you'll get
> >the same problem if deferred compaction isn't helping.
> >
> >So I don't think we should be patching slub in any special way here.
> >
> >Roman, are you using the latest kernel?  If so, what does
> >grep compact_ /proc/vmstat show after one or more of these events?
> >
> 
> We're using 3.4. And the problem reveals when we moved from 3.2 to 3.4.
> It can be also reproduced on 3.5.

FWIW, there were some compaction locking related patches merged
around 3.7. See 2a1402aa044b55c2d30ab0ed9405693ef06fb07c and follow ups.

> I'll send the exact numbers as soon I'll reproduce it again.
> It can take up to 1 week.
> 
> Thanks!
> 
> Regards,
> Roman
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
