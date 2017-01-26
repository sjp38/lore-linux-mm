Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D65B16B0260
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 09:18:43 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so58594753pgj.6
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:18:43 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a61si1535300plc.67.2017.01.26.06.18.42
        for <linux-mm@kvack.org>;
        Thu, 26 Jan 2017 06:18:42 -0800 (PST)
Date: Thu, 26 Jan 2017 23:18:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: vmscan: do not pass reclaimed slab to vmpressure
Message-ID: <20170126141836.GA3584@bbox>
References: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org>
 <20170125232713.GB20811@bbox>
 <CAOaiJ-mk=SmNR4oK+udhJNxHzmobf28wSu+nf449c=1cHMBDAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-mk=SmNR4oK+udhJNxHzmobf28wSu+nf449c=1cHMBDAg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, shiraz.hashim@gmail.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

Hi Vinayak,

On Thu, Jan 26, 2017 at 10:53:38AM +0530, vinayak menon wrote:
> Hi Minchan
> 
> On Thu, Jan 26, 2017 at 4:57 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Hello Vinayak,
> >
> > On Wed, Jan 25, 2017 at 05:08:38PM +0530, Vinayak Menon wrote:
> >> It is noticed that during a global reclaim the memory
> >> reclaimed via shrinking the slabs can sometimes result
> >> in reclaimed pages being greater than the scanned pages
> >> in shrink_node. When this is passed to vmpressure, the
> >
> > I don't know you are saying zsmalloc. Anyway, it's one of those which
> > free larger pages than requested. I should fix that but was not sent
> > yet, unfortunately.
> 
> As I understand, the problem is not related to a particular shrinker.
> In shrink_node, when subtree's reclaim efficiency is passed to vmpressure,
> the 4th parameter (sc->nr_scanned - nr_scanned) includes only the LRU
> scanned pages, but the 5th parameter (sc->nr_reclaimed - nr_reclaimed) includes
> the reclaimed slab pages also since in the previous step
> "reclaimed_slab" is added
> to it. i.e the slabs scanned are not included in scanned passed to vmpressure.
> This results in reclaimed going higher than scanned in vmpressure resulting in
> false events.

Thanks for the explain. However, such case can happen with THP page
as well as slab. In case of THP page, nr_scanned is 1 but nr_reclaimed
could be 512 so I think vmpressure should have a logic to prevent undeflow
regardless of slab shrinking.

> 
> >
> >> unsigned arithmetic results in the pressure value to be
> >> huge, thus resulting in a critical event being sent to
> >> root cgroup. Fix this by not passing the reclaimed slab
> >> count to vmpressure, with the assumption that vmpressure
> >> should show the actual pressure on LRU which is now
> >> diluted by adding reclaimed slab without a corresponding
> >> scanned value.
> >
> > I can't guess justfication of your assumption from the description.
> > Why do we consider only LRU pages for vmpressure? Could you elaborate
> > a bit?
> >
> When we encountered the false events from vmpressure, thought the problem
> could be that slab scanned is not included in sc->nr_scanned, like it is done
> for reclaimed. But later thought vmpressure works only on the scanned and
> reclaimed from LRU. I can explain what I understand, let me know if this is
> incorrect.
> vmpressure is an index which tells the pressure on LRU, and thus an
> indicator of thrashing. In shrink_node when we come out of the inner do-while
> loop after shrinking the lruvec, the scanned and reclaimed corresponds to the
> pressure felt on the LRUs which in turn indicates the pressure on VM. The
> moment we add the slab reclaimed pages to the reclaimed, we dilute the
> actual pressure felt on LRUs. When slab scanned/reclaimed is not included
> in the vmpressure, the values will indicate the actual pressure and if there
> were a lot of slab reclaimed pages it will result in lesser pressure
> on LRUs in the next run which will again be indicated by vmpressure. i.e. the

I think there is no intention to exclude slab by design of vmpressure.
Beause slab is memory consumption so freeing of slab pages really helps
the memory pressure. Also, there might be slab-intensive workload rather
than LRU. It would be great if vmpressure works well with that case.
But the problem with involving slab for vmpressure is it's not fair with
LRU pages. LRU pages are 1:1 cost model for scan:free but slab shriking
depends the each slab's object population. It means it's impossible to
get stable cost model with current slab shrinkg model, unfortunately.
So I don't obejct this patch although I want to see slab shrink model's
change which is heavy-handed work.

Thanks.


> pressure on LRUs indicate actual pressure on VM even if slab reclaimed is
> not included. Moreover, what I understand from code is, the reclaimed_slab
> includes only the inodesteals and the pages freed by slab allocator, and does
> not include the pages reclaimed by other shrinkers like
> lowmemorykiller, zsmalloc
> etc. That means even now we are including only a subset of reclaimed pages
> to vmpressure. Also, considering the case of a userspace lowmemorykiller
> which works on vmpressure on root cgroup, if the slab reclaimed in included in
> vmpressure, the lowmemorykiller will wait till most of the slab is
> shrinked before
> kicking in to kill a task. No ?
> 
> Thanks,
> Vinayak
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
